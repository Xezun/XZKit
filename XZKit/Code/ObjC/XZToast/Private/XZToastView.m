//
//  XZToastView.m
//  XZToast
//
//  Created by 徐臻 on 2025/5/9.
//

#import "XZToastView.h"
#import "XZGeometry.h"

#define kPaddingT 15.0
#define kPaddingL 15.0
#define kPaddingR 15.0
#define kPaddingB 15.0
#define kIconSize 50.0
#define kTextLine 20.0
#define kSpacing  10.0

@interface XZToastProgressView : UIView
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *trackColor;
@property (nonatomic) CGFloat progress;
@end

@interface XZToastView ()
@end

@implementation XZToastView {
    @package
    UILabel *_textLabel;
    UIView *_iconView;
}

- (instancetype)init {
    CGFloat const width = kPaddingT + kIconSize + kSpacing + kTextLine + kPaddingB;
    return [self initWithFrame:CGRectMake(0, 0, width, width)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor    = XZToast.backgroundColor;
        self.layer.cornerRadius = 6.0;
        self.clipsToBounds      = true;
        
        _style = XZToastStyleMessage;
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor     = XZToast.textColor; // UIColor.whiteColor;
        _textLabel.font          = XZToast.font;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 3;
        _textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect const bounds = self.bounds;
    
    {
        CGFloat const x = bounds.origin.x + (bounds.size.width - kIconSize) * 0.5;
        CGFloat const y = kPaddingT;
        CGFloat const w = kIconSize;
        CGFloat const h = kIconSize;
        CGSize  const iconSize = [_iconView sizeThatFits:CGSizeMake(w, h)];
        _iconView.frame = CGRectScaleAspectRatioInsideWithMode(CGRectMake(x, y, w, h), iconSize, UIViewContentModeCenter) ;
    }
    
    {
        CGFloat const minY = _iconView ? (kPaddingT + kIconSize + kSpacing) : (kPaddingT);
        CGFloat const maxH = bounds.size.height - minY - kPaddingB;
        CGSize  const textSize = [_textLabel sizeThatFits:CGSizeMake(bounds.size.width - kPaddingL - kPaddingR, 0)];
        CGFloat const w = MIN(bounds.size.width - kPaddingL - kPaddingR, textSize.width);
        CGFloat const h = MAX(textSize.height, kTextLine);
        CGFloat const x = bounds.origin.x + (bounds.size.width - w) * 0.5;
        CGFloat const y = CGRectGetMaxY(bounds) - kPaddingB - h;
        _textLabel.frame = CGRectMake(x, MAX(y, minY), w, MIN(h, maxH));
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize const iconSize = [_iconView sizeThatFits:CGSizeMake(kIconSize, kIconSize)];
    CGSize const textSize = [_textLabel sizeThatFits:CGSizeMake(size.width - kPaddingL - kPaddingR, 0)];
    
    BOOL const hasIcon = (iconSize.width > 0 && iconSize.height > 0);
    BOOL const hasText = (textSize.width > 0);
    
    if (hasIcon && hasText) {
        CGFloat const h = kPaddingT + kIconSize + kSpacing + MAX(textSize.height, kTextLine) + kPaddingB;
        CGFloat const w = MAX(h, MIN(size.width, kPaddingB + textSize.width + kPaddingR));
        return CGSizeMake(w, h);
    }
    
    if (hasIcon) {
        return CGSizeMake(kPaddingL + kIconSize + kPaddingR, kPaddingT + kIconSize + kPaddingB);
    }
    
    if (hasText) {
        CGFloat const h = kPaddingT + MAX(textSize.height, kTextLine) + kPaddingB;
        CGFloat const w = MAX(h, MIN(size.width, kPaddingB + textSize.width + kPaddingR));
        return CGSizeMake(w, h);
    }
    
    return CGSizeZero;
}

#pragma mark - <XZToastView>

- (NSString *)text {
    return _textLabel.text;
}

- (void)setText:(NSString *)text {
    _textLabel.text = text;
    [self setNeedsLayout];
}

- (void)willShowInViewController:(UIViewController *)viewController {
    id<XZToastConfiguration> const configuration = viewController.xz_toastConfiguration;
    UIColor * const backgroundColor = configuration.backgroundColor;
    if (backgroundColor) {
        self.backgroundColor = backgroundColor;
    }
    UIColor * const textColor = configuration.textColor;
    if (textColor) {
        _textLabel.textColor = textColor;
    }
    UIFont * const font = configuration.font;
    if (font) {
        _textLabel.font = font;
    }
}

- (CGFloat)progress {
    if ([_iconView isKindOfClass:[XZToastProgressView class]]) {
        return [(XZToastProgressView *)_iconView progress];
    }
    return 0;
}

- (void)setProgress:(CGFloat)progress {
    if (_style != XZToastStyleLoading) {
        return;
    }
    if (![_iconView isKindOfClass:[XZToastProgressView class]]) {
        [_iconView removeFromSuperview];
        
        CGRect frame = CGRectMake((self.bounds.size.width - kIconSize) * 0.5, kPaddingT, kIconSize, kIconSize);
        XZToastProgressView *iconView = [[XZToastProgressView alloc] init];
        iconView.frame = CGRectScaleAspectRatioInsideWithMode(frame, iconView.frame.size, UIViewContentModeCenter);;
        iconView.color = XZToast.color;
        iconView.trackColor = XZToast.trackColor;
        [self addSubview:iconView];
        
        _iconView = iconView;
    }
    [(XZToastProgressView *)_iconView setProgress:progress];
}

#pragma mark - 重写继承的方法

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p: %@, text: %@, icon: %@>", self, self.class, self.text, _iconView];
}

- (UIImage *)image {
    if ([_iconView isKindOfClass:UIImageView.class]) {
        return ((UIImageView *)_iconView).image;
    }
    return nil;
}

- (void)setStyle:(XZToastStyle)style image:(UIImage *)image progress:(CGFloat)progress {
    _style = style;
    
    // 没有图片
    switch (_style) {
        case XZToastStyleMessage:
        case XZToastStyleSuccess:
        case XZToastStyleFailure:
        case XZToastStyleWarning:
        case XZToastStyleWaiting: {
            if (image) {
                // 有图片
                if (![_iconView isKindOfClass:UIImageView.class]) {
                    [_iconView removeFromSuperview];
                    
                    CGRect frame = CGRectMake((self.bounds.size.width - kIconSize) * 0.5, kPaddingT, kIconSize, kIconSize);
                    frame = CGRectScaleAspectRatioInsideWithMode(frame, image.size, UIViewContentModeCenter);
                    UIImageView *iconView = [[UIImageView alloc] initWithFrame:frame];
                    iconView.animationRepeatCount = 0; // 动图无限循环
                    iconView.image = image;
                    [self addSubview:iconView];
                    
                    _iconView = iconView;
                }
                
                [(UIImageView *)_iconView setImage:image];
                
                // 动图
                if (image.images.count > 0) {
                    [(UIImageView *)_iconView startAnimating];
                }
            } else {
                [_iconView removeFromSuperview];
                _iconView = nil;
            }
            break;
        }
        case XZToastStyleLoading: {
            if (progress >= 0) {
                // 使用进度条
                [self setProgress:0];
            } else if (image) {
                // 使用图片
                if (![_iconView isKindOfClass:UIImageView.class]) {
                    [_iconView removeFromSuperview];
                    
                    CGRect frame = CGRectMake((self.bounds.size.width - kIconSize) * 0.5, kPaddingT, kIconSize, kIconSize);
                    frame = CGRectScaleAspectRatioInsideWithMode(frame, image.size, UIViewContentModeCenter);
                    UIImageView *iconView = [[UIImageView alloc] initWithFrame:frame];
                    iconView.animationRepeatCount = 0; // 动图无限循环
                    iconView.image = image;
                    [self addSubview:iconView];
                    
                    _iconView = iconView;
                }
                
                [(UIImageView *)_iconView setImage:image];
                
                // 动图
                if (image.images.count > 0) {
                    [(UIImageView *)_iconView startAnimating];
                }
            } else if (![_iconView isKindOfClass:UIActivityIndicatorView.class]) {
                // 默认，使用 UIActivityIndicatorView
                [_iconView removeFromSuperview];
                
                UIActivityIndicatorView *iconView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.bounds.size.width - kIconSize) * 0.5, kPaddingT, kIconSize, kIconSize)];
                iconView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleLarge;
                iconView.color = UIColor.whiteColor;
                [iconView startAnimating];
                [self addSubview:iconView];
                
                _iconView = iconView;
            }
            break;
        }
        default: {
            return;
        }
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
    image = [image imageByApplyingSymbolConfiguration:config];
    return [image imageWithTintColor:UIColor.whiteColor renderingMode:(UIImageRenderingModeAlwaysOriginal)];
}


@implementation XZToastProgressView {
    CAShapeLayer *_trackLayer;
    CAShapeLayer *_shapeLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, 37.0, 37.0)];
    if (self) {
        CALayer * const layer = self.layer;
        
        _color = UIColor.systemBlueColor;
        _trackColor = UIColor.systemGray5Color;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(18.5, 18.5) radius:16.5 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
        
        _trackLayer = [[CAShapeLayer alloc] init];
        _trackLayer.frame = CGRectMake(0, 0, 37, 37);
        _trackLayer.lineWidth = 3.0;
        _trackLayer.strokeColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
        _trackLayer.fillColor   = UIColor.clearColor.CGColor;
        _trackLayer.strokeStart = 0;
        _trackLayer.strokeEnd   = 1.0;
        _trackLayer.path = path.CGPath;
        [layer addSublayer:_trackLayer];
        
        _shapeLayer = [[CAShapeLayer alloc] init];
        _shapeLayer.frame = CGRectMake(0, 0, 37, 37);
        _shapeLayer.lineWidth = 3.0;
        _shapeLayer.lineCap = kCALineCapRound;
        _shapeLayer.strokeColor = self.tintColor.CGColor;
        _shapeLayer.fillColor   = UIColor.clearColor.CGColor;
        _shapeLayer.strokeStart = 0;
        _shapeLayer.strokeEnd   = 0;
        _shapeLayer.repeatCount = FLT_MAX;
        _shapeLayer.autoreverses = YES;
        _shapeLayer.path = _trackLayer.path;
        [layer addSublayer:_shapeLayer];
    }
    return self;
}

- (CGFloat)progress {
    return _shapeLayer.strokeEnd;
}

- (void)setProgress:(CGFloat)progress {
    _shapeLayer.strokeEnd = progress;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(37.0, 37.0);
}

- (void)setColor:(UIColor *)color {
    if (_color != color) {
        _color = color ?: UIColor.systemBlueColor;
        _shapeLayer.strokeColor = [_color resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    }
}

- (void)setTrackColor:(UIColor *)trackColor {
    if (_trackColor != trackColor) {
        _trackColor = trackColor ?: UIColor.systemGray5Color;
        _trackLayer.strokeColor = [_trackColor resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    UITraitCollection * const traitCollection = self.traitCollection;
    _trackLayer.strokeColor = [_trackColor resolvedColorWithTraitCollection:traitCollection].CGColor;
    _shapeLayer.strokeColor = [_color resolvedColorWithTraitCollection:traitCollection].CGColor;
}

@end
