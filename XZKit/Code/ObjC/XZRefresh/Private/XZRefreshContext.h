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
    /// 普通状态，非刷新状态
    XZRefreshStatePendinging,
    /// 已经开始刷新，但是由于仍然处于手势拖拽状态，尚未调整 contentInset 值。
    /// > 在拖拽的过程中，更新 contentInset 会造成页面抖动，所以需要在手势结束时（willEndDragging）才能更新 contentInset
    XZRefreshStateWillRefreshing,
    /// 正在刷新。
    XZRefreshStateRefreshing,
    /// 正在恢复状态，但是仍在拖拽中，需要在 willEndDragging 时更新 contentInsets
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

@property (nonatomic, strong, nullable) XZRefreshView *refreshView;

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
/// 自然状态下 UIScrollView 在头部或尾部时的 contentOffsetY 值。
/// - 对于 header 表示 UIScrollView 在头部的自然位置。
/// - 对于 footer 表示 UIScrollView 在尾部的自然位置。
@property (nonatomic) CGFloat contentOffsetY;


/// 刷新视图布局依赖的必须属性：刷新视图刷新时的高度。
@property (nonatomic) CGFloat refreshHeight;
/// 刷新视图布局依赖的必须属性：刷新视图适配边距的方式。
@property (nonatomic) XZRefreshAdjustment adjustment;
/// 刷新视图布局依赖的必须属性：刷新视图相对正常位置的偏移。
@property (nonatomic) CGFloat offset;

/// 根据 refreshHeight、adjustment、offset 的当前值，计算刷新视图布局所用的边距值。
/// > 读取此属性，必须先更新上述所依赖的三个刷新，保证在读取属性时，上述三个属性的值是期望的值。
@property (nonatomic, readonly) UIEdgeInsets layoutInsets;

@end

NS_ASSUME_NONNULL_END
