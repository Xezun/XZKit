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

/// 设置 XZML 缩写表。
///
/// 目前仅字体会使用缩写表。通过此函数设置 XZML 的字体名缩写表，值中的 key 为缩写、value 为完整字体名。
///
/// 调用函数会整体替换之前的缩写表；传空字典清空。
///
/// > 未命中的名称会直接作为字体名查找，因此缩写与真实字体名可以直接混用。
///
/// > 请在程序初始化时（主线程）调用，不要与后台解析并发调用。
///
/// - Parameter abbreviations: 新缩写表，其中 nil 表示移除所有
FOUNDATION_EXPORT void XZMLSetAbbreviations(NSDictionary<NSString *, NSString *> * _Nullable abbreviations);

/// 获取 XZML 缩写表。
FOUNDATION_EXPORT NSDictionary<NSString *, NSString *> * _Nullable XZMLGetAbbreviations(void);

/// XZML 样式标记字符，使用 ASCII 特殊标点符号作为标记字符。
///
/// 新增枚举请同时调整 NSCharacterSet.XZMLReservedCharacterSet 字符集。
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
    /// 缩写需由使用方通过 `XZMLSetAbbreviations()` 注册，本组件不提供内置缩写表。业务建议的缩写约定：
    /// - 1、数字常规：DR、D
    /// - 2、数字粗体：DB、B
    /// - 3、文本细体：TL、L
    /// - 4、文本常规：TR、T
    /// - 5、文本中等：TM、M
    /// - 6、文本中粗：TS、S
    XZMLAttributeFont = '&',
    
    /// 文本修饰样式。
    ///
    /// 格式：`样式` 或 `样式:线型` 或 `样式:线型:颜色`
    ///
    /// -【样式】0，删除线（默认）；1，下划线
    /// -【线型】0，单线条（默认）；1，双线条；2，粗线条
    /// -【颜色】RGB/RGBA 颜色值，默认与文本颜色相同
    /// - 文本修饰，包含多个样式，因此使用属性默认值解析，设置文本修饰样式，只会覆盖上层相同样式的设置。
    /// - 比如设置删除线样式，上层设置删除线样式会被覆盖，但是上层的下划线样式会保留。
    /// - 可以使用两个`$`可同时指定下划线和删除线。
    XZMLAttributeDecoration = '$',
    
    /// 安全文本样式：用占位字符替代目标文本的样式。
    ///
    /// 格式：`替代符号` 或 `:重复次数` 或 `替代符号:重复次数`。
    ///
    /// - 替代符号默认为`*`星号；未指定重复次数时，默认与被替代文本的字符数相同（等长遮蔽）。
    /// - 此处“字符数”按 UTF-16 代码单元计数，代理对（如 emoji）计为 2。
    /// - 重复次数上限为 64，超过部分被钳制，因此长度超过 64 的文本不再是等长遮蔽。
    /// - 安全模式替换时，忽略所有子元素。
    /// - 在安全模式下，星号`*`之后样式、文本、子元素都会被忽略，因此通过`*`的位置控制替代字符的样式。
    /// - 比如将删除线样式放在`*`之后，安全模式下，替代字符不会展示删除线。
    XZMLAttributeSecurity = '*',
    
    /// 超链接样式。
    ///
    /// 将使用 NSURL 或 NSString 创建富文本 NSLinkAttributeName 属性。
    XZMLAttributeLink = '~', // => @
    
    /// 段落样式。支持两种位段写法，可混用：
    /// - **位置式**：按位段顺序依次指定 `[行高]:行间距:首行缩进:对齐方式:断行模式:段间距:段前距:头缩进:尾缩进:书写方向`；
    /// - **具名式**：任意位段可写作 `属性名=值`（如 `lineHeight=20:lineSpacing=5`），`=` 左侧为空时退化为按位段位置解析。
    /// 合法属性名：`lineHeight`、`lineSpacing`、`firstLineHeadIndent`、`alignment`、`lineBreakMode`、`paragraphSpacing`、`paragraphSpacingBefore`、`headIndent`、`tailIndent`、`baseWritingDirection`，非法名称的位段会被忽略。
    ///
    /// > 位段值**仅在为空字符串时不写入**（保留继承/预设值），其余情况一律按解析结果写入，不会因数值为 0 或非法而跳过。
    ///
    /// - 1. lineHeight - 行高，支持三种写法：
    ///   - `x1.5`/`X1.5`：多倍行高，写入 lineHeightMultiple；
    ///   - `20-30`：区间，分别写入 minimumLineHeight 和 maximumLineHeight，某一侧留空则该侧不写入（保留继承/预设值），**不校验大小、不自动交换**；还可追加第三段 `min-max-倍数` 同时指定 lineHeightMultiple；
    ///   - 纯数字 `20`：固定行距，min=max；非数字按 0 处理。
    /// - 2. lineSpacing - 行间距
    /// - 3. firstLineHeadIndent - 首行缩进
    /// - 4. alignment - 对齐方式，取值 NSTextAlignment 枚举的原始值，不合法默认 NSTextAlignmentNatural 
    /// - 5. lineBreakMode - 断行模式，取值 NSLineBreakMode 枚举的原始值，不合法默认 NSLineBreakByTruncatingMiddle
    /// - 6. paragraphSpacing - 段间距
    /// - 7. paragraphSpacingBefore - 段前距
    /// - 8. headIndent - 头缩进
    /// - 9. tailIndent - 尾缩进
    /// - 10. baseWritingDirection - 书写方向，取值 NSWritingDirection 枚举的原始值，不合法默认 NSWritingDirectionNatural
    ///
    /// > 段落属性是**位置相关**的：位置式要设置第 N 个属性，必须同时给出前 N-1 个位段（可留空）；位段之间顺序固定，`:` 分隔符必需。
    ///
    /// > 属性个数超过 10 时，多余的位段被丢弃，前 10 个照常生效。
    ///
    /// ```objc
    /// NSString *XZML1 = @"<x1.5|Paragraph>";             // 1.5 倍行高
    /// NSString *XZML2 = @"<20|Paragraph>";               // 固定行高 20.0 point（min=max）
    /// NSString *XZML3 = @"<20-30|Paragraph>";            // 最小行高 20.0、最大行高 30.0
    /// NSString *XZML4 = @"<0:5|Paragraph>";              // 行间距 5.0 point
    /// NSString *XZML5 = @"<20-30:5:12:1:4:8:6:20:0:-1|Paragraph>"; // 指定全部 10 个段落属性
    /// NSString *XZML6 = @"<lineHeight=20:lineSpacing=5|Paragraph>"; // 具名式，无需占位前导位段
    /// ```
    XZMLAttributeParagraph = '|',
    
};

NS_ASSUME_NONNULL_END
