//
//  XZToastTask.h
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import <Foundation/Foundation.h>
#import "XZToast.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZToastTask : XZToast {
    @package
    /// 为了方便计算 toastView 的 frame 而设置。
    CGRect _frame;
}

/// 独占的 toast 不会与其它 toast 同时显示：
/// - 展示时，带背景，且立即顶掉正在展示的所有 toast
/// - 其它 toast 展示时，会被立即顶掉
@property (nonatomic, readonly) BOOL isExclusive;

@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) XZToastPosition position;
@property (nonatomic) BOOL direction;

/// 开启任务定时器。
- (void)resume:(void (^)(XZToastTask *task))block;

@property (nonatomic, readonly) BOOL isCancelled;
/// 终止 resume 倒计时，并标记已取消。
- (void)cancel;

/// 发送 task 结束，并清理内存。
- (void)finish;

- (instancetype)initWithView:(UIView *)view NS_UNAVAILABLE;
- (instancetype)initWithView:(UIView *)view duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
