//
//  UIKit+XZToast.h
//  XZToast
//
//  Created by 徐臻 on 2025/4/29.
//

#import <UIKit/UIKit.h>
#import "XZToastDefines.h"

NS_ASSUME_NONNULL_BEGIN

@class XZToast;

@interface UIResponder (XZToast)

/// 在当前控制器或当前视图所在的控制器上，弹出提示消息。
///
/// 展示提示消息依赖于控制器视图容器，因此应在 `-viewDidLoad` 之后使用，否则可能会提前控制器生命周期。
///
/// - Parameters:
///   - toast: 提示消息
///   - duration: 展示时长，值为 0 表示不限制时长
///   - position: 展示位置
///   - exclusive: 是否独占，独占的消息展示时，不再展示其它消息
///   - completion: 消息展示完成时的回调，如果消息被提前结束，则回调参数为 NO
/// - Returns: 返回值与参数 toast 不是同一对象，当需要隐藏特定 toast 时，需要使用该返回值
- (nullable XZToast *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(nullable XZToastCompletion)completion NS_SWIFT_NAME(showToast(_:duration:position:exclusive:completion:));

- (nullable XZToast *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position completion:(nullable XZToastCompletion)completion NS_SWIFT_NAME(showToast(_:duration:position:completion:));
- (nullable XZToast *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration exclusive:(BOOL)exclusive completion:(nullable XZToastCompletion)completion NS_SWIFT_NAME(showToast(_:duration:exclusive:completion:));
- (nullable XZToast *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration completion:(nullable XZToastCompletion)completion NS_SWIFT_NAME(showToast(_:duration:completion:));

- (nullable XZToast *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration;
- (nullable XZToast *)xz_showToast:(XZToast *)toast completion:(nullable XZToastCompletion)completion NS_SWIFT_NAME(showToast(_:completion:));
- (nullable XZToast *)xz_showToast:(XZToast *)toast NS_SWIFT_NAME(showToast(_:));

- (nullable XZToast *)xz_showToast:(XZToast *)toast exclusive:(BOOL)exclusive completion:(nullable XZToastCompletion)completion NS_SWIFT_NAME(showToast(_:exclusive:completion:));
- (nullable XZToast *)xz_showToast:(XZToast *)toast exclusive:(BOOL)exclusive NS_SWIFT_NAME(showToast(_:exclusive:));

- (void)xz_hideToast:(nullable XZToast *)toast completion:(nullable void (^)(void))completion NS_SWIFT_NAME(hideToast(_:completion:));
- (void)xz_hideToast:(nullable void (^)(void))completion NS_SWIFT_NAME(hideToast(_:));

/// 刷新 toast 的布局。
///
/// 如果在展示 toast 的期间，控制器的大小发生了改变，需要调用此方法来刷新布局。
///
/// 比如在容器视图为滚动视图时，可通过调用此方法刷新位置，让 toast 跟随滚动。
- (void)xz_setNeedsLayoutToasts NS_SWIFT_NAME(setNeedsLayoutToasts());
- (void)xz_layoutToastsIfNeeded NS_SWIFT_NAME(layoutToastsIfNeeded());

/// 可同时展示的 toast 的数量。
@property (nonatomic, setter=xz_setMaximumNumberOfToasts:) NSInteger xz_maximumNumberOfToasts NS_SWIFT_NAME(maximumNumberOfToasts);

/// 设置指定位置的 toast 的偏移值。
/// - Parameters:
///   - offset: 偏移值
///   - position: toast 展示位置
- (void)xz_setOffset:(CGFloat)offset forToastInPosition:(XZToastPosition)position NS_SWIFT_NAME(setOffset(_:forToastIn:));

/// 获取指定位置 toast 的偏移值。
/// - Parameter position: toast 展示位置
- (CGFloat)xz_offsetForToastInPosition:(XZToastPosition)position NS_SWIFT_NAME(offset(forToastIn:));

@end

@interface UIViewController (XZToast)

/// 展示 toast 的控制器，默认值为自身。
///
/// 子类可以通过重写此属性来实现将 toast 转发到其它控制器展示。
/// 1. 容器是滚动的控制器，比如 `UITableViewController` 等，避免 toast 会随页面滚动。
/// 2. 希望 toast 可以跨页面显示.
/// 3. 希望 toast 统一在根控制器管理。
@property (nonatomic, readonly, nullable) UIViewController *xz_toastController NS_SWIFT_NAME(toastController);

@end

NS_ASSUME_NONNULL_END
