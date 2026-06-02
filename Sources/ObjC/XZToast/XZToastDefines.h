//
//  XZToastDefines.h
//  Pods
//
//  Created by Xezun on 2025/5/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XZToast;

/// 显示或隐藏 toast 的动画时长，默认 0.5 秒。
FOUNDATION_EXPORT NSTimeInterval const XZToastAnimationDuration NS_REFINED_FOR_SWIFT;

/// 消息样式。
typedef NS_ENUM(NSUInteger, XZToastStyle) {
    /// 文本消息样式。
    ///
    /// 一般性的提示性消息。
    XZToastStyleMessage,
    /// 加载消息样式。
    ///
    /// 默认情况下，该样式的消息，支持设置进度。
    XZToastStyleLoading,
    /// 成功消息样式。
    ///
    /// 表示成功的消息类型，比如操作成功、登录成功、添加成功等场景。
    XZToastStyleSuccess,
    /// 失败消息样式。
    ///
    /// 表示失败的消息类型，比如操作失败、登录失败、添加成功等场景。
    XZToastStyleFailure,
    /// 警告消息样式。
    ///
    /// 表示警告的消息类型，比如存在风险或不允许操作等场景。
    XZToastStyleWarning,
    /// 等待消息样式。
    ///
    /// 表示等待的消息类型，比如需要等待、倒计时未结束等场景。
    XZToastStyleWaiting,
} NS_REFINED_FOR_SWIFT;

FOUNDATION_EXPORT NSString *NSStringFromXZToastStyle(XZToastStyle style) NS_REFINED_FOR_SWIFT;

/// 提示消息 XZToast 的显示位置。
///
/// 为了避免 toast 重叠，推荐：
/// - top: 展示全局类型的提示消息，比如基于 tabBarController 的提示消息。
/// - bottom: 展示次全局的提示消息，比如基于 navigationController 的提示消息。
/// - middle: 展示当前页面的提示消息。
///
/// 备忘：会被用作数组的索引，枚举值需要从 0 开始且连续。
typedef NS_ENUM(NSInteger, XZToastPosition) {
    /// 顶部。
    XZToastPositionTop = 0,
    /// 中部。
    XZToastPositionMiddle,
    /// 底部。
    XZToastPositionBottom,
} NS_REFINED_FOR_SWIFT;

FOUNDATION_EXPORT NSString *NSStringFromXZToastPosition(XZToastPosition position) NS_REFINED_FOR_SWIFT;

/// 展示提示信息完成后的回调块函数类型。
///
/// 该块函数，会被呈现它的控制器强持有，直接捕获控制器可能会造成循环引用。比如，对于常显 XZToast 类型，即展示时长`duration`为零的类型，如果没有`hideToast`操作可能会造成内存泄漏。
///
/// @param finished 如果 XZToast 在 duration 之前被取消，该参数为 NO 值，所以对于常显类型，此参数肯定为 NO 值
typedef void (^XZToastCompletion)(BOOL finished) NS_REFINED_FOR_SWIFT NS_SWIFT_UI_ACTOR;

/// 管理和配置 XZToast 消息及消息默认样式的对象。
@interface XZToastManager : NSObject

/// 用于显示 XZToast 的视图类。
@property (nonatomic) Class viewClass;

/// 可同时展示的 toast 的数量。默认 1 。
/// - 等于 0 表示不限制数量。
/// - 小于 0 表示使用全局默认。
/// - 大于 0 表示限制具体数量。
@property (nonatomic) NSInteger maximumNumberOfToasts;

/// 文本颜色。
@property (nonatomic, null_resettable) UIColor * textColor;

/// 文本字体。
@property (nonatomic, null_resettable) UIFont  * font;

/// 背景色。
@property (nonatomic, null_resettable) UIColor * backgroundColor;

/// 投影色。
@property (nonatomic, null_resettable) UIColor * shadowColor;

/// 图标色。
@property (nonatomic, null_resettable) UIColor * color;

/// 渲染色。
@property (nonatomic, null_resettable) UIColor * tintColor;

/// 默认展示时长。值 0 表示使用全局默认时长。
@property (nonatomic) NSTimeInterval duration;

/// 设置 toast 相对默认位置的偏移值。
///
/// 默认偏移值：
/// - top: 向下偏移 +20.0 点
/// - middle: 不偏移 0.0 点
/// - bottom: 向上偏移 -40.0 点
///
/// - Parameters:
///   - offset: 偏移值，正数向下，负数向上
///   - position: toast 展示位置
- (void)setOffset:(CGFloat)offset forPosition:(XZToastPosition)position;

/// 获取指定位置 toast 的偏移值。
/// - Parameter position: toast 展示位置
- (CGFloat)offsetForPosition:(XZToastPosition)position;

/// 标记 XZToast 需要调整布局。
///
/// 自定义视图的 toast 需要刷新布局时，可调用此方法。
///
/// 如果在展示 toast 的期间，控制器的大小发生了改变，需要调用此方法来刷新布局。
///
/// 比如在容器视图为滚动视图时，可通过调用此方法刷新位置，让 toast 跟随滚动。
- (void)setNeedsLayoutToasts;

/// 如果当前已经标记了需要更新布局，那么调用此方法会立即更新布局。
///
/// > 默认情况下，每个 runloop 周期，最多只会执行一次布局刷新。
- (void)layoutToastsIfNeeded;

@end


/// 管理和维护消息显示的对象。
///
/// 每次调用 `-showToast:` 都会创建一个新的 XZToastTask 对象，以记录该此调用的详细参数。
NS_REFINED_FOR_SWIFT
@interface XZToastTask : NSObject

/// 消息。
@property (nonatomic, readonly) XZToast *toast;

/// 是否独占。此值在调用 -showToast: 方法时被记录。
///
/// - 新的 toast 需排队等待独占类型的 toast 展示完毕才能展示。
/// - 独占类型的 toast 展示时，会提前结束正在展示的普通 toast 。
@property (nonatomic, readonly) BOOL isExclusive;

/// 展示时长。此值在调用 -showToast: 方法时被记录。
@property (nonatomic, readonly) NSTimeInterval duration;

/// 展示位置。此值在调用 -showToast: 方法时被记录。
@property (nonatomic, readonly) XZToastPosition position;

/// XZToastTask 对象只能在内部创建使用。
- (instancetype)init NS_UNAVAILABLE;

/// 隐藏（移除）当前提示信息。
/// - Parameter completion: 提示信息隐藏后执行的回调
- (void)hide:(void (^_Nullable)(void))completion;

@end

/// 消息视图协议。
///
/// 自定义消息视图，需实现此协议，才能使用 XZToast 提供的通用方法。
@protocol XZToastView <NSObject>

@optional
/// 消息样式。
@property (nonatomic, readonly) XZToastStyle style;

/// 消息文本。
@property (nonatomic, copy, nullable) NSString *text;

/// 消息图片。
@property (nonatomic, strong, nullable) UIImage *image;

/// 消息进度。默认情况下，仅 loading 类型的提示消息支持。
@property (nonatomic) CGFloat progress;

/// 消息视图开始转场，将进入显示状态。
///
/// 如果视图被复用，那么视图每次被复用时，此方法也会被调用，即使视图已经在控制器中。
///
/// 本方法在执行入场动画前调用，可搭配``layoutSubviews``（动画中）、``toast:didShowInViewController:``（动画后）方法，控制动画转场效果。
///
/// - Parameter toast: 消息
/// - Parameter viewController: 视图控制器
- (void)toast:(XZToast *)toast willShowInViewController:(UIViewController *)viewController;

/// 消息视图完成转场，已进入显示状态。
///
/// 本方法在入场动画完成后调用，可搭配``toast:willShowInViewController:``（动画前）、``layoutSubviews``（动画中）方法，控制动画转场效果。
///
/// - Parameters:
///   - toast: 消息
///   - viewController: 视图控制器
- (void)toast:(XZToast *)toast didShowInViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
