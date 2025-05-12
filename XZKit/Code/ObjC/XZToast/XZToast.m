//
//  XZToast.m
//  XZToast
//
//  Created by 徐臻 on 2025/3/2.
//

#import "XZToast.h"
#import "XZToastTextView.h"
#import "XZToastActivityIndicatorView.h"

NSTimeInterval const XZToastAnimationDuration = 0.35;

@implementation XZToast

@synthesize view = _view;

- (instancetype)initWithView:(UIView *)view {
    self = [super init];
    if (self) {
        _view = view;
    }
    return self;
}

+ (instancetype)viewToast:(UIView *)view {
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
    XZToastSuccessView *successView = [[XZToastSuccessView alloc] init];
    XZToastTextIconView *toastView = [[XZToastTextIconView alloc] initWithFrame:CGRectMake(0, 0, 115, 115) iconView:successView];
    toastView.text = text;
    return [[self alloc] initWithView:toastView];
}

+ (instancetype)failureToast:(NSString *)text {
    XZToastFailureView *statusView = [[XZToastFailureView alloc] init];
    XZToastTextIconView *toastView = [[XZToastTextIconView alloc] initWithFrame:CGRectMake(0, 0, 115, 115) iconView:statusView];
    toastView.text = text;
    return [[self alloc] initWithView:toastView];
}

@end
