//
//  XZPageViewDefines.h
//  XZPageView
//
//  Created by Xezun on 2024/9/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XZPageView, UITableView, UITableViewCell;
@protocol UITableViewDelegate;

/// 翻页效果动画时长 0.35 秒。
///
/// @attention 在 XZImageViewer 退场动画中，如果此动画时长值为 0.35 秒或 0.40 秒，退场后状态栏的样式可能不正常。
FOUNDATION_EXPORT NSTimeInterval const XZPageViewAnimationDuration;

/// 翻页方向。
typedef NS_ENUM(NSUInteger, XZPageViewOrientation) {
    /// 横向翻页。
    XZPageViewOrientationHorizontal = 0,
    /// 纵向翻页。
    XZPageViewOrientationVertical   = 1,
};

/// XZPageView 数据源。
NS_SWIFT_UI_ACTOR @protocol XZPageViewDataSource <NSObject>

@required
/// 在此方法中返回元素的个数。
/// @param pageView 调用此方法的对象
- (NSInteger)numberOfPagesInPageView:(XZPageView *)pageView;

/// 加载视图。在此方法中创建或重用页面视图，配置并返回它们。
/// @discussion 在页面切换过程中，不展示视图不会立即移除，而是保留为备用视图：
/// @discussion 1、切回备用视图，不需要重新加载。
/// @discussion 2、切换新视图时，备用视图将作为 reusingView 参数提供给 dataSource 复用。
/// @param pageView 调用此方法的对象
/// @param index 元素次序
/// @param reusingView 可重用的视图
- (UIView *)pageView:(XZPageView *)pageView viewForPageAtIndex:(NSInteger)index reusingView:(nullable __kindof UIView *)reusingView;
                                    
/// 当视图不展示时，此方法会被调用，询问该视图是否可以重用。
///
/// @param pageView 调用此方法的对象
/// @param reusingView 需要被重置的视图
- (BOOL)pageView:(XZPageView *)pageView shouldReuseView:(__kindof UIView *)reusingView;

@end

/// XZPageView 事件方法列表。
NS_SWIFT_UI_ACTOR @protocol XZPageViewDelegate <UIScrollViewDelegate>

@optional
/// 生命周期：元素视图将要显示。
/// - Parameters:
///   - pageView: 调用此方法的对象
///   - view: 将要显示的元素视图
///   - animated: 元素视图是否动画入场
- (void)pageView:(XZPageView *)pageView willShowView:(UIView *)view animated:(BOOL)animated NS_SWIFT_NAME(pageView(_:willShowView:animated:));

/// 生命周期：元素视图已经显示。
/// - Parameters:
///   - pageView: 调用此方法的对象
///   - view: 将要显示的元素视图
///   - animated: 元素视图是否动画入场
- (void)pageView:(XZPageView *)pageView didShowView:(UIView *)view animated:(BOOL)animated NS_SWIFT_NAME(pageView(_:didShowView:animated:));

/// 生命周期：元素视图将要隐藏。
/// - Parameters:
///   - pageView: 调用此方法的对象
///   - view: 将要显示的元素视图
///   - animated: 元素视图是否动画退场
- (void)pageView:(XZPageView *)pageView willHideView:(UIView *)view animated:(BOOL)animated NS_SWIFT_NAME(pageView(_:willHideView:animated:));

/// 生命周期：元素视图已经隐藏。
/// - Parameters:
///   - pageView: 调用此方法的对象
///   - view: 将要显示的元素视图
///   - animated: 元素视图是否动画退场
- (void)pageView:(XZPageView *)pageView didHideView:(UIView *)view animated:(BOOL)animated NS_SWIFT_NAME(pageView(_:didHideView:animated:));

/// 事件：当前正显示的页面发送改变。
/// @li 调用 ``-reloadData`` 、 ``-setCurrentPage:animated:`` 等方法导致的页面发生改变，不会触发此方法。
/// @li 当自动轮播、手势滚动触发页面发生改变时，此方法会被调用。
/// @param pageView 调用此方法的对象
/// @param index 当前显示的页面的次序
- (void)pageView:(XZPageView *)pageView didShowPageAtIndex:(NSInteger)index;

/// 事件：手势滚动页面时，页面切换的进度发生改变。
///
/// 除调用 ``-setCurrentPage:animated:`` 之外，如果 currentPage 发生改变，即会调用此方法。
/// 1. 首次显示时，自动展示第一个视图会调用此方法。
/// 2. 刷新时，如果数量减少，currenPage 的自动调整。
///
/// @param pageView 调用此方法的 XZPageView 对象。
/// @param transition 翻动的进度，值范围为 (-1.0, 0) 和 (0, 1.0) 之间，不包括边界值。
- (void)pageView:(XZPageView *)pageView didTurnPageWithTransition:(CGFloat)transition NS_SWIFT_NAME(pageView(_:didTurnPageWith:));

@end

NS_ASSUME_NONNULL_END
