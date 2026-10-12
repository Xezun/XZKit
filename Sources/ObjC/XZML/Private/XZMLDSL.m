//
//  XZMLDSL.m
//  XZKit
//
//  Created by Xezun on 2021/10/18.
//

#import "XZMLDSL.h"
#import "XZMLDefines.h"
#import "UIColor+XZKit.h"

/// XZML 元素的开始和结束标记，固定为 `<` 和 `>` 字符，不支持自定义。
#define XZMLElementStart '<'
#define XZMLElementEnd   '>'

/// 安全文本替代字符。默认替代字符为 `*` 星号。
/// @note 在元素属性中，有此属性有值表明这是一个安全文本。
static NSAttributedStringKey const XZMLSecurityMarkAttributeName  = @"XZMLSecurityMarkAttributeName";
/// 安全文本替代字符重复次数。
/// @note 0 表示重复次数默认与安全文本字符数相同。
static NSAttributedStringKey const XZMLSecurityRepeatAttributeName = @"XZMLSecurityRepeatAttributeName";
/// 安全文本替代字符最大重复次数，防止外部指定极端重复值导致内存问题。
static NSInteger const XZMLSecurityRepeatLimit = 64;
/// 字体名缩写。
static NSMutableDictionary<NSString *, NSString *> *_fontAbbreviations = nil;

/// XZML 元素属性的行为。
///
/// 在 XZML 中，可通过属性控制文本。在解析的过程中，如果已解析的属性，已经决定后续解析方式，以提高解析效率。
typedef NS_ENUM(NSUInteger, XZMLReadingMode) {
    /// 无操作，正常模式，解析属性和文本。
    XZMLReadingModeNormal,
    /// 只解析当前元素中的文本。
    XZMLReadingModeTextOnly,
    /// 跳过元素，不解析当前元素后续的属性和文本
    XZMLReadingModeSkipElement,
};

/// XZML 解析过程的中间量。
typedef struct XZMLDSLContext {
    /// XZML 字符串 UTF-8 形式。
    const char * const UTF8String;
    /// XZML 长度，字节数。
    const NSUInteger   length;
    /// 当前指向的字节。
    NSUInteger         index;
    
    NSMutableString           * __unsafe_unretained _string;
    NSMutableAttributedString * __unsafe_unretained _attributedString;
    
    /// 解析过程中元素原始样式栈
    NSMutableArray<NSMutableDictionary *> * const __unsafe_unretained _elementAttributes;
    /// 解析过程中元素计算样式栈
    NSMutableArray<NSMutableDictionary *> * const __unsafe_unretained _computeAttributes;
    
    /// 当前正在解析中的文本的默认样式。
    NSDictionary<NSAttributedStringKey, id>        * __unsafe_unretained _defaultAttribute;
    /// 当前正在解析中的文本的内联样式。
    NSMutableDictionary<NSAttributedStringKey, id> * __unsafe_unretained _currentAttribute;
} XZMLDSLContext;

static inline NSUInteger UTF8SearchASCII(const char * const UTF8String, NSUInteger index) {
    // 在 UTF-8 编码中 ASCII 字符是首位为 0 的字节
    // 只有 index 在安全范围内时，才会调用到此函数，而此循环扫描到字符串结尾 \0 时，也会结束循环，
    // 所以不需要判断 index 是否在合法范围内
    while (UTF8String[index] & 0b10000000) {
        index += 1;
    }
    return index;
}

// MARK: - 语法解析

static void didBeginElement(XZMLDSLContext * const context);
static void didFindText(XZMLDSLContext * const context, NSString *value, NSUInteger fragment);
static XZMLReadingMode didFindAttribute(XZMLDSLContext * const context, XZMLAttribute attribute, NSString *value);
static void didEndElement(XZMLDSLContext * const context);

/// 从 context 的当前位置开始，查找下一个 ASCII 字符的位置。
/// 如果当前位置就是 ASCII 字符，那么直接返回当前的 index 值。
static inline NSUInteger XZMLDSLSearchASCII(XZMLDSLContext *context) {
    return UTF8SearchASCII(context->UTF8String, context->index);;
}

/// 检测字符是否为 XZML 样式属性标记符。
static inline BOOL XZMLDSLTestAttribute(char character) {
    switch (character) {
        case XZMLAttributeColor:
        case XZMLAttributeFont:
        case XZMLAttributeDecoration:
        case XZMLAttributeSecurity:
        case XZMLAttributeLink:
        case XZMLAttributeParagraph:
            return YES;
        default:
            return NO;
    }
}

/// 跳过当前元素，包括子元素。
/// - Parameters:
///   - context: 上下文
///   - kCurrentElementEnd: 当前元素的结束标记符
static void XZMLDSLElementAbort(XZMLDSLContext * const context, char const kCurrentElementEnd) {
    BOOL isEscaping = NO;
    NSInteger hierarchies = 1;
    do {
        NSUInteger const index = XZMLDSLSearchASCII(context);

        // 跳过了多字节字符：若处于转义状态，被转义的正是该多字节字符，状态在此消费，
        // 否则转义会顺延到其后的 ASCII 字符（往往是 '>'）导致元素无法闭合。
        if (context->index < index) {
            isEscaping = NO;
        }

        context->index = index + 1; // 指向下一个字节

        char const character = context->UTF8String[index];

        // character 是逃逸字符
        if (isEscaping) {
            isEscaping = NO;
            continue;
        }

        // character 是逃逸标记
        if (character == '\\') {
            isEscaping = YES;
            continue;
        }

        // character 是元素结束字符
        if (character == kCurrentElementEnd) {
            hierarchies -= 1;
            if (hierarchies == 0) {
                break;
            }
            continue;
        }
        
        // character 是元素开始字符
        if (character == XZMLElementStart) {
            // 层数增加。
            hierarchies += 1;
            continue;
        }
    } while (context->index < context->length);
}

/// 仅识别当前元素中的文本，忽略属性。
/// - Parameters:
///   - context: 上下文
///   - kCurrentElementEnd: 当前元素的结束标记符
static NSData *XZMLDSLElementText(XZMLDSLContext * const context, char const kCurrentElementEnd) {
    NSMutableData * const value = [NSMutableData dataWithCapacity:context->length - context->index];
    
    /// 当前循环轮次是否处于逃逸模式
    BOOL isEscaping = NO;
    /// 当前元素是否应该继续识别属性
    BOOL shouldRecognizeAttributes = YES;
    /// 子元素的层级，遇到结束字符层级递减。
    NSInteger hierarchies = 1;
    /// 记录元素属性的起点，以便在识别到属性时从结果中删除属性字符
    NSUInteger startIndex = 0;
    
    do {
        NSUInteger const index = XZMLDSLSearchASCII(context);
        
        // 当前字符被跳过了，说明是非 ASCII 字符。
        if (context->index < index) {
            // 被转义的字符是多字节字符本身，状态在此消费，不能顺延到其后的 ASCII 字符
            isEscaping = NO;

            const char * const bytes = context->UTF8String + context->index;
            NSUInteger   const count = index - context->index;
            [value appendBytes:bytes length:count];
            
            // 已到达字符串末尾，推进 index，避免父级重复解析剩余字节
            if (index >= context->length) {
                context->index = context->length;
                break;
            }
        }
        
        // 指向下一个字符
        context->index = index + 1;

        char const character = context->UTF8String[index];

        // character 是逃逸字符
        if (isEscaping) {
            isEscaping = NO;
            [value appendBytes:&character length:sizeof(char)];
            continue;
        }

        // character 是逃逸标记
        if (character == '\\') {
            isEscaping = YES;
            continue;
        }

        // character 是元素结束字符
        if (character == kCurrentElementEnd) {
            hierarchies -= 1;
            if (hierarchies == 0) {
                break;
            }
            // 遇到子元素后，就不识别属性。
            shouldRecognizeAttributes = NO;
            continue;
        }
        
        // 子元素开始：character 是元素开始字符
        if (character == XZMLElementStart) {
            // 层数增加。
            hierarchies += 1;
            // 子元素继续识别属性，父元素在子元素结束时，标记不识别属性。
            shouldRecognizeAttributes = YES;
            // 记录子元素开始位置
            startIndex = value.length;
            continue;
        }

        // 属性：character 是元素属性字符
        if (shouldRecognizeAttributes && XZMLDSLTestAttribute(character)) {
            // 已识别的字符为属性，直接删除
            [value replaceBytesInRange:NSMakeRange(startIndex, value.length - startIndex) withBytes:NULL length:0];
            // 开始新的属性
            startIndex = value.length; 
            continue;
        }
        
        // character 是普通字符
        [value appendBytes:&character length:sizeof(char)];
    } while (context->index < context->length);

    return value;
}

/// 元素识别。
/// 传入的 context->index 指向当前元素开始标记之后第一个字符，
/// 本函数执行完毕 context->index 执行元素结束标记之后的第一个字符，或者指向字符串结束标志`\0`。
/// - Parameters:
///   - context: 上下文
///   - kCurrentElementEnd: 当前元素的结束标记符
///   - hierarchies: 当前元素的层级
///   - shouldRecognizeAttributes: 当前元素是否需要识别样式
static void XZMLDSLElement(XZMLDSLContext * const context, char const kCurrentElementEnd, NSUInteger const hierarchies, BOOL shouldRecognizeAttributes) {
    // 发送元素识别开始事件
    didBeginElement(context);
    
    NSMutableData * const value = [NSMutableData dataWithCapacity:context->length - context->index];
    
    // 文本段。如果当前元素包含多个子元素，那么此值表示被子元素分隔在文本段的次序。
    NSUInteger fragment = 0;
    // 当前循环轮次是否处于逃逸模式
    BOOL isEscaping = NO;
    
    do {
        NSUInteger const index = XZMLDSLSearchASCII(context);
        
        // 当前字符被跳过了，说明是非 ASCII 字符。
        if (context->index < index) {
            // 被转义的字符是多字节字符本身，状态在此消费，不能顺延到其后的 ASCII 字符
            isEscaping = NO;

            const char * const bytes = context->UTF8String + context->index;
            NSUInteger   const count = index - context->index;
            [value appendBytes:bytes length:count];
            
            // 已到达字符串末尾，推进 index，避免父级重复解析剩余字节
            if (index >= context->length) {
                context->index = context->length;
                break;
            }
        }
        
        // 指向下一个字符
        context->index = index + 1;
        
        // 当前字符
        char const character = context->UTF8String[index];

        // character 是逃逸字符
        if (isEscaping) {
            isEscaping = NO;
            [value appendBytes:&character length:sizeof(char)];
            continue;
        }

        // character 是逃逸标记
        if (character == '\\') {
            isEscaping = YES;
            continue;
        }

        // character 是元素结束字符
        if (character == kCurrentElementEnd) {
            break;
        }

        // character 是元素开始字符，子元素开始
        if (character == XZMLElementStart) {
            // 标记当前元素不再识别属性标记
            shouldRecognizeAttributes = NO;
            
            // 发送文本识别事件：已识别的字符作为普通文本
            NSUInteger const length = value.length;
            if (length > 0) {
                NSString * const text = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
                didFindText(context, text, fragment++);
                [value replaceBytesInRange:NSMakeRange(0, value.length) withBytes:NULL length:0];
            }
            
            // 子元素层级超出限制，仅保留文本
            if (hierarchies > 15) {
                [value appendData:XZMLDSLElementText(context, XZMLElementEnd)];
                continue;
            }
            
            // 识别子元素
            XZMLDSLElement(context, XZMLElementEnd, hierarchies + 1, YES);
            continue;
        }

        // character 是元素属性字符
        if (shouldRecognizeAttributes && XZMLDSLTestAttribute(character)) {
            NSString * const text = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
            [value replaceBytesInRange:NSMakeRange(0, value.length) withBytes:NULL length:0];
            
            // 发送属性识别事件
            XZMLReadingMode const mode = didFindAttribute(context, character, text);
            
            // 仅识别文本
            if (mode == XZMLReadingModeTextOnly) {
                [value appendData:XZMLDSLElementText(context, kCurrentElementEnd)];
                break;
            }
            
            // 终止当前元素
            if (mode == XZMLReadingModeSkipElement) {
                XZMLDSLElementAbort(context, kCurrentElementEnd);
                break;
            }
            
            // 继续识别
            continue;
        }

        // character 是元素文本字符
        [value appendBytes:&character length:sizeof(char)];
    } while (context->index < context->length);

    // 发送文本识别事件：已识别的字符作为文本属性
    NSString * const text = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
    didFindText(context, text, fragment);
    
    // 发送元素识别结束事件
    didEndElement(context);
}

static void XZMLDSL(NSString *XZMLString, NSMutableString *string, NSMutableAttributedString *attributedString, NSDictionary<NSAttributedStringKey, id> * _Nullable defaultAttributes) {
    if (![XZMLString isKindOfClass:NSString.class]) {
        return;
    }
    if (XZMLString.length == 0) {
        return;
    }
    
    // XZML 的解析基于 UTF-8 字节流，无法表示为 UTF-8 的字符串（如含未配对的代理项）不解析，
    // 不产生任何内容。此类字符串属于非法输入，调用方应在解析前保证编码合法。
    const char * const UTF8String = [XZMLString cStringUsingEncoding:NSUTF8StringEncoding];
    if (UTF8String == NULL) {
        return;
    }
    
    const NSUInteger UTF8Length = [XZMLString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if (UTF8Length == 0) {
        return;
    }
    
    NSMutableArray * const elementAttributes = [NSMutableArray arrayWithCapacity:32];
    NSMutableArray * const computeAttributes = [NSMutableArray arrayWithCapacity:32];
    [computeAttributes addObject:[NSMutableDictionary dictionary]];
    
    XZMLDSLContext context = {
        UTF8String,
        UTF8Length,
        0,
        string,
        attributedString,
        elementAttributes,
        computeAttributes,
        defaultAttributes,
        nil
    };
    
    // 将顶层当作普通元素解析：
    // 1. 顶层以字符串结束符 \0 作为结束符。
    // 2. 顶层不解析样式，样式标记仅对被 `<`、`>` 包围的元素生效。
    XZMLDSLElement(&context, '\0', 0, NO);
}

void XZMLDSLWithAttributedString(NSString *XZMLString, NSMutableAttributedString *attributedString, NSDictionary<NSAttributedStringKey, id> * _Nullable attributes) {
    XZMLDSL(XZMLString, nil, attributedString, attributes);
}

void XZMLDSLWithString(NSString *XZMLString, NSMutableString *string, NSDictionary<NSAttributedStringKey, id> * _Nullable attributes) {
    XZMLDSL(XZMLString, string, nil, attributes);
}

// MARK: - 内容解析

static XZMLReadingMode didFindFontAttribute(XZMLDSLContext * const context, NSString *value);
static XZMLReadingMode didFindColorAttribute(XZMLDSLContext * const context, NSString *value);
static XZMLReadingMode didFindDecorationAttribute(XZMLDSLContext * const context, NSString *value);
static XZMLReadingMode didFindSecurityAttribute(XZMLDSLContext * const context, NSString *value);
static XZMLReadingMode didFindLinkAttribute(XZMLDSLContext * const context, NSString *value);
static XZMLReadingMode didFindParagraphAttribute(XZMLDSLContext * const context, NSString *value);

static void didBeginElement(XZMLDSLContext * const context) {
    // 继承父元素样式，如果没有则新建
    NSMutableDictionary * const _currentAttribute = [context->_elementAttributes.lastObject mutableCopy] ?: [NSMutableDictionary dictionary];
    context->_currentAttribute = _currentAttribute;
    // 将当前样式入栈。
    [context->_elementAttributes addObject:context->_currentAttribute];
    // 合并后的样式
    [context->_computeAttributes addObject:[NSMutableDictionary dictionary]];
}

static void didFindText(XZMLDSLContext * const context, NSString *text, NSUInteger fragment) {
    // 找到元素文本，也可能顶层非元素文本
    NSMutableDictionary * const computeStyle = context->_computeAttributes.lastObject;
    // 样式为空，说明样式还没有合并
    if (computeStyle.count == 0) {
        // 先复制元素内联样式
        [computeStyle addEntriesFromDictionary:context->_currentAttribute];
        // 将默认样式合并，不覆盖内联样式
        [context->_defaultAttribute enumerateKeysAndObjectsUsingBlock:^(NSAttributedStringKey  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            // 过滤 XZML 属性，自定义的 XZML 属性，在富文本中不生效。
            if ([key hasPrefix:@"XZML"]) {
                return;
            }
            if (computeStyle[key] == nil) {
                computeStyle[key] = obj;
            }
        }];
    }
    
    NSString * const mark = computeStyle[XZMLSecurityMarkAttributeName];
    if (mark) {
        NSInteger repeat = [computeStyle[XZMLSecurityRepeatAttributeName] integerValue];
        if (repeat <= 0) {
            repeat = (NSInteger)text.length;
        }
        repeat = MIN(repeat, XZMLSecurityRepeatLimit);
        text = [mark stringByPaddingToLength:mark.length * repeat withString:mark startingAtIndex:0];
    }
    
    if (context->_string) {
        [context->_string appendString:text];
    } else {
        // 暂不处理 computeStyle 中包含的 XZMLSecurity(Mark|Repeat)AttributeName 字段。
        // - 不影响富文本构造。
        // - 这两个字段不属于机密数据。
        NSAttributedString * const attributedString = [[NSAttributedString alloc] initWithString:text attributes:computeStyle];
        [context->_attributedString appendAttributedString:attributedString];
    }
}

static XZMLReadingMode didFindAttribute(XZMLDSLContext * const context, XZMLAttribute attribute, NSString *value) {
    if (context->_string) {
        // 纯文本模式，仅解析安全样式
        if (attribute == XZMLAttributeSecurity) {
            return didFindSecurityAttribute(context, value);
        }
        return XZMLReadingModeNormal;
    }
    
    // 普通模式，解析所有样式
    switch (attribute) {
        case XZMLAttributeColor: {
            return didFindColorAttribute(context, value);
        }
        case XZMLAttributeFont: {
            return didFindFontAttribute(context, value);
        }
        case XZMLAttributeDecoration: {
            return didFindDecorationAttribute(context, value);
        }
        case XZMLAttributeSecurity: {
            return didFindSecurityAttribute(context, value);
        }
        case XZMLAttributeLink: {
            return didFindLinkAttribute(context, value);
        }
        case XZMLAttributeParagraph: {
            return didFindParagraphAttribute(context, value);
        }
        default: {
            // 暂不支持
            return XZMLReadingModeNormal;
        }
    }
}

static void didEndElement(XZMLDSLContext * const context) {
    [context->_elementAttributes removeLastObject];
    [context->_computeAttributes removeLastObject];
    context->_currentAttribute = context->_elementAttributes.lastObject;
}

#pragma mark - 样式解析

FOUNDATION_STATIC_INLINE UIColor *XZMLColorAttributeMakeValue(XZMLDSLContext * const context, XZMLAttributeName xzmlKey, NSAttributedStringKey nsKey, NSString *value) {
    // 使用指定值
    UIColor *color = rgba(value, nil);
    if (color) {
        return color;
    }
    // 使用继承值（父元素已经有值）
    if (context->_currentAttribute[nsKey]) {
        return nil;
    }
    // 使用预设值
    color = context->_defaultAttribute[xzmlKey];
    if (color) {
        return color;
    }
    // 使用默认值
    return context->_defaultAttribute[nsKey];
}

XZMLReadingMode didFindColorAttribute(XZMLDSLContext * const context, NSString *value) {
    if ([value containsString:@"@"]) {
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        
        UIColor * const foregroundColor = XZMLColorAttributeMakeValue(context, XZMLForegroundColorAttributeName, NSForegroundColorAttributeName, values[0]);
        if (foregroundColor) {
            context->_currentAttribute[NSForegroundColorAttributeName] = foregroundColor;
        }
        
        UIColor * const backgroundColor = XZMLColorAttributeMakeValue(context, XZMLBackgroundColorAttributeName, NSBackgroundColorAttributeName, values[1]);
        if (backgroundColor) {
            context->_currentAttribute[NSBackgroundColorAttributeName] = backgroundColor;
        }
    } else {
        UIColor *foregroundColor = XZMLColorAttributeMakeValue(context, XZMLForegroundColorAttributeName, NSForegroundColorAttributeName, value);
        if (foregroundColor != nil) {
            context->_currentAttribute[NSForegroundColorAttributeName] = foregroundColor;
        }
    }
    return XZMLReadingModeNormal;
}

FOUNDATION_STATIC_INLINE UIFont * _Nullable XZMLFontAttributeMakeValue(XZMLDSLContext * const context, NSString * _Nullable nameString, NSString * _Nullable sizeString) {
    // 未命中缩写表的名称直接作为字体名使用，因此缩写与真实字体名可以直接混用
    NSString *name = nameString.length > 0 ? (_fontAbbreviations[nameString] ?: nameString) : nil;
    CGFloat   size = sizeString.doubleValue;
    UIFont   *font = nil;
    
    // 没有指定字号
    if (isnan(size) || size <= 0) {
        // 使用继承值
        font = context->_currentAttribute[NSFontAttributeName];
        if (font == nil) {
            // 使用默认值
            font = context->_defaultAttribute[NSFontAttributeName];
            if (font == nil) {
                // 使用预设值
                font = context->_defaultAttribute[XZMLFontAttributeName];
                if (font == nil) {
                    // 解析字体失败，无法确定字号
                    return nil;
                }
            }
        }
        size = font.pointSize;
    }
    
    // 没有指定字名
    if (name.length == 0 || (font = [UIFont fontWithName:name size:size]) == nil) {
        // 使用继承值
        font = context->_currentAttribute[NSFontAttributeName];
        if (font) {
            if (font.pointSize == size) {
                return nil;
            }
            return [font fontWithSize:size];
        }
        // 使用预设值
        font = context->_defaultAttribute[XZMLFontAttributeName];
        if (font) {
            return [font fontWithSize:size];
        }
        // 使用默认值
        font = context->_defaultAttribute[NSFontAttributeName];
        if (font) {
            return [font fontWithSize:size];
        }
        // 使用系统值
        return [UIFont systemFontOfSize:size];
    }
    
    return font;
}

XZMLReadingMode didFindFontAttribute(XZMLDSLContext * const context, NSString *value) {
    if ([value containsString:@"@"]) {
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        
        UIFont * font = XZMLFontAttributeMakeValue(context, values[0], values[1]);
        if (font) {
            context->_currentAttribute[NSFontAttributeName] = font;
        }
        
        // 字体基准线调整
        if (values.count > 2) {
            CGFloat const baselineOffset = values[2].floatValue;
            if (baselineOffset != 0) {
                context->_currentAttribute[NSBaselineOffsetAttributeName] = @(baselineOffset);
            }
        }
    } else {
        // 仅指定了一个参数，作为字体名使用
        UIFont * font = XZMLFontAttributeMakeValue(context, value, nil);
        if (font) {
            context->_currentAttribute[NSFontAttributeName] = font;
        }
    }
    return XZMLReadingModeNormal;
}

FOUNDATION_STATIC_INLINE XZMLDecorationType XZMLDecorationAttributeMakeValue(XZMLDSLContext * const context, NSString *typeString) {
    // 指定了修饰类型
    if (typeString.length > 0) {
        if ([typeString isEqualToString:@"0"]) {
            return XZMLDecorationTypeStrikethrough;
        }
        if ([typeString isEqualToString:@"1"]) {
            return XZMLDecorationTypeUnderline;
        }
    }
    // 继承值
    if (context->_currentAttribute[NSStrikethroughStyleAttributeName]) {
        return XZMLDecorationTypeStrikethrough;
    }
    if (context->_currentAttribute[NSUnderlineStyleAttributeName]) {
        return XZMLDecorationTypeUnderline;
    }
    // 预设值
    if (context->_defaultAttribute[XZMLDecorationAttributeName]) {
        return [context->_defaultAttribute[XZMLDecorationAttributeName] unsignedIntegerValue];
    }
    // 默认值
    if (context->_defaultAttribute[NSStrikethroughStyleAttributeName]) {
        return XZMLDecorationTypeStrikethrough;
    }
    if (context->_defaultAttribute[NSUnderlineStyleAttributeName]) {
        return XZMLDecorationTypeUnderline;
    }
    // 系统值：有修饰标记时，默认为添加删除线
    return XZMLDecorationTypeStrikethrough;
}

/// 暂不支持通过 parser->_defaultStyle 提供默认值。
XZMLReadingMode didFindDecorationAttribute(XZMLDSLContext * const context, NSString *value) {
    XZMLDecorationType type = 0;                         // 样式 0 删除线 1 下划线
    NSUnderlineStyle  style = NSUnderlineStyleSingle;    // 线型 0 单线条 1 双线条 2 粗线条
    UIColor *         color = nil;                       // 颜色 _ 默认色 x 指定色
    
    if ([value containsString:@"@"]) {
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        
        type = XZMLDecorationAttributeMakeValue(context, values[0]);
        
        switch (values[1].integerValue) {
            case 1:
                style = NSUnderlineStyleDouble;
                break;
            case 2:
                style = NSUnderlineStyleThick;
                break;
            default:
                style = NSUnderlineStyleSingle;
                break;
        }
        
        if (values.count > 2) {
            color = rgba(values[2], nil);
        }
    } else {
        type = XZMLDecorationAttributeMakeValue(context, value);
    }
    
    if (type == 1) {
        context->_currentAttribute[NSUnderlineStyleAttributeName] = @(style);
        if (color != nil) {
            context->_currentAttribute[NSUnderlineColorAttributeName] = color;
        }
    } else {
        context->_currentAttribute[NSStrikethroughStyleAttributeName] = @(style);
        if (color != nil) {
            context->_currentAttribute[NSStrikethroughColorAttributeName] = color;
        }
        if (@available(iOS 10.3, *)) {
            // 解决 iOS 10.3 删除线不展示的问题
            if (context->_currentAttribute[NSBaselineOffsetAttributeName] == nil) {
                context->_currentAttribute[NSBaselineOffsetAttributeName] = @(0);
            }
        }
    }
    
    return XZMLReadingModeNormal;
}

XZMLReadingMode didFindSecurityAttribute(XZMLDSLContext * const context, NSString *value) {
    // 只有安全模式下，才需要解析安全字符样式
    if ([context->_defaultAttribute[XZMLSecurityModeAttributeName] boolValue]) {
        if ([value containsString:@"@"]) {
            NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
            
            NSString * const mark   = values[0];
            NSInteger  const repeat = values[1].integerValue;
            
            // 重复次数默认值：替换符为单字符，默认重复次数与文本长度相同；替换符为多字符，默认重复次数为 1 次
            if (repeat <= 0) {
                switch (mark.length) {
                    case 0:
                        context->_currentAttribute[XZMLSecurityMarkAttributeName] = @"*";
                        break;
                    case 1:
                        context->_currentAttribute[XZMLSecurityMarkAttributeName] = mark;
                        break;
                    default:
                        context->_currentAttribute[XZMLSecurityMarkAttributeName] = mark;
                        if ([mark rangeOfComposedCharacterSequenceAtIndex:0].length < mark.length) {
                            context->_currentAttribute[XZMLSecurityRepeatAttributeName] = @(1);
                            return XZMLReadingModeSkipElement;
                        }
                        break;
                }
                return XZMLReadingModeTextOnly;
            }
            
            // 设置了重复次数，元素及子元素的就不需要解析了
            context->_currentAttribute[XZMLSecurityMarkAttributeName] = mark.length > 0 ? mark : @"*";
            context->_currentAttribute[XZMLSecurityRepeatAttributeName] = @(repeat);
            return XZMLReadingModeSkipElement;
        }
        
        // 仅指定了替换字符
        if (value.length > 0) {
            context->_currentAttribute[XZMLSecurityMarkAttributeName] = value;
            if ([value rangeOfComposedCharacterSequenceAtIndex:0].length < value.length) {
                context->_currentAttribute[XZMLSecurityRepeatAttributeName] = @(1);
                return XZMLReadingModeSkipElement;
            }
        } else {
            context->_currentAttribute[XZMLSecurityMarkAttributeName] = @"*";
        }
        
        return XZMLReadingModeTextOnly;
    }
    // 非安全模式，不需要解析安全属性
    return XZMLReadingModeNormal;
}

XZMLReadingMode didFindLinkAttribute(XZMLDSLContext * const context, NSString *value) {
    if (value.length == 0) {
        // 继承值
        if (context->_currentAttribute[NSLinkAttributeName]) {
            return XZMLReadingModeNormal;
        }
        // 预设值
        value = context->_defaultAttribute[XZMLLinkAttributeName];
        if (value) {
            context->_currentAttribute[NSLinkAttributeName] = value;
            return XZMLReadingModeNormal;
        }
        // 无法解析
        return XZMLReadingModeNormal;
    }
    
    BOOL    const isFilePath = [value hasPrefix:@"/"] || [value hasPrefix:@"~"];
    NSURL * const url = isFilePath ? [NSURL fileURLWithPath:value] : [NSURL URLWithString:value];
    if (url != nil) {
        context->_currentAttribute[NSLinkAttributeName] = url;
    } else {
        context->_currentAttribute[NSLinkAttributeName] = value;
    }
    
    return XZMLReadingModeNormal;
}

/// 写入最小行高。
/// style 初始已携带继承/预设/默认的段落样式，值为 0 或非数字（如无值的标记符落入残留值时）不写入，避免覆盖上层行高。
FOUNDATION_STATIC_INLINE void XZMLParagraphSetMinimumLineHeight(NSMutableParagraphStyle *style, NSString *value, NSRange range) {
    CGFloat const lineHeight = [value substringWithRange:range].doubleValue;
    if (lineHeight > 0) {
        style.minimumLineHeight = lineHeight;
    }
}

XZMLReadingMode didFindParagraphAttribute(XZMLDSLContext * const context, NSString *value) {
    NSUInteger const length = [value lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if (length == 0) {
        return XZMLReadingModeNormal;
    }
    
    NSMutableParagraphStyle * const style = [context->_currentAttribute[NSParagraphStyleAttributeName] mutableCopy]
        ?: [context->_defaultAttribute[XZMLParagraphStyleAttributeName] mutableCopy]
        ?: [context->_defaultAttribute[NSParagraphStyleAttributeName] mutableCopy]
        ?: [[NSMutableParagraphStyle alloc] init];;
    
    const char * const UTF8String = [value cStringUsingEncoding:NSUTF8StringEncoding];
    NSUInteger start = 0;
    NSRange    range = NSMakeRange(start, 0);
    
    while (true) {
        start = UTF8SearchASCII(UTF8String, start);
        range.length = start - range.location;
        
        // 已经遍历了整个字符串
        if (start >= length) {
            // 如果还有未处理字符或未匹配到段落样式标记符，则默认为是行高值
            if (range.length > 0) {
                XZMLParagraphSetMinimumLineHeight(style, value, range);
            }
            break;
        }
        
        // 段落标记符前没有值，忽略
        if (range.length == 0) {
            start += 1;
            continue;
        }
        
        // 根据段落标记符，生成段落样式
        switch (UTF8String[start]) {
            case 'L':
            case 'l': {
                XZMLParagraphSetMinimumLineHeight(style, value, range);
                break;
            }
            case 'H':
            case 'h': {
                style.maximumLineHeight = [value substringWithRange:range].doubleValue;
                break;
            }
            case 'X':
            case 'x': {
                style.lineHeightMultiple = [value substringWithRange:range].doubleValue;
                break;
            }
            case 'A':
            case 'a': {
                NSTextAlignment const alignment = [value substringWithRange:range].integerValue;
                switch (alignment) {
                    case NSTextAlignmentLeft:
                    case NSTextAlignmentCenter:
                    case NSTextAlignmentRight:
                    case NSTextAlignmentJustified:
                    case NSTextAlignmentNatural:
                        style.alignment = alignment;
                        break;
                }
                break;
            }
            case 'K':
            case 'k': {
                NSLineBreakMode const lineBreakMode = [value substringWithRange:range].integerValue;
                switch (lineBreakMode) {
                    case NSLineBreakByWordWrapping:
                    case NSLineBreakByCharWrapping:
                    case NSLineBreakByClipping:
                    case NSLineBreakByTruncatingHead:
                    case NSLineBreakByTruncatingTail:
                    case NSLineBreakByTruncatingMiddle:
                        style.lineBreakMode = lineBreakMode;
                        break;
                }
                break;
            }
            case 'S':
            case 's': {
                style.lineSpacing = [value substringWithRange:range].doubleValue;
                break;
            }
            case 'W':
            case 'w': {
                NSWritingDirection const baseWritingDirection = [value substringWithRange:range].integerValue;
                switch (baseWritingDirection) {
                    case NSWritingDirectionNatural:
                    case NSWritingDirectionLeftToRight:
                    case NSWritingDirectionRightToLeft:
                        style.baseWritingDirection = baseWritingDirection;
                        break;
                }
                break;
            }
            case 'F':
            case 'f': {
                style.firstLineHeadIndent = [value substringWithRange:range].doubleValue;
                break;
            }
            case 'I':
            case 'i': {
                style.headIndent = [value substringWithRange:range].doubleValue;
                break;
            }
            case 'T':
            case 't': {
                style.tailIndent = [value substringWithRange:range].doubleValue;
                break;
            }
            case 'P':
            case 'p': {
                style.paragraphSpacing = [value substringWithRange:range].doubleValue;
                break;
            }
            case 'B':
            case 'b': {
                style.paragraphSpacingBefore = [value substringWithRange:range].doubleValue;
                break;
            }
            default:
                // 当前字符是普通字符，继续判断下一个字符是否为段落样式标记符
                start += 1;
                continue;
        }
        
        // 当前字符是段落样式标记符，重新开始计算下一个段落样式值的范围。
        start += 1;
        range.location = start;
        range.length = 0;
    };
    
    context->_currentAttribute[NSParagraphStyleAttributeName] = style;
    
    return XZMLReadingModeNormal;
}

void XZMLSetFontAbbreviations(NSDictionary<NSString *, NSString *> * _Nullable fontAbbreviations) {
    NSCAssert(NSThread.isMainThread, @"请在程序初始化时（主线程）执行此方法");
    _fontAbbreviations = fontAbbreviations.copy;
}

NSDictionary<NSString *, NSString *> * _Nullable XZMLGetFontAbbreviations(void) {
    return _fontAbbreviations;
}
