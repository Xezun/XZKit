//
//  XZToastTextIconView.m
//  XZToast
//
//  Created by 徐臻 on 2025/5/9.
//

#import "XZToastTextIconView.h"

#define kPaddingT 15.0
#define kPaddingL 15.0
#define kPaddingR 15.0
#define kPaddingB 15.0
#define kIconSize 50.0
#define kTextLine 20.0
#define kSpacing  10.0

@implementation XZToastTextIconView {
    @package
    UILabel *_textLabel;
    UIView *_iconView;
}

- (instancetype)init {
    CGFloat const width = kPaddingT + kIconSize + kSpacing + kTextLine + kPaddingB;
    return [self initWithFrame:CGRectMake(0, 0, width, width)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    NSString * const reason = @"需要使用子类，不可以直接创建使用";
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (instancetype)initWithIconView:(UIView *)iconView {
    CGFloat const width = kPaddingT + kIconSize + kSpacing + kTextLine + kPaddingB;
    self = [super initWithFrame:CGRectMake(0, 0, width, width)];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        self.layer.cornerRadius = 6.0;
        self.clipsToBounds = true;
        
        _iconView = iconView;
        [self addSubview:_iconView];
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor = UIColor.whiteColor;
        _textLabel.font = [UIFont monospacedDigitSystemFontOfSize:17.0 weight:(UIFontWeightRegular)];
        _textLabel.textAlignment = NSTextAlignmentCenter;
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
        _iconView.frame = CGRectMake(x, y, w, h);
    }
    
    if (_textLabel.text.length > 0) {
        CGSize  const s = [_textLabel sizeThatFits:CGSizeMake(bounds.size.width - kPaddingL - kPaddingR, 0)];
        CGFloat const w = MIN(bounds.size.width - kPaddingL - kPaddingR, s.width);
        CGFloat const h = kTextLine;
        CGFloat const x = bounds.origin.x + (bounds.size.width - w) * 0.5;
        CGFloat const y = kPaddingT + kIconSize + kSpacing;
        _textLabel.frame = CGRectMake(x, y, w, h);
    } else {
        CGFloat const x = CGRectGetMidX(bounds);
        CGFloat const y = kPaddingT + kIconSize + kSpacing;
        _textLabel.frame = CGRectMake(x, y, 0, kTextLine);
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (_textLabel.text.length > 0) {
        CGSize  const s = [_textLabel sizeThatFits:CGSizeMake(size.width - kPaddingL - kPaddingR, 0)];
        CGFloat const h = kPaddingT + kIconSize + kSpacing + kTextLine + kPaddingB;
        CGFloat const w = MAX(h, MIN(size.width, kPaddingB + s.width + kPaddingR));
        return CGSizeMake(w, h);
    }
    return CGSizeMake(kPaddingL + kIconSize + kPaddingR, kPaddingT + kIconSize + kPaddingB);
}

- (NSString *)text {
    return _textLabel.text;
}

- (void)setText:(NSString *)text {
    _textLabel.text = text;
    [self setNeedsLayout];
}

@end


@implementation XZToastActivityIndicatorView

- (instancetype)init {
    UIActivityIndicatorView *_iconView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleLarge)];
    _iconView.color = UIColor.whiteColor;
    return [super initWithIconView:_iconView];
}

- (BOOL)isAnimating {
    return ((UIActivityIndicatorView *)_iconView).isAnimating;
}

- (void)startAnimating {
    [((UIActivityIndicatorView *)_iconView) startAnimating];
}

- (void)stopAnimating {
    [((UIActivityIndicatorView *)_iconView) stopAnimating];
}

@end

@implementation XZToastTextImageView

- (instancetype)initWithImage:(XZToastBase64Image)base64image {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64image options:kNilOptions];
    UIImage *image = [[UIImage alloc] initWithData:data scale:3.0];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return [super initWithIconView:imageView];
}

@end


XZToastBase64Image const XZToastBase64ImageSuccess = @""
"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";

XZToastBase64Image const XZToastBase64ImageFailure = @""
"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";

XZToastBase64Image const XZToastBase64ImageWarning = @""
"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";

XZToastBase64Image const XZToastBase64ImageWaiting = @""
"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";
