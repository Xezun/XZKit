//
//  XZToastTask.m
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import "XZToastTask.h"
#import "XZToastWrapperView.h"
#import "XZToastManager.h"
#import "XZToastView.h"

@implementation XZToastTask {
    dispatch_block_t _timer;
    XZToastCompletion _completion;
}

- (instancetype)initWithManager:(XZToastManager *)manager toast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion {
    self = [super init];
    if (self) {
        _hideReason     = XZToastHideReasonNormal;
        _moveDirection  = XZToastMoveDirectionNone;
        _isCancelled    = NO;
        _isViewReused   = NO;
        _isViewReusable = NO;
        _manager        = manager;
        _toast          = toast;
        _duration       = duration;
        _position       = position;
        _isExclusive    = exclusive;
        _completion     = completion;
    }
    return self;
}

- (void)setWrapperView:(XZToastWrapperView *)wrapperView {
    if (_wrapperView != wrapperView) {
        _wrapperView.task = nil;
        _wrapperView = wrapperView;
        _wrapperView.task = self;
    }
}

- (void)hide:(void (^)(void))completion {
    [_manager hideToastWithTask:self completion:completion];
}

- (void)resume:(void (^)(XZToastTask * _Nonnull))block {
    typeof(self) __weak weakTask = self;
    _timer = dispatch_block_create(DISPATCH_BLOCK_NO_QOS_CLASS, ^{
        XZToastTask * const task = weakTask;
        if (task == nil) {
            return;
        }
        task->_timer = nil;
        block(task);
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((XZToastAnimationDuration + self.duration) * NSEC_PER_SEC)), dispatch_get_main_queue(), _timer);
}

- (void)cancel {
    if (_timer) {
        dispatch_block_cancel(_timer);
        _timer = nil;
    }
    _isCancelled = YES;
}

- (void)finish {
    if (_timer) {
        dispatch_block_cancel(_timer);
        _timer = nil;
    }
    if (_completion) {
        _completion(!_isCancelled);
        _completion = nil;
    }
}

- (NSString *)description {
    NSString *position = NSStringFromXZToastPosition(_position);
    NSString *duration = [NSString stringWithFormat:@"%.2f", _duration];
    NSString *wrapper  = _wrapperView ? [NSString stringWithFormat:@"%p", _wrapperView] : @"nil";
    return [NSString stringWithFormat:@"<%p: %@, toast: %p, wrapperView: %@, position: %@, duration: %@, isExclusive: %d, isCancelled: %d>", self, self.class, _toast, wrapper, position, duration, _isExclusive, _isCancelled];
}

@end
