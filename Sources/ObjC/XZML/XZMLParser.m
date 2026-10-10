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

/// 安全文本替代字符最大重复次数，防止外部指定极端重复值导致内存问题。
static NSInteger const XZMLSecurityRepeatLimit = 64;

// 使用函数以提高性能。
static XZMLReadingMode XZMLParserFontAttribute(XZMLParser * const __unsafe_unretained parser, NSString *value);
static XZMLReadingMode XZMLParserColorAttribute(XZMLParser * const __unsafe_unretained parser, NSString *value);
static XZMLReadingMode XZMLParserDecorationAttribute(XZMLParser * const __unsafe_unretained parser, NSString *value);
static XZMLReadingMode XZMLParserSecurityAttribute(XZMLParser * const __unsafe_unretained parser, NSString *value);
static XZMLReadingMode XZMLParserLinkAttribute(XZMLParser * const __unsafe_unretained parser, NSString *value);
static XZMLReadingMode XZMLParserParagraphAttribute(XZMLParser * const __unsafe_unretained parser, NSString *value);
static NSString *XZMLParserText(NSDictionary<NSAttributedStringKey, id> * _Nullable attributes, NSString *text);

@implementation XZMLParser {
    @package
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
        
        // 直接访问 IMP 以提高性能
        Class const aClass = object_getClass(self);
        _isAttributeCharacter = class_getMethodImplementation(aClass, @selector(isAttributeCharacter:));
        _didBeginElement      = class_getMethodImplementation(aClass, @selector(didBeginElement));
        _didEndElement        = class_getMethodImplementation(aClass, @selector(didEndElement));
        _foundAttribute       = class_getMethodImplementation(aClass, @selector(foundAttribute:value:));
        _foundText            = class_getMethodImplementation(aClass, @selector(foundText:fragment:));
        
        _mode = XZMLReadingModeNormal;
    }
    return self;
}

static Class _defaultParserClass = nil;

+ (Class)defaultParserClass {
    return _defaultParserClass ?: [XZMLParser class];
}

+ (void)setDefaultParserClass:(Class)defaultParserClass {
    // 非 XZMLParser 子类在解析时会 unrecognized selector 崩溃，入口即校验；传 nil 恢复默认
    NSAssert(defaultParserClass == nil || [defaultParserClass isSubclassOfClass:[XZMLParser class]], @"defaultParserClass 必须是 XZMLParser 或其子类");
    _defaultParserClass = defaultParserClass;
}

static XZMLParser *_mainParser = nil;

+ (XZMLParser *)mainParser {
    // 每次访问都校验主线程，避免单例创建后断言失效
    NSAssert(NSThread.isMainThread, @"mainParser 只能在主线程使用");
    if (_mainParser == nil) {
        _mainParser = [[XZMLParser.defaultParserClass alloc] init];
    }
    return _mainParser;
}

+ (void)setMainParser:(XZMLParser *)mainParser {
    NSAssert(NSThread.isMainThread, @"mainParser 只能在主线程使用");
    _mainParser = mainParser;
}

static inline void XZMLParserExecuteWithMode(XZMLParser * const __unsafe_unretained parser, XZMLReadingMode mode, NSString *XZMLString, NSDictionary<NSAttributedStringKey,id> *attributes) {
    [parser->_computeStyles addObject:[NSMutableDictionary dictionary]];
    parser->_defaultStyle = attributes.copy;
    parser->_currentStyle = nil;
    parser->_mode = mode;
    
    @try {
        XZMLDSL(XZMLString, parser);
    } @finally {
        // 无论正常结束还是异常穿越，都必须复位，避免残留样式栈污染下一次解析（跨调用串色）
        parser->_defaultStyle = nil;
        parser->_currentStyle = nil;
        [parser->_elementStyles removeAllObjects];
        [parser->_computeStyles removeAllObjects];
    }
}

- (NSMutableAttributedString *)attributedStringWithXZMLString:(NSString *)XZMLString attributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    [self attributedString:attributedString appendXZMLString:XZMLString attributes:attributes];
    return attributedString;
}

- (void)attributedString:(NSMutableAttributedString *)attributedString appendXZMLString:(NSString *)XZMLString attributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    _attributedString = attributedString;
    XZMLParserExecuteWithMode(self, XZMLReadingModeNormal, XZMLString, attributes);
    _attributedString = nil;
}

- (NSMutableString *)stringWithXZMLString:(NSString *)XZMLString attributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    NSMutableString *string = [[NSMutableString alloc] init];
    [self string:string appendXZMLString:XZMLString attributes:attributes];
    return string;
}

- (void)string:(NSMutableString *)string appendXZMLString:(NSString *)XZMLString attributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    _string = string;
    XZMLParserExecuteWithMode(self, XZMLReadingModeTextOnly, XZMLString, attributes);
    _string = nil;
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
}

- (void)didBeginElement {
    // 继承父元素样式，如果没有则新建
    _currentStyle = [_elementStyles.lastObject mutableCopy] ?: [NSMutableDictionary dictionary];
    // 将当前样式入栈。
    [_elementStyles addObject:_currentStyle];
    // 合并后的样式
    [_computeStyles addObject:[NSMutableDictionary dictionary]];
}

- (XZMLReadingMode)foundAttribute:(XZMLAttribute)attribute value:(NSString *)value {
    switch (_mode) {
        case XZMLReadingModeNormal:
            // 普通模式，解析所有样式
            switch (attribute) {
                case XZMLAttributeColor: {
                    return XZMLParserColorAttribute(self, value);
                }
                case XZMLAttributeFont: {
                    return XZMLParserFontAttribute(self, value);
                }
                case XZMLAttributeDecoration: {
                    return XZMLParserDecorationAttribute(self, value);
                }
                case XZMLAttributeSecurity: {
                    return XZMLParserSecurityAttribute(self, value);
                }
                case XZMLAttributeLink: {
                    return XZMLParserLinkAttribute(self, value);
                }
                case XZMLAttributeParagraph: {
                    return XZMLParserParagraphAttribute(self, value);
                }
                default: {
                    // 暂不支持
                    return XZMLReadingModeNormal;
                }
            }
            break;
            
        case XZMLReadingModeTextOnly:
            // 纯文本模式，仅解析安全样式
            if (attribute == XZMLAttributeSecurity) {
                return XZMLParserSecurityAttribute(self, value);
            }
            return XZMLReadingModeNormal;
            
        case XZMLReadingModeSkipElement:
            // Parser 不会运行于此模式（DSL 在此状态下不再查询属性），防御性返回，避免未定义返回值被误判为 TextOnly/SkipElement 触发错误分支
            return XZMLReadingModeNormal;
    }
    return XZMLReadingModeNormal;
}

- (void)foundText:(NSString *)text fragment:(NSUInteger)fragment {
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
    
    if (_mode == XZMLReadingModeTextOnly) {
        [_string appendString:XZMLParserText(computeStyle, text)];
    } else {
        NSString * const resultText = XZMLParserText(computeStyle, text);
        // 内部 XZML 属性（如安全替换标记/次数）仅用于解析阶段，不能泄漏到结果富文本；
        // 且不能原地删除（同层多个文本片段会复用 computeStyle），需拷贝后过滤。
        NSMutableDictionary *attributes = computeStyle.mutableCopy;
        for (NSAttributedStringKey key in attributes.allKeys) {
            if ([key hasPrefix:@"XZML"]) {
                [attributes removeObjectForKey:key];
            }
        }
        NSAttributedString * const attributedString = [[NSAttributedString alloc] initWithString:resultText attributes:attributes];
        [_attributedString appendAttributedString:attributedString];
    }
}

- (void)didEndElement {
    [_elementStyles removeLastObject];
    [_computeStyles removeLastObject];
    _currentStyle = _elementStyles.lastObject;
}

@end

/// 字体名缩写。
static NSMutableDictionary<NSString *, NSString *> *_fontNameAbbreviations = nil;

@implementation XZMLParser (XZMLExtendedParser)

+ (void)setFontName:(NSString *)fontName forAbbreviation:(NSString *)abbreviation {
    NSAssert(NSThread.isMainThread, @"请在程序初始化时（主线程）执行此方法");
    NSParameterAssert(abbreviation.length > 0);
    if (_fontNameAbbreviations == nil) {
        _fontNameAbbreviations = [NSMutableDictionary dictionary];
    }
    _fontNameAbbreviations[abbreviation] = fontName;
}

+ (NSString *)fontNameForAbbreviation:(NSString *)abbreviation {
    return _fontNameAbbreviations[abbreviation] ?: abbreviation;
}

@end


#pragma mark - 样式解析

FOUNDATION_STATIC_INLINE UIColor *XZMLForegroundColorFromContext(XZMLParser * const __unsafe_unretained parser, NSString *value) {
    // 使用指定值
    UIColor *color = rgba(value, nil);
    if (color) {
        return color;
    }
    // 使用继承值
    if (parser->_currentStyle[NSForegroundColorAttributeName]) {
        return nil;
    }
    // 使用预设值
    color = parser->_defaultStyle[XZMLForegroundColorAttributeName];
    if (color) {
        return color;
    }
    // 使用默认值
    return parser->_defaultStyle[NSForegroundColorAttributeName];
}

XZMLReadingMode XZMLParserColorAttribute(XZMLParser * const __unsafe_unretained parser, NSString *value) {
    if ([value containsString:@"@"]) {
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        
        UIColor * const foregroundColor = XZMLForegroundColorFromContext(parser, values[0]);
        if (foregroundColor) {
            parser->_currentStyle[NSForegroundColorAttributeName] = foregroundColor;
        }
        
        UIColor * const backgroundColor = rgba(values[1], nil);
        if (backgroundColor) {
            parser->_currentStyle[NSBackgroundColorAttributeName] = backgroundColor;
        }
    } else {
        UIColor *foregroundColor = XZMLForegroundColorFromContext(parser, value);
        if (foregroundColor != nil) {
            parser->_currentStyle[NSForegroundColorAttributeName] = foregroundColor;
        }
    }
    return XZMLReadingModeNormal;
}

FOUNDATION_STATIC_INLINE UIFont * _Nullable XZMLFontFromContext(XZMLParser * const __unsafe_unretained parser, NSString * _Nullable nameString, NSString * _Nullable sizeString) {
    NSString *name = [XZMLParser fontNameForAbbreviation:nameString];
    CGFloat   size = sizeString.doubleValue;
    UIFont   *font = nil;
    
    // 没有指定字号
    if (isnan(size) || size <= 0) {
        // 使用继承值
        font = parser->_currentStyle[NSFontAttributeName];
        if (font == nil) {
            // 使用默认值
            font = parser->_defaultStyle[NSFontAttributeName];
            if (font == nil) {
                // 使用预设值
                font = parser->_defaultStyle[XZMLFontAttributeName];
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
        font = parser->_currentStyle[NSFontAttributeName];
        if (font) {
            if (font.pointSize == size) {
                return nil;
            }
            return [font fontWithSize:size];
        }
        // 使用预设值
        font = parser->_defaultStyle[XZMLFontAttributeName];
        if (font) {
            return [font fontWithSize:size];
        }
        // 使用默认值
        font = parser->_defaultStyle[NSFontAttributeName];
        if (font) {
            return [font fontWithSize:size];
        }
        // 使用系统值
        return [UIFont systemFontOfSize:size];
    }
    
    return font;
}

XZMLReadingMode XZMLParserFontAttribute(XZMLParser * const __unsafe_unretained parser, NSString *value) {
    if ([value containsString:@"@"]) {
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        
        UIFont * font = XZMLFontFromContext(parser, values[0], values[1]);
        if (font) {
            parser->_currentStyle[NSFontAttributeName] = font;
        }
        
        // 字体基准线调整
        if (values.count > 2) {
            CGFloat const baselineOffset = values[2].floatValue;
            if (baselineOffset != 0) {
                parser->_currentStyle[NSBaselineOffsetAttributeName] = @(baselineOffset);
            }
        }
    } else {
        // 仅指定了一个参数，作为字体名使用
        UIFont * font = XZMLFontFromContext(parser, value, nil);
        if (font) {
            parser->_currentStyle[NSFontAttributeName] = font;
        }
    }
    return XZMLReadingModeNormal;
}

FOUNDATION_STATIC_INLINE XZMLDecorationType XZMLDecorationTypeFromContext(XZMLParser * const __unsafe_unretained parser, NSString *typeString) {
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
    if (parser->_currentStyle[NSStrikethroughStyleAttributeName]) {
        return XZMLDecorationTypeStrikethrough;
    }
    if (parser->_currentStyle[NSUnderlineStyleAttributeName]) {
        return XZMLDecorationTypeUnderline;
    }
    // 预设值
    if (parser->_defaultStyle[XZMLDecorationAttributeName]) {
        return [parser->_defaultStyle[XZMLDecorationAttributeName] unsignedIntegerValue];
    }
    // 默认值
    if (parser->_defaultStyle[NSStrikethroughStyleAttributeName]) {
        return XZMLDecorationTypeStrikethrough;
    }
    if (parser->_defaultStyle[NSUnderlineStyleAttributeName]) {
        return XZMLDecorationTypeUnderline;
    }
    // 系统值：有修饰标记时，默认为添加删除线
    return XZMLDecorationTypeStrikethrough;
}

/// 暂不支持通过 parser->_defaultStyle 提供默认值。
XZMLReadingMode XZMLParserDecorationAttribute(XZMLParser * const __unsafe_unretained parser, NSString *value) {
    XZMLDecorationType type = 0;                         // 样式 0 删除线 1 下划线
    NSUnderlineStyle  style = NSUnderlineStyleSingle;    // 线型 0 单线条 1 双线条 2 粗线条
    UIColor *         color = nil;                       // 颜色 _ 默认色 x 指定色
    
    if ([value containsString:@"@"]) {
        NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
        
        type = XZMLDecorationTypeFromContext(parser, values[0]);
        
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
        type = XZMLDecorationTypeFromContext(parser, value);
    }
    
    if (type == 1) {
        parser->_currentStyle[NSUnderlineStyleAttributeName] = @(style);
        if (color != nil) {
            parser->_currentStyle[NSUnderlineColorAttributeName] = color;
        }
    } else {
        parser->_currentStyle[NSStrikethroughStyleAttributeName] = @(style);
        if (color != nil) {
            parser->_currentStyle[NSStrikethroughColorAttributeName] = color;
        }
        if (@available(iOS 10.3, *)) {
            // 解决 iOS 10.3 删除线不展示的问题
            if (parser->_currentStyle[NSBaselineOffsetAttributeName] == nil) {
                parser->_currentStyle[NSBaselineOffsetAttributeName] = @(0);
            }
        }
    }
    
    return XZMLReadingModeNormal;
}

XZMLReadingMode XZMLParserSecurityAttribute(XZMLParser * const __unsafe_unretained parser, NSString *value) {
    // 只有安全模式下，才需要解析安全字符样式
    if ([parser->_defaultStyle[XZMLSecurityModeAttributeName] boolValue]) {
        if ([value containsString:@"@"]) {
            NSArray<NSString *> * const values = [value componentsSeparatedByString:@"@"];
            
            NSString * const mark   = values[0];
            NSInteger  const repeat = values[1].integerValue;
            
            // 重复次数默认值：替换符为单字符，默认重复次数与文本长度相同；替换符为多字符，默认重复次数为 1 次
            if (repeat <= 0) {
                switch (mark.length) {
                    case 0:
                        parser->_currentStyle[XZMLSecurityMarkAttributeName] = @"*";
                        break;
                    case 1:
                        parser->_currentStyle[XZMLSecurityMarkAttributeName] = mark;
                        break;
                    default:
                        parser->_currentStyle[XZMLSecurityMarkAttributeName] = mark;
                        if ([mark rangeOfComposedCharacterSequenceAtIndex:0].length < mark.length) {
                            parser->_currentStyle[XZMLSecurityRepeatAttributeName] = @(1);
                            return XZMLReadingModeSkipElement;
                        }
                        break;
                }
                return XZMLReadingModeTextOnly;
            }
            
            // 设置了重复次数，元素及子元素的就不需要解析了
            parser->_currentStyle[XZMLSecurityMarkAttributeName] = mark.length > 0 ? mark : @"*";
            parser->_currentStyle[XZMLSecurityRepeatAttributeName] = @(repeat);
            return XZMLReadingModeSkipElement;
        }
        
        // 仅指定了替换字符
        if (value.length > 0) {
            parser->_currentStyle[XZMLSecurityMarkAttributeName] = value;
            if ([value rangeOfComposedCharacterSequenceAtIndex:0].length < value.length) {
                parser->_currentStyle[XZMLSecurityRepeatAttributeName] = @(1);
                return XZMLReadingModeSkipElement;
            }
        } else {
            parser->_currentStyle[XZMLSecurityMarkAttributeName] = @"*";
        }
        
        return XZMLReadingModeTextOnly;
    }
    // 非安全模式，不需要解析安全属性
    return XZMLReadingModeNormal;
}

XZMLReadingMode XZMLParserLinkAttribute(XZMLParser * const __unsafe_unretained parser, NSString *value) {
    if (value.length == 0) {
        // 继承值
        if (parser->_currentStyle[NSLinkAttributeName]) {
            return XZMLReadingModeNormal;
        }
        // 预设值
        value = parser->_defaultStyle[XZMLLinkAttributeName];
        if (value) {
            parser->_currentStyle[NSLinkAttributeName] = value;
            return XZMLReadingModeNormal;
        }
        // 无法解析
        return XZMLReadingModeNormal;
    }
    
    BOOL    const isFilePath = [value hasPrefix:@"/"] || [value hasPrefix:@"~"];
    NSURL * const url = isFilePath ? [NSURL fileURLWithPath:value] : [NSURL URLWithString:value];
    if (url != nil) {
        parser->_currentStyle[NSLinkAttributeName] = url;
    } else {
        parser->_currentStyle[NSLinkAttributeName] = value;
    }
    
    return XZMLReadingModeNormal;
}

FOUNDATION_STATIC_INLINE CGFloat XZMLLineHeightFromContext(XZMLParser * const __unsafe_unretained parser, CGFloat lineHeight) {
    if (!isnan(lineHeight) && lineHeight > 0) {
        return lineHeight;
    }
    // 继承值
    NSParagraphStyle *parentStyle = parser->_currentStyle[NSParagraphStyleAttributeName];
    if (parentStyle.minimumLineHeight > 0) {
        return parentStyle.minimumLineHeight;
    }
    // 预设值
    lineHeight = [parser->_defaultStyle[XZMLLineHeightAttributeName] doubleValue];
    if (lineHeight > 0) {
        return lineHeight;
    }
    // 默认值
    NSParagraphStyle *defaultStyle = parser->_defaultStyle[NSParagraphStyleAttributeName];
    return defaultStyle.minimumLineHeight;
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

XZMLReadingMode XZMLParserParagraphAttribute(XZMLParser * const __unsafe_unretained parser, NSString *value) {
    NSMutableParagraphStyle * const style = [parser->_currentStyle[NSParagraphStyleAttributeName] mutableCopy]
        ?: [parser->_defaultStyle[NSParagraphStyleAttributeName] mutableCopy]
        ?: [[NSMutableParagraphStyle alloc] init];
    
    NSUInteger const length = value.length;
    
    // 未指定行高
    if (length == 0) {
        style.minimumLineHeight = XZMLLineHeightFromContext(parser, 0);
        parser->_currentStyle[NSParagraphStyleAttributeName] = style;
        return XZMLReadingModeNormal;
    }
    
    NSRange    range = NSMakeRange(0, 0);
    NSUInteger index = 0;
    
    while (true) {
        // 已经遍历了整个字符串
        if (index >= length) {
            // 如果还有未处理字符，则认为是行高值
            if (range.length > 0) {
                CGFloat const number = [[value substringWithRange:range] doubleValue];
                style.minimumLineHeight = XZMLLineHeightFromContext(parser, number);
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
                style.minimumLineHeight = XZMLLineHeightFromContext(parser, CGFloatMakeParagraphValue(value, &range));
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
                // 钳制到 NSTextAlignmentLeft(0) ~ NSTextAlignmentRight(2)，避免越界枚举导致渲染行为未定义
                style.alignment = MIN(MAX(NSIntegerMakeParagraphValue(value, &range), 0), 2);
                break;
            }
            case 'K':
            case 'k': {
                // 钳制到 UIKit NSLineBreakMode 合法范围 0 ~ 5（NSLineBreakByTruncatingMiddle）
                style.lineBreakMode = MIN(MAX(NSIntegerMakeParagraphValue(value, &range), 0), 5);
                break;
            }
            case 'S':
            case 's': {
                style.lineSpacing = CGFloatMakeParagraphValue(value, &range);
                break;
            }
            case 'W':
            case 'w': {
                // 钳制到 NSWritingDirectionRightToLeft(-1) ~ NSWritingDirectionNatural(1)
                style.baseWritingDirection = MIN(MAX(NSIntegerMakeParagraphValue(value, &range), -1), 1);
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
    
    parser->_currentStyle[NSParagraphStyleAttributeName] = style;
    
    return XZMLReadingModeNormal;
}

/// attributes 可能包含 XZMLSecurityMarkAttributeName/XZMLSecurityRepeatAttributeName 键
NSString *XZMLParserText(NSDictionary<NSAttributedStringKey, id> *attributes, NSString *text) {
    NSString * const mark = attributes[XZMLSecurityMarkAttributeName];
    if (mark) {
        NSInteger repeat = [attributes[XZMLSecurityRepeatAttributeName] integerValue];
        if (repeat <= 0) {
            // 默认与被隐藏文本字符数相同，与输入长度成正比，可接受
            repeat = (NSInteger)text.length;
        }
        // repeat 可能来自服务端下发的 XZML，钳制上限，避免构造超大字符串打爆内存
        repeat = MIN(repeat, XZMLSecurityRepeatLimit);
        return [mark stringByPaddingToLength:mark.length * repeat withString:mark startingAtIndex:0];
    }
    return text;
}


