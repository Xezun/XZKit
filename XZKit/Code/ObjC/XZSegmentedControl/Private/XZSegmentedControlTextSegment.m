//
//  XZSegmentedControlTextSegment.m
//  XZSegmentedControl
//
//  Created by Xezun on 2024/6/25.
//

#import "XZSegmentedControlTextSegment.h"
#import "XZLog.h"

@implementation XZSegmentedControlTextSegment {
    XZSegmentedControlTextLabel *_textLabel;
    CGFloat _interactiveTransition;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect const bounds = self.bounds;
        
        _textLabel = [[XZSegmentedControlTextLabel alloc] initWithFrame:bounds];
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 2;
        [self.contentView addSubview:_textLabel];
    }
    return self;
}

- (void)darkModeChanged {
    [self updateInteractiveTransition:self.isSelected ? 1.0 : 0];
}

- (void)setText:(NSString *)text {
    _textLabel.text = text;
}

- (NSString *)text {
    return _textLabel.text;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    XZLog(@"segment(%@).setSelected: %@", self.text, selected ? @"true" : @"false");

    [self updateInteractiveTransition:selected ? 1.0 : 0];
}

- (void)updateInteractiveTransition:(CGFloat)interactiveTransition {
    [super updateInteractiveTransition:interactiveTransition];
    
    XZSegmentedControl * const segmentedControl = _segmentedControl;
    XZLog(@"segment(%@, %ld).setTransition: %f", self.text, segmentedControl.selectedIndex, interactiveTransition);

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
            UITraitCollection * const traitCollection = self.traitCollection;
            UIColor           * const titleColor         = [segmentedControl.titleColor resolvedColorWithTraitCollection:traitCollection];
            UIColor           * const selectedTitleColor = [segmentedControl.selectedTitleColor resolvedColorWithTraitCollection:traitCollection];
            
            CGFloat red0 = 0, green0 = 0, blue0 = 0, alpha0 = 0;
            CGFloat red1 = 0, green1 = 0, blue1 = 0, alpha1 = 0;
            [titleColor getRed:&red0 green:&green0 blue:&blue0 alpha:&alpha0];
            [selectedTitleColor getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
            
            CGFloat const red   = red0 + (red1 - red0) * interactiveTransition;
            CGFloat const green = green0 + (green1 - green0) * interactiveTransition;
            CGFloat const blue  = blue0 + (blue1 - blue0) * interactiveTransition;
            CGFloat const alpha = alpha0 + (alpha1 - alpha0) * interactiveTransition;
            _textLabel.textColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
            
            // 文本大小动画
            UIFont *titleFont = segmentedControl.titleFont;
            UIFont *selectedTitleFont = segmentedControl.selectedTitleFont;
            
            CGFloat const pointSize0 = titleFont.pointSize;
            CGFloat const pointSize1 = selectedTitleFont.pointSize;
            
            if (pointSize0 != pointSize1) {
                // 以最大字体为基准做缩放动画。
                if (_textLabel.font.pointSize != pointSize1) {
                    _textLabel.font = [_textLabel.font fontWithSize:pointSize1];
                }
                
                if ([titleFont.familyName isEqualToString:selectedTitleFont.familyName]) {
                    CGFloat const pointSize = (pointSize0 + (pointSize1 - pointSize0) * interactiveTransition);
                    CGFloat const scale = pointSize / pointSize1;
                    _textLabel.transform = CGAffineTransformMakeScale(scale, scale);
                }
            }
        }
    }];

}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    if (previousTraitCollection.userInterfaceStyle != self.traitCollection.userInterfaceStyle) {
        [self updateInteractiveTransition:self.isSelected ? 1.0 : 0];
    }
}

@end

@implementation XZSegmentedControlTextLabel

@end

@implementation XZSegmentedControlTextModel

@end
