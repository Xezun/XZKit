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

@implementation XZSegmentLayout {
    BOOL _needsUpdateIndicatorLayout;
}

- (instancetype)initWithSegmentedControl:(XZSegmentedControl *)segmentedControl {
    self = [super init];
    if (self != nil) {
        _needsUpdateIndicatorLayout = NO;
        _segmentedControl = segmentedControl;
        _indicatorStyle = XZSegmentIndicatorStyleMarkLine;
        _indicatorClass = [XZSegmentMarkLineIndicatorView class];
        [self loadIndicatorLayoutAttributes];
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    // 自动调整 selectedIndex 到合理的范围
    NSInteger const count = [self.collectionView numberOfItemsInSection:0];
    if (count == 0) {
        _selectedIndex = NSNotFound;
    } else if (_selectedIndex == NSNotFound) {
        _selectedIndex = 0;
    } else {
        _selectedIndex = MIN(count - 1, _selectedIndex);
    }
    
    [self prepareIndicatorLayout];
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

- (UIColor *)indicatorColor {
    return _indicatorLayoutAttributes.color;
}

- (void)setIndicatorColor:(UIColor *)indicatorColor {
    _indicatorLayoutAttributes.color = indicatorColor;
    [_indicatorLayoutAttributes.indicatorView applyLayoutAttributes:_indicatorLayoutAttributes];
}

- (UIImage *)indicatorImage {
    return _indicatorLayoutAttributes.image;
}

- (void)setIndicatorImage:(UIImage *)indicatorImage {
    if (indicatorImage != nil && (_indicatorSize.width == 0 || _indicatorSize.height == 0)) {
        self.indicatorSize = indicatorImage.size;
    }
    _indicatorLayoutAttributes.image = indicatorImage;
    [_indicatorLayoutAttributes.indicatorView applyLayoutAttributes:_indicatorLayoutAttributes];
}

- (void)setIndicatorStyle:(XZSegmentIndicatorStyle)indicatorStyle {
    if (_indicatorStyle != indicatorStyle) {
        _indicatorStyle = indicatorStyle;
        
        switch (_indicatorStyle) {
            case XZSegmentIndicatorStyleMarkLine:
                self.indicatorClass = [XZSegmentMarkLineIndicatorView class];
                break;
            case XZSegmentIndicatorStyleNoteLine:
                self.indicatorClass = [XZSegmentNoteLineIndicatorView class];
                break;
            case XZSegmentIndicatorStyleCustom:
                break;
            default:
                break;
        }
    }
}

- (void)setIndicatorSize:(CGSize)indicatorSize {
    if (!CGSizeEqualToSize(_indicatorSize, indicatorSize)) {
        _indicatorSize = indicatorSize;
        [self invalidateIndicatorLayout:NO];
    }
}

@synthesize indicatorClass = _indicatorClass;

- (Class)indicatorClass {
    if (_indicatorClass == nil) {
        switch (_indicatorStyle) {
            case XZSegmentIndicatorStyleMarkLine:
                _indicatorClass = [XZSegmentMarkLineIndicatorView class];
                break;
            case XZSegmentIndicatorStyleNoteLine:
                _indicatorClass = [XZSegmentNoteLineIndicatorView class];
                break;
            case XZSegmentIndicatorStyleCustom:
                _indicatorStyle = XZSegmentIndicatorStyleMarkLine;
                _indicatorClass = [XZSegmentMarkLineIndicatorView class];
                break;
            default:
                break;
        }
        [self loadIndicatorLayoutAttributes];
    }
    return _indicatorClass;
}

- (void)setIndicatorClass:(Class)indicatorClass {
    if (_indicatorClass != indicatorClass) {
        NSParameterAssert([indicatorClass isSubclassOfClass:[XZSegmentIndicatorView class]]);
        _indicatorStyle = XZSegmentIndicatorStyleCustom;
        
        // [self registerClass:nil forDecorationViewOfKind:NSStringFromClass(_indicatorClass)];
        _indicatorClass = indicatorClass;
        [self loadIndicatorLayoutAttributes];
        
        // 不能仅刷新指示器，因为从 custom 变回内置样式，custom 的指示器会残留。
        [self invalidateLayout];
    }
}

- (void)setInteractiveTransition:(CGFloat)interactiveTransition {
    if (_indicatorLayoutAttributes.interactiveTransition != interactiveTransition) {
        _indicatorLayoutAttributes.interactiveTransition = interactiveTransition;
        
        if ([_indicatorClass supportsInteractiveTransition]) {
            [self invalidateIndicatorLayout:NO];
        }
    }
}

- (CGFloat)interactiveTransition {
    return _indicatorLayoutAttributes.interactiveTransition;
}

- (void)invalidateIndicatorLayout:(BOOL)animated {
    _indicatorLayoutAttributes.animated = animated;
    
    UICollectionViewFlowLayoutInvalidationContext *context = [[UICollectionViewFlowLayoutInvalidationContext alloc] init];
    context.invalidateFlowLayoutAttributes      = NO;
    context.invalidateFlowLayoutDelegateMetrics = NO;
    [context invalidateDecorationElementsOfKind:NSStringFromClass(_indicatorClass) atIndexPaths:@[
        [NSIndexPath indexPathForItem:0 inSection:0]
    ]];
    [self invalidateLayoutWithContext:context];
    
    
//    if (animated) {
//        [_indicatorLayoutAttributes.indicatorView animateTransition:_indicatorLayoutAttributes];
//    }
}

// MARK: - Private Methods

/// 更新 indicator 的布局。请不要直接调用此方法。
- (void)prepareIndicatorLayout {
    NSInteger const count = [self.collectionView numberOfItemsInSection:0];
    
    switch (_indicatorStyle) {
        case XZSegmentIndicatorStyleMarkLine: {
            // TODO: 将如下逻辑移动到对应的 class 中
            if (count == 0) {
                CGRect const bounds = self.collectionView.bounds;
                switch (self.scrollDirection) {
                    case UICollectionViewScrollDirectionHorizontal:
                        _indicatorLayoutAttributes.frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds) - kIndicatorWidth, 0, kIndicatorWidth);
                        break;
                    case UICollectionViewScrollDirectionVertical:
                        _indicatorLayoutAttributes.frame = CGRectMake(CGRectGetMaxX(bounds) - kIndicatorWidth, CGRectGetMinY(bounds), kIndicatorWidth, 0);
                        break;
                    default:
                        break;
                }
            } else {
                [_indicatorClass segmentedControl:_segmentedControl layout:self prepareForLayoutAttributes:_indicatorLayoutAttributes];
            }
            break;
        }
        case XZSegmentIndicatorStyleNoteLine: {
            if (count == 0) {
                CGRect const bounds = self.collectionView.bounds;
                switch (self.scrollDirection) {
                    case UICollectionViewScrollDirectionHorizontal:
                        _indicatorLayoutAttributes.frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), 0, kIndicatorWidth);
                        break;
                    case UICollectionViewScrollDirectionVertical:
                        _indicatorLayoutAttributes.frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), kIndicatorWidth, 0);
                        break;
                    default:
                        break;
                }
            } else {
                [_indicatorClass segmentedControl:_segmentedControl layout:self prepareForLayoutAttributes:_indicatorLayoutAttributes];
            }
            break;
        }
        case XZSegmentIndicatorStyleCustom: {
            [_indicatorClass segmentedControl:_segmentedControl layout:self prepareForLayoutAttributes:_indicatorLayoutAttributes];
            break;
        }
        default:
            break;
    }
}

/// 加载指示器属性。
- (void)loadIndicatorLayoutAttributes {
    NSString * const kind = NSStringFromClass(_indicatorClass);
    if ([_indicatorLayoutAttributes.representedElementKind isEqualToString:kind]) {
        return;
    }
    [self registerClass:_indicatorClass forDecorationViewOfKind:kind];
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    _indicatorLayoutAttributes = [XZSegmentIndicatorLayoutAttributes layoutAttributesForDecorationViewOfKind:kind withIndexPath:indexPath];
}

@end


