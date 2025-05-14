//
//  XZToast.m
//  XZToast
//
//  Created by 徐臻 on 2025/3/2.
//

#import "XZToast.h"
#import "XZToastView.h"

NSTimeInterval const XZToastAnimationDuration = 0.35;

static NSInteger _maximumNumberOfToasts = 3;
static CGFloat _offsets[3] = {0, 0, 0};

@implementation XZToast

+ (NSInteger)maximumNumberOfToasts {
    return _maximumNumberOfToasts;
}

+ (void)setMaximumNumberOfToasts:(NSInteger)maximumNumberOfToasts {
    _maximumNumberOfToasts = MAX(1, maximumNumberOfToasts);
}

+ (CGFloat)offsetForToastInPosition:(XZToastPosition)position {
    return _offsets[position];
}

+ (void)setOffset:(CGFloat)offset forToastInPosition:(XZToastPosition)position {
    _offsets[position] = offset;
}

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
}

+ (instancetype)viewToast:(UIView<XZToastView> *)view {
    return [[self alloc] initWithView:view];
}

+ (instancetype)messageToast:(NSString *)text {
    return [self messageToast:text image:nil];
}

+ (instancetype)messageToast:(NSString *)text image:(UIImage *)image {
    XZToastView *toastView = [[XZToastView alloc] init];
    toastView.style = XZToastStyleMessage;
    toastView.text = text;
    toastView.image = image;
    return [[self alloc] initWithView:toastView];
}

+ (instancetype)loadingToast:(NSString *)text {
    XZToastView *toastView = [[XZToastView alloc] init];
    toastView.style = XZToastStyleLoading;
    toastView.text = text;
    [toastView startAnimating];
    return [[self alloc] initWithView:toastView];
}

+ (instancetype)successToast:(NSString *)text {
    return [self messageToast:text image:UIImageFromXZToastBase64Image(XZToastBase64ImageSuccess)];
}

+ (instancetype)failureToast:(NSString *)text {
    return [self messageToast:text image:UIImageFromXZToastBase64Image(XZToastBase64ImageFailure)];
}

+ (instancetype)warningToast:(NSString *)text {
    return [self messageToast:text image:UIImageFromXZToastBase64Image(XZToastBase64ImageWarning)];
}

+ (instancetype)waitingToast:(NSString *)text {
    return [self messageToast:text image:UIImageFromXZToastBase64Image(XZToastBase64ImageWaiting)];
}

+ (XZToast *)sharedToast:(XZToastStyle const)style text:(NSString *)text image:(UIImage *)image {
    static XZToastView * __weak _sharedToastView = nil;
    
    XZToastView *toastView = _sharedToastView;
    
    if (toastView == nil) {
        toastView = [[XZToastView alloc] init];
        _sharedToastView = toastView;
    }
    
    switch (style) {
        case XZToastStyleMessage:
            toastView.style = XZToastStyleMessage;
            toastView.text = text;
            toastView.image = image;
            break;
        case XZToastStyleLoading:
            toastView.style = XZToastStyleLoading;
            toastView.text = text;
            [toastView startAnimating];
            break;
        case XZToastStyleSuccess:
            toastView.style = XZToastStyleMessage;
            toastView.text = text;
            toastView.image = image ?: UIImageFromXZToastBase64Image(XZToastBase64ImageSuccess);
            break;
        case XZToastStyleFailure:
            toastView.style = XZToastStyleMessage;
            toastView.text = text;
            toastView.image = image ?: UIImageFromXZToastBase64Image(XZToastBase64ImageFailure);
            break;
        case XZToastStyleWarning:
            toastView.style = XZToastStyleMessage;
            toastView.text = text;
            toastView.image = image ?: UIImageFromXZToastBase64Image(XZToastBase64ImageWarning);
            break;
        case XZToastStyleWaiting:
            toastView.style = XZToastStyleMessage;
            toastView.text = text;
            toastView.image = image ?: UIImageFromXZToastBase64Image(XZToastBase64ImageWaiting);
            break;
    }
    
    return [[self alloc] initWithView:toastView];
}

@end
