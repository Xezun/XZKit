//
//  XZToast.m
//  XZToast
//
//  Created by Xezun on 2025/3/2.
//

#import "XZToast.h"
#import "XZToastView.h"

NSTimeInterval const XZToastAnimationDuration = 0.35;

@implementation XZToast {
    XZToastStyle _style;
    NSString   * _text;
    UIImage    * _image;
    CGFloat      _progress;
}

- (XZToastStyle)style {
    return _style;
}

- (__kindof UIView *)view {
    return _view;
}

- (instancetype)initWithStyle:(XZToastStyle)style view:(nullable UIView *)view {
    self = [super init];
    if (self) {
        _style = style;
        _view  = view;
    }
    return self;
}

+ (instancetype)toastWithStyle:(XZToastStyle)style text:(NSString *)text image:(UIImage *)image progress:(CGFloat)progress {
    XZToast * const toast = [[self alloc] initWithStyle:style view:nil];
    toast->_text     = text.copy;
    toast->_image    = image;
    toast->_progress = progress;
    return toast;
}

+ (instancetype)toastWithStyle:(XZToastStyle)style text:(NSString *)text image:(UIImage *)image {
    return [self toastWithStyle:style text:text image:image progress:-1.0];
}

- (id)copyWithZone:(NSZone *)zone {
    XZToast * const toast = [[self.class alloc] initWithStyle:_style view:_view];
    toast->_text     = _text.copy;
    toast->_image    = _image;
    toast->_progress = _progress;
    return toast;
}

- (NSString *)description {
    NSString *view  = _view ? [NSString stringWithFormat:@"%p", _view] : @"nil";
    NSString *text  = [self.text stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    NSString *image = _image ? [NSString stringWithFormat:@"%p", _image] : @"nil";
    NSString *style = NSStringFromXZToastStyle(_style);
    return [NSString stringWithFormat:@"<%@: %p, style: %@, view: %@, text: %@, image: %@, progress: %.2f>", self.class, self, style, view, text, image, self.progress];
}

#pragma mark - 便利初始化方法

+ (instancetype)messageToast:(NSString *)text {
    UIImage * const image = [self imageForStyle:(XZToastStyleMessage)];
    return [self toastWithStyle:XZToastStyleMessage text:text image:image];
}

+ (instancetype)messageToast:(NSString *)text image:(UIImage *)image {
    return [self toastWithStyle:XZToastStyleMessage text:text image:image];
}

+ (instancetype)loadingToast:(NSString *)text {
    UIImage * const image = [self imageForStyle:(XZToastStyleLoading)];
    return [self toastWithStyle:XZToastStyleLoading text:text image:image];
}

+ (instancetype)loadingToast:(NSString *)text image:(UIImage *)image {
    return [self toastWithStyle:XZToastStyleLoading text:text image:image];
}

+ (instancetype)loadingToast:(NSString *)text progress:(CGFloat)progress {
    UIImage * const image = [self imageForStyle:(XZToastStyleLoading)];
    return [self toastWithStyle:XZToastStyleLoading text:text image:image progress:progress];
}

+ (instancetype)successToast:(NSString *)text {
    UIImage * const image = [self imageForStyle:(XZToastStyleSuccess)];
    return [self toastWithStyle:XZToastStyleSuccess text:text image:image];
}

+ (instancetype)successToast:(NSString *)text image:(UIImage *)image {
    return [self toastWithStyle:XZToastStyleSuccess text:text image:image];
}

+ (instancetype)failureToast:(NSString *)text {
    UIImage * const image = [self imageForStyle:(XZToastStyleFailure)];
    return [self toastWithStyle:XZToastStyleFailure text:text image:image];
}

+ (instancetype)failureToast:(NSString *)text image:(UIImage *)image {
    return [self toastWithStyle:XZToastStyleFailure text:text image:image];
}

+ (instancetype)warningToast:(NSString *)text {
    UIImage * const image = [self imageForStyle:(XZToastStyleWarning)];
    return [self toastWithStyle:XZToastStyleWarning text:text image:image];
}

+ (instancetype)warningToast:(NSString *)text image:(UIImage *)image {
    return [self toastWithStyle:XZToastStyleWarning text:text image:image];
}

+ (instancetype)waitingToast:(NSString *)text {
    UIImage * const image = [self imageForStyle:(XZToastStyleWaiting)];
    return [self toastWithStyle:XZToastStyleWaiting text:text image:image];
}

+ (instancetype)waitingToast:(NSString *)text image:(UIImage *)image {
    return [self toastWithStyle:XZToastStyleWaiting text:text image:image];
}

@end

@implementation XZToast (XZExtendedToast)

- (NSString *)text {
    return _text;
}

- (void)setText:(NSString *)text {
    if ((_text ? ![_text isEqualToString:text] : (text != nil))) {
        _text = text.copy;
        id<XZToastView> const view = self.view;
        if ([view conformsToProtocol:@protocol(XZToastView)] && [view respondsToSelector:@selector(setText:)]) {
            view.text = text;
        }
    }
}

- (UIImage *)image {
    return _image;
}

- (void)setImage:(UIImage *)image {
    if (_image != image) {
        _image = image;
        id<XZToastView> const view = self.view;
        if ([view conformsToProtocol:@protocol(XZToastView)] && [view respondsToSelector:@selector(setImage:)]) {
            view.image = image;
        }
    }
}

- (CGFloat)progress {
    return _progress;
}

- (void)setProgress:(CGFloat)progress {
    if (_progress != progress) {
        _progress = MAX(0, MIN(1.0, progress));
        id<XZToastView> const view = self.view;
        if ([view conformsToProtocol:@protocol(XZToastView)] && [view respondsToSelector:@selector(setProgress:)]) {
            view.progress = progress;
        }
    }
}

@end

static Class          _viewClass             = Nil;
static NSInteger      _maximumNumberOfToasts = 1;
static CGFloat        _toastOffsets[3]       = {+20.0, 0.0, -40.0};
static UIColor *      _textColor             = nil;
static UIFont  *      _font                  = nil;
static UIColor *      _backgroundColor       = nil;
static UIColor *      _shadowColor           = nil;
static UIColor *      _color                 = nil;
static UIColor *      _tintColor            = nil;
static NSTimeInterval _duration              = 1.0;
static NSMutableDictionary<NSNumber *, UIImage *> *_styleImages = nil;
static UIImage * _Nullable XZToastStyleImage(XZToastStyle style);

@implementation XZToast (XZToastAppearance)

+ (Class)viewClass {
    if (_viewClass == nil) {
        _viewClass = [XZToastView class];
    }
    return _viewClass;
}

+ (void)setViewClass:(Class)viewClass {
    NSParameterAssert([viewClass isKindOfClass:UIView.class]);
    _viewClass = viewClass;
}

+ (NSInteger)maximumNumberOfToasts {
    return _maximumNumberOfToasts;
}

+ (void)setMaximumNumberOfToasts:(NSInteger)maximumNumberOfToasts {
    _maximumNumberOfToasts = MAX(0, maximumNumberOfToasts);
}

+ (CGFloat)offsetForPosition:(XZToastPosition)position {
    return _toastOffsets[position];
}

+ (void)setOffset:(CGFloat)offset forPosition:(XZToastPosition)position {
    _toastOffsets[position] = offset;
}

+ (UIColor *)textColor {
    if (!_textColor) {
        _textColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithWhite:0.90 alpha:1.0];
            }
            return UIColor.whiteColor;
        }];
    }
    return _textColor;
}

+ (void)setTextColor:(UIColor *)textColor {
    NSParameterAssert([textColor isKindOfClass:UIColor.class]);
    _textColor = textColor;
}

+ (UIColor *)backgroundColor {
    if (!_backgroundColor) {
        _backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithWhite:0.3 alpha:0.95];
            }
            return [UIColor colorWithWhite:0.1 alpha:0.95];
        }];
    }
    return _backgroundColor;
}

+ (void)setBackgroundColor:(UIColor *)backgroundColor {
    NSParameterAssert([backgroundColor isKindOfClass:UIColor.class]);
    _backgroundColor = backgroundColor;
}

+ (UIFont *)font {
    if (!_font) {
        _font = [UIFont monospacedSystemFontOfSize:17.0 weight:(UIFontWeightRegular)];
    }
    return _font;
}

+ (void)setFont:(UIFont *)font {
    NSParameterAssert([font isKindOfClass:UIFont.class]);
    _font = font;
}

+ (UIColor *)shadowColor {
    if (_shadowColor == nil) {
        _shadowColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithWhite:0.30 alpha:1.0];
            }
            return UIColor.blackColor;
        }];
    }
    return _shadowColor;
}

+ (void)setShadowColor:(UIColor *)shadowColor {
    NSParameterAssert([shadowColor isKindOfClass:UIColor.class]);
    _shadowColor = shadowColor;
}

+ (UIColor *)color {
    if (_color == nil) {
        _color = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithWhite:0.80 alpha:1.0];
            }
            return UIColor.whiteColor;
        }];
    }
    return _color;
}

+ (void)setColor:(UIColor *)color {
    NSParameterAssert([color isKindOfClass:UIColor.class]);
    _color = color;
}

+ (UIColor *)tintColor {
    if (_tintColor == nil) {
        _tintColor = UIColor.systemBlueColor;
    }
    return _tintColor;
}

+ (void)setTintColor:(UIColor *)tintColor {
    NSParameterAssert([tintColor isKindOfClass:UIColor.class]);
    _tintColor = tintColor;
}

+ (NSTimeInterval)duration {
    return _duration;
}

+ (void)setDuration:(NSTimeInterval)duration {
    _duration = duration > 0 ? duration : 1.0;
}

+ (UIImage *)imageForStyle:(XZToastStyle)style {
    return _styleImages[@(style)] ?: XZToastStyleImage(style);
}

+ (void)setImage:(UIImage *)image forStyle:(XZToastStyle)style {
    if (image == nil) {
        _styleImages[@(style)] = image;
    } else {
        if (_styleImages == nil) {
            _styleImages = [NSMutableDictionary dictionaryWithCapacity:16];
        }
        _styleImages[@(style)] = image;
    }
}

@end


UIImage *XZToastStyleImage(XZToastStyle style) {
    UIImage * image = nil;
    switch (style) {
        case XZToastStyleMessage:
            return nil;
            break;
        case XZToastStyleLoading:
            return nil;
            break;
        case XZToastStyleSuccess:
            image = [UIImage systemImageNamed:@"checkmark.circle.fill"];
            break;
        case XZToastStyleFailure:
            image = [UIImage systemImageNamed:@"xmark.circle.fill"];
            break;
        case XZToastStyleWarning: {
            image = [UIImage systemImageNamed:@"exclamationmark.circle.fill"];
            break;
        }
        case XZToastStyleWaiting:
            if (@available(iOS 16.0, *)) {
                image = [UIImage systemImageNamed:@"timer.circle.fill"];
            } else {
                image = [UIImage systemImageNamed:@"timer"];
            }
            break;
    }
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:37.0];
    return [image imageByApplyingSymbolConfiguration:config];
}


NSString *NSStringFromXZToastStyle(XZToastStyle style) {
    switch (style) {
        case XZToastStyleMessage:
            return @"message";
        case XZToastStyleLoading:
            return @"loading";
        case XZToastStyleSuccess:
            return @"success";
        case XZToastStyleFailure:
            return @"failure";
        case XZToastStyleWarning:
            return @"warning";
        case XZToastStyleWaiting:
            return @"waiting";
        default:
            return @"unknown";
    }
}


NSString *NSStringFromXZToastPosition(XZToastPosition position) {
    switch (position) {
        case XZToastPositionTop:
            return @"top";
        case XZToastPositionMiddle:
            return @"middle";
        case XZToastPositionBottom:
            return @"bottom";
        default:
            return @"unknown";
    }
}
