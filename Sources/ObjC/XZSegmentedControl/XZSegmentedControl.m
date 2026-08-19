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
#import "XZTextSegmentView.h"

#define kReuseIdentifier @"XZSegmentedControlReuseIdentifier"

@interface XZSegmentedControl () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    XZSegmentLayout *_flowLayout;
    UICollectionView             *_collectionView;
    NSMutableArray<XZTextSegmentItem *> *_textItems;
    XZSegmentView * __weak _transitionSegment;
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
    
    CGRect const bounds = self.bounds;
    CGSize const headerSize = _headerView.frame.size;
    CGSize const footerSize = _footerView.frame.size;
    
    // 横向滚动时，自动将元素高度设置为自身高度
    // 纵向滚动时，自动将元素宽度设置为自身宽度
    
    CGRect headerFrame     = _headerView.frame;
    CGRect footerFrame     = _footerView.frame;
    CGRect collectionFrame = _collectionView.frame;
    CGSize itemSize        = _flowLayout.itemSize;
    
    switch (self.orientation) {
        case XZSegmentOrientationHorizontal: {
            if (bounds.size.height != _flowLayout.itemSize.height) {
                itemSize = CGSizeMake(_flowLayout.itemSize.width, bounds.size.height);
            }
            
            switch (self.effectiveUserInterfaceLayoutDirection) {
                case UIUserInterfaceLayoutDirectionLeftToRight:
                    headerFrame = CGRectMake(0, 0, headerSize.width, bounds.size.height);
                    footerFrame = CGRectMake(bounds.size.width - footerSize.width, 0, footerSize.width, bounds.size.height);
                    collectionFrame = CGRectMake(headerSize.width, 0, bounds.size.width - headerSize.width - footerSize.width, bounds.size.height);
                    break;
                case UIUserInterfaceLayoutDirectionRightToLeft:
                    headerFrame = CGRectMake(bounds.size.width - headerSize.width, 0, headerSize.width, bounds.size.height);
                    footerFrame = CGRectMake(0, 0, footerSize.width, bounds.size.height);
                    collectionFrame = CGRectMake(footerSize.width, 0, bounds.size.width - headerSize.width - footerSize.width, bounds.size.height);
                    break;
                default:
                    break;
            }
            break;
        }
        case XZSegmentOrientationVertical: {
            if (bounds.size.width != _flowLayout.itemSize.width) {
                itemSize = CGSizeMake(bounds.size.width, _flowLayout.itemSize.height);
            }
            headerFrame = CGRectMake(0, 0, bounds.size.width, headerSize.height);
            footerFrame = CGRectMake(0, bounds.size.height - footerSize.height, bounds.size.width, footerSize.height);
            collectionFrame = CGRectMake(0, headerSize.height, bounds.size.width, bounds.size.height - headerSize.height - footerSize.height);
            break;
        }
        default: {
            break;
        }
    }
    
    if (!CGRectEqualToRect(_headerView.frame, headerFrame)) {
        _headerView.frame = headerFrame;
    }
    if (!CGRectEqualToRect(_footerView.frame, footerFrame)) {
        _footerView.frame = footerFrame;
    }
    BOOL needsUpdate = NO;
    if (!CGSizeEqualToSize(_flowLayout.itemSize, itemSize)) {
        _flowLayout.itemSize = itemSize;
        needsUpdate = YES;
    }
    if (!CGRectEqualToRect(_collectionView.frame, collectionFrame)) {
        _collectionView.frame = collectionFrame;
        needsUpdate = YES;
    }
    if (needsUpdate) {
        [self updateTextSegmentItems];
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    [self setSelectedIndex:selectedIndex animated:animated centered:YES];
}

- (void)setSelectedIndex:(NSInteger const)selectedIndex animated:(BOOL)animated centered:(BOOL)centered {
    NSInteger const oldValue = _flowLayout.selectedIndex;
    if (selectedIndex == oldValue) return;
    
    // 取消已选
    if (oldValue != NSNotFound) {
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForItem:oldValue inSection:0];
        [_collectionView deselectItemAtIndexPath:oldIndexPath animated:animated];
    }
    
    // 移动指示器位置
    [_flowLayout setSelectedIndex:selectedIndex animated:animated];
    
    // 选中新的
    UICollectionViewScrollPosition scrollPosition = UICollectionViewScrollPositionNone;
    if (centered) {
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
    }
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:selectedIndex inSection:0];
    [_collectionView selectItemAtIndexPath:newIndexPath animated:animated scrollPosition:scrollPosition];
}

- (void)reloadData {
    [self reloadData:NO completion:nil];
}

- (void)reloadData:(BOOL)animated completion:(void (^)(BOOL))completion {
    [self updateTextSegmentItems];
    
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
    
    NSInteger const selectedIndex = self.selectedIndex;
    if (selectedIndex >= index) {
        [_flowLayout setSelectedIndex:selectedIndex + 1 animated:YES];
    }
}

- (void)removeSegmentAtIndex:(NSInteger)index {
    [_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
    NSInteger const selectedIndex = self.selectedIndex;
    if (selectedIndex >= index) {
        [_flowLayout setSelectedIndex:selectedIndex - 1 animated:YES];
    }
}

- (__kindof XZSegmentView *)viewForSegmentAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    return (XZSegmentView *)[_collectionView cellForItemAtIndexPath:indexPath];
}

- (void)registerClass:(Class)segmentClass forSegmentWithReuseIdentifier:(NSString *)identifier {
    NSParameterAssert([segmentClass isSubclassOfClass:[XZSegmentView class]]);
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
    return _textItems.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger const index = indexPath.item;
    
    // 重置 transition 。
    // 因为此处仅负责装载数据，且 cell 的 select 状态是由 collectionView 管理的，也最终会被重新赋值。
    CGFloat const transition = _flowLayout.selectedIndex == index ? 1.0 : 0;
    
    if (_dataSource) {
        XZSegmentView *segment = [_dataSource segmentedControl:self viewForSegmentAtIndex:index];
        [segment updateInteractiveTransition:transition];
        return segment;
    }
    
    XZTextSegmentItem *model = _textItems[index];

    XZTextSegmentView *segment = [collectionView dequeueReusableCellWithReuseIdentifier:kReuseIdentifier forIndexPath:indexPath];
    segment.segmentedControl = self;
    segment.text             = model.text;
    [segment updateInteractiveTransition:transition];
    
    return segment;
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
    [_flowLayout setSelectedIndex:indexPath.item animated:YES];
    [self sendActionsForControlEvents:(UIControlEventValueChanged)];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_dataSource) {
        return [_dataSource segmentedControl:self sizeForSegmentAtIndex:indexPath.item];
    }
    if (_textItems) {
        return _textItems[indexPath.item].size;
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
    return _flowLayout.selectedIndex;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (CGSize)titleSize {
    return _flowLayout.itemSize;
}

- (void)setTitleSize:(CGSize)titleSize {
    _flowLayout.itemSize = titleSize;
    [self updateTextSegmentItems];
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
    _flowLayout.interactiveTransition = interactiveTransition;
    
    NSInteger       const selectedIndex        = _flowLayout.selectedIndex;
    XZSegmentView * const selectedSegment      = [self viewForSegmentAtIndex:selectedIndex];
    XZSegmentView * const oldTransitionSegment = _transitionSegment;
    
    if (interactiveTransition > 0) {
        CGFloat const intPart = floor(interactiveTransition);
        CGFloat const decPart = interactiveTransition - intPart;
        
        [selectedSegment updateInteractiveTransition:(1.0 - decPart)];
        
        NSInteger const count = [_collectionView numberOfItemsInSection:0];
        NSInteger const transitionIndex = selectedIndex + intPart + 1;
        if (transitionIndex <= count - 1) {
            XZSegmentView * const newTransitionSegment = [self viewForSegmentAtIndex:transitionIndex];
            if (oldTransitionSegment != newTransitionSegment) {
                if (oldTransitionSegment != selectedSegment) {
                    [oldTransitionSegment updateInteractiveTransition:0];
                }
                _transitionSegment =  newTransitionSegment;
            }
            [_transitionSegment updateInteractiveTransition:decPart];
        } else if (oldTransitionSegment != nil) {
            [oldTransitionSegment updateInteractiveTransition:0];
            _transitionSegment = nil;
        }
    } else if (interactiveTransition < 0) {
        CGFloat const intPart = ceil(interactiveTransition);
        CGFloat const decPart = interactiveTransition - intPart;
        
        [selectedSegment updateInteractiveTransition:(1.0 + decPart)];
        
        NSInteger const transitionIndex = selectedIndex + intPart - 1;
        if (transitionIndex >= 0) {
            XZSegmentView * const newTransitionSegment = [self viewForSegmentAtIndex:transitionIndex];
            if (oldTransitionSegment != newTransitionSegment) {
                if (oldTransitionSegment != selectedSegment) {
                    [oldTransitionSegment updateInteractiveTransition:0];
                }
                _transitionSegment = newTransitionSegment;
            }
            [_transitionSegment updateInteractiveTransition:-decPart];
        } else if (oldTransitionSegment != nil) {
            [oldTransitionSegment updateInteractiveTransition:0];
            _transitionSegment = nil;
        }
    } else {
        [selectedSegment updateInteractiveTransition:1.0];
        
        if (oldTransitionSegment != nil) {
            // oldTransitionSegment 变为了 selectedSegment
            if (oldTransitionSegment != selectedSegment) {
                [oldTransitionSegment updateInteractiveTransition:0];
            }
            _transitionSegment = nil;
        }
    }
}

- (UIColor *)indicatorColor {
    return _flowLayout.indicatorColor;
}

- (void)setIndicatorColor:(UIColor *)indicatorColor {
    _flowLayout.indicatorColor = indicatorColor;
}

- (UIImage *)indicatorImage {
    return _flowLayout.indicatorImage;
}

- (void)setIndicatorImage:(UIImage *)indicatorImage {
    _flowLayout.indicatorImage = indicatorImage;
}

- (CGSize)indicatorSize {
    return _flowLayout.indicatorSize;
}

- (void)setIndicatorSize:(CGSize)indicatorSize {
    _flowLayout.indicatorSize = indicatorSize;
}

- (XZSegmentIndicatorStyle)indicatorStyle {
    return _flowLayout.indicatorStyle;
}

- (void)setIndicatorStyle:(XZSegmentIndicatorStyle)indicatorStyle {
    _flowLayout.indicatorStyle = indicatorStyle;
}

- (void)setIndicatorClass:(Class)indicatorClass {
    _flowLayout.indicatorClass = indicatorClass;
}

- (Class)indicatorClass {
    return _flowLayout.indicatorClass;
}

- (void)setDataSource:(id<XZSegmentDataSource>)dataSource {
    _textItems = nil;
    _dataSource = dataSource;
    [self reloadData];
}

- (NSArray<NSString *> *)titles {
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:_textItems.count];
    for (XZTextSegmentItem *item in _textItems) {
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
        _textItems = nil;
    } else if (titles.count < _textItems.count) {
        [_textItems removeObjectsInRange:NSMakeRange(titles.count, _textItems.count - titles.count)];
    } else if (titles.count > _textItems.count) {
        if (_textItems == nil) {
            _textItems = [NSMutableArray arrayWithCapacity:titles.count];
        }
        for (NSInteger i = _textItems.count; i < titles.count; i++) {
            [_textItems addObject:[[XZTextSegmentItem alloc] init]];
        }
    }
    for (NSInteger i = 0; i < _textItems.count; i++) {
        _textItems[i].text = titles[i];
    }
    [self updateTextSegmentItems];
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
        [self updateTextSegmentItems];
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
        [self updateTextSegmentItems];
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
    
    _titleFont = [UIFont systemFontOfSize:17.0];
    _selectedTitleFont = [UIFont boldSystemFontOfSize:17.0];
    _titleColor = UIColor.labelColor;
    _selectedTitleColor = UIColor.tintColor;
    
    _flowLayout = [[XZSegmentLayout alloc] initWithSegmentedControl:self];
    _flowLayout.minimumLineSpacing      = 0;
    _flowLayout.minimumInteritemSpacing = 0;
    _flowLayout.sectionHeadersPinToVisibleBounds = NO;
    _flowLayout.sectionFootersPinToVisibleBounds = NO;
    _flowLayout.itemSize = CGSizeMake(1.0, 1.0);

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
    
    [_collectionView registerClass:[XZTextSegmentView class] forCellWithReuseIdentifier:kReuseIdentifier];
    _collectionView.delegate   = self;
    _collectionView.dataSource = self;
}

- (void)updateTextSegmentItems {
    CGRect    const bounds = self.bounds;
    NSInteger const count  = _textItems.count;
    if (count == 0) {
        return YES;
    }
    CGSize const itemSize = _flowLayout.itemSize;
    switch (self.orientation) {
        case XZSegmentOrientationHorizontal: {
            if (itemSize.width <= 0) {
                for (NSInteger i = 0; i < _textItems.count; i++) {
                    XZTextSegmentItem *    const item    = _textItems[i];
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
                for (XZTextSegmentItem * const item in _textItems) {
                    item.size = CGSizeMake(itemSize.width, bounds.size.height);
                }
            }
            break;
        }
        case XZSegmentOrientationVertical: {
            if (itemSize.height <= 0) {
                for (NSInteger i = 0; i < _textItems.count; i++) {
                    XZTextSegmentItem *item = _textItems[i];
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
                for (XZTextSegmentItem * const item in _textItems) {
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
