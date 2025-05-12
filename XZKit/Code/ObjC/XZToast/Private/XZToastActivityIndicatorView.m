//
//  XZToastActivityIndicatorView.m
//  XZToast
//
//  Created by 徐臻 on 2025/5/9.
//

#import "XZToastActivityIndicatorView.h"

#define kPaddingT 15.0
#define kPaddingL 15.0
#define kPaddingR 15.0
#define kPaddingB 15.0
#define kIconSize 50.0
#define kTextLine 20.0
#define kSpacing  10.0

@implementation XZToastActivityIndicatorView {
    UIActivityIndicatorView *_indicatorView;
    UILabel *_textLabel;
}

- (instancetype)init {
    CGFloat const width = kPaddingT + kIconSize + kSpacing + kTextLine + kPaddingB;
    return [self initWithFrame:CGRectMake(0, 0, width, width)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        self.layer.cornerRadius = 6.0;
        self.clipsToBounds = true;
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleLarge)];
        _indicatorView.color = UIColor.whiteColor;
        [self addSubview:_indicatorView];
        
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
        _indicatorView.frame = CGRectMake(x, y, w, h);
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

- (void)startAnimating {
    [_indicatorView startAnimating];
}

- (void)stopAnimating {
    [_indicatorView stopAnimating];
}

- (BOOL)isAnimating {
    return _indicatorView.isAnimating;
}

@end
