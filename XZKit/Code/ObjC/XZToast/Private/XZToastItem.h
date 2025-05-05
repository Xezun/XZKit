//
//  XZToastItem.h
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import <Foundation/Foundation.h>
#import "XZToast.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZToastItem : NSObject {
    @package
    CGRect _frame;
    dispatch_block_t _task;
}
@property (nonatomic, readonly) UIView *toastView;
/// 独占的 toast 不会与其它 toast 同时显示：
/// - 展示时，带背景，且立即顶掉正在展示的所有 toast
/// - 其它 toast 展示时，会被立即顶掉
@property (nonatomic, readonly) BOOL isExclusive;

@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) NSDirectionalRectEdge position;
@property (nonatomic, readonly) CGFloat offset;

/// 展示 toast 时绑定的回调，在 toast 消失后执行，finished 表示 toast 是否按预期时长展示。
@property (nonatomic, copy, readonly, nullable) XZToastShowCompletion showCompletion;

/// 在 \_showingToasts 中的 toast 有值。
@property (nonatomic, strong, nullable) dispatch_block_t task;
@property (nonatomic, setter=setDone:) BOOL isDone;
@property (nonatomic, readonly) BOOL isCancelled;
- (void)cancel;

- (instancetype)initWithToastView:(UIView *)toastView duration:(NSTimeInterval)duration position:(NSDirectionalRectEdge)position offset:(CGFloat)offset isExclusive:(BOOL)isExclusive completion:(XZToastShowCompletion)completion;
@end

@interface XZToastOperation : NSOperation

@end

NS_ASSUME_NONNULL_END
