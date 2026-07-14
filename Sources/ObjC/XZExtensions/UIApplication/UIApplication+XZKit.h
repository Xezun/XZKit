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

/// 主窗口，展示业务的窗口。
///
/// 查找所有 `connectedScenes` 中的 `UIWindowScene` 对象，并依据 `activationState` 按照如下优先级取 `keyWindow` 或 `windows.firstObject` 对象。
///
/// - UISceneActivationStateForegroundActive
/// - UISceneActivationStateForegroundInactive
/// - UISceneActivationStateBackground
/// - UISceneActivationStateUnattached
///
/// 如果没有符合上述条件的 `window`对象，则返回 `delegate.window` 属性的对象。
@property (nonatomic, strong, setter=xz_setMainWindow:, nullable) UIWindow *xz_mainWindow NS_SWIFT_NAME(mainWindow);

@end

NS_ASSUME_NONNULL_END
