//
//  XZSegmentTextItemView.m
//  XZSegmentedControl
//
//  Created by Xezun on 2024/6/25.
//

#import "XZSegmentTextItemView.h"

@implementation XZSegmentTextItemView {
    XZSegmentTextLabel *_textLabel;
    CGFloat _interactiveTransition;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect const bounds = self.bounds;
        
        _textLabel = [[XZSegmentTextLabel alloc] initWithFrame:bounds];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 2;
        [self.contentView addSubview:_textLabel];
        
        if (@available(iOS 17.0, *)) {
            [self registerForTraitChanges:@[UITraitUserInterfaceStyle.class] withAction:@selector(userInterfaceStyleDidChange)];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.effectiveUserInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight) {
        UIEdgeInsets const edgeInsets = UIEdgeInsetsMake(_edgeInsets.top, _edgeInsets.leading, _edgeInsets.bottom, _edgeInsets.trailing);
        _textLabel.frame = UIEdgeInsetsInsetRect(self.bounds, edgeInsets);
    } else {
        UIEdgeInsets const edgeInsets = UIEdgeInsetsMake(_edgeInsets.top, _edgeInsets.trailing, _edgeInsets.bottom, _edgeInsets.leading);
        _textLabel.frame = UIEdgeInsetsInsetRect(self.bounds, edgeInsets);
    }
}

- (void)setText:(NSString *)text {
    _textLabel.text = text;
}

- (NSString *)text {
    return _textLabel.text;
}

- (void)setEdgeInsets:(NSDirectionalEdgeInsets)edgeInsets {
    if (!NSDirectionalEdgeInsetsEqualToDirectionalEdgeInsets(_edgeInsets, edgeInsets)) {
        _edgeInsets = edgeInsets;
        [self setNeedsLayout];
    }
}

- (void)updateInteractiveTransition:(CGFloat)interactiveTransition {
    [super updateInteractiveTransition:interactiveTransition];
    
    _interactiveTransition = interactiveTransition;
    
    XZSegmentedControl * const segmentedControl = self.segmentedControl;

    [UIView performWithoutAnimation:^{
        if (interactiveTransition == 0) {
            _textLabel.transform = CGAffineTransformIdentity;
            _textLabel.textColor = segmentedControl.titleColor;
            _textLabel.font = segmentedControl.titleFont;
        } else if (interactiveTransition == 1.0) {
            _textLabel.transform = CGAffineTransformIdentity;
            _textLabel.textColor = segmentedControl.selectedTitleColor;
            _textLabel.font = segmentedControl.selectedTitleFont;
        } else {
            // 文本颜色动画
            UIColor           * const titleColor         = segmentedControl.titleColor;
            UIColor           * const selectedTitleColor = segmentedControl.selectedTitleColor;
            
            CGFloat red0 = 0, green0 = 0, blue0 = 0, alpha0 = 0;
            CGFloat red1 = 0, green1 = 0, blue1 = 0, alpha1 = 0;
            [titleColor getRed:&red0 green:&green0 blue:&blue0 alpha:&alpha0];
            [selectedTitleColor getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
            
            CGFloat const red   = red0 + (red1 - red0) * interactiveTransition;
            CGFloat const green = green0 + (green1 - green0) * interactiveTransition;
            CGFloat const blue  = blue0 + (blue1 - blue0) * interactiveTransition;
            CGFloat const alpha = alpha0 + (alpha1 - alpha0) * interactiveTransition;
            _textLabel.textColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
            
            // 文本字体大小缩放效果不理想
        }
    }];

}

- (void)userInterfaceStyleDidChange {
    [self updateInteractiveTransition:_interactiveTransition];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self updateInteractiveTransition:_interactiveTransition];
}

@end

@implementation XZSegmentTextLabel

@end

@implementation XZSegmentTextItem

@end
