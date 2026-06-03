//
//  UIViewController+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/6/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (XZKit)

/// 当前控制器是否已开启状态栏样式配置能力。
///
/// UIKit 在处理状态栏是否隐藏时，并不是直接获取属性 `prefersStatusBarHidden` 的值，
/// 而是先通过`+doesOverrideViewControllerMethod:`方法判断控制器是否重写属性`prefersStatusBarHidden`，
/// 然后才会访问该属性。如果没有重写该属性，即使属性值发生改变，但是由于没有读取属性值，状态栏样式也不会更新。
///
/// 因此 XZKit 会为控制器自动重写 `preferredStatusBarStyle` 和 `prefersStatusBarHidden` 属性（不调用 super 方法）。
/// 控制器也可以重写了这俩属性，且它们会被调用，但是返回值不会生效。
///
/// > 此属性会在设置 `xz_preferredStatusBarStyle`、`xz_prefersStatusBarHidden` 属性时自动调用。
///
/// > 控制器一旦开启此能力，不能关闭，因为不能移除方法。
@property (nonatomic, readonly) BOOL xz_definesStatusBarAppearance NS_SWIFT_NAME(definesStatusBarAppearance);

/// 当前控制器的状态栏样式配置。默认为 `UIStatusBarStyleDefault` 样式，即自动跟随系统设置。
///
/// 在导航或页签控制器中，需要重写下述方法才能生效。
///
/// ```swift
/// override var childForStatusBarStyle: UIViewController? {
///     return self.presentedViewController ?? self.topViewController
/// }
/// ```
@property (nonatomic, setter=xz_setPreferredStatusBarStyle:) UIStatusBarStyle xz_preferredStatusBarStyle NS_SWIFT_NAME(statusBarStyle);

/// 配置当前控制器的状态栏样式。
/// @param preferredStatusBarStyle 待设置的样式
/// @param animated 是否展示动画
- (void)xz_setPreferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle animated:(BOOL)animated NS_SWIFT_NAME(setStatusBarStyle(_:animated:));

/// 当前控制器的状态栏隐藏状态配置。默认为 NO 状态，即不隐藏。
///
/// 在导航或页签控制器中，需要重写下述方法才能生效。
/// ```swift
/// override var childForStatusBarHidden: UIViewController? {
///     return self.presentedViewController ?? self.topViewController
/// }
/// ```
@property (nonatomic, setter=xz_setPrefersStatusBarHidden:) BOOL xz_prefersStatusBarHidden NS_SWIFT_NAME(statusBarHidden);

/// 配置当前控制器的状态栏隐藏状态。
/// @param prefersStatusBarHidden 状态栏是否隐藏
/// @param animated 是否动画转场
- (void)xz_setPrefersStatusBarHidden:(BOOL)prefersStatusBarHidden animated:(BOOL)animated NS_SWIFT_NAME(setStatusBarHidden(_:animated:));

@end

NS_ASSUME_NONNULL_END
