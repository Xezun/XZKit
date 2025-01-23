//
//  UIViewController+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/6/23.
//

#import <UIKit/UIKit.h>
@import XZDefines;

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (XZKit)

/// 开启状态栏样式配置能力。
///
/// UIKit 在处理状态栏是否隐藏时，并不是直接获取属性 `prefersStatusBarHidden` 的值，
/// 而是先通过`+doesOverrideViewControllerMethod:`方法判断控制器是否重写属性`prefersStatusBarHidden`，
/// 然后才会访问该属性。如果没有重写该属性，即使属性值发生改变，但是由于没有读取属性值，状态栏样式也不会更新。
///
/// 因此调用此方法，XZKit 会重写 `preferredStatusBarStyle` 和 `prefersStatusBarHidden` 属性。
/// 且重写的属性，不会调用超类的实现，但是如果控制器自身也重写了它们，那么 XZKit 会调用它们，但它们的值不会生效。
///
/// > 此方法会在设置 `xz_preferredStatusBarStyle`、`xz_prefersStatusBarHidden` 属性时自动调用。
///
/// > 此方法为开启能力的方法，不能关闭能力。
///
/// - Returns: 返回 YES 表示执行了开启能力的操作，返回 NO 表示已开启能力，本次调用未执行任何操作。
- (BOOL)xz_setPrefersStatusBarAppearance NS_SWIFT_NAME(setPrefersStatusBarAppearance());

/// 当前控制器是否已开启状态栏样式配置能力。
@property (nonatomic, readonly) BOOL xz_prefersStatusBarAppearance NS_SWIFT_NAME(prefersStatusBarAppearance);

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
