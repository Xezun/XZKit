//
//  XZToastTextView.m
//  XZToast
//
//  Created by 徐臻 on 2025/5/9.
//

#import "XZToastTextView.h"

#define kPaddingT 15.0
#define kPaddingL 15.0
#define kPaddingR 15.0
#define kPaddingB 15.0

@implementation XZToastTextView {
    UILabel *_textLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        self.layer.cornerRadius = 6.0;
        self.clipsToBounds = true;
        
        _textLabel = [[UILabel alloc] init];
        // _textLabel.backgroundColor = UIColor.greenColor;
        _textLabel.textColor = UIColor.whiteColor;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = [UIFont monospacedDigitSystemFontOfSize:17.0 weight:(UIFontWeightRegular)];
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect const bounds = self.bounds;
    CGSize const textSize = [_textLabel sizeThatFits:CGSizeMake(bounds.size.width - kPaddingL - kPaddingR, 0)];
    
    CGFloat const w = MIN(bounds.size.width - kPaddingL - kPaddingR, textSize.width);
    CGFloat const h = bounds.size.height - kPaddingT - kPaddingB;
    CGFloat const x = bounds.origin.x + (bounds.size.width - w) * 0.5;
    CGFloat const y = kPaddingT;
    _textLabel.frame = CGRectMake(x, y, w, h);
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (size.width <= (kPaddingL + kPaddingR)) {
        return CGSizeMake(kPaddingL + 0 + kPaddingR, kPaddingT + 0 + kPaddingB);
    }
    CGSize  const textSize = [_textLabel sizeThatFits:CGSizeMake(size.width - kPaddingL - kPaddingR, 0)];
    CGFloat const width = MIN(size.width, kPaddingT + textSize.width + kPaddingB);
    return CGSizeMake(width, kPaddingT + textSize.height + kPaddingB);
}

- (NSString *)text {
    return _textLabel.text;
}

- (void)setText:(NSString *)text {
    _textLabel.text = text;
    [self setNeedsLayout];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p: %@, text: %@>", self, self.class, self.text];
}

@end


