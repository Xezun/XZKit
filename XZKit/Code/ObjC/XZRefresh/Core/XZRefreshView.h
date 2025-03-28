//
//  XZRefreshView.h
//  XZRefresh
//
//  Created by Xezun on 2023/8/10.
//

#import <UIKit/UIKit.h>
#import "XZRefreshDefines.h"

NS_ASSUME_NONNULL_BEGIN

@class UIScrollView, UIRefreshControl, UIGestureRecognizer;

@protocol XZRefreshDelegate;

/// 刷新视图。
/// @discussion
/// 基类，无动画效果，必须使用子类。
/// @discussion
/// 当视图进入刷新状态时，可通过`UIScrollView.delegate`接收事件。
@interface XZRefreshView : UIView

/// 默认头部刷新视图。必须能够使用 `-initWithFrame:` 方法初始化。
@property (class, nonatomic, null_resettable) Class defaultHeaderClass;
/// 默认尾部刷新视图。必须能够使用 `-initWithFrame:` 方法初始化。
@property (class, nonatomic, null_resettable) Class defaultFooterClass;

/// 处理刷新事件的代理。
/// @discussion
/// 刷新事件会优先发送到此属性指定的对象，即，如果设置了此属性，那么`UIScrollView.delegate`将不会收到事件。
/// @discussion
/// 只会触发符合控件当前角色的代理事件，即，如果当前对象作为`refreshHeaderView`，那么只会触发`-scrollView:headerDidBeginRefreshing:`方法。
@property (nonatomic, weak) id<XZRefreshDelegate> delegate;

/// 当前对象所在的 UIScrollView 视图。
@property (nonatomic, weak, readonly) UIScrollView *scrollView;

/// 布局适配方式。
@property (nonatomic) XZRefreshAdjustment adjustment;

/// 是否正在（上拉加载/下拉刷新）动画。
@property (nonatomic, setter=setRefreshing:) BOOL isRefreshing;

/// 刷新视图的相对默认位置的偏移。
@property (nonatomic) CGFloat offset;

/// 自动进入刷新状态的距离。默认值 0 不自动进入刷新状态。
/// @discussion
/// 在下拉/上拉的过程中，当滚动位置到达顶部/底部的距离首次在此范围内时，将自动触发刷新操作。
@property (nonatomic) CGFloat automaticRefreshDistance;

/// 刷新区域的高度。不是当前视图的高度。
@property (nonatomic) CGFloat refreshHeight;

/// 进入下拉/上拉状态，并开始执行刷新动画。
/// @param animated 是否动画过度到刷新状态。
/// @param completion 动画完毕后的回调，finished 值为 NO 时，表示动画未完成，未执行动画，或动画中断。
- (void)beginRefreshing:(BOOL)animated completion:(nullable void (^)(BOOL finished))completion;

///  结束下拉/上拉状态，并停止刷新动画。
/// @param animated 是否动画过度到刷新状态。
/// @param completion 动画完毕后的回调。
- (void)endRefreshing:(BOOL)animated completion:(nullable void (^)(BOOL finished))completion;

/// 进入下拉/上拉状态，并开始执行刷新动画。
/// @note 方法 -beginRefreshing:completion: 的便利方法。
- (void)beginRefreshing;

/// 结束下拉/上拉状态，并停止刷新动画。
/// @note 方法 -endRefreshing:completion: 的便利方法。
- (void)endRefreshing;

#pragma mark - 自定义刷新视图可重写的方法

/// 非刷新状态时，当 UIScrollView 被下拉或上拉，在进入刷新状态前，此方法会被调用。
/// @param scrollView 被上拉或下拉的 UIScrollView 对象
/// @param distance 被上拉或下拉的距离
- (void)scrollView:(UIScrollView *)scrollView didScrollRefreshing:(CGFloat)distance;

/// 当用户停止下拉或上拉时，此方法会被调用。
/// @note 如果此方法分返回了 YES 那么 UIScrollView 将进入刷新状态。
/// @param scrollView 被上拉或下拉的 UIScrollView 对象
/// @param distance 被上拉或下拉的距离，该距离不包括间距
/// @returns 刷新视图拖动距离 distance 是否满足进入刷新状态
- (BOOL)scrollView:(UIScrollView *)scrollView shouldBeginRefreshing:(CGFloat)distance;

/// 当 scrollView 进入刷新状态时，此方法会被调用。
/// @param scrollView 调用此方法 UIScrollView 对象
/// @param animated 是否需要展示动画过程，用户操作触发刷新时，此参数为 NO
- (void)scrollView:(UIScrollView *)scrollView didBeginRefreshing:(BOOL)animated;

/// 当 scrollView 将要停止刷新时，此方法会被调用。
/// @param scrollView 调用此方法 UIScrollView 对象
/// @param animated 停止刷新状态是否动画过渡
- (void)scrollView:(UIScrollView *)scrollView willEndRefreshing:(BOOL)animated;

/// 当 scrollView 停止刷新时，此方法会被调用。
/// @param scrollView 调用此方法 UIScrollView 对象
/// @param animated 停止刷新状态是否动画过渡
- (void)scrollView:(UIScrollView *)scrollView didEndRefreshing:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
