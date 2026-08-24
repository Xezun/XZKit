//
//  XZPageView.m
//  XZKit
//
//  Created by Xezun on 2021/9/7.
//

#import "XZPageView.h"
#import "XZPageViewExtension.h"
#import "XZPageViewContext.h"
@import ObjectiveC;

@implementation XZPageView

- (void)dealloc {
    // 定时器由 runloop 持有，如果不主动停止，会持续访问已释放的对象。
    [_autoPagingTimer invalidate];
    if (_isLoaded) {
        [self XZPageViewCleanUpItemViews];
    }
}

- (instancetype)initWithFrame:(CGRect)frame orientation:(XZPageViewOrientation)orientation {
    self = [super initWithFrame:frame];
    if (self) {
        [self XZPageViewDidInitialize:orientation];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame orientation:(XZPageViewOrientationHorizontal)];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self XZPageViewDidInitialize:(XZPageViewOrientationHorizontal)];
    }
    return self;
}

- (void)XZPageViewDidInitialize:(XZPageViewOrientation)orientation {
    _context = [XZPageViewContext contextForView:self orientation:orientation];
    [super setDelegate:_context];
    
    _isLoaded      = NO;
    _isLooped      = YES;
    _currentPage   = NSNotFound;
    _pendingPage   = NSNotFound;
    _reusingPage   = NSNotFound;
    _numberOfPages = 0;
    
    self.contentOffset                  = CGPointZero;
    self.clipsToBounds                  = YES;
    self.contentSize                    = self.bounds.size;
    self.contentInset                   = UIEdgeInsetsZero;
    self.pagingEnabled                  = YES;
    self.alwaysBounceVertical           = NO;
    self.alwaysBounceHorizontal         = NO;
    self.showsVerticalScrollIndicator   = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
}

#pragma mark - 重写方法

- (void)didMoveToWindow {
    [super didMoveToWindow];
    // 执行首次刷新
    if (!_isLoaded) {
        [self reloadData];
    }
    // 检查定时器
    [_context scheduleAutoPagingTimerIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_isLoaded) {
        return;
    }
    [_context layoutSubviews:self.bounds];
}

#pragma mark - 属性

- (XZPageViewOrientation)orientation {
    return _context.orientation;
}

- (void)setOrientation:(XZPageViewOrientation)orientation {
    if (_context.orientation != orientation) {
        switch (orientation) {
            case XZPageViewOrientationHorizontal: {
                self.alwaysBounceHorizontal = self.alwaysBounceVertical;
                self.alwaysBounceVertical   = NO;
                break;
            }
            case XZPageViewOrientationVertical: {
                self.alwaysBounceVertical   = self.alwaysBounceHorizontal;
                self.alwaysBounceHorizontal = NO;
                break;
            }
            default: {
#if DEBUG
                NSString *reason = [NSString stringWithFormat:@"参数 direction 值 %ld 不是有效的 XZPageViewOrientation 枚举值", orientation];
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
#endif
                return;
            }
        }
        _context = [XZPageViewContext contextForView:self orientation:orientation];
        if (!_isLoaded) {
            return;
        }
        [_context layoutSubviews:self.bounds];
    }
}

- (BOOL)isLooped {
    return _isLooped;
}

- (void)setLooped:(BOOL)isLooped {
    if (_isLooped == isLooped) {
        return;
    }
    _isLooped = isLooped;
    
    // 单个元素，无法循环，不论是否开启循环模式，都不可左右滚动，边距处理一致。
    if (_numberOfPages <= 1) {
        return;
    }
    
    // 多个元素，当前元素不是第一个和最后一个时时，都可左右滚动的，边距处理逻辑一致。
    NSInteger const maxPage = _numberOfPages - 1;
    if (_currentPage > 0 && _currentPage < maxPage) {
        return;
    }
    
    CGRect const bounds = self.bounds;
    
    // 从 循环 => 非循环 模式，可能需要隐藏待显视图
    // 从 非循环 => 循环 模式，如果没有加载待显视图，那么由进一步的滚动事件处理即可
    if (_pendingView) {
        NSInteger const newPendingPage = XZPageLoop(_currentPage, _pendingPageDirection, maxPage, _isLooped);
        if (newPendingPage == NSNotFound) {
            // 发送待显视图的生命周期事件
            [_context willHideView:_pendingView animated:NO];
            [_pendingView removeFromSuperview];
            [_context didHideView:_pendingView animated:NO];
            
            // 先清除待显视图，避免后续的代理方法中，可能会访问到不正确的值。
            UIView *  const pendingView = _pendingView;
            NSInteger const pendingPage = _pendingPage;
            _pendingView = nil;
            _pendingPage = NSNotFound;
            
            // 尝试将待显视图加入重用机制
            if ([_dataSource pageView:self shouldReuseView:pendingView]) {
                _reusingPage = pendingPage;
                _reusingView = pendingView;
            }
        } else if (newPendingPage != _pendingPage) {
            // 发送生命周期事件
            [_context willHideView:_pendingView animated:NO];
            [_pendingView removeFromSuperview];
            [_context didHideView:_pendingView animated:NO];
            
            UIView *  const pendingView = _pendingView;
            _pendingView = nil;
            _pendingPage = newPendingPage;
            
            if ([_dataSource pageView:self shouldReuseView:pendingView]) {
                _pendingView = [_dataSource pageView:self viewForPageAtIndex:_pendingPage reusingView:pendingView];
            } else {
                _pendingView = [_dataSource pageView:self viewForPageAtIndex:_pendingPage reusingView:_reusingView];
                _reusingView = nil;
                _reusingPage = NSNotFound;
            }
            
            [_context willShowView:_pendingView animated:NO];
            [self addSubview:_pendingView];
            
            [_context layoutPendingView:bounds];
        } else {
            [_context layoutPendingView:bounds];
        }
    }
    
    [_context adjustContentInsetsToFitBounds:bounds];
}

- (void)setAutoPagingInterval:(NSTimeInterval)autoPagingInterval {
    if (_autoPagingInterval != autoPagingInterval) {
        _autoPagingInterval = autoPagingInterval;
        if (!_isLoaded) {
            return;
        }
        [_context scheduleAutoPagingTimerIfNeeded];
    }
}

- (void)suspendAutoPaging {
    [_context suspendAutoPagingTimer];
}

- (void)restartAutoPaging {
    [_context restartAutoPagingTimer];
}

- (NSInteger)numberOfPages {
    if (!_isLoaded) {
        [self reloadData];
    }
    return _numberOfPages;
}

- (void)setCurrentPage:(NSInteger)currentPage {
    [self setCurrentPage:currentPage animated:NO];
}

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated {
    if (_isLoaded) {
        [_context setCurrentPage:currentPage animated:animated];
        // 自动翻页重新计时
        [_context restartAutoPagingTimer];
    } else {
        _currentPage = currentPage;
    }
}

- (UIView *)currentView {
    return _currentView;
}

- (UIView *)pendingView {
    return _pendingView;
}

@dynamic delegate;

- (void)setDelegate:(id<XZPageViewDelegate>)delegate {
    id<XZPageViewDelegate> const newValue = delegate;
    id<XZPageViewDelegate> const oldValue = (id)super.delegate;
    
    if (oldValue == newValue) {
        return;
    }

    if (newValue) {
        [_context handleDelegateOfClass:[newValue class]];
        [super setDelegate:newValue];
    } else {
        [super setDelegate:_context];
    }
}

- (void)setDataSource:(id<XZPageViewDataSource>)dataSource {
    if (_dataSource != dataSource) {
        if (_isLoaded) {
            // 更换数据源前清理旧数据
            [self XZPageViewCleanUpItemViews];
            // 新数据源
            _dataSource = dataSource;
            // 页面进入未加载状态
            _isLoaded = NO;
        } else {
            _dataSource = dataSource;
        }
    }
}

#pragma mark - 公开方法

- (void)reloadData {
    if (_dataSource == nil) {
        return;
    }
    _isLoaded = YES;
    
    UIView * const currentView = _currentView;
    UIView * const pendingView = _pendingView;
    UIView * const reusingView = _reusingView;
    
    [self XZPageViewCleanUpItemViews];
    
    CGRect const bounds = self.bounds;
    
    _numberOfPages = [_dataSource numberOfPagesInPageView:self];
    
    if (_numberOfPages == 0) {
        _currentPage = NSNotFound;
    } else if (_currentPage == NSNotFound) {
        _currentPage = 0;
    } else if (_currentPage >= _numberOfPages) {
        _currentPage = _numberOfPages - 1;
    }
    
    if (_currentPage != NSNotFound) {
        if (currentView && [_dataSource pageView:self shouldReuseView:currentView]) {
            _currentView = [_dataSource pageView:self viewForPageAtIndex:_currentPage reusingView:currentView];
            if (pendingView && [_dataSource pageView:self shouldReuseView:pendingView]) {
                _reusingView = pendingView;
            } else if (reusingView && [_dataSource pageView:self shouldReuseView:reusingView]) {
                _reusingView = reusingView;
            }
        } else if (pendingView && [_dataSource pageView:self shouldReuseView:pendingView]) {
            _currentView = [_dataSource pageView:self viewForPageAtIndex:_currentPage reusingView:pendingView];
            if (reusingView && [_dataSource pageView:self shouldReuseView:reusingView]) {
                _reusingView = reusingView;
            }
        } else if (reusingView && [_dataSource pageView:self shouldReuseView:reusingView]) {
            _currentView = [_dataSource pageView:self viewForPageAtIndex:_currentPage reusingView:reusingView];
        } else {
            _currentView = [_dataSource pageView:self viewForPageAtIndex:_currentPage reusingView:nil];
        }
        
        [_context willShowView:_currentView animated:NO];
        [self addSubview:_currentView];
        [_context didShowView:_currentView animated:NO];
        
        [_context layoutCurrentView:bounds];
    } else if (currentView && [_dataSource pageView:self shouldReuseView:currentView]) {
        _reusingView = currentView;
    } else if (pendingView && [_dataSource pageView:self shouldReuseView:pendingView]) {
        _reusingView = pendingView;
    } else if (reusingView && [_dataSource pageView:self shouldReuseView:reusingView]) {
        _reusingView = reusingView;
    }
    
    // 调整 contentInset 已适配当前状态，并重置页面位置
    [_context adjustContentInsetsToFitBounds:bounds];
    
    // 将位置恢复到原点，并停止当前可能存在的滚动。
    [self setContentOffset:CGPointZero animated:NO];
    
    // 预加载下一页
    [_context prefetchNextPageWithDirection:YES maxPage:(_numberOfPages - 1)];
    
    // 重启自动翻页计时器
    [_context scheduleAutoPagingTimerIfNeeded];
}

#pragma mark - 私有方法

- (void)XZPageViewCleanUpItemViews {
    // 若 _pendingView 有值，说明在转场过程中，那么 currentView 必然有值，且 willHide 事件已经发送。
    if (_pendingView) {
        [_context willHideView:_pendingView animated:NO];
        
        [_currentView removeFromSuperview];
        [_context didHideView:_currentView animated:NO];
        _currentView = nil;
        _currentPage = NSNotFound;
        
        [_pendingView removeFromSuperview];
        [_context didHideView:_pendingView animated:NO];
        _pendingView = nil;
        _pendingPage = NSNotFound;
    } else if (_currentView) {
        [_context willHideView:_currentView animated:NO];
        [_currentView removeFromSuperview];
        [_context didHideView:_currentView animated:NO];
        _currentView = nil;
        _currentPage = NSNotFound;
    }
    
    _reusingView = nil;
    _reusingPage = NSNotFound;
}

@end

