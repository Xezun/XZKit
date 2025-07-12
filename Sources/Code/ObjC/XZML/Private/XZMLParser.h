//
//  XZMLParser.h
//  XZKit
//
//  Created by Xezun on 2021/10/18.
//

#import <Foundation/Foundation.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMLDSL.h>
#else
#import "XZMLDSL.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// @attention 新增枚举请同时调整 NSCharacterSet.XZMLReservedCharacterSet 字符集。
enum : XZMLAttribute {
    
    /// 颜色样式：文本前景色、文本背景色。颜色使用十六进制 RGB/RGBA 值。
    ///
    /// 属性值支持一下格式：
    /// - `#`，表示设置前景色为预设值
    /// - `RGB#`，表示设置前景色为 RGB 值
    /// - `@RGB#`，表示仅设置前景色为预设值，背景色为 RGB 值
    /// - `RGB@#`，表示设置前景色为 RGB 值，背景色为预设值
    /// - `RGB@RGB#`，表示设置前景色为 RGB 值，背景色为预设 RGB 值
    /// - `@#`，表示设置前景色和背景色都为预设值
    ///
    /// - Note: 预设值：通过键XZMLForegroundColorAttributeName在`attributes`参数中预设的值。
    XZMLAttributeColor = '#',
    
    /// 字体样式：字体、字号、偏移。
    ///
    /// 格式：字体、@字号、字体@字号、字体@字号@基准线偏移
    /// 
    /// 推荐使用 `+setFoneName:forAbbreviation:` 方法注册字体名缩写，以减少`XZML`的长度。
    ///
    /// 字体缩写约定：
    /// - 1、数字常规：DR、D
    /// - 2、数字粗体：DB、B
    /// - 3、文本细体：TL、L
    /// - 4、文本常规：TR、T
    /// - 5、文本中等：TM、M
    /// - 6、文本中粗：TS、S
    XZMLAttributeFont = '&',
    
    /// 文本修饰样式。
    /// 格式：样式、样式@线型、样式@线型@颜色
    /// @discussion【样式】0，删除线（默认）；1，下划线
    /// @discussion【线型】0，单线条（默认）；1，双线条；2，粗线条
    /// @discussion【颜色】RGB/RGBA 颜色值，默认与文本颜色相同
    /// @attention 文本修饰，包含多个样式，因此使用属性默认值解析，设置文本修饰样式，只会覆盖上层相同样式的设置。
    /// @discussion 比如设置删除线样式，上层设置删除线样式会被覆盖，但是上层的下划线样式会保留。
    /// @discussion 可以使用两个`$`可同时指定下划线和删除线。
    XZMLAttributeDecoration = '$',
    
    /// 安全文本样式：用占位字符替代目标文本的样式。
    /// 格式：替代符号、@重复次数、替代符号@重复次数。
    /// @discussion 替代符号默认为`*`星号，重复次数为4次，即4个`*`星号。
    /// @discussion 安全模式替换时，忽略所有子元素。
    /// @attention 在安全模式下，星号`*`之后样式、文本、子元素都会被忽略，因此通过`*`的位置控制替代字符的样式。
    /// @discussion 比如将删除线样式放在`*`之后，安全模式下，替代字符不会展示删除线。
    XZMLAttributeSecurity = '*',
    
    /// 超链接样式。
    /// @discussion 将使用 NSURL 或 NSString 创建富文本 NSLinkAttributeName 属性。
    XZMLAttributeLink = '~',
    
    /// 段落样式。
    /// @discussion 支持的段落属性包括：
    /// @discussion H：minimumLineHeight 最小行高，默认
    /// @discussion M：maximumLineHeight 最大行高
    /// @discussion X：lineHeightMultiple 多倍行高
    /// @discussion A：alignment 对齐方式，与枚举值对应
    /// @discussion K：lineBreakMode 断行方式，与枚举值对应
    /// @discussion S：lineSpacing 行间距（行与行之间的距离）
    /// @discussion W：baseWritingDirection 书写方向，与枚举值对应
    /// @discussion F：firstLineHeadIndent 首行缩进
    /// @discussion I：headIndent 头缩进
    /// @discussion T：tailIndent 尾缩进
    /// @discussion P：paragraphSpacing 段间距
    /// @discussion B：paragraphSpacingBefore 段前距
    /// @discussion 格式：[值][标记]
    /// @discussion 如果未指定样式标记符，则默认为最小行高`H`样式。示例：
    /// @code
    /// NSString *XZML1 = @"<20H30M^Paragraph>";   // 最小行高 20.0 point 最大行高 30.0 point
    /// NSString *XZML2 = @"<1.5X^Paragraph>";     // 1.5 倍行高
    /// NSString *XZML3 = @"<1.5X^Paragraph>";     // 1.5 倍行高
    /// NSString *XZML4 = @"<34F20X^Paragraph>";   // 首行缩进 34.0 point 行高 20.0 point
    /// @endcode
    /// @discussion 由于样式标记的存在，样式间隔符`@`是可选的，样式顺序也是任意的。
    XZMLAttributeParagraph = '^',
    
};

typedef struct XZMLParserContext {
    __unsafe_unretained NSMutableDictionary<NSAttributedStringKey, id> * _Nonnull  elementAttributes;
    __unsafe_unretained NSDictionary<NSAttributedStringKey, id>        * _Nullable defaultAttributes;
} XZMLParserContext;

@protocol XZMLParser <NSObject>

/// 解析 XZML 为富文本。
/// @discussion 默认属性中，
/// @discussion 1、`NS-`属性，为所有文字默认属性；
/// @discussion 2、`XZML-`属性，为`XZML`元素样式解析时的默认值应用于XZML文本，并覆盖同名的默认属性。
/// @param XZMLString XZML
/// @param attributedString 接收 XZML 富文本的对象
/// @param attributes 默认属性 attributes
+ (void)attributedString:(NSMutableAttributedString *)attributedString parse:(NSString *)XZMLString attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes;

/// 将 XZML 去掉样式，转为纯文本。
/// @param XZMLString XZML 字符串
/// @param string 接收 XZML 中纯文本的对象
/// @param attributes 默认属性，比如在安全模式下，会得到被替换的字符
+ (void)string:(NSMutableString *)string parse:(NSString *)XZMLString attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes;

@end

/// 解析 XZML 的对象，不需要实例化。
@interface XZMLParser : NSObject <XZMLParser>

@property (class, nonatomic, null_resettable) Class<XZMLParser> defaultParser;

// MARK: - 公开方法

/// 解析 XZML 为富文本对象。
/// @param XZMLString XZML 字符串
/// @param attributes 默认属性
+ (NSMutableAttributedString *)parse:(NSString *)XZMLString attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes;

// MARK: - 子类可通过重写如下方法来自定义解析过程

/// 判断字符 character 是否为元素起始符。
/// 1. 如果 character 是元素起始符号，那么应返回该元素的结束符号。
/// 2. 返回 XZMLElementNotAnElement 表示这不是一个元素开始符号。
/// - Parameter character: 待判断的字符
+ (XZMLElement)shouldBeginElement:(char)character;

/// 判断字符 character 是否为元素 element 的样式属性符号。
/// - Parameters:
///   - element: 当前正识别中的元素
///   - character: 待判断是否为样式标记符的字符
+ (BOOL)element:(XZMLElement)element shouldBeginAttribute:(char)character;

/// 元素解析开始。
/// - Parameters:
///   - element: 被解析的元素的标记
///   - attributes: 元素的样式属性
+ (void)didBeginElement:(XZMLElement)element context:(const XZMLParserContext)context;

/// 解析出样式。
/// - Note: 在识别属性的过程中，特定的属性，可以提前终止元素的解析，比如安全字符替换。
/// - Parameters:
///   - element: 识别中的元素
///   - attribute: 已识别的样式
///   - value: 识别出的样式值
///   - attributes: 元素的样式属性
/// - Returns: 当前元素后续的解析方式
+ (XZMLReadingOptions)element:(XZMLElement)element foundAttribute:(XZMLAttribute)attribute value:(NSString *)value context:(const XZMLParserContext)context;

/// 解析出文本。
/// - Parameters:
///   - element: 当前识别中的元素，也可能是非元素文本。
///   - text: 已识别出的文本
///   - fragment: 文本可能会被子元素分割成多段，该参数表明当前文本是其中的是第几段
///   - attributes: 富文本属性
/// - Returns: 返回的富文本将拼接到结果中
+ (nullable NSAttributedString *)element:(XZMLElement)element foundText:(NSString *)text fragment:(NSUInteger)fragment attributes:(nullable NSDictionary<NSAttributedStringKey,id> *)attributes;

/// 元素解析结束。
/// - Parameter element: 当前识别中的元素
/// - Parameter attributes: 元素的样式属性
+ (void)didEndElement:(XZMLElement)element context:(const XZMLParserContext)context;

@end

@interface XZMLParser (XZMLExtendedParser)

/// 设置字体名在 XZML 中的缩写。
/// @param fontName 字体名
/// @param abbreviation 字体名缩写
+ (void)setFontName:(nullable NSString *)fontName forAbbreviation:(NSString *)abbreviation;

/// 通过缩写获取字体名，如果不是缩写名，返回 abbreviation 自身。
/// @param abbreviation 字体名缩写
+ (NSString *)fontNameForAbbreviation:(NSString *)abbreviation;

@end

NS_ASSUME_NONNULL_END
