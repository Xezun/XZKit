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

+ (XZToast *)messageToast:(NSString *)text {
    XZToastTextView *toastView = [[XZToastTextView alloc] init];
    toastView.text = text;
    return [[self alloc] initWithView:toastView];
}

+ (XZToast *)loadingToast:(NSString *)text {
    XZToastActivityIndicatorView *toastView = [[XZToastActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 100.0, 100.0)];
    [toastView startAnimating];
    toastView.text = text;
    return [[self alloc] initWithView:toastView];
}

@end
