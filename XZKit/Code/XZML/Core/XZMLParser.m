//
//  XZMLParser.m
//  XZKit
//
//  Created by Xezun on 2021/10/18.
//

#import "XZMLParser.h"
#import "XZMLDSL.h"
@import XZExtensions;
@import XZDefines;

/// 安全文本替代字符。默认替代字符为 `*` 星号。
/// @note 在元素属性中，有此属性有值表明这是一个安全文本。
static NSAttributedStringKey const XZMLSecurityMarkAttributeName  = @"XZMLSecurityMarkAttributeName";
/// 安全文本替代字符重复次数。
/// @note 0 表示重复次数默认与安全文本字符数相同。
static NSAttributedStringKey const XZMLSecurityRepeatAttributeName = @"XZMLSecurityRepeatAttributeName";

static XZMLReadingOptions XZMLAttributeFontParser(const XZMLParserContext context, XZMLElement element, NSString *value);
static XZMLReadingOptions XZMLAttributeColorParser(const XZMLParserContext context, XZMLElement element, NSString *value);
static XZMLReadingOptions XZMLAttributeDecorationParser(const XZMLParserContext context, XZMLElement element, NSString *value);
static XZMLReadingOptions XZMLAttributeSecurityParser(const XZMLParserContext context, XZMLElement element, NSString *value);
static XZMLReadingOptions XZMLAttributeLinkParser(const XZMLParserContext context, XZMLElement element, NSString *value);
static XZMLReadingOptions XZMLAttributeParagraphParser(const XZMLParserContext context, XZMLElement element, NSString *value);
static NSString *XZMLAttributeTextParser(NSDictionary<NSAttributedStringKey, id> * _Nullable attributes, NSString *text);

static Class<XZMLParser> _defaultParser = Nil;

@implementation XZMLParser

+ (Class<XZMLParser>)defaultParser {
    return _defaultParser ?: [XZMLParser class];
}

+ (void)setDefaultParser:(Class<XZMLParser>)defaultParser {
    _defaultParser = defaultParser;
}

+ (void)attributedString:(NSMutableAttributedString * const)attributedString parse:(NSString *)XZMLString attributes:(NSDictionary<NSAttributedStringKey,id> * const)_defaultAttributes {
    /// 解析过程中 XZML 元素富文本属性栈
    NSMutableArray<NSMutableDictionary *> * const _elementAttributes = [NSMutableArray arrayWithCapacity:32];
    /// 合成后的元素文本富文本属性栈
    NSMutableArray<NSMutableDictionary *> * const _computeAttributes = [NSMutableArray arrayWithCapacity:32];
    [_computeAttributes addObject:[NSMutableDictionary dictionary]]; // 根非元素文本的合成富文本属性
    
    XZMLParserContext __block _context = { nil, _defaultAttributes };
    
    XZMLDSL(XZMLString, ^XZMLElement(char const character) {
        // 判读元素是否开始，并返回元素终止字符
        return [self shouldBeginElement:character];
    }, ^BOOL(XZMLElement const element, char const character) {
        // 判断是否为元素属性标记字符
        return [self element:element shouldBeginAttribute:character];
    }, ^(XZMLElement const element) {
        // 开始解析元素
        id const newAttributes = [_elementAttributes.lastObject mutableCopy] ?: [NSMutableDictionary dictionary];
        [_elementAttributes addObject:newAttributes];
        [_computeAttributes addObject:[NSMutableDictionary dictionary]];
        _context.elementAttributes = newAttributes;
        [self didBeginElement:element context:_context];
    }, ^XZMLReadingOptions (XZMLElement const element, XZMLElement const attribute, NSString *value) {
        // 找到元素属性
        return [self element:element foundAttribute:attribute value:value context:_context];
    }, ^(XZMLElement element, NSString * _Nonnull text, NSUInteger fragment) {
        // 找到元素文本，也可能顶层非元素文本
        NSMutableDictionary * const computeAttributes = _computeAttributes.lastObject;
        if (computeAttributes.count == 0) {
            NSDictionary * const elementAttributes = _elementAttributes.lastObject;
            if (elementAttributes.count > 0) {
                [computeAttributes addEntriesFromDictionary:elementAttributes];
            }
            [_defaultAttributes enumerateKeysAndObjectsUsingBlock:^(NSAttributedStringKey  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([key hasPrefix:@"XZML"]) {
                    return; // 过滤 XZML 属性
                }
                if (computeAttributes[key] == nil) {
                    computeAttributes[key] = obj;
                }
            }];
        }
        NSAttributedString * const textAttributedString = [self element:element foundText:text fragment:fragment attributes:computeAttributes];
        if (textAttributedString) {
            [attributedString appendAttributedString:textAttributedString];
        }
    }, ^(XZMLElement const element) {
        // 结束解析元素
        [self didEndElement:element context:_context];
        [_elementAttributes removeLastObject];
        [_computeAttributes removeLastObject];
        _context.elementAttributes = _elementAttributes.lastObject;
    });
}

+ (NSMutableAttributedString *)parse:(NSString *)XZMLString attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes {
    NSMutableAttributedString * const attributedString = [NSMutableAttributedString new];
    [self.defaultParser attributedString:attributedString parse:XZMLString attributes:attributes];
    return attributedString;
}

+ (void)string:(NSMutableString *)string parse:(NSString *)XZMLString attributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    NSMutableArray * const _attributes = [NSMutableArray array];
    
    if ([attributes[XZMLSecurityModeAttributeName] boolValue]) {
        [_attributes addObject:attributes];
    }
    
    XZMLParserContext __block _context = { nil, attributes };

    XZMLDSL(XZMLString, ^XZMLElement(char character) {
        return [self shouldBeginElement:character];
    }, ^BOOL(XZMLElement element, char character) {
        return [self element:element shouldBeginAttribute:character];
    }, ^(XZMLElement element) {
        id const attributes = [_attributes.lastObject mutableCopy];
        if (attributes) {
            [_attributes addObject:attributes];
        }
    }, ^XZMLReadingOptions(XZMLElement element, XZMLElement attribute, NSString *value) {
        if (attribute == XZMLAttributeSecurity) {
            _context.elementAttributes = _attributes.lastObject;
            return [self element:element foundAttribute:attribute value:value context:_context];
        }
        return XZMLReadingAll;
    }, ^(XZMLElement element, NSString *text, NSUInteger fragment) {
        id const attributes = _attributes.lastObject;
        [string appendString:XZMLAttributeTextParser(attributes, text)];
    }, ^(XZMLElement element) {
        [_attributes removeLastObject];
    });
}

#pragma mark - 解析过程

+ (XZMLElement)shouldBeginElement:(char)character {
    switch (character) {
        case '<':
            return '>';
        default:
            return XZMLElementNotAnElement;
    }
}

+ (BOOL)element:(XZMLElement)element shouldBeginAttribute:(char)character {
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

+ (void)didBeginElement:(XZMLElement)element context:(const XZMLParserContext)context {
    
}

+ (XZMLReadingOptions)element:(XZMLElement)element foundAttribute:(XZMLAttribute)attribute value:(NSString *)value context:(const XZMLParserContext)context {
    switch (attribute) {
        case XZMLAttributeColor: {
            return XZMLAttributeColorParser(context, element, value);
        }
        case XZMLAttributeFont: {
            return XZMLAttributeFontParser(context, element, value);
        }
        case XZMLAttributeDecoration: {
            return XZMLAttributeDecorationParser(context, element, value);
        }
        case XZMLAttributeSecurity: {
            return XZMLAttributeSecurityParser(context, element, value);
        }
        case XZMLAttributeLink: {
            return XZMLAttributeLinkParser(context, element, value);
        }
        case XZMLAttributeParagraph: {
            return XZMLAttributeParagraphParser(context, element, value);
        }
        default: {
            XZLog(@"XZML：自定义属性 %c 暂不支持", attribute);
            return XZMLReadingAll;
        }
    }
}

+ (nullable NSAttributedString *)element:(XZMLElement)element foundText:(NSString *)text fragment:(NSUInteger)fragment attributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    return [[NSAttributedString alloc] initWithString:XZMLAttributeTextParser(attributes, text) attributes:attributes];
}

+ (void)didEndElement:(XZMLElement)element context:(const XZMLParserContext)context {
    
}

@end

/// 字体名缩写。
static NSMutableDictionary<NSString *, NSString *> *_fontNameAbbreviations = nil;

@implementation XZMLParser (XZMLExtendedParser)

+ (void)setFontName:(NSString *)fontName forAbbreviation:(NSString *)abbreviation {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _fontNameAbbreviations = [NSMutableDictionary dictionary];
    });
    _fontNameAbbreviations[abbreviation] = fontName;
}

+ (NSString *)fontNameForAbbreviation:(NSString *)abbreviation {
    return _fontNameAbbreviations[abbreviation] ?: abbreviation;
}

@end




#pragma mark - 样式解析

FOUNDATION_STATIC_INLINE UIColor *XZMLForegroundColorFromContext(const XZMLParserContext context, NSString *value) {
    // 使用指定值
    UIColor *color = rgba(value, nil);
    if (color) {
        return color;
    }
    // 使用继承值
    if (context.elementAttributes[NSForegroundColorAttributeName]) {
        return nil;
    }
    // 使用预设值
    color = context.defaultAttributes[XZMLForegroundColorAttributeName];
    if (color) {
        return color;
    }
    // 使用默认值
    return context.defaultAttributes[NSForegroundColorAttributeName];
}

XZMLReadingOptions XZMLAttributeColorParser(const XZMLParserContext context, XZMLElement const element, NSString * const value) {
    if ([value containsString:@"@"]) {
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        
        UIColor * const foregroundColor = XZMLForegroundColorFromContext(context, values[0]);
        if (foregroundColor) {
            context.elementAttributes[NSForegroundColorAttributeName] = foregroundColor;
        }
        
        UIColor * const backgroundColor = rgba(values[1], nil);
        if (backgroundColor) {
            context.elementAttributes[NSBackgroundColorAttributeName] = backgroundColor;
        }
    } else {
        UIColor *foregroundColor = XZMLForegroundColorFromContext(context, value);
        if (foregroundColor != nil) {
            context.elementAttributes[NSForegroundColorAttributeName] = foregroundColor;
        }
    }
    return XZMLReadingAll;
}

FOUNDATION_STATIC_INLINE UIFont * _Nullable XZMLFontFromContext(const XZMLParserContext context, NSString * _Nullable nameString, NSString * _Nullable sizeString) {
    NSString *name = [XZMLParser fontNameForAbbreviation:nameString];
    CGFloat   size = sizeString.doubleValue;
    UIFont   *font = nil;
    
    // 没有指定字号
    if (isnan(size) || size <= 0) {
        // 使用继承值
        font = context.elementAttributes[NSFontAttributeName];
        if (font == nil) {
            // 使用默认值
            font = context.defaultAttributes[NSFontAttributeName];
            if (font == nil) {
                // 使用预设值
                font = context.defaultAttributes[XZMLFontAttributeName];
                if (font == nil) {
                    XZLog(@"[XZML] 解析字体失败，无法确定字号");
                    return nil;
                }
            }
        }
        size = font.pointSize;
    }
    
    // 没有指定字名
    if (name.length == 0 || (font = [UIFont fontWithName:name size:size]) == nil) {
        // 使用继承值
        font = context.elementAttributes[NSFontAttributeName];
        if (font) {
            if (font.pointSize == size) {
                return nil;
            }
            return [font fontWithSize:size];
        }
        // 使用预设值
        font = context.defaultAttributes[XZMLFontAttributeName];
        if (font) {
            return [font fontWithSize:size];
        }
        // 使用默认值
        font = context.defaultAttributes[NSFontAttributeName];
        if (font) {
            return [font fontWithSize:size];
        }
        // 使用系统值
        return [UIFont systemFontOfSize:size];
    }
    
    return font;
}

XZMLReadingOptions XZMLAttributeFontParser(const XZMLParserContext context, XZMLElement const element, NSString * const value) {
    if ([value containsString:@"@"]) {
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        
        UIFont * font = XZMLFontFromContext(context, values[0], values[1]);
        if (font) {
            context.elementAttributes[NSFontAttributeName] = font;
        }
        
        // 字体基准线调整
        if (values.count > 2) {
            CGFloat const baselineOffset = values[2].floatValue;
            if (baselineOffset != 0) {
                context.elementAttributes[NSBaselineOffsetAttributeName] = @(baselineOffset);
            }
        }
    } else {
        // 仅指定了一个参数，作为字体名使用
        UIFont * font = XZMLFontFromContext(context, value, nil);
        if (font) {
            context.elementAttributes[NSFontAttributeName] = font;
        }
    }
    return XZMLReadingAll;
}

FOUNDATION_STATIC_INLINE XZMLDecorationType XZMLDecorationTypeFromContext(const XZMLParserContext context, NSString *typeString) {
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
    if (context.elementAttributes[NSStrikethroughStyleAttributeName]) {
        return XZMLDecorationTypeStrikethrough;
    }
    if (context.elementAttributes[NSUnderlineStyleAttributeName]) {
        return XZMLDecorationTypeUnderline;
    }
    // 预设值
    if (context.defaultAttributes[XZMLDecorationAttributeName]) {
        return [context.defaultAttributes[XZMLDecorationAttributeName] unsignedIntegerValue];
    }
    // 默认值
    if (context.defaultAttributes[NSStrikethroughStyleAttributeName]) {
        return XZMLDecorationTypeStrikethrough;
    }
    if (context.defaultAttributes[NSUnderlineStyleAttributeName]) {
        return XZMLDecorationTypeUnderline;
    }
    // 系统值：有修饰标记时，默认为添加删除线
    return XZMLDecorationTypeStrikethrough;
}

/// 暂不支持通过 defaultAttributes 提供默认值。
XZMLReadingOptions XZMLAttributeDecorationParser(const XZMLParserContext context, XZMLElement const element, NSString * const value) {
    XZMLDecorationType type = 0;                         // 样式 0 删除线 1 下划线
    NSUnderlineStyle  style = NSUnderlineStyleSingle;    // 线型 0 单线条 1 双线条 2 粗线条
    UIColor *         color = nil;                       // 颜色 _ 默认色 x 指定色
    
    if ([value containsString:@"@"]) {
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        
        type = XZMLDecorationTypeFromContext(context, values[0]);
        
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
        type = XZMLDecorationTypeFromContext(context, value);
    }
    
    if (type == 1) {
        context.elementAttributes[NSUnderlineStyleAttributeName] = @(style);
        if (color != nil) {
            context.elementAttributes[NSUnderlineColorAttributeName] = color;
        }
    } else {
        context.elementAttributes[NSStrikethroughStyleAttributeName] = @(style);
        if (color != nil) {
            context.elementAttributes[NSStrikethroughColorAttributeName] = color;
        }
        if (@available(iOS 10.3, *)) {
            // 解决 iOS 10.3 删除线不展示的问题
            if (context.elementAttributes[NSBaselineOffsetAttributeName] == nil) {
                context.elementAttributes[NSBaselineOffsetAttributeName] = @(0);
            }
        }
    }
    
    return XZMLReadingAll;
}

XZMLReadingOptions XZMLAttributeSecurityParser(const XZMLParserContext context, XZMLElement const element, NSString * const value) {
    // 只有安全模式下，才需要解析安全字符样式
    if ([context.defaultAttributes[XZMLSecurityModeAttributeName] boolValue]) {
        if ([value containsString:@"@"]) {
            NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
            
            NSString * const mark   = values[0];
            NSInteger  const repeat = values[1].integerValue;
            
            // 重复次数默认值：替换符为单字符，默认重复次数与文本长度相同；替换符为多字符，默认重复次数为 1 次
            if (isnan(repeat) || repeat <= 0) {
                switch (mark.length) {
                    case 0:
                        context.elementAttributes[XZMLSecurityMarkAttributeName] = @"*";
                        break;
                    case 1:
                        context.elementAttributes[XZMLSecurityMarkAttributeName] = mark;
                        break;
                    default:
                        context.elementAttributes[XZMLSecurityMarkAttributeName] = mark;
                        if ([mark rangeOfComposedCharacterSequenceAtIndex:0].length < mark.length) {
                            context.elementAttributes[XZMLSecurityRepeatAttributeName] = @(1);
                            return XZMLReadingNone;
                        }
                        break;
                }
                return XZMLReadingText;
            }
            
            // 设置了重复次数，元素及子元素的就不需要解析了
            context.elementAttributes[XZMLSecurityMarkAttributeName] = mark.length > 0 ? mark : @"*";
            context.elementAttributes[XZMLSecurityRepeatAttributeName] = @(repeat);
            return XZMLReadingNone;
        }
        
        // 仅指定了替换字符
        if (value.length > 0) {
            context.elementAttributes[XZMLSecurityMarkAttributeName] = value;
            if ([value rangeOfComposedCharacterSequenceAtIndex:0].length < value.length) {
                context.elementAttributes[XZMLSecurityRepeatAttributeName] = @(1);
                return XZMLReadingNone;
            }
        } else {
            context.elementAttributes[XZMLSecurityMarkAttributeName] = @"*";
        }
        
        return XZMLReadingText;
    }
    // 非安全模式，不需要解析安全属性
    return XZMLReadingAll;
}

XZMLReadingOptions XZMLAttributeLinkParser(const XZMLParserContext context, XZMLElement element, NSString *value) {
    if (value.length == 0) {
        // 继承值
        if (context.elementAttributes[NSLinkAttributeName]) {
            return XZMLReadingAll;
        }
        // 预设值
        value = context.defaultAttributes[XZMLLinkAttributeName];
        if (value) {
            context.elementAttributes[NSLinkAttributeName] = value;
            return XZMLReadingAll;
        }
        // 无法解析
        return XZMLReadingAll;
    }
    
    BOOL    const isFilePath = [value hasPrefix:@"/"] || [value hasPrefix:@"~"];
    NSURL * const url = isFilePath ? [NSURL fileURLWithPath:value] : [NSURL URLWithString:value];
    if (url != nil) {
        context.elementAttributes[NSLinkAttributeName] = url;
    } else {
        context.elementAttributes[NSLinkAttributeName] = value;
    }
    
    return XZMLReadingAll;
}

FOUNDATION_STATIC_INLINE CGFloat XZMLLineHeightFromContext(const XZMLParserContext context, CGFloat lineHeight) {
    if (!isnan(lineHeight) && lineHeight > 0) {
        return lineHeight;
    }
    // 继承值
    NSParagraphStyle *parentStyle = context.elementAttributes[NSParagraphStyleAttributeName];
    if (parentStyle.minimumLineHeight > 0) {
        return parentStyle.minimumLineHeight;
    }
    // 预设值
    lineHeight = [context.defaultAttributes[XZMLLineHeightAttributeName] doubleValue];
    if (lineHeight > 0) {
        return lineHeight;
    }
    // 默认值
    NSParagraphStyle *defaultStyle = context.defaultAttributes[NSParagraphStyleAttributeName];
    return defaultStyle.minimumLineHeight;;
}


FOUNDATION_STATIC_INLINE CGFloat CGFloatMakeParagraphValue(NSString *value, NSRange *range) {
    value = [value substringWithRange:*range];
    range->location = range->location + range->length + 1;
    range->length = 0;
    return value.doubleValue;
};

FOUNDATION_STATIC_INLINE NSInteger NSIntegerMakeParagraphValue(NSString *value, NSRange *range) {
    value = [value substringWithRange:*range];
    range->location = range->location + range->length + 1;
    range->length = 0;
    return value.integerValue;
};

XZMLReadingOptions XZMLAttributeParagraphParser(const XZMLParserContext context, XZMLElement element, NSString *value) {
    NSMutableParagraphStyle * const style = [context.elementAttributes[NSParagraphStyleAttributeName] mutableCopy] ?: [[NSMutableParagraphStyle alloc] init];
    
    NSUInteger const length = value.length;
    
    // 未指定行高
    if (length == 0) {
        style.minimumLineHeight = XZMLLineHeightFromContext(context, 0);
        context.elementAttributes[NSParagraphStyleAttributeName] = style;
        return XZMLReadingAll;
    }
    
    NSRange    range = NSMakeRange(0, 0);
    NSUInteger index = 0;
    
    while (true) {
        // 已经遍历了整个字符串
        if (index >= length) {
            // 如果还有未处理字符，则认为是行高值
            if (range.length > 0) {
                CGFloat const number = [[value substringWithRange:range] doubleValue];
                style.minimumLineHeight = XZMLLineHeightFromContext(context, number);
            }
            break;
        }
        
        NSRange const charRange = [value rangeOfComposedCharacterSequenceAtIndex:index];
        
        // 多子节字符，肯定不是子属性标记符号
        if (charRange.length > 1) {
            range.length += charRange.length;
            index += charRange.length;
            continue;
        }
        
        switch ([value characterAtIndex:index]) {
            case 'H':
            case 'h': {
                style.minimumLineHeight = XZMLLineHeightFromContext(context, CGFloatMakeParagraphValue(value, &range));
                break;
            }
            case 'M':
            case 'm': {
                style.maximumLineHeight = CGFloatMakeParagraphValue(value, &range);
                break;
            }
            case 'X':
            case 'x': {
                style.lineHeightMultiple = CGFloatMakeParagraphValue(value, &range);
                break;
            }
            case 'A':
            case 'a': {
                style.alignment = NSIntegerMakeParagraphValue(value, &range);
                break;
            }
            case 'K':
            case 'k': {
                style.lineBreakMode = NSIntegerMakeParagraphValue(value, &range);
                break;
            }
            case 'S':
            case 's': {
                style.lineSpacing = CGFloatMakeParagraphValue(value, &range);
                break;
            }
            case 'W':
            case 'w': {
                style.baseWritingDirection = NSIntegerMakeParagraphValue(value, &range);
                break;
            }
            case 'F':
            case 'f': {
                style.firstLineHeadIndent = CGFloatMakeParagraphValue(value, &range);
                break;
            }
            case 'I':
            case 'i': {
                style.headIndent = CGFloatMakeParagraphValue(value, &range);
                break;
            }
            case 'T':
            case 't': {
                style.tailIndent = CGFloatMakeParagraphValue(value, &range);
                break;
            }
            case 'P':
            case 'p': {
                style.paragraphSpacing = CGFloatMakeParagraphValue(value, &range);
                break;
            }
            case 'B':
            case 'b': {
                style.paragraphSpacingBefore = CGFloatMakeParagraphValue(value, &range);
                break;
            }
            default:
                range.length += 1; // 值字符
                break;
        }
        
        index += 1;
    };
    
    context.elementAttributes[NSParagraphStyleAttributeName] = style;
    
    return XZMLReadingAll;
}

/// attributes 可能包含 XZMLSecurityMarkAttributeName/XZMLSecurityRepeatAttributeName 键
NSString *XZMLAttributeTextParser(NSDictionary<NSAttributedStringKey, id> *attributes, NSString *text) {
    NSString * const mark = attributes[XZMLSecurityMarkAttributeName];
    if (mark) {
        NSInteger const repeat = [attributes[XZMLSecurityRepeatAttributeName] integerValue];
        NSInteger const length = mark.length * (repeat > 0 ? repeat : text.length);
        return [mark stringByPaddingToLength:length withString:mark startingAtIndex:0];
    }
    return text;
}


