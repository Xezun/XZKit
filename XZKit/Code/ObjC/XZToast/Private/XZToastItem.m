//
//  XZToastItem.m
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import "XZToastItem.h"

@implementation XZToastItem

- (instancetype)initWithToastView:(UIView *)toastView duration:(NSTimeInterval)duration position:(NSDirectionalRectEdge)position offset:(CGFloat)offset isExclusive:(BOOL)isExclusive completion:(XZToastShowCompletion)completion {
    self = [super init];
    if (self) {
        _toastView = toastView;
        _duration = duration;
        _position = position;
        _offset = offset;
        _isExclusive = isExclusive;
        _showCompletion = completion;
        _isDone = YES;
        _isCancelled = NO;
    }
    return self;
}



- (void)cancel {
    if (!_isCancelled) {
        dispatch_block_cancel(_task);
        _task = nil;
        _isDone = NO;
        _isCancelled = YES;
    }
}

@end
