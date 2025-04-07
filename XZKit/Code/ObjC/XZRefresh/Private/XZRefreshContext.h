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

/// 已将 refreshHeight 合并到 contentInsets 中的状态掩码。
#define XZRefreshStateContentInsets (1 << 8)

/// 刷新状态枚举，可通过掩码来区分状态。
typedef NS_ENUM(NSUInteger, XZRefreshState) {
    /// 普通状态，非刷新状态。
    /// 此状态时，UIScrollView 未修改 contentInset 属性。
    XZRefreshStatePendinging     = (1 << 1),
    /// 正在刷新。
    /// 为展示刷新视图，调整了 UIScrollView 的 contentInset 属性。
    XZRefreshStateRefreshing     = (1 << 2) | XZRefreshStateContentInsets,
    /// 已经开始刷新，但是由于仍然处于手势拖拽状态，尚未调整 UIScrollView 的 contentInset 属性。
    ///
    /// **在拖拽的过程中，改变 contentInset 可能会导致页面抖动。**
    /// 因为在 UIScrollView 的滚动区域内，手势平移的距离，就是页面滚动的距离，但是在弹性区域内，滚动的距离不等于平移的距离，
    /// 所以当 contentInset 改变后，手势平移的距离虽然没有变，但是由滚动区域发生了改变，在弹性区域的滚动距离就发生改变，从而页面滚动距离改变，发生页面抖动。
    /// 但是由于这个变化不是立即触发的，无法在改变后立即修复页面位置，所以无法在用户触摸的过程中调整 contentInset 属性，
    /// 需要在手势结束后，即 `-scrollViewWillEndDragging:` 才能更新 contentInset 属性。
    XZRefreshStateWillRefreshing = (1 << 3) | XZRefreshStateRefreshing,
    /// 正在恢复状态，但是仍在拖拽中，尚未恢复 UIScrollView 的 contentInsets 属性，需要在 willEndDragging 再执行恢复操作。
    XZRefreshStateWillRecovering = (1 << 4) | XZRefreshStateContentInsets,
    /// 正在复原。刷新已经结束，且恢复了 UIScrollView 的 contentInset 属性，但是页面仍然处于动画，或减速滚动的过程中。
    /// > 结束刷新状态时，如果 UIScrollView 处于拖拽状态，由于修改 contentInset 属性可能会造成页面抖动，所以恢复 contentInset 的操作将在手势结束后。
    /// > 结束刷新的动画过程中，也是此状态。
    XZRefreshStateRecovering     = (1 << 5)
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

@end

NS_ASSUME_NONNULL_END
