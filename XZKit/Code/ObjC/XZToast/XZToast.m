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

@interface XZMessageToast : XZToast
@end

@interface XZLoadingToast : XZMessageToast
@end


@implementation XZToast

@synthesize view = _view;

- (instancetype)initWithView:(UIView *)view {
    self = [super init];
    if (self) {
        _view = view;
    }
    return self;
}

- (NSString *)text {
    return nil;
}

- (void)setText:(NSString *)text {
    
}

- (void)startAnimating {
    
}

- (void)stopAnimating {
    
}

- (BOOL)isAnimating {
    return NO;
}

+ (XZToast *)messageToast:(NSString *)text {
    XZToastTextView *_textView = [[XZToastTextView alloc] init];
    _textView.text = text;
    return [[XZMessageToast alloc] initWithView:_textView];
}

+ (XZToast *)loadingToast:(NSString *)text {
    XZToastActivityIndicatorView *_toastView = [[XZToastActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 70.0, 100.0)];
    _toastView.text = text;
    [_toastView startAnimating];
    return [[XZLoadingToast alloc] initWithView:_toastView];
}

@end


@implementation XZMessageToast

- (NSString *)text {
    return [(XZToastTextView *)self.view text];
}

- (void)setText:(NSString *)text {
    [(XZToastTextView *)self.view setText:text];
}

@end

@implementation XZLoadingToast

- (void)startAnimating {
    [(XZToastActivityIndicatorView *)self.view startAnimating];
}

- (void)stopAnimating {
    [(XZToastActivityIndicatorView *)self.view stopAnimating];
}

- (BOOL)isAnimating {
    return [(XZToastActivityIndicatorView *)self.view isAnimating];
}

@end


