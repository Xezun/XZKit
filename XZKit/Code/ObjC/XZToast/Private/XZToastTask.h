//
//  XZToastTask.h
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import <Foundation/Foundation.h>
#import "XZToast.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZToastTask : NSObject {
    @package
    CGRect _frame;
}

@property (nonatomic, readonly) UIView *toastView;
/// 独占的 toast 不会与其它 toast 同时显示：
/// - 展示时，带背景，且立即顶掉正在展示的所有 toast
/// - 其它 toast 展示时，会被立即顶掉
@property (nonatomic, readonly) BOOL isExclusive;

@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) XZToastPosition position;
@property (nonatomic, readonly) CGFloat offset;

- (void)resume:(void (^)(XZToastTask *task))block;

@property (nonatomic, readonly) BOOL isCancelled;
/// 终止 resume 倒计时，并标记已取消。
- (void)cancel;

/// 发送 task 结束，并清理内存。
- (void)finish;

- (instancetype)initWithToastView:(UIView *)toastView duration:(NSTimeInterval)duration position:(XZToastPosition)position offset:(CGFloat)offset exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion;

@end

NS_ASSUME_NONNULL_END
