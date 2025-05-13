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

+ (instancetype)messageToast:(NSString *)text image:(UIImage *)image {
    if (image == nil) {
        return [self messageToast:text];
    }
    XZToastTextImageView *toastView = [[XZToastTextImageView alloc] initWithImage:image];
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
    XZToastTextImageView *toastView = [[XZToastTextImageView alloc] initWithBase64Image:XZToastBase64ImageSuccess];
    toastView.text = text;
    return [[self alloc] initWithView:toastView];
}

+ (instancetype)failureToast:(NSString *)text {
    XZToastTextImageView *toastView = [[XZToastTextImageView alloc] initWithBase64Image:XZToastBase64ImageFailure];
    toastView.text = text;
    return [[self alloc] initWithView:toastView];
}

+ (instancetype)warningToast:(NSString *)text {
    XZToastTextImageView *toastView = [[XZToastTextImageView alloc] initWithBase64Image:XZToastBase64ImageWarning];
    toastView.text = text;
    return [[self alloc] initWithView:toastView];
}

+ (instancetype)waitingToast:(NSString *)text {
    XZToastTextImageView *toastView = [[XZToastTextImageView alloc] initWithBase64Image:XZToastBase64ImageWaiting];
    toastView.text = text;
    return [[self alloc] initWithView:toastView];
}

@end
