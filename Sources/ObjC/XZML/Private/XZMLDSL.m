//
//  XZMLDSL.m
//  XZKit
//
//  Created by Xezun on 2021/10/18.
//

#import "XZMLDSL.h"
#import "XZMLDefines.h"
#import "UIColor+XZKit.h"
#import "XZLog.h"

/// XZML 元素的开始和结束标记，固定为 `<` 和 `>` 字符，不支持自定义。
#define XZMLElementStart '<'
#define XZMLElementEnd   '>'
#define XZMLEscapingMark '\\'

/// 安全文本替代字符。默认替代字符为 `*` 星号。
/// @note 在元素属性中，有此属性有值表明这是一个安全文本。
static NSAttributedStringKey const XZMLSecurityMarkAttributeName  = @"XZMLSecurityMarkAttributeName";
/// 安全文本替代字符重复次数。
/// @note 0 表示重复次数默认与安全文本字符数相同。
static NSAttributedStringKey const XZMLSecurityRepeatAttributeName = @"XZMLSecurityRepeatAttributeName";
/// 安全文本替代字符最大重复次数，防止外部指定极端重复值导致内存问题。
static NSInteger const XZMLSecurityRepeatLimit = 64;
/// 字体名缩写表。key 为缩写，value 为完整字体名；由 XZMLSetFontAbbreviations 整体替换，解析期间只读。
static NSDictionary<NSString *, NSString *> *_fontAbbreviations = nil;

/// XZML 元素属性的行为。
///
/// 在 XZML 中，可通过属性控制文本。在解析的过程中，如果已解析的属性，已经决定后续解析方式，以提高解析效率。
typedef NS_ENUM(NSUInteger, XZMLReadingMode) {
    /// 无操作，正常模式，解析属性和文本。
    XZMLReadingModeNormal,
    /// 只解析当前元素中的文本。
    XZMLReadingModeText,
    /// 提前结束当前元素，正在解析的元素，不解析后续的属性和文本。
    XZMLReadingModeBreak,
    /// 忽略元素，跳过元素，当作整个元素不存在，没有元素解析事件。
    XZMLReadingModeIgnore,
};

/// XZML 解析过程的中间量。
typedef struct XZMLDSLContext {
    NSString * __unsafe_unretained _XZML;
    
    /// 纯文本模式时，此值不为 nil
    NSMutableString           * __unsafe_unretained _string;
    /// 富文本模式时，此值不为 nil
    NSMutableAttributedString * __unsafe_unretained _attributedString;
    
    /// 外部提供默认样式和预置样式。
    NSDictionary<NSAttributedStringKey, id>  * const __unsafe_unretained _defaultAttribute;
    /// 解析过程中元素内联样式栈
    NSMutableArray<NSMutableDictionary *>    * const __unsafe_unretained _elementAttributes;
    /// 解析过程中元素计算样式栈
    NSMutableArray<NSMutableDictionary *>    * const __unsafe_unretained _computeAttributes;
    /// 当前正在解析中的文本的内联样式，一般情况下就是 `_elementAttributes` 的最后一个元素。
    NSMutableDictionary<NSAttributedStringKey, id> * __unsafe_unretained _currentAttribute;
    /// XZMLReadingMode
    NSMutableArray<NSNumber *>                     * __unsafe_unretained _modes;
} XZMLDSLContext;

// MARK: - 语法解析

static void XZMLDSLDidBeginElement(XZMLDSLContext * const context, NSUInteger const hierarchies);
static void XZMLDSLDidFindText(XZMLDSLContext * const context, NSString *value);
static XZMLReadingMode XZMLDSLDidFindAttribute(XZMLDSLContext * const context, XZMLAttribute attribute, NSString *value);
static void XZMLDSLDidEndElement(XZMLDSLContext * const context, NSUInteger const hierarchies);

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

/// 判断字符是否为 ASCII 字符。只有函数返回 YES 参数 character 的值才是 ASCII 字符。
static inline BOOL XZMLDSLTestASCII(NSString * substring, NSRange range, unichar *character) {
    if (substring == nil || range.length == 0) {
        return NO;
    }
    // 多字节字符
    if (range.length > 1) {
        return NO;
    }
    *character = [substring characterAtIndex:0];
    return isascii(*character);
}

/// 非 UTF8 字符串的解析方式。
static inline void XZMLDSL(XZMLDSLContext * const context, XZMLReadingMode mode) {
    /// 元素的层级
    NSUInteger __block hierarchies      = 0;
    /// 是否为逃逸模式
    BOOL       __block isEscaping       = NO;
    /// 元素是否还有样式需要解析。将顶层当作没有样式、没有开始结束标记的普通元素解析。
    BOOL       __block isAttributeEnded = YES;
    
    context->_modes[hierarchies] = @(mode);
    XZMLDSLDidBeginElement(context, hierarchies);
    
    /// 文本段
    NSMutableString          * const fragment = [NSMutableString string];
    NSRange                    const eRange   = NSMakeRange(0, context->_XZML.length);
    NSStringEnumerationOptions const eOptions = NSStringEnumerationByComposedCharacterSequences;
    [context->_XZML enumerateSubstringsInRange:eRange options:eOptions usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        // 判断当前字符是否为 ASCII 字符
        unichar asciiCharacter = 0;
        BOOL const isASCIICharacter = XZMLDSLTestASCII(substring, substringRange, &asciiCharacter);
        
        switch ([context->_modes[hierarchies] unsignedIntegerValue]) {
            case XZMLReadingModeNormal: {
                // 非 ASCII 字符
                if (!isASCIICharacter) {
                    isEscaping = NO;
                    if (substring) [fragment appendString:substring];
                    return;
                }
                
                // 逃逸模式
                if (isEscaping) {
                    isEscaping = NO;
                    [fragment appendString:substring];
                    return;
                }
                
                // 逃逸标记
                if (asciiCharacter == XZMLEscapingMark) {
                    isEscaping = YES;
                    return;
                }
                
                // 结束标记
                if (asciiCharacter == XZMLElementEnd) {
                    // 顶层元素
                    if (hierarchies == 0) {
                        [fragment appendString:substring];
                        break;
                    }
                    
                    // 结算文本
                    NSUInteger const length = fragment.length;
                    if (length > 0) {
                        XZMLDSLDidFindText(context, fragment);
                        [fragment deleteCharactersInRange:NSMakeRange(0, length)];
                    }
                    
                    // 结束元素
                    XZMLDSLDidEndElement(context, hierarchies);
                    hierarchies -= 1;       // 返回父元素层级
                    isAttributeEnded = YES; // 子元素提前终止父元素的样式识别
                    return;
                }
                
                // 开始标记
                if (asciiCharacter == XZMLElementStart) {
                    // 结算文本
                    NSUInteger const length = fragment.length;
                    if (length > 0) {
                        XZMLDSLDidFindText(context, fragment);
                        [fragment deleteCharactersInRange:NSMakeRange(0, length)];
                    }
                    
                    // 层级递进
                    hierarchies += 1;
                    isAttributeEnded = NO; 
                    context->_modes[hierarchies] = @(XZMLReadingModeNormal);
                    XZMLDSLDidBeginElement(context, hierarchies);
                    return;
                }
                                
                // 样式段已结束
                if (isAttributeEnded) {
                    [fragment appendString:substring];
                    return;
                }
                
                // 样式标记
                if (XZMLDSLTestAttribute(asciiCharacter)) {
                    // 结算样式
                    XZMLReadingMode const newElementMode = XZMLDSLDidFindAttribute(context, asciiCharacter, fragment);
                    [fragment deleteCharactersInRange:NSMakeRange(0, fragment.length)];
                    context->_modes[hierarchies] = @(newElementMode);
                    return;
                }
                
                // 普通字符
                [fragment appendString:substring];
                return;
            }
                
            case XZMLReadingModeText: {
                // 非 ASCII 字符
                if (!isASCIICharacter) {
                    isEscaping = NO;
                    if (substring) [fragment appendString:substring];
                    return;
                }
                
                // 逃逸模式
                if (isEscaping) {
                    isEscaping = NO;
                    [fragment appendString:substring];
                    return;
                }
                
                // 逃逸标记
                if (asciiCharacter == XZMLEscapingMark) {
                    isEscaping = YES;
                    return;
                }
                
                // 结束标记
                if (asciiCharacter == XZMLElementEnd) {
                    if (hierarchies == 0) {
                        [fragment appendString:substring];
                        return;
                    }
                    
                    // 结算文本
                    NSUInteger const length = fragment.length;
                    if (length > 0) {
                        XZMLDSLDidFindText(context, fragment);
                        [fragment deleteCharactersInRange:NSMakeRange(0, length)];
                    }
                    
                    // 结束元素
                    XZMLDSLDidEndElement(context, hierarchies);
                    hierarchies -= 1;
                    isAttributeEnded = YES;
                    return;
                }
                
                // 开始标记
                if (asciiCharacter == XZMLElementStart) {
                    // 结算文本
                    NSUInteger const length = fragment.length;
                    if (length > 0) {
                        XZMLDSLDidFindText(context, fragment);
                        [fragment deleteCharactersInRange:NSMakeRange(0, length)];
                    }
                    
                    // 层级递进
                    hierarchies += 1;
                    isAttributeEnded = NO;
                    context->_modes[hierarchies] = @(XZMLReadingModeText);
                    XZMLDSLDidBeginElement(context, hierarchies);
                    return;
                }
                                
                // 样式段已结束
                if (isAttributeEnded) {
                    [fragment appendString:substring];
                    return;
                }
                
                // 样式标记
                if (XZMLDSLTestAttribute(asciiCharacter)) {
                    NSUInteger const length = fragment.length;
                    if (length > 0) {
                        [fragment deleteCharactersInRange:NSMakeRange(0, length)];
                    }
                    return;
                }
                
                // 普通字符
                [fragment appendString:substring];
                return;
            }
                
            case XZMLReadingModeBreak: {
                if (!isASCIICharacter) {
                    isEscaping = NO;
                    return;
                }
                // 逃逸模式
                if (isEscaping) {
                    isEscaping = NO;
                    return;
                }
                
                // 逃逸标记
                if (asciiCharacter == XZMLEscapingMark) {
                    isEscaping = YES;
                    return;
                }
                
                // 结束标记
                if (asciiCharacter == XZMLElementEnd) {
                    if (hierarchies == 0) {
                        return;
                    }
                    
                    // 元素提前终止，但是元素依然存在
                    XZMLDSLDidFindText(context, fragment);
                    
                    hierarchies -= 1;
                    isAttributeEnded = YES;
                    XZMLDSLDidEndElement(context, hierarchies);
                }
                
                // 开始标记
                if (asciiCharacter == XZMLElementStart) {
                    hierarchies += 1;
                    isAttributeEnded = NO;
                    context->_modes[hierarchies] = @(XZMLReadingModeIgnore);
                }
                return;
            }
                
            case XZMLReadingModeIgnore: {
                if (!isASCIICharacter) {
                    isEscaping = NO;
                    return;
                }
                
                // 逃逸模式
                if (isEscaping) {
                    isEscaping = NO;
                    return;
                }
                
                // 逃逸标记
                if (asciiCharacter == XZMLEscapingMark) {
                    isEscaping = YES;
                    return;
                }
                
                // 结束标记
                if (asciiCharacter == XZMLElementEnd) {
                    if (hierarchies == 0) {
                        return;
                    }
                    hierarchies -= 1;
                }
                
                // 开始标记
                if (asciiCharacter == XZMLElementStart) {
                    hierarchies += 1;
                    context->_modes[hierarchies] = @(XZMLReadingModeIgnore);
                }
                return;
            }
        }
    }];
    
    if (fragment.length > 0) {
        XZMLDSLDidFindText(context, fragment);
    }
    
    // 闭合所有元素
    for (NSInteger i = hierarchies; i >= 0; i--) {
        XZMLDSLDidEndElement(context, i);
    }
}

static void XZMLDSLWithMode(NSString *XZMLString, XZMLReadingMode mode, NSMutableString * _Nullable string, NSMutableAttributedString * _Nullable attributedString, NSDictionary<NSAttributedStringKey, id> * _Nullable defaultAttributes) {
    NSMutableArray * const modes = [NSMutableArray arrayWithCapacity:16];
    NSMutableArray * const elementAttributes = [NSMutableArray arrayWithCapacity:16];
    NSMutableArray * const computeAttributes = [NSMutableArray arrayWithCapacity:16];
    [computeAttributes addObject:[NSMutableDictionary dictionary]];
    XZMLDSLContext context = {
        XZMLString,
        string,
        attributedString,
        defaultAttributes,
        elementAttributes,
        computeAttributes,
        nil, // currentAttribute
        modes
    };
    XZMLDSL(&context, mode);
}

void XZMLDSLWithAttributedString(NSString *XZMLString, NSMutableAttributedString *attributedString, NSDictionary<NSAttributedStringKey, id> * _Nullable defaultAttributes) {
    if (XZMLString == nil || ![XZMLString isKindOfClass:NSString.class] || XZMLString.length == 0) {
        return;
    }
    
    XZMLDSLWithMode(XZMLString, XZMLReadingModeNormal, nil, attributedString, defaultAttributes);
}

void XZMLDSLWithString(NSString *XZMLString, NSMutableString *string, NSDictionary<NSAttributedStringKey, id> * _Nullable defaultAttributes) {
    if (XZMLString == nil || ![XZMLString isKindOfClass:NSString.class] || XZMLString.length == 0) {
        return;
    }
    XZMLReadingMode const mode = [defaultAttributes[XZMLSecurityModeAttributeName] boolValue] ? XZMLReadingModeNormal : XZMLReadingModeText;
    XZMLDSLWithMode(XZMLString, mode, string, nil, defaultAttributes);
}

// MARK: - 内容解析

static XZMLReadingMode XZMLDSLDidFindFontAttribute(XZMLDSLContext * const context, NSString *value);
static XZMLReadingMode XZMLDSLDidFindColorAttribute(XZMLDSLContext * const context, NSString *value);
static XZMLReadingMode XZMLDSLDidFindDecorationAttribute(XZMLDSLContext * const context, NSString *value);
static XZMLReadingMode XZMLDSLDidFindSecurityAttribute(XZMLDSLContext * const context, NSString *value);
static XZMLReadingMode XZMLDSLDidFindLinkAttribute(XZMLDSLContext * const context, NSString *value);
static XZMLReadingMode XZMLDSLDidFindParagraphAttribute(XZMLDSLContext * const context, NSString *value);

static void XZMLDSLDidBeginElement(XZMLDSLContext * const context, NSUInteger const hierarchies) {
    XZLog(@"XZMLDSLDidBeginElement: %lu", hierarchies);
    // 继承父元素样式，如果没有则新建
    NSMutableDictionary * const _currentAttribute = [context->_elementAttributes.lastObject mutableCopy] ?: [NSMutableDictionary dictionary];
    context->_currentAttribute = _currentAttribute;
    // 将当前样式入栈。
    [context->_elementAttributes addObject:context->_currentAttribute];
    // 合并后的样式
    [context->_computeAttributes addObject:[NSMutableDictionary dictionary]];
}

static void XZMLDSLDidFindText(XZMLDSLContext * const context, NSString *text) {
    XZLog(@"XZMLDSLDidFindText: %@", text);
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
        // computeStyle 中可能包含解析内部键 XZMLSecurity(Mark|Repeat)AttributeName，此处有意不做过滤：
        // - 不影响富文本构造，两个键不属于 UIKit 认识的富文本属性，渲染时被忽略。
        // - 这两个字段是样式配置（替代字符与重复次数），不属于机密数据。
        // - 由 XZMLTests.testSecurityInternalKeysRetainedInResult 锁定该行为。
        NSAttributedString * const attributedString = [[NSAttributedString alloc] initWithString:text attributes:computeStyle];
        [context->_attributedString appendAttributedString:attributedString];
    }
}

static XZMLReadingMode XZMLDSLDidFindAttribute(XZMLDSLContext * const context, XZMLAttribute attribute, NSString *value) {
    XZLog(@"XZMLDSLDidFindAttribute: %c => %@", attribute, value);
    if (context->_string) {
        // 纯文本模式，仅解析安全样式
        if (attribute == XZMLAttributeSecurity) {
            return XZMLDSLDidFindSecurityAttribute(context, value);
        }
        return XZMLReadingModeNormal;
    }
    
    // 普通模式，解析所有样式
    switch (attribute) {
        case XZMLAttributeColor: {
            return XZMLDSLDidFindColorAttribute(context, value);
        }
        case XZMLAttributeFont: {
            return XZMLDSLDidFindFontAttribute(context, value);
        }
        case XZMLAttributeDecoration: {
            return XZMLDSLDidFindDecorationAttribute(context, value);
        }
        case XZMLAttributeSecurity: {
            return XZMLDSLDidFindSecurityAttribute(context, value);
        }
        case XZMLAttributeLink: {
            return XZMLDSLDidFindLinkAttribute(context, value);
        }
        case XZMLAttributeParagraph: {
            return XZMLDSLDidFindParagraphAttribute(context, value);
        }
        default: {
            // 暂不支持
            return XZMLReadingModeNormal;
        }
    }
}

static void XZMLDSLDidEndElement(XZMLDSLContext * const context, NSUInteger const hierarchies) {
    XZLog(@"XZMLDSLDidEndElement: %lu", hierarchies);
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

XZMLReadingMode XZMLDSLDidFindColorAttribute(XZMLDSLContext * const context, NSString *value) {
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

XZMLReadingMode XZMLDSLDidFindFontAttribute(XZMLDSLContext * const context, NSString *value) {
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

/// 文本修饰样式。修饰类型包含下划线与删除线两种互斥子样式，因此只覆盖同名子样式，另一类保留继承值。
XZMLReadingMode XZMLDSLDidFindDecorationAttribute(XZMLDSLContext * const context, NSString *value) {
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

XZMLReadingMode XZMLDSLDidFindSecurityAttribute(XZMLDSLContext * const context, NSString *value) {
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
                            return XZMLReadingModeBreak;
                        }
                        break;
                }
                return XZMLReadingModeText;
            }
            
            // 设置了重复次数，元素及子元素的就不需要解析了
            context->_currentAttribute[XZMLSecurityMarkAttributeName] = mark.length > 0 ? mark : @"*";
            context->_currentAttribute[XZMLSecurityRepeatAttributeName] = @(repeat);
            return XZMLReadingModeBreak;
        }
        
        // 仅指定了替换字符
        if (value.length > 0) {
            NSString * const mark = value.copy;
            context->_currentAttribute[XZMLSecurityMarkAttributeName] = mark;
            // 判断 mark 是不是单个语义字符。
            if ([mark rangeOfComposedCharacterSequenceAtIndex:0].length < mark.length) {
                context->_currentAttribute[XZMLSecurityRepeatAttributeName] = @(1);
                return XZMLReadingModeBreak;
            }
            return XZMLReadingModeText;
            
        }
        
        // 未指定替换字符，默认星号。
        context->_currentAttribute[XZMLSecurityMarkAttributeName] = @"*";
        return XZMLReadingModeText;
    }
    // 非安全模式，不需要解析安全属性
    return XZMLReadingModeNormal;
}

XZMLReadingMode XZMLDSLDidFindLinkAttribute(XZMLDSLContext * const context, NSString *value) {
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

XZMLReadingMode XZMLDSLDidFindParagraphAttribute(XZMLDSLContext * const context, NSString *value) {
    NSUInteger const length = [value lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if (length == 0) {
        return XZMLReadingModeNormal;
    }
    
    NSMutableParagraphStyle * const style = [context->_currentAttribute[NSParagraphStyleAttributeName] mutableCopy]
        ?: [context->_defaultAttribute[XZMLParagraphStyleAttributeName] mutableCopy]
        ?: [context->_defaultAttribute[NSParagraphStyleAttributeName] mutableCopy]
        ?: [[NSMutableParagraphStyle alloc] init];
    
    NSArray<NSString *> *values = [value componentsSeparatedByString:@"@"];
    switch (values.count) {
        case 10: {
            NSWritingDirection const baseWritingDirection = values[9].integerValue;
            switch (baseWritingDirection) {
                case NSWritingDirectionNatural:
                case NSWritingDirectionLeftToRight:
                case NSWritingDirectionRightToLeft:
                    style.baseWritingDirection = baseWritingDirection;
                    break;
            }
        }
        case 9:
            style.tailIndent = values[8].doubleValue;
        case 8:
            style.headIndent = values[7].doubleValue;
        case 7:
            style.paragraphSpacingBefore = values[6].doubleValue;
        case 6:
            style.paragraphSpacing = values[5].doubleValue;
        case 5: {
            NSLineBreakMode const lineBreakMode = values[4].integerValue;
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
        }
        case 4: {
            NSTextAlignment const alignment = values[3].integerValue;
            switch (alignment) {
                case NSTextAlignmentLeft:
                case NSTextAlignmentCenter:
                case NSTextAlignmentRight:
                case NSTextAlignmentJustified:
                case NSTextAlignmentNatural:
                    style.alignment = alignment;
                    break;
            }
        }
        case 3:
            style.firstLineHeadIndent = values[2].doubleValue;
        case 2:
            style.lineSpacing = values[1].doubleValue;
        case 1: {
            NSString * const value = values[0];
            if ([value containsString:@"-"]) {
                NSArray<NSString *> *values = [value componentsSeparatedByString:@"-"];
                style.minimumLineHeight = values[0].doubleValue;
                style.maximumLineHeight = values[1].doubleValue;
            } else {
                style.lineHeightMultiple = value.doubleValue;
            }
            break;
        }
        default:
            break;
    }
    
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
