//
//  XZToastTask.h
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import <Foundation/Foundation.h>
#import "XZToast.h"
#import "XZToastContainerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZToastTask : XZToast {
    @package
    /// 为了方便计算 toastView 的 frame 而设置。
    CGRect _frame;
}

@property (nonatomic, readonly) XZToastContainerView *view;

/// 独占的 toast 不会与其它 toast 同时显示：
/// - 展示时，带背景，且立即顶掉正在展示的所有 toast
/// - 其它 toast 展示时，会被立即顶掉
@property (nonatomic, readonly) BOOL isExclusive;

@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) XZToastPosition position;
/// 记录动画执行方向。
/// 1. 显示时，仅对在中部展示的  toast 生效，决定旧 toast 被新 toast 挤出中间位置时，是挤向上方（YES），还是挤向下方（NO）。
@property (nonatomic) BOOL showDirection;
// 隐藏时，标记 toast 是否为因为数量超限而被移除，在顶部或底部展示的 toast 会以挤出的方向动画。
@property (nonatomic) BOOL hideDirection;

@property (nonatomic, setter=setViewReused:) BOOL isViewReused;

/// 开启任务定时器。
- (void)resume:(void (^)(XZToastTask *task))block;

@property (nonatomic, readonly) BOOL isCancelled;
/// 终止 resume 倒计时，并标记已取消。
- (void)cancel;

/// 发送 task 结束，并清理内存。
- (void)finish;

- (instancetype)initWithView:(UIView *)view NS_UNAVAILABLE;
- (instancetype)initWithView:(XZToastContainerView *)view duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
