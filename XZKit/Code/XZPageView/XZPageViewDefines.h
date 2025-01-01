//
//  XZPageViewDefines.h
//  XZPageView
//
//  Created by 徐臻 on 2024/9/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XZPageView;

/// 翻页效果动画时长。
FOUNDATION_EXPORT NSTimeInterval const XZPageViewAnimationDuration;

/// 翻页方向。
typedef NS_ENUM(NSUInteger, XZPageViewOrientation) {
    /// 横向翻页。
    XZPageViewOrientationHorizontal = 0,
    /// 纵向翻页。
    XZPageViewOrientationVertical = 1,
};

/// XZPageView 数据源。
@protocol XZPageViewDataSource <NSObject>

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
                                    
/// 当视图不再展示时，此方法会被调用，此方法返回的视图将会被缓存，并在需要时重用。
/// @discussion 如果有待展示的内容，视图会直接在 `pageView:viewForPageAtIndex:reusingView:` 方法中作为 reusingView 使用，而不会调用此方法。
/// @param pageView 调用此方法的对象
/// @param reusingView 需要被重置的视图
- (nullable UIView *)pageView:(XZPageView *)pageView prepareForReusingView:(__kindof UIView *)reusingView;

@end

/// XZPageView 事件方法列表。
@protocol XZPageViewDelegate <UIScrollViewDelegate>

@optional
/// 翻页到某页时，此方法会被调用。
/// @discussion 只有用户操作或者自动翻页会触发此代理方法。
/// @param pageView 调用此方法的 XZPageView 对象
/// @param index 被展示元素的索引，不会是 NSNotFound
- (void)pageView:(XZPageView *)pageView didShowPageAtIndex:(NSInteger)index;

/// 当用户翻动页面时，此方法会被调用。
/// @param pageView 调用此方法的 XZPageView 对象。
/// @param transition 翻动的进度，值范围为 (0, 1.0) 之间，不包括边界值。
- (void)pageView:(XZPageView *)pageView didTurnPageWithTransition:(CGFloat)transition;

@end

NS_ASSUME_NONNULL_END
