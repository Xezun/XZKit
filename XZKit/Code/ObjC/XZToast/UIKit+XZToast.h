//
//  UIKit+XZToast.h
//  XZToast
//
//  Created by 徐臻 on 2025/4/29.
//

#import <UIKit/UIKit.h>
#import "XZToastDefines.h"

NS_ASSUME_NONNULL_BEGIN

@class XZToast, XZToastTask;
@protocol XZToastConfiguration;

@interface UIResponder (XZToast)

/// 在当前控制器或当前视图所在的控制器上，弹出提示消息。
///
/// 1. 展示提示消息依赖于控制器视图容器，因此应在 `-viewDidLoad` 之后使用，否则可能会提前控制器生命周期。
/// 2. 呈现 XZToast 的控制器会强持有`completion`块函数，对于不能自动结束的类型，应注意循环引用造成的内存泄漏问题，或者保证`hideToast`一定会被调用。
/// 3. 独占类型的消息，不建议使用复用视图，因为复用的视图的内容可能会被其它逻辑修改和使用。
///
/// - Parameters:
///   - toast: 提示消息
///   - duration: 展示时长，值为 0 时，表示不限制时长，一直保持展示，除非调用 `hideToast` 方法，默认 1.0 秒
///   - position: 展示位置
///   - exclusive: 是否独占，独占的 toast 消息展示时，不再展示其它 toast 消息
///   - completion: 消息展示完成时的回调，如果消息被提前结束，则回调参数为 NO 值
/// - Returns: 返回值与参数 toast 不是同一对象，当需要隐藏特定 toast 时，需要使用该返回值
- (nullable XZToastTask *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(nullable XZToastCompletion)completion NS_REFINED_FOR_SWIFT NS_SWIFT_NAME(__showToast(_:duration:position:exclusive:completion:));

- (nullable XZToastTask *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position completion:(nullable XZToastCompletion)completion NS_SWIFT_UNAVAILABLE("");
- (nullable XZToastTask *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration exclusive:(BOOL)exclusive completion:(nullable XZToastCompletion)completion NS_SWIFT_UNAVAILABLE("");
- (nullable XZToastTask *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration completion:(nullable XZToastCompletion)completion NS_SWIFT_UNAVAILABLE("");

- (nullable XZToastTask *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration NS_SWIFT_UNAVAILABLE("");
- (nullable XZToastTask *)xz_showToast:(XZToast *)toast completion:(nullable XZToastCompletion)completion NS_SWIFT_UNAVAILABLE("");
- (nullable XZToastTask *)xz_showToast:(XZToast *)toast NS_SWIFT_UNAVAILABLE("");

- (nullable XZToastTask *)xz_showToast:(XZToast *)toast position:(XZToastPosition)position NS_SWIFT_UNAVAILABLE("");
- (nullable XZToastTask *)xz_showToast:(XZToast *)toast position:(XZToastPosition)position completion:(nullable XZToastCompletion)completion NS_SWIFT_UNAVAILABLE("");

- (nullable XZToastTask *)xz_showToast:(XZToast *)toast exclusive:(BOOL)exclusive completion:(nullable XZToastCompletion)completion NS_SWIFT_UNAVAILABLE("");
- (nullable XZToastTask *)xz_showToast:(XZToast *)toast exclusive:(BOOL)exclusive NS_SWIFT_UNAVAILABLE("");

- (void)xz_hideToast:(nullable XZToast *)toast completion:(nullable void (^)(void))completion NS_REFINED_FOR_SWIFT NS_SWIFT_NAME(__hideToast(_:completion:));
- (void)xz_hideToast:(nullable void (^)(void))completion NS_SWIFT_UNAVAILABLE("");

/// 可用于配置 XZToast 外观样式的对象。
///
/// 通过此属性配置的外观样式仅应用于当前控制，若要配置全局默认样式，可通过``XZToast``的类属性或类方法。
@property (nonatomic, strong, readonly) id<XZToastConfiguration> xz_toastConfiguration NS_SWIFT_NAME(toastConfiguration);

@end


@interface UIViewController (XZToast)

/// 展示 toast 的控制器，默认值按 `presentedViewController`、`tabBarController`、 `navigationController` 的顺序查找第一个存在的控制器，如都没有则使用自身。
///
/// 子类可以通过重写此属性来实现将 toast 转发到其它控制器展示。
/// 1. 容器是滚动的控制器，比如 `UITableViewController` 等，避免 toast 会随页面滚动。
/// 2. 统一 toast 的显示和管理。
@property (nonatomic, readonly) UIViewController *xz_toastController NS_SWIFT_NAME(toastController);

@end

NS_ASSUME_NONNULL_END
