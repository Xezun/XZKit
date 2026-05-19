//
//  UIKit+XZToast.h
//  XZToast
//
//  Created by 徐臻 on 2025/4/29.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZToastDefines.h>
#else
#import "XZToastDefines.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class XZToast, XZToastTask, XZToastManager;

@interface UIResponder (XZToastSupporting)

/// 显示提示消息。
///
/// 1. 展示提示消息依赖于控制器视图容器，因此应在 `-viewDidLoad` 之后使用，否则可能会提前控制器生命周期。
/// 2. 控制器会强持有`completion`块函数，对于不能自动结束的类型，应注意循环引用造成的内存泄漏问题，或者保证`hideToast`一定会被调用。
///
/// - Parameters:
///   - toast: 消息
///   - duration: 展示时长，值为 0 时，表示不限制时长，一直保持展示，除非调用 `hideToast` 方法，默认 1.0 秒
///   - position: 展示位置
///   - exclusive: 是否独占，独占的消息在展示时长结束前，其它 toast 消息会一直处于列队等待状态
///   - completion: 消息展示完成时的回调，如果消息被提前结束，则回调参数为 NO 值
/// - Returns: 返回值与参数 toast 不是同一对象，当需要隐藏特定 toast 时，需要使用该返回值
- (XZToastTask *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(nullable XZToastCompletion)completion NS_SWIFT_DISABLE_ASYNC NS_SWIFT_NAME(__showToast(_:duration:position:exclusive:completion:));

/// 隐藏提示消息。
/// - Parameters:
///   - toast: 消息对象
///   - completion: 消息隐藏后的回调
- (void)xz_hideToast:(nullable XZToast *)toast completion:(nullable void (^)(void))completion NS_REFINED_FOR_SWIFT NS_SWIFT_DISABLE_ASYNC NS_SWIFT_NAME(__hideToast(_:completion:));

/// 管理和配置当前视图或视图控制器的 XZToast 消息的对象。
///
/// 视图的 toastManager 与其所在的视图控制器的 toastManager 相同。
///
/// 通过此属性配置的外观样式仅应用于当前控制器，若要配置全局默认样式，可通过``XZToast``的类属性或类方法。
///
/// 视图控制器可通过重写此方法，将显示 XZToast 的操作转发给其他控制器，比如导航控制器或页签控制器。
///
/// ```swift
/// override var toastManager: XZToastManager {
///     return navigationController?.toastManager ?? super.toastManager
/// }
/// ```
@property (nonatomic, strong, readonly) XZToastManager *xz_toastManager NS_SWIFT_NAME(toastManager);

/// 显示提示消息。
- (XZToastTask *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position completion:(nullable XZToastCompletion)completion NS_SWIFT_UNAVAILABLE("");
/// 显示提示消息。
- (XZToastTask *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration exclusive:(BOOL)exclusive completion:(nullable XZToastCompletion)completion NS_SWIFT_UNAVAILABLE("");
/// 显示提示消息。
- (XZToastTask *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration completion:(nullable XZToastCompletion)completion NS_SWIFT_UNAVAILABLE("");

/// 显示提示消息。
- (XZToastTask *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration NS_SWIFT_UNAVAILABLE("");
/// 显示提示消息。
- (XZToastTask *)xz_showToast:(XZToast *)toast completion:(nullable XZToastCompletion)completion NS_SWIFT_UNAVAILABLE("");
/// 显示提示消息。
- (XZToastTask *)xz_showToast:(XZToast *)toast NS_SWIFT_UNAVAILABLE("");

/// 显示提示消息。
- (XZToastTask *)xz_showToast:(XZToast *)toast position:(XZToastPosition)position NS_SWIFT_UNAVAILABLE("");
/// 显示提示消息。
- (XZToastTask *)xz_showToast:(XZToast *)toast position:(XZToastPosition)position completion:(nullable XZToastCompletion)completion NS_SWIFT_UNAVAILABLE("");

/// 显示提示消息。
- (XZToastTask *)xz_showToast:(XZToast *)toast exclusive:(BOOL)exclusive completion:(nullable XZToastCompletion)completion NS_SWIFT_UNAVAILABLE("");
/// 显示提示消息。
- (XZToastTask *)xz_showToast:(XZToast *)toast exclusive:(BOOL)exclusive NS_SWIFT_UNAVAILABLE("");

/// 隐藏所有提示消息。
- (void)xz_hideToast:(nullable void (^)(void))completion NS_SWIFT_UNAVAILABLE("");

@end

@interface UIApplication (XZToastSupporting)
@end

@interface UIWindow (XZToastSupporting)
@end

@interface UIViewController (XZToastSupporting)
@end

NS_ASSUME_NONNULL_END
