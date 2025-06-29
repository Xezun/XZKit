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
    if (_isPageLoaded) {
        [self XZPageViewCleanUpViews];
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
    
    _isPageLoaded       = NO;
    _isLooped      = YES;
    _currentPage   = NSNotFound;
    _reusingPage   = NSNotFound;
    _numberOfPages = 0;
    
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
    if (!_isPageLoaded) {
        [self reloadData];
    }
    // 检查定时器
    [_context scheduleAutoPagingTimerIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_isPageLoaded) {
        return;
    }
    [_context layoutSubviews:self.bounds];
}

@dynamic delegate;

#pragma mark - 属性

- (XZPageViewOrientation)orientation {
    return _context.orientation;
}

- (void)setOrientation:(XZPageViewOrientation)orientation {
    if (_context.orientation != orientation) {
        switch (orientation) {
            case XZPageViewOrientationHorizontal: {
                self.alwaysBounceHorizontal = self.alwaysBounceVertical;
                self.alwaysBounceVertical = NO;
                break;
            }
            case XZPageViewOrientationVertical: {
                self.alwaysBounceVertical = self.alwaysBounceHorizontal;
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
        if (!_isPageLoaded) {
            return;
        }
        [_context layoutSubviews:self.bounds];
    }
}

- (BOOL)isLooped {
    return _isLooped;
}

- (void)setLooped:(BOOL)isLooped {
    if (_isLooped != isLooped) {
        _isLooped = isLooped;
    
        // 不可循环
        if (!_isPageLoaded || _numberOfPages <= 1) {
            return;
        }
        
        // 只有当位置处于第一个或者最后一个时，才需要进行调整
        NSInteger const maxPage = _numberOfPages - 1;
        if (_currentPage == 0 || _currentPage == maxPage) {
            CGRect const bounds = self.bounds;
            
            // 从 循环 => 非循环 模式，可能需要隐藏待显视图
            // 从 非循环 => 循环 模式，如果没有加载待显视图，那么由进一步的滚动事件处理即可
            if (_pendingView) {
                NSInteger const pendingPage = XZLoopPage(_currentPage, _pendingPageDirection, maxPage, _isLooped);
                if (pendingPage == NSNotFound) {
                    [_context willHideView:_pendingView animated:NO];
                    [_pendingView removeFromSuperview];
                    [_context didHideView:_pendingView animated:NO];
                    if ([_dataSource pageView:self shouldReuseView:_pendingView]) {
                        _reusingPage = _pendingPage;
                        _reusingView = _pendingView;
                    }
                    _pendingView = nil;
                    _pendingPage = NSNotFound;
                } else if (pendingPage != _pendingPage) {
                    // 似乎不太可能
                    [_context willHideView:_pendingView animated:NO];
                    [_pendingView removeFromSuperview];
                    [_context didHideView:_pendingView animated:NO];
                    
                    _pendingPage = pendingPage;
                    if ([_dataSource pageView:self shouldReuseView:_pendingView]) {
                        _pendingView = [_dataSource pageView:self viewForPageAtIndex:_pendingPage reusingView:_pendingView];
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
            
            [_context adjustContentInsets:bounds];
        }
    }
}

- (void)setAutoPagingInterval:(NSTimeInterval)autoPagingInterval {
    if (_autoPagingInterval != autoPagingInterval) {
        _autoPagingInterval = autoPagingInterval;
        if (!_isPageLoaded) {
            return;
        }
        [_context scheduleAutoPagingTimerIfNeeded];
    }
}

- (NSInteger)numberOfPages {
    if (!_isPageLoaded) {
        [self reloadData];
    }
    return _numberOfPages;
}

- (void)setCurrentPage:(NSInteger)currentPage {
    [self setCurrentPage:currentPage animated:NO];
}

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated {
    if (_isPageLoaded) {
        [_context setCurrentPage:currentPage animated:animated];
        // 自动翻页重新计时
        [_context resumeAutoPagingTimer];
    } else {
        _currentPage = currentPage;
    }
}

- (UIView *)currentView {
    if (!_isPageLoaded) {
        [self reloadData];
    }
    return _currentView;
}

- (UIView *)pendingView {
    if (!_isPageLoaded) {
        [self reloadData];
    }
    return _pendingView;
}

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
        if (_isPageLoaded) {
            // 清除数据
            [self XZPageViewCleanUpViews];
            // 新数据源
            _dataSource = dataSource;
            // 页面进入未加载状态
            _isPageLoaded = NO;
        } else {
            _dataSource = dataSource;
        }
    }
}

#pragma mark - 公开方法

- (void)reloadData {
    _isPageLoaded = YES;
    
    CGRect const bounds = self.bounds;
    
    {
        _numberOfPages = [_dataSource numberOfPagesInPageView:self];
        
        // 先确定 currentPage 然后再根据 _currentView 的情况处理及发送事件
        if (_numberOfPages == 0) {
            _currentPage = NSNotFound;
        } else if (_currentPage == NSNotFound) {
            _currentPage = 0;
        } else if (_currentPage >= _numberOfPages) {
            _currentPage = _numberOfPages - 1;
        }
        
        if (_currentView) {
            if (!_pendingView) {
                [_context willHideView:_currentView animated:NO];
            }
            [_currentView removeFromSuperview];
            [_context didHideView:_currentView animated:NO];
            
            if (_currentPage != NSNotFound) {
                if ([_dataSource pageView:self shouldReuseView:_currentView]) {
                    _currentView = [_dataSource pageView:self viewForPageAtIndex:_currentPage reusingView:_currentView];
                } else {
                    _currentView = [_dataSource pageView:self viewForPageAtIndex:_currentPage reusingView:_reusingView];
                    _reusingView = nil;
                    _reusingPage = NSNotFound;
                }
                [_context willShowView:_currentView animated:NO];
                [self addSubview:_currentView];
                [_context didShowView:_currentView animated:NO];
                [_context layoutCurrentView:bounds];
            } else {
                if ([_dataSource pageView:self shouldReuseView:_currentView]) {
                    _reusingView = _currentView;
                    _reusingPage = NSNotFound;
                }
                _currentView = nil;
            }
        } else {
            if (_currentPage != NSNotFound) {
                _currentView = [_dataSource pageView:self viewForPageAtIndex:_currentPage reusingView:_reusingView];
                _reusingView = nil;
                _reusingPage = NSNotFound;
                [_context willShowView:_currentView animated:NO];
                [self addSubview:_currentView];
                [_context didShowView:_currentView animated:NO];
                [_context layoutCurrentView:bounds];
            } else {
                // 没有 _currentView 也没有 _currentPage 不需要处理
            }
        }
        
        if (_pendingView) {
            [_context willHideView:_pendingView animated:NO];
            [_pendingView removeFromSuperview];
            [_context didHideView:_pendingView animated:NO];
            
            _pendingPage = XZLoopPage(_currentPage, _pendingPageDirection, _numberOfPages - 1, _isLooped);
            
            if (_pendingPage != NSNotFound) {
                if ([_dataSource pageView:self shouldReuseView:_pendingView]) {
                    _pendingView = [_dataSource pageView:self viewForPageAtIndex:_pendingPage reusingView:_pendingView];
                } else {
                    _pendingView = [_dataSource pageView:self viewForPageAtIndex:_pendingPage reusingView:_reusingView];
                    _reusingView = nil;
                    _reusingPage = NSNotFound;
                }
                [_context willShowView:_pendingView animated:NO];
                [self addSubview:_pendingView];
            } else {
                if ([_dataSource pageView:self shouldReuseView:_pendingView]) {
                    _reusingView = _pendingView;
                    _reusingPage = NSNotFound;
                }
                _pendingView = nil;
            }
            [_context layoutPendingView:bounds];
        }
        
        // 调整 contentInset 已适配当前状态，并重置页面位置
        // 方法 -setContentOffset:animated: 可以停到当前可能存在的滚动
        [_context adjustContentInsets:bounds];
        [self setContentOffset:CGPointZero animated:NO];
        
        // 重启自动翻页计时器
        [_context scheduleAutoPagingTimerIfNeeded];
    }
}

#pragma mark - 私有方法

- (void)XZPageViewCleanUpViews {
    // 清理页面
    if (_currentPage != NSNotFound) {
        if (!_pendingView) {
            [_context willHideView:_currentView animated:NO];
        }
        [_currentView removeFromSuperview];
        [_context didHideView:_currentView animated:NO];
        _currentView = nil;
        _currentPage = NSNotFound;
    }
    
    if (_pendingPage != NSNotFound) {
        [_context willHideView:_pendingView animated:NO];
        [_pendingView removeFromSuperview];
        [_context didHideView:_pendingView animated:NO];
        _pendingView = nil;
        _pendingPage = NSNotFound;
    }
    
    _reusingPage = NSNotFound;
    _reusingView = nil;
}

@end

