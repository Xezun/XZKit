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
/// 样式可能会有多个子属性，比如字体样式，包含字体名和字体大小两个子属性，在 XZML 中用 `@` 符号分隔不同的属性。
///
/// ### 取值优先级
///
/// - 直接写在 XZML 中**指定值**和**继承值**优先级最高。
/// - 在 `attributes` 参数中，通过 `XZMLAttributeName` 提供的**预设值**。
/// - 在 `attributes` 参数中，通过 `NSAttributedStringKey` 提供的**默认值**。
/// - 系统默认值。
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

NS_ASSUME_NONNULL_END
