//
//  XZToastTask.h
//  XZToast
//
//  Created by Xezun on 2025/4/30.
//

#import <Foundation/Foundation.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZToast.h>
#import <XZKit/XZToastWrapperView.h>
#else
#import "XZToast.h"
#import "XZToastWrapperView.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// 将 Toast 移除的原因。
typedef NS_ENUM(NSInteger, XZToastHideReason) {
    /// 展示完成，或被外部提前取消。移除效果为渐隐。
    XZToastHideReasonNormal = +1,
    /// 数量超过限制被取消。移除效果，挤出位置。
    XZToastHideReasonExceed = -1
};

/// 展示 Toast 的视图，在执行动画时的运动方向。
typedef NS_ENUM(NSInteger, XZToastMoveDirection) {
    /// 向下移动
    XZToastMoveDirectionLand = +1,
    /// 不移动
    XZToastMoveDirectionNone = +0,
    /// 向上移动
    XZToastMoveDirectionRise = -1
};

@class XZToastManager;

@interface XZToastTask () {
    @package
    /// 为了方便计算 toastView 的 frame 而设置。
    CGRect _frame;
}

@property (nonatomic, unsafe_unretained, readonly) XZToastManager *manager;

- (instancetype)initWithManager:(XZToastManager *)manager toast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion NS_DESIGNATED_INITIALIZER;

/// 容器视图。懒加载。
@property (nonatomic, strong, nullable) XZToastWrapperView *wrapperView;

/// 容器视图是否可以复用。
@property (nonatomic, setter=setViewReusable:) BOOL isViewReusable;

/// 容器视图，是否已经复用。
@property (nonatomic, setter=setViewReused:) BOOL isViewReused;

/// 运动方向。
/// 1. 显示时，仅对在中部展示的  toast 生效，决定旧 toast 被新 toast 挤出中间位置时，是挤向上方（YES），还是挤向下方（NO）。
@property (nonatomic) XZToastMoveDirection moveDirection;

/// 标记 toast 被移除的原因。
@property (nonatomic) XZToastHideReason hideReason;

/// 任务即将开始，开启任务定时器。
- (void)resume:(void (^)(XZToastTask *task))block;

/// 是否已取消。
@property (nonatomic, readonly) BOOL isCancelled;

/// 终止 resume 倒计时，并标记已取消。必须调用 -finish 方法才能结束生命周期。
- (void)cancel;

/// 发送 task 结束，并清理内存。
- (void)finish;

@end

NS_ASSUME_NONNULL_END
