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
    _context = [XZPageViewContext contextWithPageView:self orientation:orientation];
    [super setDelegate:_context];
    
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
    // 开启自动计时器
    [_context scheduleAutoPagingTimerIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_context layoutSubviews:self.bounds];
}

@dynamic delegate;

#pragma mark - 属性

- (void)setDataSource:(id<XZPageViewDataSource>)dataSource {
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        [self reloadData];
    }
}

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
        _context = [XZPageViewContext contextWithPageView:self orientation:orientation];
        [self reloadData];
    }
}

- (BOOL)isLooped {
    return _isLooped;
}

- (void)setLooped:(BOOL)isLooped {
    if (_isLooped != isLooped) {
        _isLooped = isLooped;
    
        // 不可循环
        if (_numberOfPages <= 1) {
            return;
        }
        
        // 只有当位置处于第一个或者最后一个时，才需要进行调整
        NSInteger const maxPage = _numberOfPages - 1;
        if (_currentPage == 0 || _currentPage == maxPage) {
            CGRect const bounds = self.bounds;
            [_context adjustContentInsets:bounds];
            if (_reusingPage != NSNotFound) {
                _reusingPageDirection = XZScrollDirection(_currentPage, _reusingPage, maxPage, _isLooped);
                [_context layoutReusingPageView:bounds];
            }
        }
    }
}

- (void)setAutoPagingInterval:(NSTimeInterval)autoPagingInterval {
    if (_autoPagingInterval != autoPagingInterval) {
        _autoPagingInterval = autoPagingInterval;
        [_context scheduleAutoPagingTimerIfNeeded];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    [self setCurrentPage:currentPage animated:NO];
}

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated {
    [_context setCurrentPage:currentPage animated:animated];
    // 自动翻页重新计时
    [_context resumeAutoPagingTimer];
}

- (UIView *)currentView {
    return _currentView;
}

- (UIView *)pendingView {
    return _reusingView;
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

#pragma mark - 公开方法

- (void)reloadData {
    // 重置数据
    _numberOfPages = 0;
    _currentPage = NSNotFound;
    [_context reloadCurrentPageView];
    _reusingPage = NSNotFound;
    [_context reloadReusingPageView];
    
    // 刷新
    [self reloadDataWithoutEvents];
    
    // 发送事件
    if (_didShowPage && _currentPage != NSNotFound) {
        _didShowPage(self, _currentPage);
    }
}

#pragma mark - 私有方法

- (void)reloadDataWithoutEvents {
    CGRect const bounds = self.bounds;
    
    _numberOfPages = [_dataSource numberOfPagesInPageView:self];
    
    // 自动调整当前页
    if (_numberOfPages == 0) {
        _currentPage = NSNotFound;
    } else if (_currentPage == NSNotFound) {
        _currentPage = 0;
    } else if (_currentPage >= _numberOfPages) {
        _currentPage = _numberOfPages - 1;
    }
    
    // 重载当前页
    [_context reloadCurrentPageView];
    [_context layoutCurrentPageView:bounds];
    
    // 重载备用页
    _reusingPage = NSNotFound;
    [_context reloadReusingPageView];
    [_context layoutReusingPageView:bounds];
    
    // 调整 contentInset 已适配当前状态，并重置页面位置
    // 方法 -setContentOffset:animated: 可以停到当前可能存在的滚动
    [_context adjustContentInsets:bounds];
    [self setContentOffset:CGPointZero animated:NO];
    
    // 重启自动翻页计时器
    [_context scheduleAutoPagingTimerIfNeeded];
}

@end

