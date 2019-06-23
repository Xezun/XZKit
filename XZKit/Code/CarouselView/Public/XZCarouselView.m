//
//  XZCarouselView.m
//  XZCarouselView
//
//  Created by mlibai on 2017/2/13.
//  Copyright © 2017年 mlibai. All rights reserved.
//

#import "XZCarouselView.h"
#import "XZCarouselView.ItemView.h"
#import "XZCarouselView.ScrollView.h"
#import <XZKit/XZKit-Swift.h>

NSTimeInterval const XZCarouselViewAnimationDuration = 0.3;
NSInteger      const XZCarouselViewNotFound          = -1;
NSTimeInterval const XZCarouselViewTransitioningAnimationDuration = 7.0;

static NSString *XZCarouselViewTransitionAnimationKey = @"XZCarouselViewTransitionAnimationKey";

/// 记录缩放状态的结构体。
typedef struct _XZCarouselViewZoomingState {
    CGPoint contentOffset;
    CGFloat zoomScale;
} _XZCarouselViewZoomingState;
static _XZCarouselViewZoomingState const _XZCarouselViewZoomingStateDefault = {{0.0, 0.0}, 1.0};

/// 记录 ItemView 信息的结构体，以方便重用。
typedef struct _XZCarouselViewItemViewInfo {
    NSInteger index;
    CGSize preferredContentSize;
    UIView * __unsafe_unretained contentView;
} _XZCarouselViewItemViewInfo;


/// 设置视图，如果是缩放记忆模式，会保存当前的缩放状态。// 在执行本函数前 oldIndex 与 newIndex 已判断不相等。
static void XZCarouselViewItemViewSetContentView(XZCarouselView * const _Nonnull carouselView, _XZCarouselViewItemView * const _Nonnull itemView, NSInteger const newIndex, UIView * const contentView, CGSize const preferredContentSize);
/// 对一个数进行轮回，numberOfItems 必须大于 0 。
static NSInteger XZCarouselViewWrappedIndex(NSInteger const index, NSInteger const numberOfItems);
/// 从 fromIndex 到 toIndex 的滚动方向。
static XZCarouselViewPagingDirection XZCarouselViewPagingDirectionMake(BOOL const isWrapped, NSInteger const fromIndex, NSInteger const toIndex, NSInteger const count);
/// 根据指定的 transition 来判断当前是否需要刷新视图、更新间距，同时发送转场结束事件、index变更事件、转场动画进度事件、发送事件。
static void XZCarouselViewTransitionDidChange(XZCarouselView * const _Nonnull carouselView, CGFloat const transition, BOOL const sendsIndexChangeEvents, BOOL const sendsTransitionEvents, BOOL const animated);
/// 给所有 itemView 加载 contentView 。
static void XZCarouselViewLoadContentViewWithIndexes(XZCarouselView * const _Nonnull carouselView, NSInteger newItemViewIndexes[const 5], BOOL const animated);
/// 添加自定义转场动画。
static void XZCarouselViewAddTransitionAnimationIfNeeded(XZCarouselView * const _Nonnull carouselView, BOOL isUserInteractive);
/// 移除自定义转场动画。
static void XZCarouselViewRemoveTransitionAnimationIfNeeded(XZCarouselView * const _Nonnull carouselView, BOOL isCompleted);
/// 获取当前的转场进度。
static CGFloat XZCarouselViewScrollViewGetTransition(_XZCarouselViewScrollView * const _Nonnull scrollView);


@interface XZCarouselView () <_XZCarouselViewItemViewDelegate> {
    @package
    id<XZCarouselViewDelegate> __weak _delegate;
    id<XZCarouselViewDataSource> __weak _dataSource;
    id<XZCarouselViewTransitioningDelegate> __weak _transitioningDelegate;
    BOOL _remembersZoomingState;
    BOOL _keepsTransitioningViews;
    BOOL _isWrapped;
    NSInteger _currentIndex;
    NSInteger _numberOfViews;
    CAAnimation *_transitioningAnimation;
    /// 转场进度：用来优化计算待加载的视图，当新的 transition 与 _transition 有相同的符号时，不刷新现有的视图。
    CGFloat _transition;
    /// 用于处理自动轮播的定时器。
    NSTimer * __weak _Nullable _scrollTimer;
    /// 横向滚动的滚动视图。
    _XZCarouselViewScrollView    * _Nonnull _scrollView;
    /// 缓存的缩放状态，非缩放记忆模式为 NULL 。
    _XZCarouselViewZoomingState * _Nullable _cachedZoomingStates;
    /// 是否处于转场过程中。
    BOOL _isTransitioning;
    /// 重用池。
    NSMutableArray<UIView *> * _Nullable _reusingViews;
}

@end

@implementation XZCarouselView

@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;
@synthesize scrollView = _scrollView;
@synthesize wrapped = _isWrapped;
@synthesize numberOfViews = _numberOfViews;
@synthesize zoomingLockEnabled = _isZoomingLockEnabled;
@synthesize remembersZoomingState = _remembersZoomingState;
@synthesize doubleTapGestureRecognizer = _doubleTapGestureRecognizer;
@synthesize keepsTransitioningViews = _keepsTransitioningViews;
@synthesize transitioningAnimation = _transitioningAnimation;
@synthesize transitioningDelegate = _transitioningDelegate;

- (void)dealloc {
    free(_cachedZoomingStates);
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame pagingOrientation:(XZCarouselViewPagingOrientationHorizontal)];
}

- (instancetype)initWithFrame:(CGRect)frame pagingOrientation:(XZCarouselViewPagingOrientation)pagingOrientation {
    self = [super initWithFrame:frame];
    if (self) {
        [super setClipsToBounds:YES];
        [self _XZCarouselViewDidInitialize:pagingOrientation contentMode:(UIViewContentModeRedraw)];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        XZCarouselViewPagingOrientation const pagingOrientation = (super.tag == -1 ? XZCarouselViewPagingOrientationVertical : XZCarouselViewPagingOrientationHorizontal);
        UIViewContentMode const contentMode = super.contentMode;
        [self _XZCarouselViewDidInitialize:pagingOrientation contentMode:contentMode];
    }
    return self;
}

- (void)_XZCarouselViewDidInitialize:(XZCarouselViewPagingOrientation const)pagingOrientation contentMode:(UIViewContentMode const)contentMode {
    _isWrapped             = YES; // 默认无限轮播模式开启。
    _currentIndex          = XZCarouselViewNotFound; // 默认没有内容。
    _numberOfViews         = 0;
    _pagingDirection       = XZCarouselViewPagingDirectionForward; // 默认正向轮播。
    _isZoomingLockEnabled  = YES; // 默认缩放锁启用。
    _remembersZoomingState = NO; // 非记忆缩放模式。
    _reusingViews          = nil;
    _keepsTransitioningViews = NO;
    
    UIColor * const backgroundColor = self.backgroundColor;
    BOOL const clipsToBounds = self.clipsToBounds;
    
    // 重写了 layoutSubviews 方法就不要使用 autoresizingMask 了。
    // 使用了 autoresizingMask 后，可能会导致 _scrollView 与其子视图大小可能不一致的情况。
    _scrollView = [[_XZCarouselViewScrollView alloc] initWithFrame:self.bounds carouselView:self pagingOrientation:pagingOrientation];
    // 统一 clipsToBounds
    _scrollView.clipsToBounds = clipsToBounds;
    // 统一 backgroundColor
    _scrollView.backgroundColor = backgroundColor;
    _scrollView->_itemView0.backgroundColor = backgroundColor;
    _scrollView->_itemView1.backgroundColor = backgroundColor;
    _scrollView->_itemView2.backgroundColor = backgroundColor;
    _scrollView->_itemView3.backgroundColor = backgroundColor;
    _scrollView->_itemView4.backgroundColor = backgroundColor;
    // 统一 contentMode
    _scrollView->_itemView0.contentMode = contentMode;
    _scrollView->_itemView1.contentMode = contentMode;
    _scrollView->_itemView2.contentMode = contentMode;
    _scrollView->_itemView3.contentMode = contentMode;
    _scrollView->_itemView4.contentMode = contentMode;
    [self addSubview:_scrollView];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
#else
    _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
#endif
    
    _scrollView.delegate = self;
    _scrollView->_itemView2.delegate = self;
}

#pragma mark - Override Methods

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    if (_scrollView == nil) {
        return;
    }
    [_scrollView setBackgroundColor:backgroundColor];
    [_scrollView->_itemView0 setBackgroundColor:backgroundColor];
    [_scrollView->_itemView1 setBackgroundColor:backgroundColor];
    [_scrollView->_itemView2 setBackgroundColor:backgroundColor];
    [_scrollView->_itemView3 setBackgroundColor:backgroundColor];
    [_scrollView->_itemView4 setBackgroundColor:backgroundColor];
}

- (void)setClipsToBounds:(BOOL)clipsToBounds {
    [super setClipsToBounds:clipsToBounds];
    [_scrollView setClipsToBounds:clipsToBounds];
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    if (_scrollView == nil) {
        // initWithCoder: 初始化过程中，属性是通过 setter 方法初始化的。
        return [super setContentMode:contentMode];
    }
    if (_scrollView->_itemView2.contentMode == contentMode) {
        return;
    }
    [_scrollView->_itemView0 setContentMode:contentMode];
    [_scrollView->_itemView1 setContentMode:contentMode];
    [_scrollView->_itemView2 setContentMode:contentMode];
    [_scrollView->_itemView3 setContentMode:contentMode];
    [_scrollView->_itemView4 setContentMode:contentMode];
    
    // 重置所有视图的缩放状态。
    if (_numberOfViews == 0) {
        return;
    }
    if (_remembersZoomingState) {
        for (NSInteger i = 0; i < _numberOfViews; i++) {
            _cachedZoomingStates[i] = _XZCarouselViewZoomingStateDefault;
        }
    }
}

- (UIViewContentMode)contentMode {
    return [_scrollView->_itemView2 contentMode];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect kBounds = self.self.bounds;
    
    if (CGRectEqualToRect(_scrollView.frame, kBounds)) {
        return;
    }
    
    // 在调整布局的过程中，_scrollView 与子视图的位置大小关系，并不一定是正确的业务逻辑表现。
    [_scrollView setDelegate:nil];
    
    // 轮播图大小改变时，重置缩放状态。
    _scrollView.scrollEnabled = YES;
    [_scrollView->_itemView0 setZoomScale:1.0 animated:NO];
    [_scrollView->_itemView0 setContentOffset:(CGPointZero) animated:NO];
    [_scrollView->_itemView1 setZoomScale:1.0 animated:NO];
    [_scrollView->_itemView1 setContentOffset:(CGPointZero) animated:NO];
    [_scrollView->_itemView2 setZoomScale:1.0 animated:NO];
    [_scrollView->_itemView2 setContentOffset:(CGPointZero) animated:NO];
    [_scrollView->_itemView3 setZoomScale:1.0 animated:NO];
    [_scrollView->_itemView3 setContentOffset:(CGPointZero) animated:NO];
    [_scrollView->_itemView4 setZoomScale:1.0 animated:NO];
    [_scrollView->_itemView4 setContentOffset:(CGPointZero) animated:NO];
    
    if (_remembersZoomingState) {
        for (NSInteger i = 0; i < _numberOfViews; i++) {
            _cachedZoomingStates[i] = _XZCarouselViewZoomingStateDefault;
        }
    }
    
    // 移除动画。
    XZCarouselViewRemoveTransitionAnimationIfNeeded(self, NO);
    
    // 判断当前是否需要发送 transition 事件。
    BOOL const needsSendTransitionEvents = XZCarouselViewScrollViewGetTransition(_scrollView) != 0.0;
    
    _scrollView.frame = kBounds;
    [_scrollView layoutIfNeeded];
    
    if (_numberOfViews == 0) { // 当前没有可显示的内容的默认布局。
        [_scrollView setPrevItemViewVisiable:NO nextItemViewVisiable:NO];
    } else if (_isWrapped) { // 当前为无限轮播模式。
        [_scrollView setPrevItemViewVisiable:YES nextItemViewVisiable:YES];
    } else { // 非无限轮播
        [_scrollView setPrevItemViewVisiable:_currentIndex > 0 nextItemViewVisiable:_currentIndex < _numberOfViews - 1];
    }
    
    // 展示中间的视图，带 animated 的方法会同时使 UIScrollView 停止滚动。
    [_scrollView setContentOffset:_scrollView->_itemView2.frame.origin animated:NO];
    // 因为强制滚动视图到 2 位置，所以发送 transition 事件。
    XZCarouselViewTransitionDidChange(self, 0, NO, needsSendTransitionEvents, NO);
    
    // 非无限轮播模式，只有一个视图。
    return [_scrollView setDelegate:self];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    if ([self window] == nil) {
        // 如果轮播图不显示了，则自动轮播停止。
        [_scrollTimer invalidate];
    } else {
        // 轮播图显示时，自动检查是否需要自动轮播。
        [self _XZCarouselViewAutoScrollIfNeeded];
    }
}

#pragma mark - Public Methods

- (void)_XZCarouselViewPrepareReloadData {
    // 刷新视图，重置缩放。
    _scrollView.scrollEnabled = YES;
    
    // 获取视图数量
    _numberOfViews = MAX(0, [_dataSource numberOfViewsInCarouselView:self]);
    
    // 重置缩放状态缓存。
    if (!_remembersZoomingState || _numberOfViews == 0) {
        free(_cachedZoomingStates);
        _cachedZoomingStates = NULL;
    } else {
        if (_cachedZoomingStates == NULL) {
            _cachedZoomingStates = malloc(_numberOfViews * sizeof(_XZCarouselViewZoomingState));
        } else {
            _cachedZoomingStates = realloc(_cachedZoomingStates, _numberOfViews * sizeof(_XZCarouselViewZoomingState));
        }
        for (NSInteger i = 0; i < _numberOfViews; i++) {
            _cachedZoomingStates[i] = _XZCarouselViewZoomingStateDefault;
        }
    }
}

- (void)reloadData {
    [self _XZCarouselViewPrepareReloadData];
    
    // 修正当前 _currentIndex 。
    if (_numberOfViews == 0) { // 如果没有视图显示。
        _currentIndex = XZCarouselViewNotFound;
        [_scrollView setPrevItemViewVisiable:NO nextItemViewVisiable:NO]; // 即使触发 didScroll 方法，因为 _numberOfViews == 0 所以什么也不会发生。
        return XZCarouselViewTransitionDidChange(self, 0, NO, NO, NO);
    }
    
    if (_currentIndex == XZCarouselViewNotFound) {
        _currentIndex = 0;
    } else if (_currentIndex >= _numberOfViews) {
        _currentIndex = _numberOfViews - 1;
    }
    
    // 调整显示区域大小。发送事件。重置倒计时。
    _transition = 0; // force to reload all views.
    if ([_scrollView setPrevItemViewVisiable:_isWrapped || _currentIndex > 0 nextItemViewVisiable: _isWrapped || _currentIndex < _numberOfViews - 1]) {
        return [self _XZCarouselViewAutoScrollIfNeeded];
    }
    XZCarouselViewTransitionDidChange(self, XZCarouselViewScrollViewGetTransition(_scrollView), YES, YES, NO);
    return [self _XZCarouselViewAutoScrollIfNeeded];
}

- (void)setCurrentIndex:(NSInteger const)newIndex animated:(BOOL)animated {
    // 如果当前视图尚未刷新。
    if (_currentIndex == XZCarouselViewNotFound) {
        [self _XZCarouselViewPrepareReloadData];
        NSAssert(_numberOfViews > 0, ([NSString stringWithFormat:@"当前没有任何可以显示的视图，无法设置 currentIndex 为 %ld 。", (long)newIndex]));
        _currentIndex = newIndex;
        if ([_scrollView setPrevItemViewVisiable:_isWrapped || _currentIndex > 0 nextItemViewVisiable:_isWrapped || _currentIndex < _numberOfViews - 1]) {
            return [self _XZCarouselViewAutoScrollIfNeeded];
        }
        XZCarouselViewTransitionDidChange(self, XZCarouselViewScrollViewGetTransition(_scrollView), NO, YES, NO);
        return [self _XZCarouselViewAutoScrollIfNeeded];
    }
    
    // _currentIndex 没有改变。
    if (newIndex == _currentIndex) {
        return;
    }
    
    // 如果轮播图没有停在 2 上，说明正在动画，那么本次动画就取消，直接刷新视图。
    CGFloat const transition = XZCarouselViewScrollViewGetTransition(_scrollView);
    if (animated && !_isTransitioning && transition == 0) {
        // 暂停自动轮播，以避免动画过程中的自动轮播。
        [self _XZCarouselViewPauseAutoScroll];
        
        NSInteger newIndexs[5];
        XZCarouselViewPagingDirection const scrollDirection = XZCarouselViewPagingDirectionMake(_isWrapped, _currentIndex, newIndex, _numberOfViews);
        _XZCarouselViewItemView * __unsafe_unretained targetItemView = nil;
        switch (scrollDirection) {
            case XZCarouselViewPagingDirectionForward:
                if (_isWrapped) {
                    newIndexs[0] = _keepsTransitioningViews ? XZCarouselViewWrappedIndex(_currentIndex - 1, _numberOfViews) : XZCarouselViewNotFound;
                    newIndexs[1] = _currentIndex;
                    newIndexs[2] = newIndex;
                    newIndexs[3] = _keepsTransitioningViews ? XZCarouselViewWrappedIndex(newIndex + 1, _numberOfViews) : XZCarouselViewNotFound;
                    newIndexs[4] = XZCarouselViewNotFound;
                } else {
                    newIndexs[0] = (( _keepsTransitioningViews && _currentIndex > 0) ? (_currentIndex - 1) : XZCarouselViewNotFound);
                    newIndexs[1] = _currentIndex;
                    newIndexs[2] = newIndex;
                    newIndexs[3] = ((_keepsTransitioningViews && newIndex < _numberOfViews - 1) ? _currentIndex + 1 : XZCarouselViewNotFound);
                    newIndexs[4] = XZCarouselViewNotFound;
                }
                targetItemView = _scrollView.itemView1;
                break;
                
            default:
                if (_isWrapped) {
                    newIndexs[0] = XZCarouselViewNotFound;
                    newIndexs[1] = _keepsTransitioningViews ? XZCarouselViewWrappedIndex(newIndex - 1, _numberOfViews) : XZCarouselViewNotFound;
                    newIndexs[2] = newIndex;
                    newIndexs[3] = _currentIndex;
                    newIndexs[4] = _keepsTransitioningViews ? XZCarouselViewWrappedIndex(_currentIndex + 1, _numberOfViews) : XZCarouselViewNotFound;
                } else {
                    newIndexs[0] = XZCarouselViewNotFound;
                    newIndexs[1] = ((_keepsTransitioningViews && newIndex > 0) ? newIndex - 1 : XZCarouselViewNotFound);
                    newIndexs[2] = newIndex;
                    newIndexs[3] = _currentIndex;
                    newIndexs[4] = ((_keepsTransitioningViews && _currentIndex < _numberOfViews - 1) ? (_currentIndex + 1) : XZCarouselViewNotFound);
                }
                targetItemView = _scrollView.itemView3;
                break;
        }
        
        // 添加自定义转场动画。
        XZCarouselViewAddTransitionAnimationIfNeeded(self, NO);
        
        // 更新 _currentIndex 。
        _currentIndex = newIndex;
        // 加载指定的视图。
        XZCarouselViewLoadContentViewWithIndexes(self, newIndexs, YES);
        _transition = -(CGFloat)scrollDirection; // 避免在滚动的过程中，由于 transition 变化更新了视图内容。
        [_scrollView setDelegate:nil];
        [_scrollView setPrevItemViewVisiable:_isWrapped || _currentIndex > 0 nextItemViewVisiable:_isWrapped || _currentIndex < _numberOfViews - 1];
        [_scrollView setContentOffset:targetItemView.frame.origin animated:NO]; // 移动到显示位置到当前视图的位置。
        [_scrollView setDelegate:self];
        
        // UIView 动画和 CAnimation 虽然可以一起使用，但是对于 _transitionAnimation 只需要其中一段动画的需求，由于 UIView 动画不能精确控制
        // 时间，导致 _transitionAnimation 动画的执行时间不能控制在指定区间内。特别是动画时间越短，误差就越大，动画不一致的情况越严重。
        // 因此，多种方案尝试后，还是采用  setContentOffset:animated: 来制造滚动，通过进度来控制动画，来避免上面的问题。
        
        // 滚动到目标位置。
        CGPoint const newOffset = self->_scrollView.itemView2.frame.origin;
        [self->_scrollView setContentOffset:newOffset animated:YES];
        
        // 自动轮播定时器的恢复放在 -scrollViewDidEndScrollingAnimation: 代理方法中。
        // [self _XZCarouselViewAutoScrollIfNeeded];
    } else {
        _currentIndex = newIndex;
        // 根据新的 index 加载视图，重新调整布局。-setShowingHead:showingLast: 返回 NO 表示没有重新设置 contentOffset 。
        if ([_scrollView setPrevItemViewVisiable:_isWrapped || _currentIndex > 0 nextItemViewVisiable: _isWrapped || _currentIndex < _numberOfViews - 1]) {
            return [self _XZCarouselViewAutoScrollIfNeeded];
        }
        XZCarouselViewTransitionDidChange(self, transition, NO, YES, NO);
        // 索引改变，倒计时重新开始计时。
        return [self _XZCarouselViewAutoScrollIfNeeded];
    }
}

- (UIView *)viewForIndex:(NSInteger)index {
    return [self _XZCarouselViewItemViewForIndex:index].contentView;
}

- (void)setPreferredSize:(CGSize)preferredSize forViewAtIndex:(NSInteger)index animated:(BOOL)animated {
    [[self _XZCarouselViewItemViewForIndex:index] setPreferredContentSize:preferredSize animated:animated];
}

- (_XZCarouselViewItemView *)_XZCarouselViewItemViewForIndex:(NSInteger)index {
    if (_scrollView.itemView1.index == index) {
        return _scrollView->_itemView1;
    }
    if (_scrollView.itemView3.index == index) {
        return _scrollView->_itemView3;
    }
    if (_scrollView.itemView2.index == index) {
        return _scrollView->_itemView2;
    }
    if (_scrollView.itemView0.index == index) {
        return _scrollView->_itemView0;
    }
    if (_scrollView.itemView4.index == index) {
        return _scrollView->_itemView4;
    }
    return nil;
}

#pragma mark - <UIScrollViewDelegate.拖动>

/// 横向滚动的 UIScrollView 的手势事件。
- (void)_XZCarouselViewScrollViewPanGestureRecognizerAction:(UIPanGestureRecognizer *)panGestureRecognizer {
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            XZCarouselViewAddTransitionAnimationIfNeeded(self, YES);
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            break;
        default:
            break;
    }
}

/// 将要拖动。
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_scrollView != scrollView || _numberOfViews == 0) {
        return;
    }
    // 开始拖动时，暂停计时器。
    [self _XZCarouselViewPauseAutoScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // 手势停止，如果开始减速，继续执行手势动画到停止滚动，然后移除动画。
    // 手势停止，没有减速，说明正好停在整页上。
    if (decelerate) {
        return;
    }
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != _scrollView || _numberOfViews == 0) {
        return;
    }
    
    CGFloat const transition = XZCarouselViewScrollViewGetTransition(_scrollView);

    // 减速停止，如果没有停在 1 3 上，说明不是自然停止（被手势强制停止），不需要处理 index 变化。
    if (transition != 1.0 && transition != -1.0 && transition != 0.0) {
        return;
    }
    
    // 移除动画。动画需要在 transition 变回 0 前移除。
    XZCarouselViewRemoveTransitionAnimationIfNeeded(self, YES);
    
    // 没有切换到新的视图。
    if (transition == 0.0) {
        return [self _XZCarouselViewAutoScrollIfNeeded];
    }
    
    // 调整位置。
    [_scrollView setDelegate:nil];
    if (transition == 1.0) {
        if (_isWrapped) {
            _currentIndex = XZCarouselViewWrappedIndex(_currentIndex + 1, _numberOfViews);
            [_scrollView setContentOffset:_scrollView->_itemView2.frame.origin];
        } else if (_currentIndex < _numberOfViews - 1) {
            _currentIndex += 1;
            [_scrollView setContentOffset:_scrollView->_itemView2.frame.origin];
            [_scrollView setPrevItemViewVisiable:_currentIndex > 0 nextItemViewVisiable:_currentIndex < _numberOfViews - 1];
        }
    } else {
        if (_isWrapped) {
            _currentIndex = XZCarouselViewWrappedIndex(_currentIndex - 1, _numberOfViews);
            [_scrollView setContentOffset:_scrollView->_itemView2.frame.origin];
        } else if (_currentIndex > 0) {
            _currentIndex -= 1;
            [_scrollView setContentOffset:_scrollView->_itemView2.frame.origin];
            [_scrollView setPrevItemViewVisiable:_currentIndex > 0 nextItemViewVisiable:_currentIndex < _numberOfViews - 1];
        }
    }
    [_scrollView setDelegate:self];
    
    // 发送 indexChanged 事件。
    XZCarouselViewTransitionDidChange(self, 0, YES, YES, YES);
    
    // 处理自动轮播.
    return [self _XZCarouselViewAutoScrollIfNeeded];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // 本方法触发时机：
    //     1. 调用 -setCurrentIndex:animated: 且参数为 YES 时，目标位置 2 。
    //     2. 自动轮播触发时，目标位置 1 或 3 。
    // 通过 UIScrollView 的 -setContentOffset:animated: 方法设置滚动的过程中，手势可以强制停止滚动，
    // 且强制停止时，此方法会在手势事件触发之前调用。所以是否在目标位置被手势中断，对判断逻辑没有影响：
    // 在目标位置上时，移除动画；在 1 3 上减少/增加 index ；启动自动轮播。
    [self scrollViewDidEndDecelerating:scrollView];
}

#pragma mark - <UIScrollViewDelegate.其它>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != _scrollView || _numberOfViews == 0) {
        return;
    }
    
    CGFloat const transition = XZCarouselViewScrollViewGetTransition(_scrollView);
    
    if (transition <= 1.0 && transition >= -1.0) {
        // 1, 2, 3 之间滚动，直接发送转场进度事件就可以了。
        return XZCarouselViewTransitionDidChange(self, transition, NO, YES, YES);
    }
    
    CGPoint const oldOffset = _scrollView.contentOffset;
    CGRect const itemViewFrame2 = _scrollView->_itemView2.frame;
    
    if (transition > 1.0) {
        CGRect const itemViewFrame3 = _scrollView->_itemView3.frame;
        CGPoint const deltaOffset = CGPointMake(oldOffset.x - itemViewFrame3.origin.x, oldOffset.y - itemViewFrame3.origin.y);
        [_scrollView setDelegate:nil];
        if (_isWrapped) {
            _currentIndex = XZCarouselViewWrappedIndex(_currentIndex + 1, _numberOfViews);
            [_scrollView setContentOffset:CGPointMake(itemViewFrame2.origin.x + deltaOffset.x, itemViewFrame2.origin.y + deltaOffset.y)];
        } else if (_currentIndex < _numberOfViews - 1) {
            _currentIndex += 1;
            [_scrollView setContentOffset:CGPointMake(itemViewFrame2.origin.x + deltaOffset.x, itemViewFrame2.origin.y + deltaOffset.y)];
            [_scrollView setPrevItemViewVisiable:_currentIndex > 0 nextItemViewVisiable:_currentIndex < _numberOfViews - 1];
        }
        XZCarouselViewTransitionDidChange(self, 0, YES, YES, YES); // 发送 indexChanged 事件。
        XZCarouselViewTransitionDidChange(self, XZCarouselViewScrollViewGetTransition(_scrollView), NO, YES, YES); // 发送 transition 事件。
        return [_scrollView setDelegate:self];
    }
    
    CGRect const itemViewFrame1 = _scrollView.itemView1.frame;
    CGPoint const deltaOffset = CGPointMake(oldOffset.x - itemViewFrame1.origin.x, oldOffset.y - itemViewFrame1.origin.y);
    [_scrollView setDelegate:nil];
    if (_isWrapped) {
        _currentIndex = XZCarouselViewWrappedIndex(_currentIndex - 1, _numberOfViews);
        [_scrollView setContentOffset:CGPointMake(itemViewFrame2.origin.x + deltaOffset.x, itemViewFrame2.origin.y + deltaOffset.y)];
    } else if (_currentIndex > 0) {
        _currentIndex -= 1;
        [_scrollView setContentOffset:CGPointMake(itemViewFrame2.origin.x + deltaOffset.x, itemViewFrame2.origin.y + deltaOffset.y)];
        [_scrollView setPrevItemViewVisiable:_currentIndex > 0 nextItemViewVisiable:_currentIndex < _numberOfViews - 1];
    }
    XZCarouselViewTransitionDidChange(self, 0, YES, YES, YES); // 发送 indexChanged 事件。
    XZCarouselViewTransitionDidChange(self, XZCarouselViewScrollViewGetTransition(_scrollView), NO, YES, YES); // 发送 transition 事件。
    return [_scrollView setDelegate:self];
}

#pragma mark - <UIScrollViewDelegate.缩放代理>
/// 为了解决缩放视图在 bouncing 的过程中，使 _scrollView 发生横向滚动却不触发手势，
/// 从而导致无法加载自定义转场动画，所以当缩放视图拖拽时，横向滚动的视图就不允许滚动。
- (void)_XZCarouselViewItemViewWillBeginDragging:(_XZCarouselViewItemView *)itemView {
    _scrollView.scrollEnabled = NO;
}

- (void)_XZCarouselViewItemViewDidEndDragging:(_XZCarouselViewItemView *)itemView willDecelerate:(BOOL)decelerate {
    if (decelerate || _isZoomingLockEnabled) {
        return;
    }
    _scrollView.scrollEnabled = YES;
}

- (void)_XZCarouselViewItemViewDidEndDecelerating:(_XZCarouselViewItemView *)itemView {
    if (_isZoomingLockEnabled) {
        return;
    }
    _scrollView.scrollEnabled = YES;
}

- (void)_XZCarouselViewItemViewWillBeginZooming:(_XZCarouselViewItemView *)itemView {
    // 横向滚动是否开启。
    _scrollView.scrollEnabled = !_isZoomingLockEnabled;
    
    // 暂停自动轮播。
    [self _XZCarouselViewPauseAutoScroll];
    
    // 发送代理事件。
    if ([_delegate respondsToSelector:@selector(carouselView:willBeginZoomingView:atIndex:)]) {
        [_delegate carouselView:self willBeginZoomingView:itemView.contentView atIndex:itemView.index];
    }
}

- (void)_XZCarouselViewItemViewDidZoom:(_XZCarouselViewItemView *)itemView {
    if ([_delegate respondsToSelector:@selector(carouselView:didZoomView:atIndex:)]) {
        [_delegate carouselView:self didZoomView:itemView.contentView atIndex:itemView.index];
    }
}

- (void)_XZCarouselViewItemViewDidEndZooming:(_XZCarouselViewItemView *)itemView atScale:(CGFloat)scale {
    if (scale == 1.0) {
        // 缩放停止时，检测是否恢复了默认大小，如果是，则恢复横向滚动。
        _scrollView.scrollEnabled = YES;
        // 检查是否需要启动自动轮播。
        [self _XZCarouselViewAutoScrollIfNeeded];
    }
    if ([_delegate respondsToSelector:@selector(carouselView:didEndZoomingView:atIndex:atScale:)]) {
        [_delegate carouselView:self didEndZoomingView:itemView.contentView atIndex:itemView.index atScale:scale];
    }
}

#pragma mark - Events and Actions

/// 自动轮播计时器事件。
- (void)_XZCarouselViewScrollTimerAction:(NSTimer *)timer {
    if (0 == _numberOfViews) {
        return;
    }
    if (!_isWrapped) {
        if (_numberOfViews == 1) {
            return;
        }
        if (_currentIndex == 0) {
            _pagingDirection = XZCarouselViewPagingDirectionForward;
        } else if (_currentIndex == _numberOfViews - 1) {
            _pagingDirection = XZCarouselViewPagingDirectionBackward;
        }
    }
    // 添加转场动画。
    XZCarouselViewAddTransitionAnimationIfNeeded(self, NO);
    // 跳转。
    if (_pagingDirection == XZCarouselViewPagingDirectionForward) {
        CGPoint const newOffset = _scrollView->_itemView3.frame.origin;
        [_scrollView setContentOffset:newOffset animated:YES];
    } else {
        CGPoint const newOffset = _scrollView->_itemView1.frame.origin;
        [_scrollView setContentOffset:newOffset animated:YES];
    }
}

/// 如果设置了自动轮播，启动计时器，并重置计时。只有在 window 上时，轮播图才会自动轮播。
- (void)_XZCarouselViewAutoScrollIfNeeded {
    if (_timeInterval > 0 && self.window != nil) {
        if (_scrollTimer == nil) {
            // 不在 window 上不能启动 timer ，以避免内存泄漏。
            _scrollTimer = [NSTimer scheduledTimerWithTimeInterval:CGFLOAT_MAX target:self selector:@selector(_XZCarouselViewScrollTimerAction:) userInfo:nil repeats:YES];
        }
        _scrollTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:_timeInterval];
    } else {
        [self _XZCarouselViewPauseAutoScroll];
    }
}

/// 停止自动录播倒计时。
- (void)_XZCarouselViewPauseAutoScroll {
    [_scrollTimer setFireDate:[NSDate distantFuture]];
}

/// 双击缩放手势事件。
- (void)_XZCarouselViewDoubleTapGestureRecognizerAction:(UITapGestureRecognizer *)tap {
    if (_scrollView->_itemView2.minimumZoomScale < _scrollView->_itemView2.maximumZoomScale) {
        if (_scrollView.itemView2.zoomScale != 1.0) {
            // 恢复默认
            _scrollView.scrollEnabled = YES;
            [_scrollView->_itemView2 setZoomScale:1.0 animated:YES];
        } else {
            _scrollView.scrollEnabled = !_isZoomingLockEnabled;
            
            CGPoint const location = [tap locationInView:_scrollView->_itemView2];
            // 会触发 layoutSubviews 方法；会触发代理方法。
            [_scrollView->_itemView2 zoomToRect:CGRectMake(location.x, location.y, 0, 0) animated:YES];
        }
    }
}

#pragma mark - 属性

- (XZCarouselViewPagingOrientation)pagingOrientation {
    return _scrollView.pagingOrientation;
}

- (void)setPagingOrientation:(XZCarouselViewPagingOrientation)pagingOrientation {
    [_scrollView setDelegate:nil];
    [_scrollView setPagingOrientation:pagingOrientation];
    [_scrollView setDelegate:self];
    XZCarouselViewTransitionDidChange(self, 0, NO, YES, NO);
}

- (BOOL)isReusingModeEnabled {
    return _reusingViews != nil;
}

- (void)setReusingModeEnabled:(BOOL)reusingModeEnabled {
    if (_reusingViews == nil && reusingModeEnabled) {
        _reusingViews = [NSMutableArray array];
    } else if (!reusingModeEnabled) {
        _reusingViews = nil;
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    [self setCurrentIndex:currentIndex animated:NO];
}

- (void)setWrapped:(BOOL)wrapped {
    if (_isWrapped != wrapped) {
        _isWrapped = wrapped;
        
        // 更改此属性时，刷新视图。
        if (_numberOfViews == 0) {
            return;
        }
        
        _transition = 0;
        if ([_scrollView setPrevItemViewVisiable:_isWrapped || _currentIndex > 0 nextItemViewVisiable:_isWrapped || _currentIndex < _numberOfViews - 1]) {
            return;
        }
        XZCarouselViewTransitionDidChange(self, XZCarouselViewScrollViewGetTransition(_scrollView), NO, NO, NO);
    }
}

- (void)setRemembersZoomingState:(BOOL)remembersZoomingState {
    if (_remembersZoomingState != remembersZoomingState) {
        _remembersZoomingState = remembersZoomingState;
        
        if (_numberOfViews == 0) {
            return;
        }
        if (_remembersZoomingState && _cachedZoomingStates == NULL) {
            _cachedZoomingStates = malloc(sizeof(_XZCarouselViewZoomingState) * _numberOfViews);
            for (NSInteger i = 0; i < _numberOfViews; i++) {
                _cachedZoomingStates[i] = _XZCarouselViewZoomingStateDefault;
            }
        } else if (!_remembersZoomingState) {
            free(_cachedZoomingStates);
            _cachedZoomingStates = NULL;
        }
    }
}

- (void)setTimeInterval:(NSTimeInterval)scrollInterval {
    if (_timeInterval != scrollInterval) {
        _timeInterval = MAX(0, scrollInterval);
        [self _XZCarouselViewAutoScrollIfNeeded];
    }
}

- (CGFloat)minimumZoomScale {
    return _scrollView->_itemView2.minimumZoomScale;
}

- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale {
    [self setMinimumZoomScale:minimumZoomScale maximumZoomScale:self.maximumZoomScale];
}

- (CGFloat)maximumZoomScale {
    return _scrollView->_itemView2.maximumZoomScale;
}

- (void)setMaximumZoomScale:(CGFloat)maximumZoomScale {
    [self setMinimumZoomScale:self.minimumZoomScale maximumZoomScale:maximumZoomScale];
}

- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale maximumZoomScale:(CGFloat)maximumZoomScale {
    [_scrollView->_itemView2 setMinimumZoomScale:minimumZoomScale maximumZoomScale:maximumZoomScale];
    
    // 当最大缩放倍数超过 1 时，开启双击放大功能。
    if (maximumZoomScale > 1.0) {
        [self doubleTapGestureRecognizer];
    }
}

- (BOOL)bouncesZoom {
    return _scrollView->_itemView2.bouncesZoom;
}

- (void)setBouncesZoom:(BOOL)bouncesZoom {
    return [_scrollView->_itemView2 setBouncesZoom:bouncesZoom];
}

- (CGFloat)zoomScale {
    return  _scrollView->_itemView2.zoomScale;
}

- (void)setZoomScale:(CGFloat)zoomScale {
    [_scrollView.itemView2 setZoomScale:zoomScale animated:NO];
}

- (void)setZoomScale:(CGFloat)scale animated:(BOOL)animated {
    [_scrollView->_itemView2 setZoomScale:scale animated:animated];
}

- (void)setZoomingLockEnabled:(BOOL)zoomingLockEnabled {
    if (_isZoomingLockEnabled != zoomingLockEnabled) {
        _isZoomingLockEnabled = zoomingLockEnabled;
        // 没有缩放或者缩放锁未开启，则可以横向滚动。
        _scrollView.scrollEnabled = (_scrollView->_itemView2.zoomScale == 1.0 || !_isZoomingLockEnabled);
    }
}

- (UITapGestureRecognizer *)doubleTapGestureRecognizer {
    if (_doubleTapGestureRecognizer != nil) {
        return _doubleTapGestureRecognizer;
    }
    _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_XZCarouselViewDoubleTapGestureRecognizerAction:)];
    _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:_doubleTapGestureRecognizer];
    return _doubleTapGestureRecognizer;
}

- (void)setTransitioningAnimation:(CAAnimation *)transitioningAnimation {
    if (_transitioningAnimation != transitioningAnimation) {
        if ( (_transitioningAnimation == nil && _transitioningDelegate == nil) && transitioningAnimation != nil ) {
            [_scrollView.panGestureRecognizer addTarget:self action:@selector(_XZCarouselViewScrollViewPanGestureRecognizerAction:)];
        } else if ( (transitioningAnimation == nil && _transitioningDelegate == nil) && _transitioningAnimation != nil) {
            [_scrollView.panGestureRecognizer removeTarget:self action:@selector(_XZCarouselViewScrollViewPanGestureRecognizerAction:)];
        }
        _transitioningAnimation = transitioningAnimation;
    }
}

- (void)setTransitioningDelegate:(id<XZCarouselViewTransitioningDelegate>)transitioningDelegate {
    if (_transitioningDelegate != transitioningDelegate) {
        if ( (_transitioningDelegate == nil && _transitioningAnimation == nil) && transitioningDelegate != nil) {
            [_scrollView.panGestureRecognizer addTarget:self action:@selector(_XZCarouselViewScrollViewPanGestureRecognizerAction:)];
        } else if ( (transitioningDelegate == nil && _transitioningAnimation == nil) && _transitioningDelegate != nil ) {
            [_scrollView.panGestureRecognizer removeTarget:self action:@selector(_XZCarouselViewScrollViewPanGestureRecognizerAction:)];
        }
        _transitioningDelegate = transitioningDelegate;
    }
}

- (void)setKeepsTransitioningViews:(BOOL)showsLeadingTrailingViews {
    if (_keepsTransitioningViews != showsLeadingTrailingViews) {
        _keepsTransitioningViews = showsLeadingTrailingViews;
        if (_numberOfViews == 0) {
            return;
        }
        _transition = 0; // force to reload all views.
        XZCarouselViewTransitionDidChange(self, XZCarouselViewScrollViewGetTransition(_scrollView), NO, NO, NO);
    }
}

- (void)setInteritemSpacing:(CGFloat)interitemSpacing {
    // 与轮播进度相结合控制间距。
    _scrollView->_itemView0.interitemSpacing = interitemSpacing;
    _scrollView->_itemView1.interitemSpacing = interitemSpacing;
    _scrollView->_itemView3.interitemSpacing = interitemSpacing;
    _scrollView->_itemView4.interitemSpacing = interitemSpacing;
    _scrollView->_itemView2.interitemSpacing = interitemSpacing;
}

- (CGFloat)interitemSpacing {
    return _scrollView->_itemView2.interitemSpacing;
}

- (BOOL)gestureRecognizer:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([_delegate respondsToSelector:@selector(carouselView:edgeInsetsForGestureTransitioningView:atIndex:)]) {
        XZEdgeInsets const edgeInsets1 = [_delegate carouselView:self edgeInsetsForGestureTransitioningView:_scrollView.itemView2.contentView atIndex:_currentIndex];
        if (XZEdgeInsetsEqualToEdgeInsets(edgeInsets1, XZEdgeInsetsZero)) { // zero 表示全屏返回。
            return YES;
        }
        CGPoint const location = [touch locationInView:self];
        UIEdgeInsets const edgeInsets2 = UIEdgeInsetsFromXZEdgeInsets(edgeInsets1, self.xz_userInterfaceLayoutDirection);
        return CGRectContainsPointInEdgeInsets(self.bounds, edgeInsets2, location);
    }
    return YES;
}

@end


@implementation XZCarouselView (XZCarouselViewContextTransitioning)

- (void)setTransitionViewHierarchy:(XZCarouselViewTransitionViewHierarchy)transitionViewHierarchy {
    [_scrollView setItemViewHierarchy:transitionViewHierarchy];
}

- (XZCarouselViewTransitionViewHierarchy)transitionViewHierarchy {
    return [_scrollView itemViewHierarchy];
}

- (UIView *)backwardSupplementaryView {
    return _scrollView->_itemView0.transitionView;
}

- (UIView *)backwardTransitioningView {
    return _scrollView->_itemView1.transitionView;
}

- (UIView *)transitioningView {
    return _scrollView->_itemView2.transitionView;
}

- (UIView *)forwardTransitioningView {
    return _scrollView->_itemView3.transitionView;
}

- (UIView *)forwardSupplementaryView {
    return _scrollView->_itemView4.transitionView;
}

- (void)bringTransitionViewToFront:(UIView *)transitionView {
    [_scrollView bringSubviewToFront:transitionView.superview];
}

- (void)sendTransitionViewToBack:(UIView *)transitionView {
    [_scrollView sendSubviewToBack:transitionView.superview];
}

- (void)insertTransitionView:(UIView *)transitionView1 belowTransitionView:(UIView *)transitionView2 {
    [_scrollView insertSubview:transitionView1.superview belowSubview:transitionView2.superview];
}

- (void)insertTransitionView:(UIView *)transitionView1 aboveTransitionView:(UIView *)transitionView2 {
    [_scrollView insertSubview:transitionView1.superview aboveSubview:transitionView2.superview];
}

@end

#pragma mark - 私有函数。

static void XZCarouselViewItemViewSetContentView(XZCarouselView * const carouselView, _XZCarouselViewItemView * const itemView, NSInteger const newIndex, UIView * const contentView, CGSize const preferredContentSize) {
    // oldIndex 与 newIndex 已知不相等。
    NSInteger const oldIndex = itemView.index;
    if (carouselView->_remembersZoomingState) {
        if (oldIndex == XZCarouselViewNotFound) {
            _XZCarouselViewZoomingState const zoomingState = carouselView->_cachedZoomingStates[newIndex];
            return [itemView setIndex:newIndex contentView:contentView preferredContentSize:preferredContentSize zoomScale:zoomingState.zoomScale contentOffset:zoomingState.contentOffset];
        }
        
        carouselView->_cachedZoomingStates[oldIndex].zoomScale = itemView.zoomScale;
        carouselView->_cachedZoomingStates[oldIndex].contentOffset = itemView.contentOffset;
        
        if (newIndex == XZCarouselViewNotFound) {
            return [itemView setIndex:newIndex contentView:nil preferredContentSize:(CGSizeZero) zoomScale:1.0 contentOffset:(CGPointZero)];
        }
        _XZCarouselViewZoomingState const zoomingState = carouselView->_cachedZoomingStates[newIndex];
        return [itemView setIndex:newIndex contentView:contentView preferredContentSize:preferredContentSize zoomScale:zoomingState.zoomScale contentOffset:zoomingState.contentOffset];
    }
    
    if (newIndex == XZCarouselViewNotFound) {
        return [itemView setIndex:newIndex contentView:nil preferredContentSize:(CGSizeZero) zoomScale:1.0 contentOffset:(CGPointZero)];
    }
    
    return [itemView setIndex:newIndex contentView:contentView preferredContentSize:preferredContentSize zoomScale:1.0 contentOffset:(CGPointZero)];
}

static void XZCarouselViewTransitionDidChange(XZCarouselView * const carouselView, CGFloat const transition, BOOL const sendsIndexChangeEvents, BOOL const sendsTransitionEvents, BOOL const animated) {
    NSInteger targetContentViewIndexes[5] = {XZCarouselViewNotFound, XZCarouselViewNotFound, XZCarouselViewNotFound, XZCarouselViewNotFound, XZCarouselViewNotFound};
    
    if (carouselView->_numberOfViews == 0) {
        carouselView->_transition = 0;
        
        [carouselView->_scrollView updateTransitionForItemViews:0];
        
        XZCarouselViewRemoveTransitionAnimationIfNeeded(carouselView, NO);
        
        return XZCarouselViewLoadContentViewWithIndexes(carouselView, targetContentViewIndexes, animated);
    }
    
    // 是否需要刷新视图。
    BOOL needsLoadingContentView = NO;
    if (transition == 0) {
        needsLoadingContentView = YES;
        if (carouselView->_keepsTransitioningViews) {
            if (carouselView->_isWrapped) {
                targetContentViewIndexes[1] = XZCarouselViewWrappedIndex(carouselView->_currentIndex - 1, carouselView->_numberOfViews);
                targetContentViewIndexes[3] = XZCarouselViewWrappedIndex(carouselView->_currentIndex + 1, carouselView->_numberOfViews);
            } else {
                targetContentViewIndexes[1] = (carouselView->_currentIndex > 0 ? carouselView->_numberOfViews - 1 : XZCarouselViewNotFound);
                targetContentViewIndexes[3] = (carouselView->_currentIndex < carouselView->_numberOfViews - 1 ? carouselView->_currentIndex + 1 : XZCarouselViewNotFound);
            }
        }
        targetContentViewIndexes[2] = carouselView->_currentIndex;
    } else if (transition > 0 && carouselView->_transition <= 0) { // 正向滚动，加载 2 3 4 。
        needsLoadingContentView = YES;
        if (carouselView->_isWrapped) {
            if (carouselView->_keepsTransitioningViews) {
                targetContentViewIndexes[1] = XZCarouselViewWrappedIndex(carouselView->_currentIndex - 1, carouselView->_numberOfViews);
                targetContentViewIndexes[3] = XZCarouselViewWrappedIndex(carouselView->_currentIndex + 1, carouselView->_numberOfViews);
                targetContentViewIndexes[4] = XZCarouselViewWrappedIndex(carouselView->_currentIndex + 2, carouselView->_numberOfViews);
            } else {
                targetContentViewIndexes[3] = XZCarouselViewWrappedIndex(carouselView->_currentIndex + 1, carouselView->_numberOfViews);
            }
            targetContentViewIndexes[2] = carouselView->_currentIndex;
        } else {
            if (carouselView->_keepsTransitioningViews && carouselView->_currentIndex > 0) {
                targetContentViewIndexes[1] = carouselView->_currentIndex - 1;
            }
            if (carouselView->_currentIndex + 1 <= carouselView->_numberOfViews - 1) {
                targetContentViewIndexes[3] = carouselView->_currentIndex + 1;
                if (carouselView->_keepsTransitioningViews && carouselView->_currentIndex + 2 <= carouselView->_numberOfViews - 1) {
                    targetContentViewIndexes[4] = carouselView->_currentIndex + 2;
                }
            }
            targetContentViewIndexes[2] = carouselView->_currentIndex;
        }
    } else if (transition < 0 && carouselView->_transition >= 0) { // 反向滚动，加载 0 1 2 。
        needsLoadingContentView = YES;
        if (carouselView->_isWrapped) {
            if (carouselView->_keepsTransitioningViews) {
                targetContentViewIndexes[0] = XZCarouselViewWrappedIndex(carouselView->_currentIndex - 2, carouselView->_numberOfViews);
                targetContentViewIndexes[1] = XZCarouselViewWrappedIndex(carouselView->_currentIndex - 1, carouselView->_numberOfViews);
                targetContentViewIndexes[3] = XZCarouselViewWrappedIndex(carouselView->_currentIndex + 1, carouselView->_numberOfViews);
            } else {
                targetContentViewIndexes[1] = XZCarouselViewWrappedIndex(carouselView->_currentIndex - 1, carouselView->_numberOfViews);
            }
            targetContentViewIndexes[2] = carouselView->_currentIndex;
        } else {
            if (carouselView->_currentIndex > 0) {
                if (carouselView->_keepsTransitioningViews && carouselView->_currentIndex > 1) {
                    targetContentViewIndexes[0] = carouselView->_currentIndex - 2;
                }
                targetContentViewIndexes[1] = carouselView->_currentIndex - 1;
            }
            if (carouselView->_keepsTransitioningViews && carouselView->_currentIndex < carouselView->_numberOfViews - 1) {
                targetContentViewIndexes[3] = carouselView->_currentIndex + 1;
            }
            targetContentViewIndexes[2] = carouselView->_currentIndex;
        }
    }
    
    carouselView->_transition = transition;
    
    // 加载视图。发送视图添加/移除事件。
    if (needsLoadingContentView) {
        XZCarouselViewLoadContentViewWithIndexes(carouselView, targetContentViewIndexes, animated);
    }
    
    // 处理间距。
    [carouselView->_scrollView updateTransitionForItemViews:transition];
    
    // 处理手势动画进度。
    if (carouselView->_isTransitioning) {
        if (transition > 0) {
            carouselView->_scrollView->_itemView1.transitionViewIfLoaded.layer.timeOffset = 6.0;
            carouselView->_scrollView->_itemView2.transitionViewIfLoaded.layer.timeOffset = 0.0 + transition; // 0.0 -> 1.0
            carouselView->_scrollView->_itemView3.transitionViewIfLoaded.layer.timeOffset = 4.0 + transition; // 4.0 -> 5.0
        } else if (transition < 0) {
            carouselView->_scrollView->_itemView1.transitionViewIfLoaded.layer.timeOffset = 6.0 - transition; // 6.0 -> 7.0
            carouselView->_scrollView->_itemView2.transitionViewIfLoaded.layer.timeOffset = 2.0 - transition; // 2.0 -> 3.0
            carouselView->_scrollView->_itemView3.transitionViewIfLoaded.layer.timeOffset = 4.0;
        } else {
            carouselView->_scrollView->_itemView1.transitionViewIfLoaded.layer.timeOffset = 6.0;
            carouselView->_scrollView->_itemView2.transitionViewIfLoaded.layer.timeOffset = 0.0;
            carouselView->_scrollView->_itemView3.transitionViewIfLoaded.layer.timeOffset = 4.0;
        }
    }
    
    // 发送 index 变更事件。
    if (sendsIndexChangeEvents && [carouselView->_delegate respondsToSelector:@selector(carouselView:didShowView:atIndex:)]) {
        [carouselView->_delegate carouselView:carouselView didShowView:carouselView->_scrollView->_itemView2.contentView atIndex:carouselView->_currentIndex];
    }
    
    // 轮播视图先开始 transition
    if (sendsTransitionEvents && [carouselView->_delegate respondsToSelector:@selector(carouselView:didTransition:animated:)]) {
        [carouselView->_delegate carouselView:carouselView didTransition:transition animated:animated];
    }
}

static void XZCarouselViewLoadContentViewWithIndexes(XZCarouselView * const carouselView, NSInteger newItemViewIndexes[const 5], BOOL const animated) {
    void * const itemViews[5] = {
        (__bridge void *)(newItemViewIndexes[0] == XZCarouselViewNotFound ? carouselView->_scrollView->_itemView0 : carouselView->_scrollView.itemView0),
        (__bridge void *)(carouselView->_scrollView->_itemView1),
        (__bridge void *)(carouselView->_scrollView->_itemView2),
        (__bridge void *)(carouselView->_scrollView->_itemView3),
        (__bridge void *)(newItemViewIndexes[4] == XZCarouselViewNotFound ? carouselView->_scrollView->_itemView4 : carouselView->_scrollView.itemView4)
    };
    
    // 是否需要重载视图。
    BOOL needscontentViewsUpdate = NO;
    
    // 记录当前视图中，依然要显示的视图。
    NSInteger yet = 0;
    _XZCarouselViewItemViewInfo yetDisplayViews[5];
    
    // 待移除的视图。记得当初学的时候，好像 C 数组是不能存对象的，但是昨天试了下发现完全没有问题，ARC 也能管理 C 数组中对象的引用。
    // 该特性可能需要高版本的 Xcode 支持，目前所用 Version 10.2 (10E125)，低版本 Xcode 不保证会不会出现野指针的问题。
    NSInteger non = 0;
    UIView *nonDisplayViews[5] = {nil, nil, nil, nil, nil};
    
    BOOL const needsSendWilEndEvents = [carouselView->_delegate respondsToSelector:@selector(carouselView:willEndTransitioningView:atIndex:animated:)];
    BOOL const needsSendDidEndEvents = [carouselView->_delegate respondsToSelector:@selector(carouselView:didEndTransitioningView:atIndex:animated:)];
    BOOL const needsSendSEnqueueView = [carouselView->_dataSource respondsToSelector:@selector(carouselView:shouldEnqueueView:atIndex:)];
    
    // 判断数据是否发生变更：将依然显示的视图，加入 yetDisplayViews 列表，将不显示的视图加入重用池（如果启用）并发送事件。
    // 如果 itemView 的视图不需要更新则标记 XZCarouselViewNotFound 并在第二步的操作中不再处理；如果 itemView 将不显示视图（index 待设置为 XZCarouselViewNotFound），则立即设置，并在下面第二步的操作中不再处理。
    for (NSInteger i = 0; i < 5; i++) {
        _XZCarouselViewItemView * const __unsafe_unretained itemView = (__bridge _XZCarouselViewItemView *)(itemViews[i]);
        if (itemView == nil) {
            continue;
        }
        if (itemView.index == newItemViewIndexes[i]) {
            // 当前已加载的视图与待加载的一致，标记已加载。
            newItemViewIndexes[i] = XZCarouselViewNotFound;
            continue;
        }
        // 当前已加载的视图与待加载的不一致，判断视图是否继续显示，并加入相应的列表。
        needscontentViewsUpdate = YES;
        if (itemView.index == XZCarouselViewNotFound || itemView.contentView == nil) {
            // 当前 itemView 没有视图。
        } else {
            // 当前 itemView 没有视图，判断该视图是否继续显示。
            BOOL findIndexInNewIndexes = NO;
            for (NSInteger m = 0; m < 5; m++) {
                if (newItemViewIndexes[m] == itemView.index) {
                    findIndexInNewIndexes = YES;
                    break;
                }
            }
            if (findIndexInNewIndexes) {
                // 依然显示的视图，加入列表。
                yetDisplayViews[yet].index = itemView.index;
                yetDisplayViews[yet].preferredContentSize = itemView.preferredContentSize;
                yetDisplayViews[yet].contentView = CFRetain((__bridge CFTypeRef)(itemView.contentView));
                yet += 1;
            } else {
                // 待移除的视图，加入重用池。
                NSInteger const index = itemView.index;
                CGSize const preferredContentSize  = itemView.preferredContentSize;
                UIView * const contentView = itemView.contentView;
                // 发送事件
                if (needsSendWilEndEvents) {
                    [carouselView->_delegate carouselView:carouselView willEndTransitioningView:contentView atIndex:index animated:animated];
                }
                XZCarouselViewItemViewSetContentView(carouselView, itemView, XZCarouselViewNotFound, nil, CGSizeZero);
                if (needsSendDidEndEvents) {
                    [carouselView->_delegate carouselView:carouselView didEndTransitioningView:contentView atIndex:index animated:animated];
                }
                // 恢复默认大小后再加入重用池。
                contentView.transform = CGAffineTransformIdentity;
                contentView.frame     = CGRectMake(0, 0, preferredContentSize.width, preferredContentSize.height);
                if (needsSendSEnqueueView) {
                    if ([carouselView->_dataSource carouselView:carouselView shouldEnqueueView:contentView atIndex:index]) {
                        nonDisplayViews[non++] = contentView;
                    }
                } else {
                    nonDisplayViews[non++] = contentView;
                }
            }
        }
        // 如果 itemView 将不显示视图，则先移除，以便后续不需要处理 XZCarouselViewNotFound 的 itemView 。
        // 视图在上面的步骤已经加入相应的列表，不会被销毁。
        if (newItemViewIndexes[i] == XZCarouselViewNotFound) {
            XZCarouselViewItemViewSetContentView(carouselView, itemView, XZCarouselViewNotFound, nil, CGSizeZero);
        }
    }
    
    if (!needscontentViewsUpdate) {
        return;
    }
    
    // 遍历 newItemViewIndexes 如果待加载的视图为 XZCarouselViewNotFound 则跳过，否则加载新视图：
    // 先从 yetDisplayViews 中查找，找到直接使用；
    // 如果没找到，则从通过数据源获取，如果重用池有待重用的视图，从数据源获取时，将待重用的视图返回给数据源决定是否重用。
    
    BOOL const needsSendWilBeginEvents = [carouselView->_delegate respondsToSelector:@selector(carouselView:willBeginTransitioningView:atIndex:animated:)];
    BOOL const needsSendDidBeginEvents = [carouselView->_delegate respondsToSelector:@selector(carouselView:didBeginTransitioningView:atIndex:animated:)];
    
    for (NSInteger i = 0; i < 5; i++) {
        _XZCarouselViewItemView * const __unsafe_unretained itemView = (__bridge _XZCarouselViewItemView *)(itemViews[i]);
        if (itemView == nil) {
            continue;
        }
        if (newItemViewIndexes[i] == XZCarouselViewNotFound) { // XZCarouselViewNotFound 的视图已处理。
            continue;
        }
        
        // 从 yetDisplayViews 中查找 index 相同的视图，直接显示。
        BOOL didLoadContentView = NO;
        for (NSInteger j = 0; j < yet; j++) {
            if (yetDisplayViews[j].index == newItemViewIndexes[i]) {
                XZCarouselViewItemViewSetContentView(carouselView, itemView, newItemViewIndexes[i], yetDisplayViews[j].contentView, yetDisplayViews[j].preferredContentSize); // 重用
                yetDisplayViews[j].index = XZCarouselViewNotFound; // 标记已重用。
                CFRelease((__bridge CFTypeRef)(yetDisplayViews[j].contentView));
                didLoadContentView = YES;
                break;
            }
        }
        if (didLoadContentView) {
            continue;
        }
        
        UIView *contentView = nil;
        if (non > 0) { // 临时重用池
            UIView * const reusingView = nonDisplayViews[non - 1];
            contentView = [carouselView->_dataSource carouselView:carouselView viewForIndex:newItemViewIndexes[i] reusingView:reusingView];
            if (contentView == reusingView) { // 视图被重用了。
                nonDisplayViews[--non] = nil;
            }
        } else if (carouselView->_reusingViews != nil && carouselView->_reusingViews.count > 0) { // 持久重用池。
            // 从数据源获取。
            UIView * const reusingView = carouselView->_reusingViews.lastObject;
            contentView = [carouselView->_dataSource carouselView:carouselView viewForIndex:newItemViewIndexes[i] reusingView:reusingView];
            // 视图如果被重用了，就从重用池移除，否则保留。
            if (reusingView == contentView) {
                [carouselView->_reusingViews removeLastObject];
            }
        } else { // 新的数据。
            contentView = [carouselView->_dataSource carouselView:carouselView viewForIndex:newItemViewIndexes[i] reusingView:nil];
        }
        if (needsSendWilBeginEvents) {
            [carouselView->_delegate carouselView:carouselView willBeginTransitioningView:contentView atIndex:newItemViewIndexes[i] animated:animated];
        }
        XZCarouselViewItemViewSetContentView(carouselView, itemView, newItemViewIndexes[i], contentView, contentView.frame.size);
        if (needsSendDidBeginEvents) {
            [carouselView->_delegate carouselView:carouselView didBeginTransitioningView:contentView atIndex:newItemViewIndexes[i] animated:animated];
        }
    }
    
    if (carouselView->_reusingViews != nil && non > 0) {
        for (NSInteger i = 0; i < non; i++) {
            [carouselView->_reusingViews addObject:nonDisplayViews[i]];
        }
    }
}

static void XZCarouselViewAddTransitionAnimationIfNeeded(XZCarouselView * const carouselView, BOOL isInteractive) {
    if (carouselView->_isTransitioning) {
        return;
    }
    
    if (carouselView->_transitioningDelegate) {
        carouselView->_isTransitioning = YES;
        
        // 优先使用代理的自定义动画。
        [carouselView->_transitioningDelegate carouselView:carouselView animateTransition:isInteractive];
        
        carouselView->_scrollView->_itemView1.transitionViewIfLoaded.layer.speed = 0;
        carouselView->_scrollView->_itemView2.transitionViewIfLoaded.layer.speed = 0;
        carouselView->_scrollView->_itemView3.transitionViewIfLoaded.layer.speed = 0;
        
        carouselView->_scrollView->_itemView1.transitionViewIfLoaded.layer.timeOffset = 0.0;
        carouselView->_scrollView->_itemView2.transitionViewIfLoaded.layer.timeOffset = 0.0;
        carouselView->_scrollView->_itemView3.transitionViewIfLoaded.layer.timeOffset = 0.0;
        return;
    }
    
    if (carouselView->_transitioningAnimation == nil) {
        return;
    }
    
    // 添加过渡动画。在代理方法中添加动画的时机已经太晚了，无法控制动画进度。
    // 这里有一点需要确认，当手势 Began 之后，是否一定会触发。
    carouselView->_isTransitioning = YES;
    
    carouselView->_transitioningAnimation.fillMode   = kCAFillModeBoth;
    carouselView->_transitioningAnimation.duration   = XZCarouselViewTransitioningAnimationDuration;
    carouselView->_transitioningAnimation.speed      = 1.0;
    carouselView->_transitioningAnimation.timeOffset = 0.0;
    carouselView->_transitioningAnimation.beginTime  = 0;
    // 因为 timingFunction 是针对整个 7 秒的动画，而非某一区间。
    carouselView->_transitioningAnimation.timingFunction = nil;
    carouselView->_transitioningAnimation.removedOnCompletion = NO;
    carouselView->_transitioningAnimation.autoreverses = NO;
    
    [carouselView->_scrollView.itemView1 transitionView].layer.speed = 0;
    [carouselView->_scrollView.itemView1 transitionView].layer.timeOffset = 0.0; // 手势过程中更新了此值。
    [carouselView->_scrollView.itemView1.transitionView.layer addAnimation:carouselView->_transitioningAnimation forKey:XZCarouselViewTransitionAnimationKey];
    
    [carouselView->_scrollView.itemView2 transitionView].layer.speed = 0;
    [carouselView->_scrollView.itemView2 transitionView].layer.timeOffset = 0.0;
    [carouselView->_scrollView.itemView2.transitionView.layer addAnimation:carouselView->_transitioningAnimation forKey:XZCarouselViewTransitionAnimationKey];
    
    [carouselView->_scrollView.itemView3 transitionView].layer.speed = 0;
    [carouselView->_scrollView.itemView3 transitionView].layer.timeOffset = 0.0;
    [carouselView->_scrollView.itemView3.transitionView.layer addAnimation:carouselView->_transitioningAnimation forKey:XZCarouselViewTransitionAnimationKey];
}

static void XZCarouselViewRemoveTransitionAnimationIfNeeded(XZCarouselView * const carouselView, BOOL const isCompleted) {
    if (!carouselView->_isTransitioning) {
        return;
    }
    
    // 标记已停止转场。
    carouselView->_isTransitioning = NO;

    // 动画视图。
    UIView * const transitionView1 = [carouselView->_scrollView->_itemView1 transitionViewIfLoaded];
    UIView * const transitionView2 = [carouselView->_scrollView->_itemView2 transitionViewIfLoaded];
    UIView * const transitionView3 = [carouselView->_scrollView->_itemView3 transitionViewIfLoaded];
    
    if (carouselView->_transitioningDelegate) {
        // 将 transitionViews 放回到 itemView 上，方便代理恢复原始大小。
        [carouselView->_scrollView->_itemView1 bringBackTransitionViewIfNeeded];
        [carouselView->_scrollView->_itemView2 bringBackTransitionViewIfNeeded];
        [carouselView->_scrollView->_itemView3 bringBackTransitionViewIfNeeded];
        
        // The delegate should remove the animations added to the transitionView.
        [carouselView->_transitioningDelegate carouselView:carouselView animationEnded:isCompleted];
    } else {
        [transitionView1.layer removeAnimationForKey:XZCarouselViewTransitionAnimationKey];
        [transitionView2.layer removeAnimationForKey:XZCarouselViewTransitionAnimationKey];
        [transitionView3.layer removeAnimationForKey:XZCarouselViewTransitionAnimationKey];
    }
    
    // reset the animation state.
    transitionView1.layer.speed = 1.0;
    transitionView1.layer.timeOffset = 0.0;
    
    transitionView2.layer.speed = 1.0;
    transitionView2.layer.timeOffset = 0.0;
    
    transitionView3.layer.speed = 1.0;
    transitionView3.layer.timeOffset = 0.0;
}

static CGFloat XZCarouselViewScrollViewGetTransition(_XZCarouselViewScrollView * const scrollView) {
    CGRect const itemViewFrame2 = scrollView->_itemView2.frame;
    switch (scrollView->_pagingOrientation) {
        case XZCarouselViewPagingOrientationHorizontal:
            return (scrollView.contentOffset.x - itemViewFrame2.origin.x) / (scrollView->_itemView3.frame.origin.x - itemViewFrame2.origin.x);
        case XZCarouselViewPagingOrientationVertical:
            return (scrollView.contentOffset.y - itemViewFrame2.origin.y) / itemViewFrame2.size.height;
    }
}

static NSInteger XZCarouselViewWrappedIndex(NSInteger const index, NSInteger const numberOfItems) {
    if (index < 0) {
        return XZCarouselViewWrappedIndex(numberOfItems + index, numberOfItems);
    }
    if (index >= numberOfItems) {
        return XZCarouselViewWrappedIndex(index - numberOfItems, numberOfItems);
    }
    return index;
}

static XZCarouselViewPagingDirection XZCarouselViewPagingDirectionMake(BOOL const isWrapped, NSInteger const fromIndex, NSInteger const toIndex, NSInteger const count) {
    if (isWrapped) {
        if (toIndex == 0 && fromIndex == count - 1) {
            return XZCarouselViewPagingDirectionForward;
        }
        if (fromIndex == 0 && toIndex == count - 1) {
            return XZCarouselViewPagingDirectionBackward;
        }
    }
    return (fromIndex < toIndex ? XZCarouselViewPagingDirectionForward : XZCarouselViewPagingDirectionBackward);
}


#pragma mark - 公开函数

/// 如果内容可以放下内容，则返回内容在容器中央的 frame，否则将内容等比缩小到容器正好可以容纳下。
CGRect XZCarouselViewFittingContentWithMode(CGRect const bounds, CGSize const contentSize, UIViewContentMode const contentMode) {
    switch (contentMode) {
        case UIViewContentModeScaleToFill: {
            return bounds;
        }
        case UIViewContentModeScaleAspectFill: {
            if (contentSize.width <= 0 || contentSize.height <= 0) {
                return bounds;
            }
            CGFloat w = bounds.size.width;
            CGFloat h = (contentSize.height / contentSize.width) * w;
            if (h < bounds.size.height) {
                h = bounds.size.height;
                w = (contentSize.width / contentSize.height) * h;
            }
            CGFloat const x = bounds.origin.x + (bounds.size.width - w) * 0.5;
            CGFloat const y = bounds.origin.y + (bounds.size.height - h) * 0.5;
            return CGRectMake(x, y, w, h);
        }
        case UIViewContentModeScaleAspectFit: {
            if (contentSize.width <= 0) {
                if (contentSize.height <= 0) {
                    return bounds;
                }
                return CGRectMake(CGRectGetMidX(bounds), CGRectGetMinY(bounds), 0, bounds.size.height);
            }
            if (contentSize.height <= 0) {
                return CGRectMake(CGRectGetMinX(bounds), CGRectGetMidY(bounds), bounds.size.width, 0);
            }
            CGFloat h = bounds.size.height;
            CGFloat w = (contentSize.width / contentSize.height) * h;
            if (w > bounds.size.width) {
                w = bounds.size.width;
                h = (contentSize.height / contentSize.width) * w;
            }
            CGFloat const x = bounds.origin.x + (bounds.size.width - w) * 0.5;
            CGFloat const y = bounds.origin.y + (bounds.size.height - h) * 0.5;
            return CGRectMake(x, y, w, h);
        }
        case UIViewContentModeRedraw: {
            if (contentSize.width <= bounds.size.width && contentSize.height <= bounds.size.height) {
                return XZCarouselViewFittingContentWithMode(bounds, contentSize, UIViewContentModeCenter);
            }
            return XZCarouselViewFittingContentWithMode(bounds, contentSize, UIViewContentModeScaleAspectFit);
        }
        case UIViewContentModeCenter: {
            CGFloat const w = MAX(0, contentSize.width);
            CGFloat const h = MAX(0, contentSize.height);
            CGFloat const x = CGRectGetMinX(bounds) + (bounds.size.width - w) * 0.5;
            CGFloat const y = CGRectGetMinY(bounds) + (bounds.size.height - h) * 0.5;
            return CGRectMake(x, y, w, h);
        }
        case UIViewContentModeTop: {
            CGFloat const w = MAX(0, contentSize.width);
            CGFloat const h = MAX(0, contentSize.height);
            CGFloat const x = bounds.origin.x + (bounds.size.width - w) * 0.5;
            CGFloat const y = CGRectGetMinY(bounds);
            return CGRectMake(x, y, w, h);
        }
        case UIViewContentModeBottom: {
            CGFloat const w = MAX(0, contentSize.width);
            CGFloat const h = MAX(0, contentSize.height);
            CGFloat const x = bounds.origin.x + (bounds.size.width - w) * 0.5;
            CGFloat const y = CGRectGetMaxY(bounds) - h;
            return CGRectMake(x, y, w, h);
        }
        case UIViewContentModeLeft: {
            CGFloat const w = MAX(0, contentSize.width);
            CGFloat const h = MAX(0, contentSize.height);
            CGFloat const x = CGRectGetMinX(bounds);
            CGFloat const y = CGRectGetMinY(bounds) + (bounds.size.height - contentSize.height) * 0.5;
            return CGRectMake(x, y, w, h);
        }
        case UIViewContentModeRight: {
            CGFloat const w = MAX(0, contentSize.width);
            CGFloat const h = MAX(0, contentSize.height);
            CGFloat const x = CGRectGetMaxX(bounds) - contentSize.width;
            CGFloat const y = CGRectGetMinY(bounds) + (bounds.size.height - contentSize.height) * 0.5;
            return CGRectMake(x, y, w, h);
        }
        case UIViewContentModeTopLeft: {
            CGFloat const w = MAX(0, contentSize.width);
            CGFloat const h = MAX(0, contentSize.height);
            CGFloat const x = CGRectGetMinX(bounds);
            CGFloat const y = CGRectGetMinY(bounds);
            return CGRectMake(x, y, w, h);
        }
        case UIViewContentModeTopRight: {
            CGFloat const w = MAX(0, contentSize.width);
            CGFloat const h = MAX(0, contentSize.height);
            CGFloat const x = CGRectGetMaxX(bounds) - w;
            CGFloat const y = CGRectGetMinY(bounds);
            return CGRectMake(x, y, w, h);
        }
        case UIViewContentModeBottomLeft: {
            CGFloat const w = MAX(0, contentSize.width);
            CGFloat const h = MAX(0, contentSize.height);
            CGFloat const x = CGRectGetMinX(bounds);
            CGFloat const y = CGRectGetMaxY(bounds) - h;
            return CGRectMake(x, y, w, h);
        }
        case UIViewContentModeBottomRight: {
            CGFloat const w = MAX(0, contentSize.width);
            CGFloat const h = MAX(0, contentSize.height);
            CGFloat const x = CGRectGetMaxX(bounds) - w;
            CGFloat const y = CGRectGetMaxY(bounds) - h;
            return CGRectMake(x, y, w, h);
        }
            
            // Extended Modes.
        case UIViewContentModeTop + 1000 * (UIViewContentModeScaleToFill + 1): {
            if (contentSize.width <= 0) {
                CGFloat const h = MAX(0, contentSize.height);
                return CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), bounds.size.width, h);
            }
            CGFloat const h = bounds.size.width * MAX(0, contentSize.height) / contentSize.width;
            return CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetWidth(bounds), h);
        }
        case UIViewContentModeBottom + 1000 * (UIViewContentModeScaleToFill + 1): {
            if (contentSize.width <= 0) {
                CGFloat const h = MAX(0, contentSize.height);
                return CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds) - h, bounds.size.width, h);
            }
            CGFloat const h = bounds.size.width * MAX(0, contentSize.height) / contentSize.width;
            return CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds) - h, CGRectGetWidth(bounds), h);
        }
        case UIViewContentModeLeft + 1000 * (UIViewContentModeScaleToFill + 1): {
            if (contentSize.height <= 0) {
                CGFloat const w = MAX(0, contentSize.width);
                return CGRectMake(bounds.origin.x, bounds.origin.y, w, bounds.size.height);
            }
            CGFloat const w = bounds.size.height * contentSize.width / contentSize.height;
            return CGRectMake(bounds.origin.x, bounds.origin.y, w, bounds.size.height);
        }
        case UIViewContentModeRight + 1000 * (UIViewContentModeScaleToFill + 1): {
            if (contentSize.height <= 0) {
                CGFloat const w = MAX(0, contentSize.width);
                return CGRectMake(CGRectGetMaxX(bounds) - w, bounds.origin.y, w, bounds.size.height);
            }
            CGFloat const w = bounds.size.height * contentSize.width / contentSize.height;
            return CGRectMake(CGRectGetMaxX(bounds) - w, bounds.origin.y, w, bounds.size.height);
        }
        case UIViewContentModeTopLeft + 1000 * (UIViewContentModeScaleToFill + 1):
        case UIViewContentModeTopRight + 1000 * (UIViewContentModeScaleToFill + 1):
        case UIViewContentModeBottomLeft + 1000 * (UIViewContentModeScaleToFill + 1):
        case UIViewContentModeBottomRight + 1000 * (UIViewContentModeScaleToFill + 1): { // 两条边适应，就是 UIViewContentModeScaleAspectFill 模式。
            UIViewContentMode newMode = XZCarouselViewExtendingContentMode(UIViewContentModeScaleAspectFill, contentMode - 1000 * (UIViewContentModeScaleToFill + 1));
            return XZCarouselViewFittingContentWithMode(bounds, contentSize, newMode);
        }
        case UIViewContentModeTop + 1000 * (UIViewContentModeScaleAspectFit + 1):
        case UIViewContentModeBottom + 1000 * (UIViewContentModeScaleAspectFit + 1):
        case UIViewContentModeLeft + 1000 * (UIViewContentModeScaleAspectFit + 1):
        case UIViewContentModeRight + 1000 * (UIViewContentModeScaleAspectFit + 1):
        case UIViewContentModeTopLeft + 1000 * (UIViewContentModeScaleAspectFit + 1):
        case UIViewContentModeTopRight + 1000 * (UIViewContentModeScaleAspectFit + 1):
        case UIViewContentModeBottomLeft + 1000 * (UIViewContentModeScaleAspectFit + 1):
        case UIViewContentModeBottomRight + 1000 * (UIViewContentModeScaleAspectFit + 1): {
            CGSize const newContentSize = XZCarouselViewFittingContentWithMode(bounds, contentSize, UIViewContentModeScaleAspectFit).size;
            return XZCarouselViewFittingContentWithMode(bounds, newContentSize, contentMode - 1000 * (UIViewContentModeScaleAspectFit + 1));
        }
        case UIViewContentModeTop + 1000 * (UIViewContentModeScaleAspectFill + 1):
        case UIViewContentModeBottom + 1000 * (UIViewContentModeScaleAspectFill + 1):
        case UIViewContentModeLeft + 1000 * (UIViewContentModeScaleAspectFill + 1):
        case UIViewContentModeRight + 1000 * (UIViewContentModeScaleAspectFill + 1):
        case UIViewContentModeTopLeft + 1000 * (UIViewContentModeScaleAspectFill + 1):
        case UIViewContentModeTopRight + 1000 * (UIViewContentModeScaleAspectFill + 1):
        case UIViewContentModeBottomLeft + 1000 * (UIViewContentModeScaleAspectFill + 1):
        case UIViewContentModeBottomRight + 1000 * (UIViewContentModeScaleAspectFill + 1): {
            CGSize const newContentSize = XZCarouselViewFittingContentWithMode(bounds, contentSize, UIViewContentModeScaleAspectFill).size;
            return XZCarouselViewFittingContentWithMode(bounds, newContentSize, contentMode - 1000 * (UIViewContentModeScaleAspectFill + 1));
        }
        case UIViewContentModeTop + 1000 * (UIViewContentModeRedraw + 1):
        case UIViewContentModeBottom + 1000 * (UIViewContentModeRedraw + 1):
        case UIViewContentModeLeft + 1000 * (UIViewContentModeRedraw + 1):
        case UIViewContentModeRight + 1000 * (UIViewContentModeRedraw + 1):
        case UIViewContentModeTopLeft + 1000 * (UIViewContentModeRedraw + 1):
        case UIViewContentModeTopRight + 1000 * (UIViewContentModeRedraw + 1):
        case UIViewContentModeBottomLeft + 1000 * (UIViewContentModeRedraw + 1):
        case UIViewContentModeBottomRight + 1000 * (UIViewContentModeRedraw + 1): {
            CGSize const newContentSize = XZCarouselViewFittingContentWithMode(bounds, contentSize, UIViewContentModeRedraw).size;
            return XZCarouselViewFittingContentWithMode(bounds, newContentSize, contentMode - 1000 * (UIViewContentModeRedraw + 1));
        }
    }
    return bounds;
}

UIViewContentMode XZCarouselViewExtendingContentMode(UIViewContentMode fitMode, UIViewContentMode alignMode) {
    return 1000 * (fitMode + 1) + alignMode;
}


