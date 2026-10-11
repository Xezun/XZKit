//
//  XZMLDSL.h
//  XZKit
//
//  Created by Xezun on 2021/10/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XZMLParser;

/// XZML 语法解析函数。
/// - Parameters:
///   - XZMLString: XZML 字符串
///   - parser: 接收语法分析结果的解析器对象
//FOUNDATION_EXPORT void XZMLDSL(NSString *XZMLString, XZMLParser *parser);
FOUNDATION_EXPORT void XZMLDSLWithAttributedString(NSString *XZMLString, NSMutableAttributedString *attributedString, NSDictionary<NSAttributedStringKey, id> * _Nullable attributes);
FOUNDATION_EXPORT void XZMLDSLWithString(NSString *XZMLString, NSMutableString *string, NSDictionary<NSAttributedStringKey, id> * _Nullable attributes);

/// XZML 样式标记字符，使用 ASCII 特殊标点符号作为标记字符。
/// @attention 新增枚举请同时调整 NSCharacterSet.XZMLReservedCharacterSet 字符集。
typedef char XZMLAttribute NS_TYPED_EXTENSIBLE_ENUM;

enum : XZMLAttribute {
    /// 颜色样式：文本前景色、文本背景色。颜色使用十六进制 RGB/RGBA 值。
    ///
    /// 属性值支持以下格式（`@` 之前为前景色，之后为背景色）：
    /// - `#`，表示设置前景色为预设值
    /// - `AAA#`，表示设置前景色为 AAA 值
    /// - `@BBB#`，表示仅设置前景色为预设值，背景色为 BBB 值
    /// - `AAA@#`，表示设置前景色为 AAA 值，背景色为预设值
    /// - `AAA@BBB#`，表示设置前景色为 AAA 值，背景色为 BBB 值
    /// - `@#`，表示设置前景色为预设值，背景色为预设值
    ///
    /// - Note: 预设值：通过键 XZMLForegroundColorAttributeName 在 `attributes` 参数中预设的值。
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
    /// @discussion 替代符号默认为`*`星号；未指定重复次数时，默认与被替代文本的字符数相同（等长遮蔽）。
    /// @discussion 安全模式替换时，忽略所有子元素。
    /// @attention 在安全模式下，星号`*`之后样式、文本、子元素都会被忽略，因此通过`*`的位置控制替代字符的样式。
    /// @discussion 比如将删除线样式放在`*`之后，安全模式下，替代字符不会展示删除线。
    XZMLAttributeSecurity = '*',
    
    /// 超链接样式。
    /// @discussion 将使用 NSURL 或 NSString 创建富文本 NSLinkAttributeName 属性。
    XZMLAttributeLink = '~',
    
    /// 段落样式。
    /// @discussion 支持的段落属性包括：
    /// @discussion L：minimumLineHeight 最小行高，默认
    /// @discussion H：maximumLineHeight 最大行高
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
    /// NSString *XZML1 = @"<20L30H^Paragraph>";   // 最小行高 20.0 point 最大行高 30.0 point
    /// NSString *XZML2 = @"<1.5X^Paragraph>";     // 1.5 倍行高
    /// NSString *XZML3 = @"<1.5X^Paragraph>";     // 1.5 倍行高
    /// NSString *XZML4 = @"<34F20X^Paragraph>";   // 首行缩进 34.0 point 行高 20.0 point
    /// @endcode
    /// @discussion 由于样式标记的存在，样式间隔符`@`是可选的，样式顺序也是任意的。
    XZMLAttributeParagraph = '^',
    
};

NS_ASSUME_NONNULL_END
