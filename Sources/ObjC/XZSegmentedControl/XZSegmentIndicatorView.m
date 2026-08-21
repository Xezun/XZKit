//
//  XZSegmentIndicatorView.m
//  XZSegmentedControl
//
//  Created by Xezun on 2024/7/9.
//

#import "XZSegmentIndicatorView.h"
#import "XZSegmentedControl.h"
#import "XZSegmentLineIndicatorView.h"

@implementation XZSegmentIndicatorView

+ (BOOL)supportsInteractiveTransition {
    return NO;
}

+ (void)layout:(XZSegmentLayout *)layout prepareLayoutAttributes:(XZSegmentIndicatorLayoutAttributes *)layoutAttributes {
    
}

- (void)prepareForSegmentedControl:(XZSegmentedControl *)segmentedControl {
    
}

- (void)applyLayoutAttributes:(XZSegmentIndicatorLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    // 获取指示器实例对象，以在更新指示器样式时，能直接修改指示器。
    // Indicator 的角色是 DecorationView 由 UIKit 创建，无法直接获取。
    [layoutAttributes.layout.segmentedControl setIndicatorView:self];
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
