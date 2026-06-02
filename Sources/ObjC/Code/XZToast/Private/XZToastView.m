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
#define kSpacingA 10.0

@interface XZToastView ()
@end

@implementation XZToastView {
    UIColor *_color;
    UIColor *_tintColor;
    
    BOOL _hasIcon;
    UILabel *_textLabel;
    UIView  *_iconView;
}

- (instancetype)init {
    CGFloat const width = kPaddingT + kIconSize + kSpacingA + kTextLine + kPaddingB;
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
        _iconView.alpha = 1.0;
        _iconView.transform = CGAffineTransformIdentity;
        _iconView.frame = [self iconRectForBounds:bounds];
    } else if (_iconView.alpha > 0) {
        // _iconView 可能会留存复用，若已隐藏则没有必要缩小
        // 使用 transform 处理 icon 的缩放动画：
        // 1、UIActivityIndicatorView 无法通过 frame 控制大小。
        // 2、使用 frame 缩小 System Symbol Image 动画的过程中，视图 UIImageView 有淡色的背景。
        // 3、缩小动画不能直接到 0 否则没有动画效果，可能是因为大小为 0 视图不绘制了。
        CGRect  const frame = _iconView.frame;
        CGFloat const dx = CGRectGetMidX(bounds) - CGRectGetMidX(frame);
        CGFloat const dy = kPaddingT - CGRectGetMidY(frame);
        _iconView.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(dx, dy), 0.01, 0.01);
        _iconView.alpha = 0;
    }
    
    {
        CGFloat const minY = _hasIcon ? (kPaddingT + kIconSize + kSpacingA) : (kPaddingT);
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
    BOOL const _hasText = !_textLabel.isHidden;
    
    if (_hasIcon && _hasText) {
        CGSize const textSize = [_textLabel sizeThatFits:CGSizeMake(size.width - kPaddingL - kPaddingR, 0)];
        CGFloat const h = kPaddingT + kIconSize + kSpacingA + MAX(textSize.height, kTextLine) + kPaddingB;
        CGFloat const w = MAX(h, MIN(size.width, kPaddingB + textSize.width + kPaddingR));
        return CGSizeMake(w, h);
    }
    
    if (_hasIcon) {
        return CGSizeMake(kPaddingL + kIconSize + kPaddingR, kPaddingT + kIconSize + kPaddingB);
    }
    
    if (_hasText) {
        CGSize  const textSize = [_textLabel sizeThatFits:CGSizeMake(size.width - kPaddingL - kPaddingR, 0)];
        CGFloat const h = kPaddingT + MAX(textSize.height, kTextLine) + kPaddingB;
        CGFloat const w = MAX(h, MIN(size.width, kPaddingB + textSize.width + kPaddingR));
        return CGSizeMake(w, h);
    }
    
    return CGSizeZero;
}

- (CGRect)iconRectForBounds:(CGRect)bounds {
    CGSize const iconSize = [_iconView sizeThatFits:CGSizeMake(kIconSize, kIconSize)];
    return [self iconRectForSize:iconSize forBounds:bounds];
}

- (CGRect)iconRectForSize:(CGSize)iconSize forBounds:(CGRect)bounds {
    CGFloat const x = bounds.origin.x + (bounds.size.width - kIconSize) * 0.5;
    CGFloat const y = kPaddingT;
    CGFloat const w = kIconSize;
    CGFloat const h = kIconSize;
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
        return;
    }
    
    if (image == nil) {
        return;
    }
    
    [self loadIconViewWithImage:image progress:-1.0 bounds:self.bounds];
    [self.xz_toastManager setNeedsLayoutToasts];
}

- (CGFloat)progress {
    if ([_iconView isKindOfClass:[XZToastProgressView class]]) {
        return [(XZToastProgressView *)_iconView progress];
    }
    return 0;
}

- (void)setProgress:(CGFloat)progress {
    if ([_iconView isKindOfClass:[XZToastProgressView class]]) {
        [(XZToastProgressView *)_iconView setProgress:progress];
        return;
    }
    
    if (progress < 0 || progress > 1.0) {
        return;
    }
    
    [self loadIconViewWithImage:nil progress:progress bounds:self.bounds];
    [self.xz_toastManager setNeedsLayoutToasts];
}

- (void)toast:(XZToast *)toast willShowInViewController:(UIViewController *)viewController {
    XZToastManager * const manager = viewController.xz_toastManager;
    
    { // 配置样式 textColor/font/backgroundColor/shadowColor/color/tintColor
        self.backgroundColor = manager.backgroundColor;
        _textLabel.textColor = manager.textColor;
        _textLabel.font      = manager.font;
        _color               = manager.color;
        _tintColor           = manager.tintColor;
    }
    
    CGRect const bounds = self.bounds;
    
    // 样式
    _style = toast.style;
    
    { // 文字
        NSString * const text = toast.text;
        _textLabel.text = text;
        if (text.length > 0) {
            _textLabel.hidden = NO;
            CGRect const frame = _textLabel.frame;
            CGSize const size  = [_textLabel sizeThatFits:CGSizeMake(0, bounds.size.height)];
            _textLabel.frame = CGRectAdjustSizeWithMode(frame, size, UIViewContentModeCenter);
        } else {
            _textLabel.hidden = YES;
        }
    }
    
    { // 图片或进度
        UIImage *image    = toast.image;
        CGFloat  progress = toast.progress;
        
        if (image.renderingMode != UIImageRenderingModeAlwaysOriginal) {
            image = [image imageWithTintColor:_color renderingMode:(UIImageRenderingModeAlwaysOriginal)];
        }
        
        [self loadIconViewWithImage:image progress:progress bounds:bounds];
    }
}

- (void)toast:(XZToast *)toast didShowInViewController:(UIViewController *)viewController {
    _iconView.transform = CGAffineTransformIdentity;
}

#pragma mark - 重写继承的方法

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p: %@, text: %@, icon: %@>", self, self.class, self.text, _iconView];
}

#pragma mark - 私有方法

- (void)loadIconViewWithImage:(UIImage *)image progress:(CGFloat)progress bounds:(CGRect)bounds {
    UIView * iconView = nil;
    if (progress >= 0 && progress <= 1.0) {
        // 加载视图
        XZToastProgressView *progressView = nil;
        if ([_iconView isKindOfClass:[XZToastProgressView class]]) {
            progressView = (XZToastProgressView *)_iconView;
            progressView.alpha = 1.0;
        } else {
            progressView = [[XZToastProgressView alloc] init];
            [self addSubview:progressView];
        }
        
        // 配置样式
        progressView.color = _tintColor;
        progressView.trackColor = _color;
        
        // 配置数据
        progressView.progress = progress;
        
        iconView = progressView;
    } else if (image) {
        // 加载视图
        UIImageView *imageView = nil;
        if ([_iconView isKindOfClass:UIImageView.class]) {
            imageView = (UIImageView *)_iconView;
            imageView.alpha = 1.0;
            imageView.transform = CGAffineTransformIdentity;
        } else {
            imageView = [[UIImageView alloc] init];
            imageView.clipsToBounds = YES;
            imageView.animationRepeatCount = 0; // 动图无限循环
            [self addSubview:imageView];
        }
        
        // 配置数据
        imageView.image = image;
        if (image.images.count > 0) {
            [imageView startAnimating];
        }
        
        iconView = imageView;
    } else if (_style == XZToastStyleLoading) {
        // 加载视图
        UIActivityIndicatorView *activityView = nil;
        if ([_iconView isKindOfClass:UIActivityIndicatorView.class]) {
            activityView = (UIActivityIndicatorView *)_iconView;
            activityView.alpha = 1.0;
        } else {
            activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleLarge)];
            activityView.clipsToBounds = YES;
            [self addSubview:activityView];
        }
        
        // 配置样式
        activityView.color = _color;
        
        // 配置数据
        [activityView startAnimating];
        
        iconView = activityView;
    }
    
    if (iconView) {
        // 新的 icon 基于当前 bounds 进行布局。
        CGSize const size = [iconView sizeThatFits:bounds.size];
        
        if (_hasIcon) {
            // icon 前后都有：在现有位置直接显示。
            iconView.frame = CGRectAdjustSizeWithMode(_iconView.frame, size, UIViewContentModeCenter);
        } else {
            CGRect const frame = [self iconRectForSize:size forBounds:bounds];
            iconView.frame = frame;
            // icon 从无到有：展示从小到大的缩放效果。
            // 使用 transform 处理缩放，因为 frame 进行缩放的效果不理想，详见 layoutSubvies 方法中的备注。
            CGFloat const dx = CGRectGetMidX(bounds) - CGRectGetMidX(frame);
            CGFloat const dy = kPaddingT - CGRectGetMidY(frame);
            iconView.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(dx, dy), 0.01, 0.01);
        }
        
        // 如果 icon 发生了改变，移除旧的
        // 不使用 transition 动画，是因为动画效果会添加到整个 XZToastWrapperView 上，原因未知。
        if (_iconView != iconView) {
            [_iconView removeFromSuperview];
            _iconView = iconView;
        }
        
        _hasIcon = YES;
    } else {
        _hasIcon = NO;
    }
}

@end


