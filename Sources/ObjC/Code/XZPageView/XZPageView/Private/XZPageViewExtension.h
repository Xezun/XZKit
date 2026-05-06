//
//  XZPageViewExtension.h
//  XZPageView
//
//  Created by Xezun on 2024/9/25.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZPageView.h>
#else
#import "XZPageView.h"
#endif

@class XZPageViewContext, UITableView, UICollectionView;

@interface XZPageView () {
    @package
    /// 负责逻辑处理的上下文对象。
    XZPageViewContext * _context;
    
    /// 页面是否已同步加载数据。
    /// 判断，首次或者数据源发生改变后，是否已执行刷新。
    BOOL                _isLoaded;
    
    /// 是否为循环模式。
    BOOL                _isLooped;
    /// 总页数。
    NSInteger           _numberOfPages;
    
    /// 当前页。
    NSInteger           _currentPage;
    /// 当前页对应的视图。
    UIView  * _Nullable _currentView;
    
    /// 页面切换的目标页。
    NSInteger           _pendingPage;
    /// 目标页对应的视图。当转场发生时，此属性才会被赋值，且视图在容器视图中。
    UIView  * _Nullable _pendingView;
    /// YES 表示加载在正向滚动的方向上，NO 表示加载在反向滚动的方向上。
    BOOL                _pendingPageDirection;
    
    /// 可复用页。
    NSInteger           _reusingPage;
    /// 可复用页对应的视图。该视图未添加到容器视图中。
    UIView  * _Nullable _reusingView;
    
    /// 自动轮播时间间隔。
    NSTimeInterval      _autoPagingInterval;
    /// 自动翻页定时器，请使用方法操作计时器，而非直接使用变量。
    /// 1、视图必须添加到 window 上，才会创建定时器。
    /// 2、从 widow 上移除会销毁定时器，并在再次添加到 window 上时重建。
    /// 3、滚动的过程中，定时器会暂停，并在滚动后重新开始计时。
    /// 4、刷新数据，定时器会重新开始计时。
    /// 5、改变 currentPage 定时器会重新计时。
    NSTimer * _Nullable __unsafe_unretained _autoPagingTimer;
    
    /// 发送翻页事件的方法。使用块函数封装的 imp 调用，以优化性能。
    void (^ _Nullable _didTurnPage)(XZPageView * _Nonnull pageView, CGFloat x, CGFloat width);
}

@end

