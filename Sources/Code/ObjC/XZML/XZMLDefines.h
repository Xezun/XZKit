//
//  XZMLDefines.h
//  XZML
//
//  Created by Xezun on 2024/10/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 元素属性应用规则。
//
// 指定值：在 XZML 中指定的样式属性的值。
// 预设值：在 attributes 参数中，通过 XZML~AttributeName 键提供的值。
// 继承值：从父元素继承获取的值。
// 默认值：在 attributes 参数中，通过 NS~AttributeName 键提供的值。
// 系统值：值在无法确定时，兜底使用的值，但不是所有属性都有系统值。比如，若无法确定字体，则采用系统字体，但字号则无类似默认。
//
// 普通子属性：属性可能会有多个子属性，比如字体名称、字体大小等。
// 默认子属性：只有一个，可通过 XZML~AttributeName 键，在 attributes 参数中提供预设值。
//
// 某些不可分割的样式值，作为预设值时，可能会同时携带普通子属性值，但该值优先级比默认值低。
// 比如 UIFont 对象会同时提供字体名称和字体大小，其中，只有在无法确定时，才会使用字体大小。
// 取值优先级：
// 默认子属性：指定值、继承值、预设值、默认值、系统值，其中默认值、系统值是兜底值。
// 普通子属性：指定值、继承值、默认值、预设值、系统值，其中默认值、预设值、系统值是兜底值，预设值对于普通子属性来说是额外的选项，一般情况下是没有的。

/// 通过此键为 XZML 样式预设字体名。
/// 1. 值为 UIFont 对象。
/// 2. 只有字体名是预设值，字体大小仅在指定值、继承值、默认值都不存在时才会使用。
FOUNDATION_EXPORT NSAttributedStringKey const XZMLFontAttributeName;

/// 通过此键为 XZML 样式预设前景色。
/// 1. 值为代表前景色的 UIColor 对象。
FOUNDATION_EXPORT NSAttributedStringKey const XZMLForegroundColorAttributeName;

/// 通过此键为 XZML 样式预设文本修饰类型。
/// 1. 值为代表文本修饰类型枚举 XZMLDecorationType 的值的 NSNumber 对象。
FOUNDATION_EXPORT NSAttributedStringKey const XZMLDecorationAttributeName;

/// 通过此键为 XZML 样式预设安全模式。
/// 1. 值为布尔值，YES 表示当前为安全模式，NO 为非安全模式。
FOUNDATION_EXPORT NSAttributedStringKey const XZMLSecurityModeAttributeName;

/// 通过此键为 XZML 样式预设超链接。
/// 1. 值为 NSString 或 NSURL 对象。
/// 2. 其中功能以 `~` 或 `/` 开头的 NSString 对象，会被认为是文件路径，用 `+[NSURL fileURLWithPath:]` 转换为 NSURL 对象。
FOUNDATION_EXPORT NSAttributedStringKey const XZMLLinkAttributeName;

/// 通过此键为 XZML 样式预设段落（最小）行高。
/// 1. 值为代表文本段落最小行高的 CGFloat 值的 NSNumber 对象。
FOUNDATION_EXPORT NSAttributedStringKey const XZMLLineHeightAttributeName;


/// 文本修饰类型枚举。
typedef NS_ENUM(NSUInteger, XZMLDecorationType) {
    /// 删除线
    XZMLDecorationTypeStrikethrough = 0,
    /// 下划线
    XZMLDecorationTypeUnderline,
};

NS_ASSUME_NONNULL_END
