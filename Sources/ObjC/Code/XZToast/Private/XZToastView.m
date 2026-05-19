//
//  XZToastView.m
//  XZToast
//
//  Created by 徐臻 on 2025/5/9.
//

#import "XZToastView.h"
#import "XZGeometry.h"
#import "XZToastProgressView.h"

typedef NS_ENUM(NSUInteger, XZToastViewIconType) {
    XZToastViewIconTypeNone,
    XZToastViewIconTypeImage,
    XZToastViewIconTypeProgress,
    XZToastViewIconTypeActivity
};

#define kPaddingT 15.0
#define kPaddingL 15.0
#define kPaddingR 15.0
#define kPaddingB 15.0
#define kIconSize 50.0
#define kTextLine 20.0
#define kSpacing  10.0

@interface XZToastView ()
@end

@implementation XZToastView {
    BOOL _hasIcon;
    BOOL _hasText;
    UILabel *_textLabel;
    UIView  *_iconView;
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
        _hasIcon = NO;
        _hasText = NO;
        
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
    
    if (_hasIcon) {
        _iconView.transform = CGAffineTransformIdentity;
        _iconView.frame = [self iconRectForBounds:bounds];
    } else if (_iconView) {
        // 使用 transform 处理 icon 的缩放动画：
        // 1、UIActivityIndicatorView 无法通过 frame 控制大小。
        // 2、使用 frame 缩小 System Symbol Image 动画的过程中，视图 UIImageView 有淡色的背景。
        // 3、缩小动画不能直接到 0 否则没有动画效果，可能是因为大小为 0 视图不绘制了。
        CGRect  const frame = _iconView.frame;
        CGFloat const dx = CGRectGetMidX(bounds) - CGRectGetMidX(frame);
        CGFloat const dy = kPaddingT - CGRectGetMidY(frame);
        _iconView.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(dx, dy), 0.01, 0.01);
    }
    
    {
        CGFloat const minY = _hasIcon ? (kPaddingT + kIconSize + kSpacing) : (kPaddingT);
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
    CGSize const textSize = [_textLabel sizeThatFits:CGSizeMake(size.width - kPaddingL - kPaddingR, 0)];
    
    if (_hasIcon && _hasText) {
        CGFloat const h = kPaddingT + kIconSize + kSpacing + MAX(textSize.height, kTextLine) + kPaddingB;
        CGFloat const w = MAX(h, MIN(size.width, kPaddingB + textSize.width + kPaddingR));
        return CGSizeMake(w, h);
    }
    
    if (_hasIcon) {
        return CGSizeMake(kPaddingL + kIconSize + kPaddingR, kPaddingT + kIconSize + kPaddingB);
    }
    
    if (_hasText) {
        CGFloat const h = kPaddingT + MAX(textSize.height, kTextLine) + kPaddingB;
        CGFloat const w = MAX(h, MIN(size.width, kPaddingB + textSize.width + kPaddingR));
        return CGSizeMake(w, h);
    }
    
    return CGSizeZero;
}

- (CGRect)iconRectForBounds:(CGRect)bounds {
    CGFloat const x = bounds.origin.x + (bounds.size.width - kIconSize) * 0.5;
    CGFloat const y = kPaddingT;
    CGFloat const w = kIconSize;
    CGFloat const h = kIconSize;
    CGSize  const iconSize = [_iconView sizeThatFits:CGSizeMake(w, h)];
    return CGRectScaleAspectRatioInsideWithMode(CGRectMake(x, y, w, h), iconSize, UIViewContentModeCenter);
}

#pragma mark - <XZToastView>

@synthesize style = _style;

- (XZToastStyle)style {
    return _style;
}

- (NSString *)text {
    return _textLabel.text;
}

- (void)setText:(NSString *)text {
    _textLabel.text = text;
    [self.xz_toastManager setNeedsLayoutToasts];
}

- (UIImage *)image {
    if ([_iconView isKindOfClass:UIImageView.class]) {
        return ((UIImageView *)_iconView).image;
    }
    return nil;
}

- (void)setImage:(UIImage *)image {
    if ([_iconView isKindOfClass:UIImageView.class]) {
        ((UIImageView *)_iconView).image = image;
        [self.xz_toastManager setNeedsLayoutToasts];
    }
}

- (CGFloat)progress {
    if ([_iconView isKindOfClass:[XZToastProgressView class]]) {
        return [(XZToastProgressView *)_iconView progress];
    }
    return 0;
}

- (void)setProgress:(CGFloat)progress {
    if ([_iconView isKindOfClass:[XZToastProgressView class]]) {
        return [(XZToastProgressView *)_iconView setProgress:progress];
    }
    
    if (_style != XZToastStyleLoading || progress < 0 || progress > 1.0) {
        return;
    }
    
    [_iconView removeFromSuperview];
    _iconView = [[XZToastProgressView alloc] init];
    _iconView.frame = [self iconRectForBounds:self.bounds];
    [self addSubview:_iconView];
    [self.xz_toastManager setNeedsLayoutToasts];
}

- (void)toast:(XZToast *)toast willShowInViewController:(UIViewController *)viewController {
    XZToastManager * const manager = viewController.xz_toastManager;
    
    // 配置样式
    UIColor * const backgroundColor = manager.backgroundColor;
    if (backgroundColor) {
        self.backgroundColor = backgroundColor;
    }
    UIColor * const textColor = manager.textColor;
    if (textColor) {
        _textLabel.textColor = textColor;
    }
    UIFont * const font = manager.font;
    if (font) {
        _textLabel.font = font;
    }
    
    CGRect const bounds = self.bounds;
    
    // 配置数据
    _style = toast.style;
    
    // 文字
    _textLabel.text = toast.text;
    _hasText = (toast.text.length > 0);
    if (_hasText) {
        CGRect const frame = _textLabel.frame;
        CGSize const size  = [_textLabel sizeThatFits:CGSizeMake(0, bounds.size.height)];
        _textLabel.frame = CGRectAdjustSizeWithMode(frame, size, UIViewContentModeCenter);
    }
    
    UIImage * const image    = toast.image;
    CGFloat   const progress = toast.progress;
    switch (_style) {
        case XZToastStyleMessage:
        case XZToastStyleSuccess:
        case XZToastStyleFailure:
        case XZToastStyleWarning:
        case XZToastStyleWaiting: {
            if (image) {
                _hasIcon = YES;
                
                if (![_iconView isKindOfClass:UIImageView.class]) {
                    [_iconView removeFromSuperview];
                    
                    CGRect const frame = _iconView ? _iconView.frame : [self iconRectForBounds:bounds];
                    UIImageView *iconView = [[UIImageView alloc] initWithFrame:frame];
                    iconView.clipsToBounds = YES;
                    iconView.animationRepeatCount = 0; // 动图无限循环
                    iconView.image = image;
                    [self addSubview:iconView];
                    
                    if (!_iconView) {
                        CGFloat const dx = CGRectGetMidX(bounds) - CGRectGetMidX(frame);
                        CGFloat const dy = kPaddingT - CGRectGetMidY(frame);
                        iconView.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(dx, dy), 0.01, 0.01);
                    }
                    _iconView = iconView;
                }
                
                [(UIImageView *)_iconView setImage:image];
                
                // 动图
                if (image.images.count > 0) {
                    [(UIImageView *)_iconView startAnimating];
                }
            } else {
                _hasIcon = NO;
            }
            break;
        }
        case XZToastStyleLoading: {
            _hasIcon = YES;
            if (progress >= 0 && progress <= 1.0) {
                // 使用进度条
                if (![_iconView isKindOfClass:[XZToastProgressView class]]) {
                    [_iconView removeFromSuperview];
                    
                    CGRect const frame = _iconView ? _iconView.frame : [self iconRectForBounds:bounds];
                    XZToastProgressView *iconView = [[XZToastProgressView alloc] initWithFrame:frame];
                    iconView.color = XZToast.color;
                    iconView.trackColor = XZToast.trackColor;
                    [self addSubview:iconView];
                    
                    if (!_iconView) {
                        CGFloat const dx = CGRectGetMidX(bounds) - CGRectGetMidX(frame);
                        CGFloat const dy = kPaddingT - CGRectGetMidY(frame);
                        iconView.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(dx, dy), 0.01, 0.01);
                    }
                    _iconView = iconView;
                }
                
                [(XZToastProgressView *)_iconView setProgress:progress];
            } else if (image) {
                // 使用图片
                if (![_iconView isKindOfClass:UIImageView.class]) {
                    [_iconView removeFromSuperview];
                    
                    CGRect const frame = _iconView ? _iconView.frame : [self iconRectForBounds:bounds];
                    UIImageView *iconView = [[UIImageView alloc] initWithFrame:frame];
                    iconView.clipsToBounds = YES;
                    iconView.animationRepeatCount = 0; // 动图无限循环
                    iconView.image = image;
                    [self addSubview:iconView];
                    
                    if (!_iconView) {
                        CGFloat const dx = CGRectGetMidX(bounds) - CGRectGetMidX(frame);
                        CGFloat const dy = kPaddingT - CGRectGetMidY(frame);
                        iconView.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(dx, dy), 0.01, 0.01);
                    }
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
                
                CGRect const frame = _iconView ? _iconView.frame : [self iconRectForBounds:bounds];
                UIActivityIndicatorView *iconView = [[UIActivityIndicatorView alloc] initWithFrame:frame];
                iconView.clipsToBounds = YES;
                iconView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleLarge;
                iconView.color = UIColor.whiteColor;
                [iconView startAnimating];
                [self addSubview:iconView];
                
                if (!_iconView) {
                    CGFloat const dx = CGRectGetMidX(bounds) - CGRectGetMidX(frame);
                    CGFloat const dy = kPaddingT - CGRectGetMidY(frame);
                    iconView.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(dx, dy), 0.01, 0.01);
                }
                _iconView = iconView;
            }
            break;
        }
        default: {
            return;
        }
    }
}

- (void)toast:(XZToast *)toast didShowInViewController:(UIViewController *)viewController {
    if (!_hasIcon) {
        [_iconView removeFromSuperview];
        _iconView = nil;
    }
}

#pragma mark - 重写继承的方法

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p: %@, text: %@, icon: %@>", self, self.class, self.text, _iconView];
}

@end


