//
//  XZToastTask.m
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import "XZToastTask.h"
#import "XZToastWrapperView.h"
#import "XZToastManager.h"

@implementation XZToastTask {
    dispatch_block_t _timer;
    XZToastCompletion _completion;
}

@dynamic view;

- (instancetype)initWithManager:(XZToastManager *)manager view:(UIView<XZToastView> *)view duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion {
    self = [super initWithView:view];
    if (self) {
        _manager       = manager;
        _wrapperView   = nil;
        _hideReason    = XZToastHideReasonNormal;
        _moveDirection = XZToastMoveDirectionNone;
        _duration      = duration;
        _position      = position;
        _isExclusive   = exclusive;
        _completion    = completion;
        _isCancelled   = NO;
        _needsUpdateFrame = YES;
    }
    return self;
}

- (void)hide:(void (^)(void))completion {
    [_manager hideToast:self completion:completion];
}

#pragma mark - <XZToastView>

- (void)setText:(NSString *)text {
    [super setText:text];
    [self setNeedsUpdateFrame];
}

@synthesize wrapperView = _wrapperView;

- (XZToastWrapperView *)wrapperView {
    if (_wrapperView == nil) {
        _wrapperView = [[XZToastWrapperView alloc] initWithView:self.view];
        _wrapperView.task = self;
    }
    return _wrapperView;
}

- (void)setWrapperView:(XZToastWrapperView *)wrapperView {
    if (_wrapperView != wrapperView) {
        _wrapperView.task = nil;
        _wrapperView = wrapperView;
        _wrapperView.task = self;
    }
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

- (void)setNeedsUpdateFrame {
    if (_needsUpdateFrame) {
        return;
    }
    _needsUpdateFrame = YES;
    [self.manager setNeedsLayoutToasts];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p: %@, wrapper: %@, view: %@>", self, self.class, _wrapperView, self.view];
}

@end
