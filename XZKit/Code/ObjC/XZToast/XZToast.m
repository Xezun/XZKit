//
//  XZToast.m
//  XZToast
//
//  Created by 徐臻 on 2025/3/2.
//

#import "XZToast.h"

NSTimeInterval const XZToastAnimationDuration = 0.35;

/// UILabel 在从长变短时，如果在短的状态下，文字占不满宽度，则无法添加动画。
/// 
/// 因此定义了此视图。
@interface XZToastTextView : UIView
@property (nonatomic, readonly) UILabel *textLabel;
@end

@implementation XZToast

@synthesize view = _view;

- (instancetype)initWithView:(UIView *)view {
    self = [super init];
    if (self) {
        _view = view;
    }
    return self;
}

+ (XZToast *)messageToast:(NSString *)text {
    static XZToastTextView *_textView = nil;
    if (_textView == nil) {
        _textView = [[XZToastTextView alloc] init];
    }
    _textView.textLabel.text = text;
    return [[self alloc] initWithView:_textView];
}

@end

@implementation XZToastTextView

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
    CGFloat const h = textSize.height;
    CGFloat const x = bounds.origin.x + (bounds.size.width - w) * 0.5;
    CGFloat const y = bounds.origin.y + (bounds.size.height - h) * 0.5;
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

@end



