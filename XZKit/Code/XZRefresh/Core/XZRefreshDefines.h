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
/// 默认刷新视图的高度 50.0 点。
FOUNDATION_EXPORT CGFloat        const XZRefreshHeight NS_SWIFT_NAME(refreshHeight);

/// XZRefreshView 适配 UIScrollView 边距的方式。
typedef NS_ENUM(NSUInteger, XZRefreshAdjustment) {
    /// 自动适配由 contentInsetAdjustmentBehavior 影响的边距。
    XZRefreshAdjustmentAutomatic,
    /// 仅适配 UIScrollView 自身的边距。
    XZRefreshAdjustmentNormal,
    /// 不适配边距。
    XZRefreshAdjustmentNone,
};

@class XZRefreshView, UIRefreshControl, UICollectionView;

/// 在使用 XZRefresh 时，除 target-action 方式外，还可通过此协议接收刷新事件。
/// @note 本协议与 UIScrollViewDelegate 协议使用同一事件接收者，即为 UIScrollView 的属性 delegate 对象。
@protocol XZRefreshDelegate <UIScrollViewDelegate>
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
