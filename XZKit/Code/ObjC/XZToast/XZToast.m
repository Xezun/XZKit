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
    XZToastTextView *_textView = [[XZToastTextView alloc] init];
    _textView.text = text;
    return [[XZToast alloc] initWithView:_textView];
}

+ (XZToast *)loadingToast:(NSString *)text {
    XZToastActivityIndicatorView *_toastView = [[XZToastActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 70.0, 100.0)];
    _toastView.text = text;
    [_toastView startAnimating];
    return [[XZToast alloc] initWithView:_toastView];
}

@end
