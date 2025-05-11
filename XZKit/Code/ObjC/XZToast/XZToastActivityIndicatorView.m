//
//  XZToastActivityIndicatorView.m
//  XZToast
//
//  Created by 徐臻 on 2025/5/9.
//

#import "XZToastActivityIndicatorView.h"

@implementation XZToastActivityIndicatorView {
    UIActivityIndicatorView *_indicatorView;
    UILabel *_textLabel;
}

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, 100, 100)];
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
        _textLabel.font = [UIFont systemFontOfSize:17.0];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect const bounds = self.bounds;
    
    {
        CGFloat const x = bounds.origin.x + (bounds.size.width - 50.0) * 0.5;
        CGFloat const y = 10.0;
        CGFloat const w = 50.0;
        CGFloat const h = 50.0;
        _indicatorView.frame = CGRectMake(x, y, w, h);
    }
    
    {
        CGSize  const s = [_textLabel sizeThatFits:CGSizeMake(bounds.size.width - 20.0, 0)];
        CGFloat const w = MIN(bounds.size.width - 20.0, s.width);
        CGFloat const h = 20.0;
        CGFloat const x = bounds.origin.x + (bounds.size.width - w) * 0.5;
        CGFloat const y = 10.0 + 50.0 + 10.0;
        _textLabel.frame = CGRectMake(x, y, w, h);
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize  const s = [_textLabel sizeThatFits:CGSizeMake(size.width - 20.0, 0)];
    CGFloat const h = 10.0 + 50.0 + 10.0 + 20.0 + 10.0;
    CGFloat const w = MAX(h, MIN(size.width, 10.0 + s.width + 10.0));
    return CGSizeMake(w, h);
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
