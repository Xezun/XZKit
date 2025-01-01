//
//  UIApplication+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/6/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (XZKit)

/// 状态栏样式是否是由控制器管理的。
@property (class, nonatomic, readonly) BOOL xz_isViewControllerBasedStatusBarAppearance NS_SWIFT_NAME(isViewControllerBasedStatusBarAppearance);

/// 状态栏样式是否是由控制器管理的。
@property (nonatomic, readonly) BOOL xz_isViewControllerBasedStatusBarAppearance NS_SWIFT_NAME(isViewControllerBasedStatusBarAppearance);

@end

NS_ASSUME_NONNULL_END
