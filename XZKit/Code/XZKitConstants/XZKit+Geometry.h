//
//  XZKitGeometry.h
//  XZKit
//
//  Created by 徐臻 on 2019/3/27.
//  Copyright © 2019 mlibai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 与 UIEdgeInsets 相同，只不过方便适配 LTR/RTL 布局。
typedef struct {
    /// 上边距。
    CGFloat top;
    /// 前边距。
    CGFloat leading;
    /// 底边距。
    CGFloat bottom;
    /// 后边距。
    CGFloat trailing;
} XZEdgeInsets NS_SWIFT_NAME(EdgeInsets);
//typedef struct XZEdgeInsets XZEdgeInsets;

/// 与 UIRectEdge 相同，只不过方便适配 LTR/RTL 布局。
typedef NS_OPTIONS(NSUInteger, XZRectEdge) {
    XZRectEdgeTop      = 1 << 0,
    XZRectEdgeLeading  = 1 << 1,
    XZRectEdgeBottom   = 1 << 2,
    XZRectEdgeTrailing = 1 << 3
} NS_SWIFT_NAME(RectEdge);

/// 边距全部为零的常量。
UIKIT_EXTERN XZEdgeInsets const XZEdgeInsetsZero NS_SWIFT_NAME(EdgeInsets.zero);

/// 构造 XZEdgeInsets 。
///
/// @param top 上边距。
/// @param leading 前边距。
/// @param bottom 底边距。
/// @param trailing 后边距。
/// @return XZEdgeInsets 值。
UIKIT_EXTERN XZEdgeInsets XZEdgeInsetsMake(CGFloat top, CGFloat leading, CGFloat bottom, CGFloat trailing) NS_SWIFT_UNAVAILABLE("Use EdgeInsets.init(top:leading:bottom:trailing:) instead.");
/// 将 UIEdgeInsets 转换为 XZEdgeInsets 。
///
/// @param edgeInsets 待转换的 UIEdgeInsets 值。
/// @param layoutDirection UIEdgeInsets 值的布局方向。
/// @return XZEdgeInsets 值。
UIKIT_EXTERN XZEdgeInsets XZEdgeInsetsFromUIEdgeInsets(UIEdgeInsets edgeInsets, UIUserInterfaceLayoutDirection layoutDirection) NS_SWIFT_UNAVAILABLE("Use EdgeInsets.init(_:layoutDirection:) instead.");
/// 将 XZEdgeInsets 转换为 UIEdgeInsets 。
///
/// @param edgeInsets 待转换的 XZEdgeInsets 值。
/// @param layoutDirection 指定布局方向。
/// @return UIEdgeInsets 值。
UIKIT_EXTERN UIEdgeInsets UIEdgeInsetsFromXZEdgeInsets(XZEdgeInsets edgeInsets, UIUserInterfaceLayoutDirection layoutDirection) NS_SWIFT_UNAVAILABLE("Use UIEdgeInsets.init(_:layoutDirection:) instead.");

NS_ASSUME_NONNULL_END
