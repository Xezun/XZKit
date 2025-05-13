//
//  XZToast.m
//  XZToast
//
//  Created by 徐臻 on 2025/3/2.
//

#import "XZToast.h"
#import "XZToastTextView.h"
#import "XZToastTextIconView.h"

NSTimeInterval const XZToastAnimationDuration = 0.35;

@implementation XZToast

@synthesize view = _view;

- (instancetype)initWithView:(UIView<XZToastView> *)view {
    self = [super init];
    if (self) {
        _view = view;
    }
    return self;
}

- (NSString *)text {
    return self.view.text;
}

- (void)setText:(NSString *)text {
    self.view.text = text;
    [self.view xz_setNeedsLayoutToasts];
}

+ (instancetype)viewToast:(UIView<XZToastView> *)view {
    return [[self alloc] initWithView:view];
}

+ (instancetype)messageToast:(NSString *)text {
    XZToastTextView *toastView = [[XZToastTextView alloc] init];
    toastView.text = text;
    return [[self alloc] initWithView:toastView];
}

+ (instancetype)loadingToast:(NSString *)text {
    XZToastActivityIndicatorView *toastView = [[XZToastActivityIndicatorView alloc] init];
    [toastView startAnimating];
    toastView.text = text;
    return [[self alloc] initWithView:toastView];
}

+ (instancetype)successToast:(NSString *)text {
    XZToastTextImageView *toastView = [[XZToastTextImageView alloc] initWithImage:XZToastBase64ImageSuccess];
    toastView.text = text;
    return [[self alloc] initWithView:toastView];
}

+ (instancetype)failureToast:(NSString *)text {
    XZToastTextImageView *toastView = [[XZToastTextImageView alloc] initWithImage:XZToastBase64ImageFailure];
    toastView.text = text;
    return [[self alloc] initWithView:toastView];
}

+ (instancetype)warningToast:(NSString *)text {
    XZToastTextImageView *toastView = [[XZToastTextImageView alloc] initWithImage:XZToastBase64ImageWarning];
    toastView.text = text;
    return [[self alloc] initWithView:toastView];
}

+ (instancetype)waitingToast:(NSString *)text {
    XZToastTextImageView *toastView = [[XZToastTextImageView alloc] initWithImage:XZToastBase64ImageWaiting];
    toastView.text = text;
    return [[self alloc] initWithView:toastView];
}

@end
