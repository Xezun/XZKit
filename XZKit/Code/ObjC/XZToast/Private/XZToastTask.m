//
//  XZToastTask.m
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import "XZToastTask.h"
#import "XZToastShadowView.h"

@implementation XZToastTask {
    dispatch_block_t _timer;
    XZToastCompletion _completion;
}

@dynamic view;

- (instancetype)initWithView:(XZToastShadowView *)view duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion {
    self = [super initWithView:view];
    if (self) {
        _hideReason  = XZToastHideReasonNormal;
        _moveDirection = XZToastMoveDirectionNone;
        _duration    = duration;
        _position    = position;
        _isExclusive = exclusive;
        _completion  = completion;
        _isCancelled = NO;
    }
    return self;
}

- (void)resume:(void (^)(XZToastTask * _Nonnull))block {
    typeof(self) __weak wtask = self;
    _timer = dispatch_block_create(DISPATCH_BLOCK_NO_QOS_CLASS, ^{
        XZToastTask * const otask = wtask;
        if (otask == nil) {
            return;
        }
        block(otask);
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((XZToastAnimationDuration + self.duration) * NSEC_PER_SEC)), dispatch_get_main_queue(), _timer);
}

- (void)finish {
    _timer = nil;
    if (_completion) {
        _completion(!_isCancelled);
        _completion = nil;
    }
}

- (void)cancel {
    if (_timer) {
        dispatch_block_cancel(_timer);
        _timer = nil;
    }
    _isCancelled = YES;
}

@end
