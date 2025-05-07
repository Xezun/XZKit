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
/// 当组件依赖 window 处理逻辑时，通常情况下是获取 `keyWindow` 来处理，但是有时候 `keyWindow` 并不是业务主窗口。
///
/// 此属性可写。默认情况，此属性会按优先级取 UIApplicationDelegate、UIWindowSceneDelegate 的 `window` 属性。
@property (nonatomic, setter=xz_setMainWindow:, nullable) UIWindow *xz_mainWindow NS_SWIFT_NAME(mainWindow);

@end

NS_ASSUME_NONNULL_END
