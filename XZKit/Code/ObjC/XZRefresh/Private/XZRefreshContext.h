//
//  XZRefreshContext.h
//  XZRefresh
//
//  Created by Xezun on 2023/8/12.
//

#import <UIKit/UIKit.h>
#import "XZRefreshView.h"

NS_ASSUME_NONNULL_BEGIN

@class XZRefreshView;
@protocol XZRefreshDelegate;

/// 刷新状态
typedef NS_ENUM(NSUInteger, XZRefreshState) {
    /// 正常状态
    XZRefreshStatePendinging,
    /// 正在刷新，但是仍在拖拽中，需要在 willEndDragging 时更新 contentInsets
    XZRefreshStateWillRefreshing,
    /// 正在刷新
    XZRefreshStateRefreshing,
    /// 正在复原，但是仍在拖拽中，需要在 willEndDragging 时更新 contentInsets
    XZRefreshStateWillRecovering,
    /// 正在复原
    XZRefreshStateRecovering
};

/// 记录刷新过程中的环境值，这是一个值对象，不负责任何事件逻辑。
/// 由于 refreshControl 的以下属性，会直接影响到刷新视图的布局，
/// 且在刷新的过程中，XZRefresh 需要根据这些值，来调整动画因此将它们的值缓存下来，
/// 以避免非法的更改，导致布局异常。
@interface XZRefreshContext : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (XZRefreshContext *)headerContextForScrollView:(UIScrollView *)scrollView;
+ (XZRefreshContext *)footerContextForScrollView:(UIScrollView *)scrollView;

@property (nonatomic, strong, nullable) XZRefreshView *view;

@property (nonatomic) XZRefreshState state;

/// 是否需要调整布局的标记。
@property (nonatomic) BOOL needsLayout;

/// 当次下拉/上拉，能否自动进入刷新状态。
/// 每次下拉/上拉开始时设置此值，以保证当次只会进入一次刷新状态。
@property (nonatomic, setter=setAutomatic:) BOOL isAutomatic;
/// 自动刷新的距离。
@property (nonatomic) CGFloat automaticRefreshDistance;

/// 刷新视图的位置和大小。
@property (nonatomic) CGRect frame;
/// 调整 frame 的过程是否需要动画状态。
@property (nonatomic) BOOL needsAnimatedTransitioning;
/// 在 scrollView 自然状态时的 contentOffsetY 值。
/// @discussion 对于 header 表示在头部的自然位置。
/// @discussion 对于 footer 表示在尾部的自然位置。
@property (nonatomic) CGFloat contentOffsetY;


/// 记录布局刷新视图所使用的刷新高度。
@property (nonatomic) CGFloat height;
@property (nonatomic) XZRefreshAdjustment adjustment;
@property (nonatomic) CGFloat offset;

/// 根据当前状态计算后的边距，因此获取此属性时，需先更新上面三个属性。
@property (nonatomic, readonly) UIEdgeInsets layoutInsets;

@end

NS_ASSUME_NONNULL_END
