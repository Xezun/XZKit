//
//  XZToastTextView.m
//  XZToast
//
//  Created by 徐臻 on 2025/5/9.
//

#import "XZToastTextView.h"

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
        _textLabel.font = [UIFont systemFontOfSize:17.0];
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect const bounds = self.bounds;
    CGSize const textSize = [_textLabel sizeThatFits:CGSizeMake(bounds.size.width - 20.0, 0)];
    
    CGFloat const w = MIN(bounds.size.width - 20.0, textSize.width);
    CGFloat const h = bounds.size.height - 20.0;
    CGFloat const x = bounds.origin.x + (bounds.size.width - w) * 0.5;
    CGFloat const y = 10.0;
    _textLabel.frame = CGRectMake(x, y, w, h);
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (size.width <= 20.0) {
        return CGSizeMake(20.0, 20.0);
    }
    CGSize  const textSize = [_textLabel sizeThatFits:CGSizeMake(size.width - 20.0, 0)];
    CGFloat const width = MIN(size.width, textSize.width + 20.0);
    return CGSizeMake(width, textSize.height + 20.0);
}

- (NSString *)text {
    return _textLabel.text;
}

- (void)setText:(NSString *)text {
    _textLabel.text = text;
    [self setNeedsLayout];
}

@end


