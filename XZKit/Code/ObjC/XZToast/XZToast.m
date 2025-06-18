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
static CGFloat   _toastOffsets[3]       = {+20.0, 0.0, -20.0};
static UIColor * _textColor             = nil;
static UIFont  * _font                  = nil;
static UIColor * _backgroundColor       = nil;
static UIColor * _shadowColor           = nil;

@implementation XZToast

+ (NSInteger)maximumNumberOfToasts {
    return _maximumNumberOfToasts;
}

+ (void)setMaximumNumberOfToasts:(NSInteger)maximumNumberOfToasts {
    _maximumNumberOfToasts = MAX(1, maximumNumberOfToasts);
}

+ (CGFloat)toastOffsetForPosition:(XZToastPosition)position {
    return _toastOffsets[position];
}

+ (void)setToastOffset:(CGFloat)offset forPosition:(XZToastPosition)position {
    _toastOffsets[position] = offset;
}

+ (UIColor *)textColor {
    if (_textColor) {
        return _textColor;
    }
    return UIColor.whiteColor;
}

+ (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
}

+ (UIColor *)backgroundColor {
    if (_backgroundColor) {
        return _backgroundColor;
    }
    return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
        if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            return [UIColor colorWithWhite:0.3 alpha:0.9];
        }
        return [UIColor colorWithWhite:0.0 alpha:0.7];
    }];
}

+ (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
}

+ (UIFont *)font {
    if (_font) {
        return _font;
    }
    return [UIFont monospacedDigitSystemFontOfSize:17.0 weight:(UIFontWeightRegular)];
}

+ (void)setFont:(UIFont *)font {
    _font = font;
}

+ (UIColor *)shadowColor {
    if (_shadowColor == nil) {
        _shadowColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithWhite:0.2 alpha:1.0];
            }
            return UIColor.blackColor;
        }];
    }
    return _shadowColor;
}

+ (void)setShadowColor:(UIColor *)shadowColor {
    _shadowColor = shadowColor;
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

- (id)copyWithZone:(NSZone *)zone {
    return [[self.class alloc] initWithView:_view];
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

+ (instancetype)sharedToast:(XZToastStyle)style text:(NSString *)text {
    return [self sharedToast:style text:text image:nil];
}

+ (instancetype)sharedToast:(XZToastStyle)style image:(UIImage *)image {
    return [self sharedToast:style text:nil image:image];
}

@end
