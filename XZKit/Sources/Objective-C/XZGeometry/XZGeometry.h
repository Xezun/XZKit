//
//  XZGeometry.h
//  XZKit
//
//  Created by 徐臻 on 2019/3/27.
//  Copyright © 2019 XEZUN INC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XZKit/XZKitDefines.h>

NS_ASSUME_NONNULL_BEGIN

/// 边距。与 UIEdgeInsets 相同，只不过方便适配 LTR/RTL 布局。
typedef struct XZ_BOXABLE XZEdgeInsets {
    /// 上边距。
    CGFloat top;
    /// 前边距。
    CGFloat leading;
    /// 底边距。
    CGFloat bottom;
    /// 后边距。
    CGFloat trailing;
} XZEdgeInsets;

/// 与 UIRectEdge 相同，只不过方便适配 LTR/RTL 布局。
typedef NS_OPTIONS(NSUInteger, XZRectEdge) {
    XZRectEdgeTop      = 1 << 0,
    XZRectEdgeLeading  = 1 << 1,
    XZRectEdgeBottom   = 1 << 2,
    XZRectEdgeTrailing = 1 << 3
};

/// 边距全部为零的常量。
UIKIT_EXTERN XZEdgeInsets const XZEdgeInsetsZero NS_SWIFT_NAME(XZEdgeInsets.zero);

/// 判断两个 XZEdgeInsets 是否相等。
/// @param edgeInsets1 XZEdgeInsets
/// @param edgeInsets2 XZEdgeInsets
/// @return 是否相等。
UIKIT_EXTERN BOOL XZEdgeInsetsEqualToEdgeInsets(XZEdgeInsets edgeInsets1, XZEdgeInsets edgeInsets2);

/// 构造 XZEdgeInsets 。
/// @param top 上边距。
/// @param leading 前边距。
/// @param bottom 底边距。
/// @param trailing 后边距。
/// @return XZEdgeInsets 值。
UIKIT_EXTERN XZEdgeInsets XZEdgeInsetsMake(CGFloat top, CGFloat leading, CGFloat bottom, CGFloat trailing);

/// 将 UIEdgeInsets 转换为 XZEdgeInsets 。
/// @param edgeInsets 待转换的 UIEdgeInsets 值。
/// @param layoutDirection UIEdgeInsets 值的布局方向。
/// @return XZEdgeInsets 值。
UIKIT_EXTERN XZEdgeInsets XZEdgeInsetsFromUIEdgeInsets(UIEdgeInsets edgeInsets, UIUserInterfaceLayoutDirection layoutDirection);

/// 将 XZEdgeInsets 转换为 UIEdgeInsets 。
/// @param edgeInsets 待转换的 XZEdgeInsets 值。
/// @param layoutDirection 指定布局方向。
/// @return UIEdgeInsets 值。
UIKIT_EXTERN UIEdgeInsets UIEdgeInsetsFromXZEdgeInsets(XZEdgeInsets edgeInsets, UIUserInterfaceLayoutDirection layoutDirection);

/// 判断某点是否在指定的区域点边缘内。
/// @param bounds CGRect
/// @param edgeInsets UIEdgeInsets
/// @param point CGPoint
/// @return YES or NO
UIKIT_EXTERN BOOL CGRectContainsPointInEdgeInsets(CGRect bounds, UIEdgeInsets edgeInsets, CGPoint point);

/// 将 XZEdgeInsets 序列化为字符串。
/// @param edgeInsets XZEdgeInsets
FOUNDATION_EXPORT NSString *NSStringFromXZEdgeInsets(XZEdgeInsets edgeInsets);

/// 从字符串中反解出 XZEdgeInsets 结构体。
/// @param aString 字符串
FOUNDATION_EXPORT XZEdgeInsets XZEdgeInsetsFromString(NSString * _Nullable aString);

/// 将 XZEdgeInsets 序列化为字符串。
/// @param rectEdge XZRectEdge
FOUNDATION_EXPORT NSString *NSStringFromXZRectEdge(XZRectEdge rectEdge);

/// 从字符串反解出 XZRectEdge 结构体。
/// @param aString XZRectEdge
FOUNDATION_EXPORT XZRectEdge XZRectEdgeFromString(NSString * _Nullable aString);

/// 计算 size 在 rect 区域，以 contentMode 模式适配时的大小和位置。
/// @param rect 适配的区域
/// @param size 待适配的大小
/// @param contentMode 适配模式
FOUNDATION_EXPORT CGRect CGRectAdjustingSizeByUsingContentMode(CGRect rect, CGSize size, UIViewContentMode contentMode);

NS_ASSUME_NONNULL_END
