//
//  XZPageViewExtension.h
//  XZPageView
//
//  Created by Xezun on 2024/9/25.
//

#import "XZPageView.h"

@class XZPageViewContext;

@interface XZPageView () {
    @package
    XZPageViewContext * _context;
    
    /// 用来标记是否已执行首次刷新。
    BOOL _isPageLoaded;
    
    BOOL                _isLooped;
    NSInteger           _numberOfPages;
    
    NSInteger           _currentPage;
    UIView  * _Nullable _currentView;
    
    NSInteger           _pendingPage;
    UIView  * _Nullable _pendingView;
    /// YES 表示加载在正向滚动的方向上，NO 表示加载在反向滚动的方向上。
    BOOL                _pendingPageDirection;
    
    UIView  * _Nullable _reusingView;
    NSInteger           _reusingPage;
    
    NSTimeInterval      _autoPagingInterval;
    /// 自动翻页定时器，请使用方法操作计时器，而非直接使用变量。
    /// 1、视图必须添加到 window 上，才会创建定时器。
    /// 2、从 widow 上移除会销毁定时器，并在再次添加到 window 上时重建。
    /// 3、滚动的过程中，定时器会暂停，并在滚动后重新开始计时。
    /// 4、刷新数据，定时器会重新开始计时。
    /// 5、改变 currentPage 定时器会重新计时。
    NSTimer * _Nullable __unsafe_unretained _autoPagingTimer;
    
    void (^ _Nullable _didTurnPage)(XZPageView * _Nonnull pageView, CGFloat x, CGFloat width);
}

@end

