//
//  XZMLParser.m
//  XZKit
//
//  Created by Xezun on 2021/10/18.
//

#import "XZMLParser.h"
#import "XZMLDSL.h"
#import "XZMLDefines.h"
#import "UIColor+XZKit.h"
@import ObjectiveC;

/// 安全文本替代字符。默认替代字符为 `*` 星号。
/// @note 在元素属性中，有此属性有值表明这是一个安全文本。
static NSAttributedStringKey const XZMLSecurityMarkAttributeName  = @"XZMLSecurityMarkAttributeName";
/// 安全文本替代字符重复次数。
/// @note 0 表示重复次数默认与安全文本字符数相同。
static NSAttributedStringKey const XZMLSecurityRepeatAttributeName = @"XZMLSecurityRepeatAttributeName";

static XZMLReadingMode XZMLAttributeFontParser(NSMutableDictionary<NSAttributedStringKey, id> *elementAttributes, NSString *value, NSDictionary<NSAttributedStringKey, id> * _Nullable defaultAttributes);
static XZMLReadingMode XZMLAttributeColorParser(NSMutableDictionary<NSAttributedStringKey, id> *elementAttributes, NSString *value, NSDictionary<NSAttributedStringKey, id> * _Nullable defaultAttributes);
static XZMLReadingMode XZMLAttributeDecorationParser(NSMutableDictionary<NSAttributedStringKey, id> *elementAttributes, NSString *value, NSDictionary<NSAttributedStringKey, id> * _Nullable defaultAttributes);
static XZMLReadingMode XZMLAttributeSecurityParser(NSMutableDictionary<NSAttributedStringKey, id> *elementAttributes, NSString *value, NSDictionary<NSAttributedStringKey, id> * _Nullable defaultAttributes);
static XZMLReadingMode XZMLAttributeLinkParser(NSMutableDictionary<NSAttributedStringKey, id> *elementAttributes, NSString *value, NSDictionary<NSAttributedStringKey, id> * _Nullable defaultAttributes);
static XZMLReadingMode XZMLAttributeParagraphParser(NSMutableDictionary<NSAttributedStringKey, id> *elementAttributes, NSString *value, NSDictionary<NSAttributedStringKey, id> * _Nullable defaultAttributes);
static NSString *XZMLTextParser(NSDictionary<NSAttributedStringKey, id> * _Nullable attributes, NSString *text);

@implementation XZMLParser {
    /// 解析过程中 XZML 元素富文本属性栈
    NSMutableArray<NSMutableDictionary *> *_elementStyles;
    /// 合成后的元素文本富文本属性栈
    NSMutableArray<NSMutableDictionary *> *_computeStyles;
    
    /// 当前正在解析中的文本的内联样式。
    NSMutableDictionary<NSAttributedStringKey, id> *_currentStyle;
    /// 当前正在解析中的文本的默认样式。
    NSDictionary<NSAttributedStringKey, id>        *_defaultStyle;
}

@synthesize mode = _mode;
@synthesize currentAttributes = _currentStyle;
@synthesize defaultAttributes = _defaultStyle;

- (instancetype)init {
    self = [super init];
    if (self) {
        _elementStyles = [NSMutableArray arrayWithCapacity:32];
        _computeStyles = [NSMutableArray arrayWithCapacity:32];
        
        // 不在元素标记符内的普通文本的样式。
        [_computeStyles addObject:[NSMutableDictionary dictionary]];
        
        Class const aClass = object_getClass(self);
        _isAttributeCharacter = class_getMethodImplementation(aClass, @selector(isAttributeCharacter:));
        _didBeginElement      = class_getMethodImplementation(aClass, @selector(didBeginElement));
        _didEndElement        = class_getMethodImplementation(aClass, @selector(didEndElement));
        _foundAttribute       = class_getMethodImplementation(aClass, @selector(foundAttribute:value:));
        _foundText            = class_getMethodImplementation(aClass, @selector(foundText:fragment:));
        
        _mode = XZMLReadingModeNone;
    }
    return self;
}

static XZMLParser *_defaultParser = nil;

+ (XZMLParser *)defaultParser {
    if (_defaultParser == nil) {
        _defaultParser = [[XZMLParser alloc] init];
    }
    return _defaultParser;
}

+ (void)setDefaultParser:(XZMLParser *)defaultParser {
    _defaultParser = defaultParser;
}

- (NSMutableAttributedString *)attributedStringWithXZMLString:(NSString *)XZMLString attributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    [self attributedString:attributedString appendXZMLString:XZMLString attributes:attributes];
    return attributedString;
}

- (void)attributedString:(NSMutableAttributedString *)attributedString appendXZMLString:(NSString *)XZMLString attributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    _defaultStyle = attributes.copy;
    _attributedString = attributedString;
    _mode = XZMLReadingModeNone;
    XZMLDSL(XZMLString, self);
}

- (NSMutableString *)stringWithXZMLString:(NSString *)XZMLString attributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    NSMutableString *string = [[NSMutableString alloc] init];
    [self string:string appendXZMLString:XZMLString attributes:attributes];
    XZMLDSL(XZMLString, self);
}

- (void)string:(NSMutableString *)string appendXZMLString:(NSString *)XZMLString attributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    _defaultStyle = attributes.copy;
    _string = string;
    _mode = XZMLReadingModeText;
    XZMLDSL(XZMLString, self);
}

- (BOOL)isAttributeCharacter:(char)character {
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
    return NO;
}

- (void)didBeginElement {
    if (_mode == XZMLReadingModeText) {
        if (_currentStyle == nil) {
            _currentStyle = [NSMutableDictionary dictionary];
        } else {
            [_currentStyle removeAllObjects];
        }
        return;
    }
    // 继承父元素样式，如果没有则新建
    _currentStyle = [_elementStyles.lastObject mutableCopy] ?: [NSMutableDictionary dictionary];
    // 将当前样式入栈。
    [_elementStyles addObject:_currentStyle];
    // 合并后的样式
    [_computeStyles addObject:[NSMutableDictionary dictionary]];
}

- (XZMLReadingMode)foundAttribute:(XZMLAttribute)attribute value:(NSString *)value {
    if (_mode == XZMLReadingModeText) {
        if (attribute == XZMLAttributeSecurity) {
            return XZMLAttributeSecurityParser(_currentStyle, value, _defaultStyle);
        }
        return XZMLReadingModeText;
    }
    switch (attribute) {
        case XZMLAttributeColor: {
            return XZMLAttributeColorParser(_currentStyle, value, _defaultStyle);
        }
        case XZMLAttributeFont: {
            return XZMLAttributeFontParser(_currentStyle, value, _defaultStyle);
        }
        case XZMLAttributeDecoration: {
            return XZMLAttributeDecorationParser(_currentStyle, value, _defaultStyle);
        }
        case XZMLAttributeSecurity: {
            return XZMLAttributeSecurityParser(_currentStyle, value, _defaultStyle);
        }
        case XZMLAttributeLink: {
            return XZMLAttributeLinkParser(_currentStyle, value, _defaultStyle);
        }
        case XZMLAttributeParagraph: {
            return XZMLAttributeParagraphParser(_currentStyle, value, _defaultStyle);
        }
        default: {
            // 暂不支持
            return XZMLReadingModeNone;
        }
    }
}

- (void)foundText:(NSString *)text fragment:(NSUInteger)fragment {
    if (_mode == XZMLReadingModeText) {
        [_string appendString:text];
    } else {
        // 找到元素文本，也可能顶层非元素文本
        NSMutableDictionary * const computeStyle = _computeStyles.lastObject;
        // 样式为空，说明样式还没有合并
        if (computeStyle.count == 0) {
            // 先复制元素内联样式
            [computeStyle addEntriesFromDictionary:_currentStyle];
            // 将默认样式合并，不覆盖内联样式
            [_defaultStyle enumerateKeysAndObjectsUsingBlock:^(NSAttributedStringKey  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                // 过滤 XZML 属性，自定义的 XZML 属性，在富文本中不生效。
                if ([key hasPrefix:@"XZML"]) {
                    return;
                }
                if (computeStyle[key] == nil) {
                    computeStyle[key] = obj;
                }
            }];
        }
        NSAttributedString * const attributedString = [[NSAttributedString alloc] initWithString:XZMLTextParser(computeStyle, text) attributes:computeStyle];// [self foundText:text fragment:fragment attributes:computeAttributes];
        if (attributedString) {
            [_attributedString appendAttributedString:attributedString];
        }
    }
}

- (void)didEndElement {
    if (_mode == XZMLReadingModeText) {
        
    } else {
        [_elementStyles removeLastObject];
        [_computeStyles removeLastObject];
        _currentStyle = _elementStyles.lastObject;
    }
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

FOUNDATION_STATIC_INLINE UIColor *XZMLForegroundColorFromContext(NSMutableDictionary<NSAttributedStringKey, id> *elementAttributes, NSString *value, NSDictionary<NSAttributedStringKey, id> * _Nullable defaultAttributes) {
    // 使用指定值
    UIColor *color = rgba(value, nil);
    if (color) {
        return color;
    }
    // 使用继承值
    if (elementAttributes[NSForegroundColorAttributeName]) {
        return nil;
    }
    // 使用预设值
    color = defaultAttributes[XZMLForegroundColorAttributeName];
    if (color) {
        return color;
    }
    // 使用默认值
    return defaultAttributes[NSForegroundColorAttributeName];
}

XZMLReadingMode XZMLAttributeColorParser(NSMutableDictionary<NSAttributedStringKey, id> *elementAttributes, NSString * const value, NSDictionary<NSAttributedStringKey, id> * _Nullable defaultAttributes) {
    if ([value containsString:@"@"]) {
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        
        UIColor * const foregroundColor = XZMLForegroundColorFromContext(elementAttributes, values[0], defaultAttributes);
        if (foregroundColor) {
            elementAttributes[NSForegroundColorAttributeName] = foregroundColor;
        }
        
        UIColor * const backgroundColor = rgba(values[1], nil);
        if (backgroundColor) {
            elementAttributes[NSBackgroundColorAttributeName] = backgroundColor;
        }
    } else {
        UIColor *foregroundColor = XZMLForegroundColorFromContext(elementAttributes, value, defaultAttributes);
        if (foregroundColor != nil) {
            elementAttributes[NSForegroundColorAttributeName] = foregroundColor;
        }
    }
    return XZMLReadingModeNone;
}

FOUNDATION_STATIC_INLINE UIFont * _Nullable XZMLFontFromContext(NSMutableDictionary<NSAttributedStringKey, id> *elementAttributes, NSString * _Nullable nameString, NSString * _Nullable sizeString, NSDictionary<NSAttributedStringKey, id> * _Nullable defaultAttributes) {
    NSString *name = [XZMLParser fontNameForAbbreviation:nameString];
    CGFloat   size = sizeString.doubleValue;
    UIFont   *font = nil;
    
    // 没有指定字号
    if (isnan(size) || size <= 0) {
        // 使用继承值
        font = elementAttributes[NSFontAttributeName];
        if (font == nil) {
            // 使用默认值
            font = defaultAttributes[NSFontAttributeName];
            if (font == nil) {
                // 使用预设值
                font = defaultAttributes[XZMLFontAttributeName];
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
        font = elementAttributes[NSFontAttributeName];
        if (font) {
            if (font.pointSize == size) {
                return nil;
            }
            return [font fontWithSize:size];
        }
        // 使用预设值
        font = defaultAttributes[XZMLFontAttributeName];
        if (font) {
            return [font fontWithSize:size];
        }
        // 使用默认值
        font = defaultAttributes[NSFontAttributeName];
        if (font) {
            return [font fontWithSize:size];
        }
        // 使用系统值
        return [UIFont systemFontOfSize:size];
    }
    
    return font;
}

XZMLReadingMode XZMLAttributeFontParser(NSMutableDictionary<NSAttributedStringKey, id> *elementAttributes, NSString * const value, NSDictionary<NSAttributedStringKey, id> * _Nullable defaultAttributes) {
    if ([value containsString:@"@"]) {
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        
        UIFont * font = XZMLFontFromContext(elementAttributes, values[0], values[1], defaultAttributes);
        if (font) {
            elementAttributes[NSFontAttributeName] = font;
        }
        
        // 字体基准线调整
        if (values.count > 2) {
            CGFloat const baselineOffset = values[2].floatValue;
            if (baselineOffset != 0) {
                elementAttributes[NSBaselineOffsetAttributeName] = @(baselineOffset);
            }
        }
    } else {
        // 仅指定了一个参数，作为字体名使用
        UIFont * font = XZMLFontFromContext(elementAttributes, value, nil, defaultAttributes);
        if (font) {
            elementAttributes[NSFontAttributeName] = font;
        }
    }
    return XZMLReadingModeNone;
}

FOUNDATION_STATIC_INLINE XZMLDecorationType XZMLDecorationTypeFromContext(NSMutableDictionary<NSAttributedStringKey, id> *elementAttributes, NSString *typeString, NSDictionary<NSAttributedStringKey, id> * _Nullable defaultAttributes) {
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
    if (elementAttributes[NSStrikethroughStyleAttributeName]) {
        return XZMLDecorationTypeStrikethrough;
    }
    if (elementAttributes[NSUnderlineStyleAttributeName]) {
        return XZMLDecorationTypeUnderline;
    }
    // 预设值
    if (defaultAttributes[XZMLDecorationAttributeName]) {
        return [defaultAttributes[XZMLDecorationAttributeName] unsignedIntegerValue];
    }
    // 默认值
    if (defaultAttributes[NSStrikethroughStyleAttributeName]) {
        return XZMLDecorationTypeStrikethrough;
    }
    if (defaultAttributes[NSUnderlineStyleAttributeName]) {
        return XZMLDecorationTypeUnderline;
    }
    // 系统值：有修饰标记时，默认为添加删除线
    return XZMLDecorationTypeStrikethrough;
}

/// 暂不支持通过 defaultAttributes 提供默认值。
XZMLReadingMode XZMLAttributeDecorationParser(NSMutableDictionary<NSAttributedStringKey, id> *elementAttributes, NSString * const value, NSDictionary<NSAttributedStringKey, id> * _Nullable defaultAttributes) {
    XZMLDecorationType type = 0;                         // 样式 0 删除线 1 下划线
    NSUnderlineStyle  style = NSUnderlineStyleSingle;    // 线型 0 单线条 1 双线条 2 粗线条
    UIColor *         color = nil;                       // 颜色 _ 默认色 x 指定色
    
    if ([value containsString:@"@"]) {
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        
        type = XZMLDecorationTypeFromContext(elementAttributes, values[0], defaultAttributes);
        
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
        type = XZMLDecorationTypeFromContext(elementAttributes, value, defaultAttributes);
    }
    
    if (type == 1) {
        elementAttributes[NSUnderlineStyleAttributeName] = @(style);
        if (color != nil) {
            elementAttributes[NSUnderlineColorAttributeName] = color;
        }
    } else {
        elementAttributes[NSStrikethroughStyleAttributeName] = @(style);
        if (color != nil) {
            elementAttributes[NSStrikethroughColorAttributeName] = color;
        }
        if (@available(iOS 10.3, *)) {
            // 解决 iOS 10.3 删除线不展示的问题
            if (elementAttributes[NSBaselineOffsetAttributeName] == nil) {
                elementAttributes[NSBaselineOffsetAttributeName] = @(0);
            }
        }
    }
    
    return XZMLReadingModeNone;
}

XZMLReadingMode XZMLAttributeSecurityParser(NSMutableDictionary<NSAttributedStringKey, id> *elementAttributes, NSString * const value, NSDictionary<NSAttributedStringKey, id> * _Nullable defaultAttributes) {
    // 只有安全模式下，才需要解析安全字符样式
    if ([defaultAttributes[XZMLSecurityModeAttributeName] boolValue]) {
        if ([value containsString:@"@"]) {
            NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
            
            NSString * const mark   = values[0];
            NSInteger  const repeat = values[1].integerValue;
            
            // 重复次数默认值：替换符为单字符，默认重复次数与文本长度相同；替换符为多字符，默认重复次数为 1 次
            if (repeat <= 0) {
                switch (mark.length) {
                    case 0:
                        elementAttributes[XZMLSecurityMarkAttributeName] = @"*";
                        break;
                    case 1:
                        elementAttributes[XZMLSecurityMarkAttributeName] = mark;
                        break;
                    default:
                        elementAttributes[XZMLSecurityMarkAttributeName] = mark;
                        if ([mark rangeOfComposedCharacterSequenceAtIndex:0].length < mark.length) {
                            elementAttributes[XZMLSecurityRepeatAttributeName] = @(1);
                            return XZMLReadingModeSkip;
                        }
                        break;
                }
                return XZMLReadingModeText;
            }
            
            // 设置了重复次数，元素及子元素的就不需要解析了
            elementAttributes[XZMLSecurityMarkAttributeName] = mark.length > 0 ? mark : @"*";
            elementAttributes[XZMLSecurityRepeatAttributeName] = @(repeat);
            return XZMLReadingModeSkip;
        }
        
        // 仅指定了替换字符
        if (value.length > 0) {
            elementAttributes[XZMLSecurityMarkAttributeName] = value;
            if ([value rangeOfComposedCharacterSequenceAtIndex:0].length < value.length) {
                elementAttributes[XZMLSecurityRepeatAttributeName] = @(1);
                return XZMLReadingModeSkip;
            }
        } else {
            elementAttributes[XZMLSecurityMarkAttributeName] = @"*";
        }
        
        return XZMLReadingModeText;
    }
    // 非安全模式，不需要解析安全属性
    return XZMLReadingModeNone;
}

XZMLReadingMode XZMLAttributeLinkParser(NSMutableDictionary<NSAttributedStringKey, id> *elementAttributes, NSString *value, NSDictionary<NSAttributedStringKey, id> * _Nullable defaultAttributes) {
    if (value.length == 0) {
        // 继承值
        if (elementAttributes[NSLinkAttributeName]) {
            return XZMLReadingModeNone;
        }
        // 预设值
        value = defaultAttributes[XZMLLinkAttributeName];
        if (value) {
            elementAttributes[NSLinkAttributeName] = value;
            return XZMLReadingModeNone;
        }
        // 无法解析
        return XZMLReadingModeNone;
    }
    
    BOOL    const isFilePath = [value hasPrefix:@"/"] || [value hasPrefix:@"~"];
    NSURL * const url = isFilePath ? [NSURL fileURLWithPath:value] : [NSURL URLWithString:value];
    if (url != nil) {
        elementAttributes[NSLinkAttributeName] = url;
    } else {
        elementAttributes[NSLinkAttributeName] = value;
    }
    
    return XZMLReadingModeNone;
}

FOUNDATION_STATIC_INLINE CGFloat XZMLLineHeightFromContext(NSMutableDictionary<NSAttributedStringKey, id> *elementAttributes, CGFloat lineHeight, NSDictionary<NSAttributedStringKey, id> * _Nullable defaultAttributes) {
    if (!isnan(lineHeight) && lineHeight > 0) {
        return lineHeight;
    }
    // 继承值
    NSParagraphStyle *parentStyle = elementAttributes[NSParagraphStyleAttributeName];
    if (parentStyle.minimumLineHeight > 0) {
        return parentStyle.minimumLineHeight;
    }
    // 预设值
    lineHeight = [defaultAttributes[XZMLLineHeightAttributeName] doubleValue];
    if (lineHeight > 0) {
        return lineHeight;
    }
    // 默认值
    NSParagraphStyle *defaultStyle = defaultAttributes[NSParagraphStyleAttributeName];
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

XZMLReadingMode XZMLAttributeParagraphParser(NSMutableDictionary<NSAttributedStringKey, id> *elementAttributes, NSString *value, NSDictionary<NSAttributedStringKey, id> * _Nullable defaultAttributes) {
    NSMutableParagraphStyle * const style = [elementAttributes[NSParagraphStyleAttributeName] mutableCopy] ?: [[NSMutableParagraphStyle alloc] init];
    
    NSUInteger const length = value.length;
    
    // 未指定行高
    if (length == 0) {
        style.minimumLineHeight = XZMLLineHeightFromContext(elementAttributes, 0, defaultAttributes);
        elementAttributes[NSParagraphStyleAttributeName] = style;
        return XZMLReadingModeNone;
    }
    
    NSRange    range = NSMakeRange(0, 0);
    NSUInteger index = 0;
    
    while (true) {
        // 已经遍历了整个字符串
        if (index >= length) {
            // 如果还有未处理字符，则认为是行高值
            if (range.length > 0) {
                CGFloat const number = [[value substringWithRange:range] doubleValue];
                style.minimumLineHeight = XZMLLineHeightFromContext(elementAttributes, number, defaultAttributes);
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
                style.minimumLineHeight = XZMLLineHeightFromContext(elementAttributes, CGFloatMakeParagraphValue(value, &range), defaultAttributes);
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
    
    elementAttributes[NSParagraphStyleAttributeName] = style;
    
    return XZMLReadingModeNone;
}

/// attributes 可能包含 XZMLSecurityMarkAttributeName/XZMLSecurityRepeatAttributeName 键
NSString *XZMLTextParser(NSDictionary<NSAttributedStringKey, id> *attributes, NSString *text) {
    NSString * const mark = attributes[XZMLSecurityMarkAttributeName];
    if (mark) {
        NSInteger const repeat = [attributes[XZMLSecurityRepeatAttributeName] integerValue];
        NSInteger const length = mark.length * (repeat > 0 ? repeat : text.length);
        return [mark stringByPaddingToLength:length withString:mark startingAtIndex:0];
    }
    return text;
}


