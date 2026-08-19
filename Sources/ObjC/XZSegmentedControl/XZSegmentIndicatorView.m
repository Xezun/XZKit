//
//  XZSegmentIndicatorView.m
//  XZSegmentedControl
//
//  Created by Xezun on 2024/7/9.
//

#import "XZSegmentIndicatorView.h"
#import "XZSegmentedControl.h"

@implementation XZSegmentIndicatorView

+ (BOOL)supportsInteractiveTransition {
    return NO;
}

+ (void)segmentedControl:(XZSegmentedControl *)segmentedControl layout:(XZSegmentLayout *)layout prepareForLayoutAttributes:(XZSegmentIndicatorLayoutAttributes *)layoutAttributes {
    
}

- (void)applyLayoutAttributes:(XZSegmentIndicatorLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    if (layoutAttributes.animated) {
        [UIView animateWithDuration:0.35 animations:^{
            self.frame = layoutAttributes.frame;
        }];
    } else {
        self.frame = layoutAttributes.frame;
    }
}

- (void)willShowInSegmentedControl:(XZSegmentedControl *)segmentedControl {
    
}

@end


@implementation XZSegmentIndicatorLayoutAttributes

@synthesize interactiveTransition = _interactiveTransition;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.zIndex = -1;
        _color = UIColor.tintColor;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    XZSegmentIndicatorLayoutAttributes *new = [super copyWithZone:zone];
    new->_image = _image;
    new->_color = _color;
    new->_interactiveTransition = _interactiveTransition;
    new->_indicatorView = _indicatorView;
    return new;
}
@end
