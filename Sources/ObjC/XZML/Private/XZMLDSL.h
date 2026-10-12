//
//  XZMLDSL.h
//  XZKit
//
//  Created by Xezun on 2021/10/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 解析 XZML 字符串，将样式化的富文本追加到 `attributedString` 末尾。
///
/// 解析过程中的非法输入均降级处理、不抛异常：非字符串与空串不产生任何内容；
/// 无法表示为 UTF-8 的字符串（如含未配对的代理项）不解析，不产生任何内容。
///
/// - Parameters:
///   - XZMLString: XZML 字符串
///   - attributedString: 接收解析结果的富文本对象，内容由本函数追加
///   - attributes: 默认样式与预设样式，可为 nil，详见 `XZMLAttributeName` 的取值优先级说明
FOUNDATION_EXPORT void XZMLDSLWithAttributedString(NSString *XZMLString, NSMutableAttributedString *attributedString, NSDictionary<NSAttributedStringKey, id> * _Nullable attributes);

/// 解析 XZML 字符串，仅提取纯文本并追加到 `string` 末尾，丢弃除安全模式以外的所有样式。
///
/// 安全模式（`XZMLSecurityModeAttributeName` 为 YES）下仍会执行星号遮蔽替换。
///
/// - Parameters:
///   - XZMLString: XZML 字符串
///   - string: 接收解析结果的字符串，内容由本函数追加
///   - attributes: 默认样式与预设样式，可为 nil
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
    /// - Note: 前景色与背景色共用同一套取值优先级，仅各自的键不同：
    ///   指定值 → 继承值 → 预设值（`XZMLForegroundColorAttributeName` / `XZMLBackgroundColorAttributeName`）
    ///   → 默认值（`NSForegroundColorAttributeName` / `NSBackgroundColorAttributeName`）。
    /// - Note: 子属性值为空或非法时不写入，沿用上述优先级取到的值，不会重置为透明色。
    /// - Note: 不含 `@` 时只设置前景色，背景色保持原样（继承值或不变）。
    XZMLAttributeColor = '#',
    
    /// 字体样式：字体、字号、偏移。
    ///
    /// 格式：字体、@字号、字体@字号、字体@字号@基准线偏移
    ///
    /// 未注册缩写的名称直接作为字体名查找，因此 `<宋体&>`、`<Helvetica@20&>` 这类写法无需任何注册即可生效。
    ///
    /// 缩写需由使用方通过 `XZMLSetFontAbbreviations()` 注册，本组件不提供内置缩写表。业务建议的缩写约定：
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
    /// @discussion 此处“字符数”按 UTF-16 代码单元计数，代理对（如 emoji）计为 2。
    /// @attention 重复次数上限为 64，超过部分被钳制，因此长度超过 64 的文本不再是等长遮蔽。
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
    /// @discussion A：alignment 对齐方式，取值 NSTextAlignmentLeft(0) ~ NSTextAlignmentNatural(4)
    /// @discussion K：lineBreakMode 断行方式，取值 NSLineBreakByWordWrapping(0) ~ NSLineBreakByTruncatingMiddle(5)
    /// @discussion S：lineSpacing 行间距（行与行之间的距离）
    /// @discussion W：baseWritingDirection 书写方向，取值 NSWritingDirectionNatural(-1) ~ NSWritingDirectionRightToLeft(1)
    /// @discussion F：firstLineHeadIndent 首行缩进
    /// @discussion I：headIndent 头缩进
    /// @discussion T：tailIndent 尾缩进
    /// @discussion P：paragraphSpacing 段间距
    /// @discussion B：paragraphSpacingBefore 段前距
    /// @discussion 格式：[值][标记]
    /// @discussion 如果末尾存在未被任何标记符消耗的值，则按最小行高（`L`）处理。
    /// @discussion `A`、`K`、`W` 仅接受上表范围内的枚举值，越界值被忽略（不钳制），段落样式沿用继承值或默认值。
    /// @discussion 标记符前没有任何值时，该标记符被忽略，不会把继承/预设的段落属性覆盖为 0。
    /// @discussion 行高类属性（`L`）的值非正数时不写入，沿用继承值或预设值。
    /// @discussion 示例：
    /// @code
    /// NSString *XZML1 = @"<20L30H^Paragraph>";   // 最小行高 20.0 point 最大行高 30.0 point
    /// NSString *XZML2 = @"<1.5X^Paragraph>";     // 1.5 倍行高
    /// NSString *XZML3 = @"<24^Paragraph>";       // 未指定标记符，最小行高 24.0 point
    /// NSString *XZML4 = @"<34F20X^Paragraph>";   // 首行缩进 34.0 point 多倍行高 20.0
    /// @endcode
    /// @discussion 由于样式标记的存在，样式间隔符`@`是可选的，样式顺序也是任意的。
    XZMLAttributeParagraph = '^',
    
};

NS_ASSUME_NONNULL_END
