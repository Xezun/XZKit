//
//  XZMLDefines.h
//  XZML
//
//  Created by Xezun on 2024/10/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 通过 ``XZMLAttributeName`` 键，指定 XZML 中元素的预设样式。
///
/// ### 样式值
///
/// - 指定值：在 XZML 中指定的样式值。
/// - 继承值：从父元素继承的样式值。
/// - 预设值：在 attributes 参数中，通过 XZMLAttributeName 键预设的样式值。
/// - 默认值：在 attributes 参数中，通过 NSAttributedStringKey 键提供的样式值。
/// - 系统值：在无法确定时，兜底使用的值，但不是所有样式都有系统值。
///
/// ### 样式属性
///
/// 样式可能会有多个子属性，比如字体样式，包含字体名和字体大小两个子属性，在 XZML 中用 `:` 符号分隔不同的子属性。
///
/// ### 取值优先级
///
/// - 直接写在 XZML 中的**指定值**和**继承值**优先级最高。
/// - 在 `attributes` 参数中，通过 `XZMLAttributeName` 提供的**预设值**优先级其次。
/// - 在 `attributes` 参数中，通过 `NSAttributedStringKey` 提供的**默认值**优先级再次。
/// - 系统默认值，仅部分样式支持，比如无法推断字体名时，使用 `systemFont` 字体。
///
/// ```objc
/// [[NSAttributedString alloc] initWithXZML:@"<F00#&XZML> is designed for rich text." attributes:@{
///     XZMLFontAttributeName: [UIFont systemFontOfSize:15],
///     NSFontAttributeName: [UIFont systemFontOfSize:14]
/// }];
///  ```
typedef NSAttributedStringKey XZMLAttributeName;

/// 通过此键为 XZML 预设字体样式，值为 UIFont 对象。
FOUNDATION_EXPORT XZMLAttributeName const XZMLFontAttributeName NS_REFINED_FOR_SWIFT;

/// 通过此键为 XZML 预设前景色样式，值为 UIColor 对象。
FOUNDATION_EXPORT XZMLAttributeName const XZMLForegroundColorAttributeName NS_REFINED_FOR_SWIFT;
/// 通过此键为 XZML 预设背景色样式，值为 UIColor 对象。
FOUNDATION_EXPORT XZMLAttributeName const XZMLBackgroundColorAttributeName NS_REFINED_FOR_SWIFT;

/// 通过此键为 XZML 样式预设文本修饰类型，值为包装 XZMLDecorationType 枚举值的 NSNumber 对象。
FOUNDATION_EXPORT XZMLAttributeName const XZMLDecorationAttributeName NS_REFINED_FOR_SWIFT;

/// 通过此键为 XZML 样式预设安全模式，值为包装 BOOL 的 NSNumber 对象。
///
/// 值为布尔值，YES 表示当前为安全模式，NO 为非安全模式。
FOUNDATION_EXPORT XZMLAttributeName const XZMLSecurityModeAttributeName NS_REFINED_FOR_SWIFT;

/// 通过此键为 XZML 样式预设超链接，值为 NSString 或 NSURL 对象，建议为 NSURL 对象，直接用于富文本构造。
///
/// 在 XZML 中，若字符串以 `~` 或 `/` 开头，会被认为是文件路径，用 `+[NSURL fileURLWithPath:]` 转换为 NSURL 对象。
FOUNDATION_EXPORT XZMLAttributeName const XZMLLinkAttributeName NS_REFINED_FOR_SWIFT;

/// 通过此键为 XZML 样式预设段落样式，值为 NSParagraphStyle 对象。
FOUNDATION_EXPORT XZMLAttributeName const XZMLParagraphStyleAttributeName NS_REFINED_FOR_SWIFT;


/// 文本修饰类型枚举。
typedef NS_ENUM(NSUInteger, XZMLDecorationType) {
    /// 删除线
    XZMLDecorationTypeStrikethrough = 0,
    /// 下划线
    XZMLDecorationTypeUnderline,
};

/// 设置 XZML 的字体名缩写表，值中的 key 为缩写、value 为完整字体名。
///
/// 调用会整体替换之前的缩写表；传 nil 清空。
/// 未命中的名称会直接作为字体名查找，因此缩写与真实字体名可以直接混用。
///
/// @attention 请在程序初始化时（主线程）调用，不要与后台解析并发调用。
FOUNDATION_EXPORT void XZMLSetFontAbbreviations(NSDictionary<NSString *, NSString *> * _Nullable fontAbbreviations);

/// 获取当前的 XZML 字体名缩写表，未设置过时返回 nil。
///
/// 返回值仅包含已注册的缩写，未注册的缩写不在此表中。
FOUNDATION_EXPORT NSDictionary<NSString *, NSString *> * _Nullable XZMLGetFontAbbreviations(void);

/// XZML 样式标记字符，使用 ASCII 特殊标点符号作为标记字符。
/// @attention 新增枚举请同时调整 NSCharacterSet.XZMLReservedCharacterSet 字符集。
typedef NS_ENUM(char, XZMLAttribute) {
    /// 颜色样式：文本前景色、文本背景色。颜色使用十六进制 RGB/RGBA 值。
    ///
    /// 属性值支持以下格式（`:` 之前为前景色，之后为背景色）：
    /// - `#`，表示设置前景色为预设值
    /// - `AAA#`，表示设置前景色为 AAA 值
    /// - `:BBB#`，表示仅设置前景色为预设值，背景色为 BBB 值
    /// - `AAA:#`，表示设置前景色为 AAA 值，背景色为预设值
    /// - `AAA:BBB#`，表示设置前景色为 AAA 值，背景色为 BBB 值
    /// - `:#`，表示设置前景色为预设值，背景色为预设值
    ///
    /// - Note: 前景色与背景色共用同一套取值优先级，仅各自的键不同：
    ///   指定值 → 继承值 → 预设值（`XZMLForegroundColorAttributeName` / `XZMLBackgroundColorAttributeName`）
    ///   → 默认值（`NSForegroundColorAttributeName` / `NSBackgroundColorAttributeName`）。
    /// - Note: 子属性值为空或非法时不写入，沿用上述优先级取到的值，不会重置为透明色。
    /// - Note: 不含 `:` 时只设置前景色，背景色保持原样（继承值或不变）。
    XZMLAttributeColor = '#',
    
    /// 字体样式：字体、字号、偏移。
    ///
    /// 格式：`字体名` 或 `:字号` 或 `字体名:字号` 或 `字体名:字号:基准线偏移`
    ///
    /// 未注册缩写的名称直接作为字体名查找，因此 `<宋体&>`、`<Helvetica:20&>` 这类写法无需任何注册即可生效。
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
    /// 格式：`样式` 或 `样式:线型` 或 `样式:线型:颜色`
    /// @discussion【样式】0，删除线（默认）；1，下划线
    /// @discussion【线型】0，单线条（默认）；1，双线条；2，粗线条
    /// @discussion【颜色】RGB/RGBA 颜色值，默认与文本颜色相同
    /// @attention 文本修饰，包含多个样式，因此使用属性默认值解析，设置文本修饰样式，只会覆盖上层相同样式的设置。
    /// @discussion 比如设置删除线样式，上层设置删除线样式会被覆盖，但是上层的下划线样式会保留。
    /// @discussion 可以使用两个`$`可同时指定下划线和删除线。
    XZMLAttributeDecoration = '$',
    
    /// 安全文本样式：用占位字符替代目标文本的样式。
    /// 格式：`替代符号` 或 `:重复次数` 或 `替代符号:重复次数`。
    /// @discussion 替代符号默认为`*`星号；未指定重复次数时，默认与被替代文本的字符数相同（等长遮蔽）。
    /// @discussion 此处“字符数”按 UTF-16 代码单元计数，代理对（如 emoji）计为 2。
    /// @attention 重复次数上限为 64，超过部分被钳制，因此长度超过 64 的文本不再是等长遮蔽。
    /// @discussion 安全模式替换时，忽略所有子元素。
    /// @attention 在安全模式下，星号`*`之后样式、文本、子元素都会被忽略，因此通过`*`的位置控制替代字符的样式。
    /// @discussion 比如将删除线样式放在`*`之后，安全模式下，替代字符不会展示删除线。
    XZMLAttributeSecurity = '*',
    
    /// 超链接样式。
    ///
    /// @discussion 将使用 NSURL 或 NSString 创建富文本 NSLinkAttributeName 属性。
    XZMLAttributeLink = '~', // => @
    
    /// 段落样式。按位置指定段落属性：[多倍行高|最小行高-最大行高]:行间距:首行缩进:对齐方式:断行模式:段间距:段前距:头缩进:尾缩进:书写方向
    /// @discussion 各位置对应的段落属性依次为：
    /// @discussion 1. 行高：`最小行高-最大行高` 同时指定 minimumLineHeight 和 maximumLineHeight，两端大小颠倒时自动交换；
    ///   不含 `-` 时按 lineHeightMultiple 多倍行高解析，值非正数时不写入。
    /// @discussion 2. 行间距 lineSpacing
    /// @discussion 3. 首行缩进 firstLineHeadIndent
    /// @discussion 4. 对齐方式 alignment，取值 NSTextAlignmentLeft(0) ~ NSTextAlignmentNatural(4)
    /// @discussion 5. 断行模式 lineBreakMode，取值 NSLineBreakByWordWrapping(0) ~ NSLineBreakByTruncatingMiddle(5)
    /// @discussion 6. 段间距 paragraphSpacing
    /// @discussion 7. 段前距 paragraphSpacingBefore
    /// @discussion 8. 头缩进 headIndent
    /// @discussion 9. 尾缩进 tailIndent
    /// @discussion 10. 书写方向 baseWritingDirection，取值 NSWritingDirectionNatural(-1) ~ NSWritingDirectionRightToLeft(1)
    /// @attention 段落属性是**位置相关**的：要设置第 N 个属性，必须同时给出前 N-1 个属性（可留空）；
    ///   留空的数值属性按 0 处理，会覆盖继承值，只有行高留空或非法时不写入。
    /// @discussion `alignment`、`lineBreakMode`、`baseWritingDirection` 仅接受上表范围内的枚举值，越界值被忽略（不钳制），段落样式沿用继承值或默认值。
    /// @discussion 行高区间的 `-` 两侧必须都有内容，非法的区间写法（如 `30-`、`-5`）整个行高属性被忽略，不会降级按多倍行高解析。
    /// @discussion 属性个数超过 10 时，多余的属性被丢弃，前 10 个属性照常生效。
    /// @discussion 示例：
    /// @code
    /// NSString *XZML1 = @"<1.5|Paragraph>";              // 1.5 倍行高
    /// NSString *XZML2 = @"<20-30|Paragraph>";            // 最小行高 20.0 point 最大行高 30.0 point
    /// NSString *XZML3 = @"<0:5|Paragraph>";              // 行间距 5.0 point
    /// NSString *XZML4 = @"<0:5:12:1|Paragraph>";         // 行间距 5.0、首行缩进 12.0、居中对齐
    /// NSString *XZML5 = @"<20-30:5:12:1:4:8:6:20:0:-1|Paragraph>"; // 指定全部 10 个段落属性
    /// @endcode
    /// @discussion 由于段落属性按位置解析，属性之间的顺序是固定的，`:` 分隔符也是必需的。
    XZMLAttributeParagraph = '|',
    
};

NS_ASSUME_NONNULL_END
