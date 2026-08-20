//
//  XZSegmentedControl.m
//  XZSegmentedControl
//
//  Created by M. X. Z. on 2016/10/7.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "XZSegmentedControl.h"
#import "XZSegmentContainerView.h"
#import "XZSegmentLayout.h"
#import "XZSegmentTextItemView.h"
#import "XZSegmentLineIndicatorView.h"
#import "XZGeometry.h"

#define kReuseIdentifier @"XZSegmentedControlReuseIdentifier"

@interface XZSegmentedControl () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    NSInteger _selectedIndex;
    XZSegmentLayout  *_flowLayout;
    UICollectionView *_collectionView;
    NSMutableArray<XZSegmentTextItem *> *_titleItems;
    XZSegmentItemView * __weak _pendingSegment;
    XZSegmentIndicatorView *_indicatorView;
}

@end

@implementation XZSegmentedControl

- (instancetype)initWithFrame:(CGRect)frame orientation:(XZSegmentOrientation)orientation {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self XZSegmentInitialize:orientation];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame orientation:(XZSegmentOrientationHorizontal)];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self != nil) {
        [self XZSegmentInitialize:XZSegmentOrientationHorizontal];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 横向滚动时，自动将元素高度设置为自身高度
    // 纵向滚动时，自动将元素宽度设置为自身宽度
    CGRect const bounds = self.bounds;
    
    CGRect headerFrame = _headerView.frame;
    CGRect footerFrame = _footerView.frame;
    CGRect collectionFrame = _collectionView.frame;
    
    CGSize const headerSize = headerFrame.size;
    CGSize const footerSize = footerFrame.size;

    switch (self.orientation) {
        case XZSegmentOrientationHorizontal: {
            switch (self.effectiveUserInterfaceLayoutDirection) {
                case UIUserInterfaceLayoutDirectionLeftToRight: {
                    headerFrame = CGRectMake(0, 0, headerSize.width, bounds.size.height);
                    footerFrame = CGRectMake(bounds.size.width - footerSize.width, 0, footerSize.width, bounds.size.height);
                    collectionFrame = CGRectMake(headerSize.width, 0, bounds.size.width - headerSize.width - footerSize.width, bounds.size.height);
                    break;
                }
                case UIUserInterfaceLayoutDirectionRightToLeft: {
                    headerFrame = CGRectMake(bounds.size.width - headerSize.width, 0, headerSize.width, bounds.size.height);
                    footerFrame = CGRectMake(0, 0, footerSize.width, bounds.size.height);
                    collectionFrame = CGRectMake(footerSize.width, 0, bounds.size.width - headerSize.width - footerSize.width, bounds.size.height);
                    break;
                }
            }
            break;
        }
        case XZSegmentOrientationVertical: {
            headerFrame = CGRectMake(0, 0, bounds.size.width, headerSize.height);
            footerFrame = CGRectMake(0, bounds.size.height - footerSize.height, bounds.size.width, footerSize.height);
            collectionFrame = CGRectMake(0, headerSize.height, bounds.size.width, bounds.size.height - headerSize.height - footerSize.height);
            break;
        }
    }
    
    if (!CGRectEqualToRect(_headerView.frame, headerFrame)) {
        _headerView.frame = headerFrame;
    }
    
    if (!CGRectEqualToRect(_footerView.frame, footerFrame)) {
        _footerView.frame = footerFrame;
    }
    
    if (!CGRectEqualToRect(_collectionView.frame, collectionFrame)) {
        _collectionView.frame = collectionFrame;
        [self XZSegmentUpdateTitleItems];
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    if (_selectedIndex == selectedIndex) {
        return;
    }
    NSParameterAssert(_selectedIndex >= 0 && _selectedIndex < self.numberOfSegments);
    
    XZSegmentItemView *oldSelectedSegment = [self viewForSegmentAtIndex:_selectedIndex];
    [oldSelectedSegment updateInteractiveTransition:0];
    
    _selectedIndex = MAX(0, MIN(selectedIndex, self.numberOfSegments));
    
    XZSegmentItemView *newSelectedSegment = [self viewForSegmentAtIndex:_selectedIndex];
    [newSelectedSegment updateInteractiveTransition:1.0];
    
    if (_pendingSegment != oldSelectedSegment && _pendingSegment != newSelectedSegment) {
        [_pendingSegment updateInteractiveTransition:0];
    }
    _pendingSegment = nil;
    
    // 刷新指示器布局
    if (animated) {
        [_collectionView performBatchUpdates:^{
            [_flowLayout invalidateIndicatorLayout:0 animated:YES];
        } completion:nil];
    } else {
        [_flowLayout invalidateIndicatorLayout:0 animated:YES];
    }
    
    // 将 selected 显示在中间
    UICollectionViewScrollPosition scrollPosition = UICollectionViewScrollPositionNone;
    switch (_flowLayout.scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal:
            scrollPosition = UICollectionViewScrollPositionCenteredHorizontally;
            break;
        case UICollectionViewScrollDirectionVertical:
            scrollPosition = UICollectionViewScrollPositionCenteredVertically;
            break;
        default:
            break;
    }
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:selectedIndex inSection:0];
    [_collectionView selectItemAtIndexPath:newIndexPath animated:animated scrollPosition:scrollPosition];
}

- (void)reloadData {
    [self reloadData:NO completion:nil];
}

- (void)reloadData:(BOOL)animated completion:(void (^)(BOOL))completion {
    [self XZSegmentUpdateTitleItems];
    
    // 自动调整 selectedIndex 到合理的范围
    NSInteger const count = self.numberOfSegments;
    if (count == 0) {
        _selectedIndex = NSNotFound;
    } else if (_selectedIndex == NSNotFound) {
        _selectedIndex = 0;
    } else {
        _selectedIndex = MIN(count - 1, _selectedIndex);
    }
    
    // 直接在 reloadData 后面 selectItem 操作无效，所以要使用 performBatchUpdates 方法
    typeof(self) __weak wself = self;
    void (^ const reloadData)(void) = ^{
        [self->_collectionView performBatchUpdates:^{
            // The _flowLayout will change the selectedIndex automatically
            [self->_collectionView reloadData];
        } completion:^(BOOL finished) {
            typeof(self) __strong const self = wself;
            if (self == nil || self.numberOfSegments == 0) return;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedIndex inSection:0];
            [self->_collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:(UICollectionViewScrollPositionNone)];
            if (completion) {
                completion(finished);
            }
        }];
    };
    if (animated) {
        reloadData();
    } else {
        [UIView performWithoutAnimation:reloadData];
    }
}

- (void)insertSegmentAtIndex:(NSInteger)index {
    [_collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
}

- (void)removeSegmentAtIndex:(NSInteger)index {
    [_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
}

- (__kindof XZSegmentItemView *)viewForSegmentAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    return (XZSegmentItemView *)[_collectionView cellForItemAtIndexPath:indexPath];
}

- (void)registerClass:(Class)segmentClass forSegmentWithReuseIdentifier:(NSString *)identifier {
    NSParameterAssert([segmentClass isSubclassOfClass:[XZSegmentItemView class]]);
    NSParameterAssert(![identifier isEqualToString:kReuseIdentifier]);
    [_collectionView registerClass:segmentClass forCellWithReuseIdentifier:identifier];
}

- (void)registerNib:(UINib *)segmentNib forSegmentWithReuseIdentifier:(NSString *)identifier {
    NSParameterAssert(![identifier isEqualToString:kReuseIdentifier]);
    [_collectionView registerNib:segmentNib forCellWithReuseIdentifier:identifier];
}

- (__kindof UICollectionViewCell *)dequeueReusableSegmentWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    return [_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_dataSource) {
        return [_dataSource numberOfSegmentsInSegmentedControl:self];
    }
    return _titleItems.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger const index = indexPath.item;
    
    // 重置 transition 。
    CGFloat const transition = (_selectedIndex == index ? 1.0 : 0.0);
    
    if (_dataSource) {
        XZSegmentItemView *segment = [_dataSource segmentedControl:self viewForSegmentAtIndex:index];
        [segment updateInteractiveTransition:transition];
        return segment;
    }
    
    XZSegmentTextItem *model = _titleItems[index];

    XZSegmentTextItemView *segment = [collectionView dequeueReusableCellWithReuseIdentifier:kReuseIdentifier forIndexPath:indexPath];
    segment.segmentedControl = self;
    segment.text             = model.text;
    [segment updateInteractiveTransition:transition];
    
    return segment;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    _indicatorView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kind forIndexPath:indexPath];
    [_indicatorView prepareForSegmentedControl:self];
    return _indicatorView;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    return NO;
}

#pragma mark - <UICollectionViewDelegate>

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.isEnabled) return;
    [self setSelectedIndex:indexPath.item animated:YES];
    [self sendActionsForControlEvents:(UIControlEventValueChanged)];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_dataSource) {
        return [_dataSource segmentedControl:self sizeForSegmentAtIndex:indexPath.item];
    }
    if (_titleItems) {
        return _titleItems[indexPath.item].size;
    }
    return collectionViewLayout.itemSize;
}

#pragma mark - 属性

- (NSInteger)numberOfSegments {
    return [_collectionView numberOfItemsInSection:0];
}

- (XZSegmentOrientation)orientation {
    return (XZSegmentOrientation)_flowLayout.scrollDirection;
}

- (void)setOrientation:(XZSegmentOrientation)direction {
    switch (direction) {
        case XZSegmentOrientationVertical:
            _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
            _collectionView.alwaysBounceHorizontal = NO;
            _collectionView.alwaysBounceVertical   = YES;
            break;
            
        case XZSegmentOrientationHorizontal:
            _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            _collectionView.alwaysBounceHorizontal = YES;
            _collectionView.alwaysBounceVertical   = NO;
            break;
            
        default:
            @throw [NSException exceptionWithName:NSGenericException reason:nil userInfo:nil];
    }
}

- (void)setHeaderView:(UIView *)headerView {
    if (_headerView != headerView) {
        [_headerView removeFromSuperview];
        _headerView = headerView;
        if (_headerView != nil) {
            if (CGRectIsEmpty(_headerView.frame)) {
                [_headerView sizeToFit];
            }
            [self addSubview:_headerView];
        }
    }
}

- (void)setFooterView:(UIView *)footerView {
    if (_footerView != footerView) {
        [_footerView removeFromSuperview];
        _footerView = footerView;
        if (_footerView != nil) {
            if (CGRectIsEmpty(_footerView.frame)) {
                [_footerView sizeToFit];
            }
            [self addSubview:_footerView];
        }
    }
}

- (NSInteger)selectedIndex {
    return _selectedIndex;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (CGSize)titleSize {
    return _flowLayout.itemSize;
}

- (void)setTitleSize:(CGSize)titleSize {
    _flowLayout.itemSize = titleSize;
    [self XZSegmentUpdateTitleItems];
}


- (CGFloat)titleSpacing {
    return _flowLayout.minimumInteritemSpacing;
}

- (void)setTitleSpacing:(CGFloat)titleSpacing {
    switch (_flowLayout.scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal:
            _flowLayout.minimumLineSpacing = titleSpacing;
            _flowLayout.minimumInteritemSpacing = titleSpacing;
            break;
        case UICollectionViewScrollDirectionVertical:
            _flowLayout.minimumLineSpacing = titleSpacing;
            _flowLayout.minimumInteritemSpacing = titleSpacing;
            break;
        default:
            @throw [NSException exceptionWithName:NSGenericException reason:nil userInfo:nil];
            break;
    }
}

- (void)updateInteractiveTransition:(CGFloat)interactiveTransition {
    [_flowLayout invalidateIndicatorLayout:interactiveTransition animated:NO];
    
    NSInteger           const selectedIndex   = _selectedIndex;
    XZSegmentItemView * const selectedSegment = [self viewForSegmentAtIndex:selectedIndex];
    
    if (interactiveTransition == 0) {
        [selectedSegment updateInteractiveTransition:1.0];
        [_pendingSegment updateInteractiveTransition:0.0];
        _pendingSegment = nil;
        return;
    }
    
    CGFloat progress = 0;
    NSInteger pendingIndex = 0;
    
    if (interactiveTransition > 0) {
        progress = interactiveTransition - floor(interactiveTransition);
        pendingIndex = selectedIndex + ceil(interactiveTransition);
    } else {
        progress = -interactiveTransition - floor(-interactiveTransition);
        pendingIndex = selectedIndex + floor(interactiveTransition);
    }
    
    [selectedSegment updateInteractiveTransition:(1.0 - progress)];
    if (pendingIndex >= 0 && pendingIndex < self.numberOfSegments) {
        XZSegmentItemView * const pendingSegment = [self viewForSegmentAtIndex:pendingIndex];
        if (_pendingSegment != pendingSegment) {
            [_pendingSegment updateInteractiveTransition:0];
            _pendingSegment = pendingSegment;
        }
        [_pendingSegment updateInteractiveTransition:progress];
    } else if (_pendingSegment) {
        [_pendingSegment updateInteractiveTransition:0];
        _pendingSegment = nil;
    }
}

- (void)setIndicatorColor:(UIColor *)indicatorColor {
    if ([_indicatorColor isEqual:indicatorColor]) {
        return;
    }
    _indicatorColor = indicatorColor;
    switch (_indicatorStyle) {
        case XZSegmentIndicatorStyleMarkLine:
        case XZSegmentIndicatorStyleNoteLine: {
            XZSegmentLineIndicatorView *indicatorView = (id)self->_indicatorView;
            indicatorView.color = _indicatorColor;
            break;
        }
        default:
            break;
    }
}

- (void)setIndicatorImage:(UIImage *)indicatorImage {
    if ([_indicatorImage isEqual:indicatorImage]) {
        return;
    }
    _indicatorImage = indicatorImage;
    switch (_indicatorStyle) {
        case XZSegmentIndicatorStyleMarkLine:
        case XZSegmentIndicatorStyleNoteLine: {
            XZSegmentLineIndicatorView *indicatorView = (id)self->_indicatorView;
            indicatorView.image = _indicatorImage;
            break;
        }
        default:
            break;
    }
}

- (void)setIndicatorSize:(CGSize)indicatorSize {
    if (CGSizeEqualToSize(_indicatorSize, indicatorSize)) {
        return;
    }
    _indicatorSize = indicatorSize;
    [_flowLayout invalidateIndicatorLayout:0 animated:YES];
}

- (void)setIndicatorStyle:(XZSegmentIndicatorStyle)indicatorStyle {
    if (_indicatorStyle != indicatorStyle) {
        switch (_indicatorStyle) {
            case XZSegmentIndicatorStyleMarkLine:
                _flowLayout.indicatorClass = [XZSegmentMarkLineIndicatorView class];
                break;
            case XZSegmentIndicatorStyleNoteLine:
                _flowLayout.indicatorClass = [XZSegmentNoteLineIndicatorView class];
                break;
            case XZSegmentIndicatorStyleCustom:
                break;
            default:
                return;
        }
        _indicatorStyle = indicatorStyle;
    }
}

- (void)setIndicatorClass:(Class)indicatorClass {
    NSParameterAssert([indicatorClass isSubclassOfClass:[XZSegmentIndicatorView class]]);
    _indicatorStyle = XZSegmentIndicatorStyleCustom;
    _flowLayout.indicatorClass = indicatorClass;
}

- (Class)indicatorClass {
    return _flowLayout.indicatorClass;
}

- (void)setDataSource:(id<XZSegmentDataSource>)dataSource {
    _titleItems = nil;
    _dataSource = dataSource;
    [self reloadData];
}

- (NSArray<NSString *> *)titles {
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:_titleItems.count];
    for (XZSegmentTextItem *item in _titleItems) {
        [items addObject:item.text];
    }
    return items;
}

- (void)setTitles:(NSArray<NSString *> *)titles {
    [self setTitles:titles animated:NO];
}

- (void)setTitles:(NSArray<NSString *> *)titles animated:(BOOL)animated {
    _dataSource = nil;
    if (titles.count == 0) {
        _titleItems = nil;
    } else if (titles.count < _titleItems.count) {
        [_titleItems removeObjectsInRange:NSMakeRange(titles.count, _titleItems.count - titles.count)];
    } else if (titles.count > _titleItems.count) {
        if (_titleItems == nil) {
            _titleItems = [NSMutableArray arrayWithCapacity:titles.count];
        }
        for (NSInteger i = _titleItems.count; i < titles.count; i++) {
            [_titleItems addObject:[[XZSegmentTextItem alloc] init]];
        }
    }
    for (NSInteger i = 0; i < _titleItems.count; i++) {
        _titleItems[i].text = titles[i];
    }
    [self XZSegmentUpdateTitleItems];
    [self reloadData:animated completion:nil];
}

@synthesize titleFont = _titleFont;

- (UIFont *)titleFont {
    if (_titleFont != nil) {
        return _titleFont;
    }
    return [UIFont systemFontOfSize:17.0];
}

- (void)setTitleFont:(UIFont *)titleFont {
    if (_titleFont != titleFont) {
        _titleFont = titleFont;
        [self XZSegmentUpdateTitleItems];
    }
}

@synthesize selectedTitleFont = _selectedTitleFont;

- (UIFont *)selectedTitleFont {
    if (_selectedTitleFont != nil) {
        return _selectedTitleFont;
    }
    if (_titleFont != nil) {
        return _titleFont;
    }
    return [UIFont boldSystemFontOfSize:17.0];
}

- (void)setSelectedTitleFont:(UIFont *)selectedTitleFont {
    if (_selectedTitleFont != selectedTitleFont) {
        _selectedTitleFont = selectedTitleFont;
        [self XZSegmentUpdateTitleItems];
    }
}

- (UIColor *)titleColor {
    if (_titleColor != nil) {
        return _titleColor;
    }
    return UIColor.labelColor;
}

- (UIColor *)selectedTitleColor {
    if (_selectedTitleColor != nil) {
        return _selectedTitleColor;
    }
    return UIColor.systemBlueColor;
}

#pragma mark - Private Methods

- (void)XZSegmentInitialize:(XZSegmentOrientation)orientation {
    self.clipsToBounds = YES;
    
    CGRect const bounds = self.bounds;
    
    _selectedIndex = NSNotFound;
    
    _titleFont = [UIFont systemFontOfSize:17.0];
    _selectedTitleFont = [UIFont boldSystemFontOfSize:17.0];
    _titleColor = UIColor.labelColor;
    _selectedTitleColor = UIColor.tintColor;
    
    _indicatorStyle = XZSegmentIndicatorStyleMarkLine;
    _flowLayout = [[XZSegmentLayout alloc] initWithSegmentedControl:self indicatorClass:[XZSegmentMarkLineIndicatorView class]];
    _flowLayout.minimumLineSpacing      = 0;
    _flowLayout.minimumInteritemSpacing = 0;
    _flowLayout.sectionHeadersPinToVisibleBounds = NO;
    _flowLayout.sectionFootersPinToVisibleBounds = NO;
    _flowLayout.itemSize = CGSizeNull; // 实际不会使用此值，使用 CGSizeZero 会产生控制台警告

    _collectionView = [[XZSegmentContainerView alloc] initWithFrame:bounds collectionViewLayout:_flowLayout];
    _collectionView.autoresizingMask               = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _collectionView.backgroundColor                = [UIColor clearColor];
    _collectionView.prefetchingEnabled             = NO;
    _collectionView.allowsSelection                = YES;
    _collectionView.allowsMultipleSelection        = NO; // 不允许多选
    _collectionView.clipsToBounds                  = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator   = NO;
    [self addSubview:_collectionView];
    
    switch (orientation) {
        case XZSegmentOrientationHorizontal:
            _flowLayout.scrollDirection            = UICollectionViewScrollDirectionHorizontal;
            _collectionView.alwaysBounceVertical   = NO;
            _collectionView.alwaysBounceHorizontal = YES;
            break;
        case XZSegmentOrientationVertical:
            _flowLayout.scrollDirection            = UICollectionViewScrollDirectionVertical;
            _collectionView.alwaysBounceVertical   = YES;
            _collectionView.alwaysBounceHorizontal = NO;
            break;
        default:
            break;
    }
    
    [_collectionView registerClass:[XZSegmentTextItemView class] forCellWithReuseIdentifier:kReuseIdentifier];
    _collectionView.delegate   = self;
    _collectionView.dataSource = self;
}

- (void)XZSegmentUpdateTitleItems {
    CGRect    const bounds = self.bounds;
    NSInteger const count  = _titleItems.count;
    if (count == 0) {
        return YES;
    }
    CGSize const itemSize = _flowLayout.itemSize;
    switch (self.orientation) {
        case XZSegmentOrientationHorizontal: {
            if (CGSizeIsNull(itemSize)) {
                for (NSInteger i = 0; i < _titleItems.count; i++) {
                    XZSegmentTextItem *    const item    = _titleItems[i];
                    CGSize                 const size    = CGSizeMake(0, bounds.size.height);
                    NSStringDrawingOptions const options = NSStringDrawingUsesLineFragmentOrigin;
                    CGFloat const width1 = [item.text boundingRectWithSize:size options:options attributes:@{
                        NSFontAttributeName: self.titleFont
                    } context:nil].size.width;
                    CGFloat const width2 = [item.text boundingRectWithSize:size options:options attributes:@{
                        NSFontAttributeName: self.selectedTitleFont
                    } context:nil].size.width;
                    CGFloat const width = ceil(_titleEdgeInsets.leading + MAX(width1, width2) + _titleEdgeInsets.trailing);
                    item.size = CGSizeMake(width, bounds.size.height);
                    item.edgeInsets = NSDirectionalEdgeInsetsMake(0, _titleEdgeInsets.leading, 0, _titleEdgeInsets.trailing);
                }
            } else {
                for (XZSegmentTextItem * const item in _titleItems) {
                    item.size = CGSizeMake(itemSize.width, bounds.size.height);
                }
            }
            break;
        }
        case XZSegmentOrientationVertical: {
            if (CGSizeIsNull(itemSize)) {
                for (NSInteger i = 0; i < _titleItems.count; i++) {
                    XZSegmentTextItem *item = _titleItems[i];
                    CGSize                 const size    = CGSizeMake(bounds.size.width, 0);
                    NSStringDrawingOptions const options = NSStringDrawingUsesLineFragmentOrigin;
                    CGFloat const height1 = [item.text boundingRectWithSize:size options:options attributes:@{
                        NSFontAttributeName: self.titleFont
                    } context:nil].size.height;
                    CGFloat const height2 = [item.text boundingRectWithSize:size options:options attributes:@{
                        NSFontAttributeName: self.selectedTitleFont
                    } context:nil].size.height;
                    CGFloat const height = ceil(_titleEdgeInsets.top + MAX(height1, height2) + _titleEdgeInsets.bottom);
                    item.size = CGSizeMake(bounds.size.width, height);
                    item.edgeInsets = NSDirectionalEdgeInsetsMake(_titleEdgeInsets.top, 0, _titleEdgeInsets.bottom, 0);
                }
            } else {
                for (XZSegmentTextItem * const item in _titleItems) {
                    item.size = CGSizeMake(bounds.size.width, itemSize.height);
                }
            }
            break;
        }
        default:
            break;
    }
    return YES;
}

@end
