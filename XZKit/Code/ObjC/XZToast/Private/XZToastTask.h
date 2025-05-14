//
//  XZToastTask.h
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import <Foundation/Foundation.h>
#import "XZToast.h"
#import "XZToastShadowView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, XZToastHideReason) {
    /// 展示完成，或被外部提前取消
    XZToastHideReasonNormal = +1,
    /// 数量超过限制被取消
    XZToastHideReasonExceed = -1
};

typedef NS_ENUM(NSInteger, XZToastMoveDirection) {
    XZToastMoveDirectionLand = +1,
    XZToastMoveDirectionNone = +0,
    XZToastMoveDirectionRise = -1
};

@class XZToastManager;

@interface XZToastTask : XZToast {
    @package
    /// 为了方便计算 toastView 的 frame 而设置。
    CGRect _frame;
    /// 标记 `_frame` 值需要更新。
    BOOL _needsUpdateFrame;
}

/// 复用模式下，该属性由外部复制，否则懒加载。
@property (nonatomic, strong) XZToastShadowView *wrapperView;

/// 独占的 toast 不会与其它 toast 同时显示：
/// - 展示时，带背景，且立即顶掉正在展示的所有 toast
/// - 其它 toast 展示时，会被立即顶掉
@property (nonatomic, readonly) BOOL isExclusive;

@property (nonatomic, readonly) NSTimeInterval duration;

@property (nonatomic, readonly) XZToastPosition position;

/// 运动方向。
/// 1. 显示时，仅对在中部展示的  toast 生效，决定旧 toast 被新 toast 挤出中间位置时，是挤向上方（YES），还是挤向下方（NO）。
@property (nonatomic) XZToastMoveDirection moveDirection;

// 如果 toast 是否为因为数量超限而被移除（值为-1），隐藏时，标记在顶部或底部展示的 toast 会以挤出的方向动画。
@property (nonatomic) XZToastHideReason hideReason;

/// 标记 view 是否为复用视图。
/// 如果 toast 未展示就直接丢弃，也会标记此属性为 YES 以避免处理视图。
@property (nonatomic, setter=setViewReused:) BOOL isViewReused;

/// 开启任务定时器。
- (void)resume:(void (^)(XZToastTask *task))block;

@property (nonatomic, readonly) BOOL isCancelled;
/// 终止 resume 倒计时，并标记已取消。
- (void)cancel;

/// 发送 task 结束，并清理内存。
- (void)finish;

- (instancetype)initWithView:(UIView *)view NS_UNAVAILABLE;
- (instancetype)initWithManager:(XZToastManager *)manager view:(UIView<XZToastView> *)view duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak, readonly) XZToastManager *manager;

- (void)setNeedsUpdateFrame;
- (void)hide:(void (^_Nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
