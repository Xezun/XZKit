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

+ (void)layout:(XZSegmentLayout *)layout prepareLayoutAttributes:(XZSegmentIndicatorLayoutAttributes *)layoutAttributes {
    
}

- (void)prepareForSegmentedControl:(XZSegmentedControl *)segmentedControl {
    
}

- (void)applyLayoutAttributes:(XZSegmentIndicatorLayoutAttributes *)layoutAttributes {
    // Indicator 的角色是 DecorationView 由 UIKit 创建，只能在此方法中获取实例对象。
    XZSegmentedControl * const segmentedControl = layoutAttributes.layout.segmentedControl;
    if (segmentedControl->_indicatorView != self) {
        segmentedControl->_indicatorView = self;
        [self prepareForSegmentedControl:segmentedControl];
    }
}

@end


@implementation XZSegmentIndicatorLayoutAttributes

- (instancetype)init {
    self = [super init];
    if (self) {
        self.zIndex = -1;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    XZSegmentIndicatorLayoutAttributes *new = [super copyWithZone:zone];
    new->_layout = _layout;
    new->_interactiveTransition = _interactiveTransition;
    return new;
}
@end
