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

- (void)animateTransition:(XZSegmentIndicatorLayoutAttributes *)layoutAttributes {
    [UIView animateWithDuration:0.35 animations:^{
        self.frame = layoutAttributes.frame;
    }];
}

- (void)applyLayoutAttributes:(XZSegmentIndicatorLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    // 1、方法 -applyLayoutAttributes: 比 -preferredLayoutAttributesFittingAttributes: 更先调用。
    // 2、方法 -preferredLayoutAttributesFittingAttributes: 参数中的 layoutAttributes 为复制份，设置 delegate、zIndex 不会被保存到原始对象。
    // 所以要在这个方法里设置 indicatorView
    layoutAttributes.indicatorView = self;
}

@end


@implementation XZSegmentIndicatorLayoutAttributes

@synthesize interactiveTransition = _interactiveTransition;

- (instancetype)init {
    self = [super init];
    if (self) {
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
