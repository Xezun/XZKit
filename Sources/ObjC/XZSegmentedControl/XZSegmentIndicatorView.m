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
    new->_animated = _animated;
    return new;
}
@end
