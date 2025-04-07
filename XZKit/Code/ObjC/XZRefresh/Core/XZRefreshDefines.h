//
//  XZRefreshDefines.h
//  XZRefresh
//
//  Created by Xezun on 2023/8/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 过渡动画所使用的时长 0.35 秒。
FOUNDATION_EXPORT NSTimeInterval const XZRefreshAnimationDuration NS_SWIFT_NAME(animationDuration);
/// 默认刷新视图的高度 44.0 点。
FOUNDATION_EXPORT CGFloat        const XZRefreshHeight NS_SWIFT_NAME(refreshHeight);

/// 刷新视图适配 UIScrollView 边距的方式。
typedef NS_ENUM(NSUInteger, XZRefreshAdjustment) {
    /// 刷新视图适配 UIScrollView.adjustedContentInset 边距。
    ///
    /// 在该适配模式下：
    /// - 头部刷新视图布局在 adjustedContentInset.top 区域上面。
    /// - 底部刷新视图布局在 adjustedContentInset.bottom 区域的下面。
    XZRefreshAdjustmentAutomatic,
    /// 刷新视图适配 UIScrollView.contentInset 边距。
    ///
    /// 在该适配模式下：
    /// - 头部刷新视图布局在 contentInset.top 区域上面。
    /// - 底部刷新视图布局在 contentInset.bottom 区域的下面。
    XZRefreshAdjustmentNormal,
    /// 刷新视图不适配边距。
    ///
    /// 在该适配模式下：
    /// - 头部刷新视图布局在 contentSize 区域上面。
    /// - 底部刷新视图布局在 contentSize 区域的下面。
    XZRefreshAdjustmentNone,
};

@class XZRefreshView, UIRefreshControl, UICollectionView;

/// XZRefresh 使用 UIScrollView.delegate 作为刷新事件的接收者。
NS_SWIFT_UI_ACTOR @protocol XZRefreshDelegate <UIScrollViewDelegate>
@optional
/// 当头部视图开始动画时，此方法会被调用。
/// @param scrollView 触发此方法的 UIScrollView 对象。
/// @param refreshView 已开始动的 XZRefreshView 对象。
- (void)scrollView:(UIScrollView *)scrollView headerDidBeginRefreshing:(XZRefreshView *)refreshView;

/// 当尾部视图开始动画时，此方法会被调用。
/// @param scrollView 触发此方法的 UIScrollView 对象。
/// @param refreshView 已开始动画的 XZRefreshView 对象。
- (void)scrollView:(UIScrollView *)scrollView footerDidBeginRefreshing:(XZRefreshView *)refreshView;

@end


NS_ASSUME_NONNULL_END
