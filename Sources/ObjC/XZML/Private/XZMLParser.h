//
//  XZMLParser.h
//  XZKit
//
//  Created by Xezun on 2021/10/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// XZML 样式标记字符，使用 ASCII 特殊标点符号作为标记字符。
/// @attention 新增枚举请同时调整 NSCharacterSet.XZMLReservedCharacterSet 字符集。
typedef char XZMLAttribute NS_TYPED_EXTENSIBLE_ENUM;

enum : XZMLAttribute {
    /// 颜色样式：文本前景色、文本背景色。颜色使用十六进制 RGB/RGBA 值。
    ///
    /// 属性值支持以下格式（`@` 之前为前景色，之后为背景色）：
    /// - `#`，表示设置前景色为预设值
    /// - `RGB#`，表示设置前景色为 RGB 值
    /// - `@RGB#`，表示仅设置前景色为预设值，背景色为 RGB 值
    /// - `RGB@#`，表示设置前景色为 RGB 值，背景色不设置
    /// - `RGB@RGB#`，表示设置前景色为 RGB 值，背景色为 RGB 值
    /// - `@#`，表示设置前景色为预设值，背景色不设置
    ///
    /// - Note: 预设值：通过键XZMLForegroundColorAttributeName在`attributes`参数中预设的值。
    /// - Note: 背景色仅支持直接指定的 RGB 值，不支持继承和预设，值为空时不设置背景色。
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

@class NSJSONSerialization, NSXMLParser;

/// 解析 XZML 的对象。
///
/// 非线程安全类型，多线程使用，需考虑并发冲突问题。
@interface XZMLParser : NSObject {
    @package
    IMP _isAttributeCharacter;
    IMP _didBeginElement;
    IMP _foundAttribute;
    IMP _foundText;
    IMP _didEndElement;
}

/// 默认解析器的类型。
///
/// 使用 Foundation 原生类的 XZML 拓展方法时，默认使用此类型创建解析器。
@property (class, nonatomic) Class defaultParserClass;

/// 用于主线程的 XZML 解析器。
///
/// 此属性不是线程安全的，请仅在主线程中使用。
///
/// 默认使用 `defaultParserClass` 初始化解析器，自定义 XZML 解析器，建议在程序初始化时就设置 `defaultParserClass`。
///
/// - UIKit 与 Foundation 原生类的 XZML 拓展，均使用 `defaultParserClass` 每次新建解析器，不经过此解析器。
/// - 此解析器作为可选的共享实例提供，供需要避免反复创建解析器的主线程场景使用。
@property (class, nonatomic) XZMLParser *mainParser;

- (NSMutableAttributedString *)attributedStringWithXZMLString:(NSString *)XZMLString attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes;
- (void)attributedString:(NSMutableAttributedString *)attributedString appendXZMLString:(NSString *)XZMLString attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes;

- (NSMutableString *)stringWithXZMLString:(NSString *)XZMLString attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes;
- (void)string:(NSMutableString *)string appendXZMLString:(NSString *)XZMLString attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes;

// 以下属性只有在解析过程中才有效。
//
// 解析流程约定：
// - 顶层内容按伪容器元素解析：无论字符串是否以元素开头，解析开始与结束都会各调用一次
//   `didBeginElement`/`didEndElement`，顶层纯文本也通过 `foundText:fragment:` 上报
//   （此时 `currentAttributes` 为空字典）。
// - 顶层不识别样式标记，`foundAttribute:value:` 只在真实元素内部被调用。
// - `fragment` 是被同级子元素分隔的文本片段序号，在每个元素内从 0 开始。
// - 元素嵌套深度上限为 16 层，超出部分降级为普通文本，不再解析样式。

@property (nonatomic, readonly) XZMLReadingMode mode;
@property (nonatomic, readonly, nullable) NSMutableAttributedString *attributedString;
@property (nonatomic, readonly, nullable) NSMutableString *string;
@property (nonatomic, readonly) NSMutableDictionary<NSAttributedStringKey, id>    *currentAttributes;
@property (nonatomic, readonly, nullable) NSDictionary<NSAttributedStringKey, id> *defaultAttributes;

/// 判断字符是否为 XZML 样式属性字符。
/// - Parameter character: 待判断的字符
- (BOOL)isAttributeCharacter:(char)character;
/// 当 XZMLParser 开始解析一个新的 XZML 元素时，此方法会被调用。
- (void)didBeginElement;
/// 当 XZMLParser 解析出样式时，此方法会被调用。
///
/// 在此方法中，可根据元素的样式，返回当前元素，后续的解析模式。
- (XZMLReadingMode)foundAttribute:(XZMLAttribute)attribute value:(NSString *)value;
- (void)foundText:(NSString *)text fragment:(NSUInteger)fragment;
- (void)didEndElement;

@end

@interface XZMLParser (XZMLExtendedParser)

/// 设置字体名在 XZML 中的缩写。
///
/// 非线程安全方法，在使用 XZMLParser 实例前配置字体缩写，以避免并发问题。
///
/// @param fontName 字体名
/// @param abbreviation 字体名缩写
+ (void)setFontName:(nullable NSString *)fontName forAbbreviation:(NSString *)abbreviation;

/// 通过缩写获取字体名，如果不是缩写名，返回 abbreviation 自身。
///
/// @param abbreviation 字体名缩写
+ (NSString *)fontNameForAbbreviation:(NSString *)abbreviation;

@end

NS_ASSUME_NONNULL_END
