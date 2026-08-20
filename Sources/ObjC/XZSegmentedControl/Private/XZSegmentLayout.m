//
//  XZSegmentLayout.m
//  XZSegmentedControl
//
//  Created by Xezun on 2024/6/25.
//

#import "XZSegmentLayout.h"
#import "XZSegmentLineIndicatorView.h"

#define kIndicatorKind   @"Indicator"
#define kIndicatorWidth  3.0

@implementation XZSegmentLayout

- (instancetype)initWithSegmentedControl:(XZSegmentedControl *)segmentedControl indicatorClass:(Class)indicatorClass {
    self = [super init];
    if (self != nil) {
        _segmentedControl = segmentedControl;
        _indicatorClass   = indicatorClass;
        [self loadIndicatorLayoutAttributes];
    }
    return self;
}

// MARK: - Override Methods

- (void)prepareLayout {
    [super prepareLayout];
    [_indicatorClass layout:self prepareLayoutAttributes:_indicatorLayoutAttributes];
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *items = [super layoutAttributesForElementsInRect:rect];
    if (!CGRectIsEmpty(_indicatorLayoutAttributes.frame)) {
        if (CGRectIntersectsRect(rect, _indicatorLayoutAttributes.frame)) {
            items = [items arrayByAddingObject:_indicatorLayoutAttributes];
        }
    }
    return items;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0 || indexPath.item != 0) {
        return nil;
    }
    if (![elementKind isEqualToString:_indicatorLayoutAttributes.representedElementKind]) {
        return nil;
    }
    return _indicatorLayoutAttributes;
}

- (UIUserInterfaceLayoutDirection)developmentLayoutDirection {
    return UIUserInterfaceLayoutDirectionLeftToRight;
}

- (BOOL)flipsHorizontallyInOppositeLayoutDirection {
    return YES;
}

// MARK: - Open Methods

- (UICollectionViewLayoutAttributes *)layoutAttributesForSegmentAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    return [self layoutAttributesForItemAtIndexPath:indexPath];
}

- (void)setIndicatorClass:(Class)indicatorClass {
    if (_indicatorClass != indicatorClass) {
        _indicatorClass = indicatorClass;
        [self loadIndicatorLayoutAttributes];
        // 不能仅刷新指示器，因为从 custom 变回内置样式，custom 的指示器会残留。
        [self invalidateLayout];
    }
}

- (void)invalidateIndicatorLayout:(CGFloat)interactiveTransition {
    _indicatorLayoutAttributes.interactiveTransition = interactiveTransition;
    
    UICollectionViewFlowLayoutInvalidationContext *context = [[UICollectionViewFlowLayoutInvalidationContext alloc] init];
    context.invalidateFlowLayoutAttributes      = NO;
    context.invalidateFlowLayoutDelegateMetrics = NO;
    [context invalidateDecorationElementsOfKind:NSStringFromClass(_indicatorClass) atIndexPaths:@[
        [NSIndexPath indexPathForItem:0 inSection:0]
    ]];
    [self invalidateLayoutWithContext:context];
}

// MARK: - Private Methods

/// 加载指示器属性。
- (void)loadIndicatorLayoutAttributes {
    NSString * const kind = NSStringFromClass(_indicatorClass);
    if ([_indicatorLayoutAttributes.representedElementKind isEqualToString:kind]) {
        return;
    }
    [self registerClass:_indicatorClass forDecorationViewOfKind:kind];
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    _indicatorLayoutAttributes = [XZSegmentIndicatorLayoutAttributes layoutAttributesForDecorationViewOfKind:kind withIndexPath:indexPath];
    _indicatorLayoutAttributes.layout = self;
}

@end


