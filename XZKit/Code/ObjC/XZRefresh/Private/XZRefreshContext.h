//
//  XZRefreshContext.h
//  XZRefresh
//
//  Created by Xezun on 2023/8/12.
//

#import <UIKit/UIKit.h>
#import "XZRefreshView.h"
#import "XZRuntime.h"
#import "XZMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class XZRefreshView;
@protocol XZRefreshDelegate;

typedef NS_ENUM(NSUInteger, XZRefreshMask) {
    /// 包含此掩码的 XZRefreshState 状态，表明已将 refreshHeight 合并到 .contentInset 中。
    XZRefreshMaskContentInsets = (1 << 8),
    /// 包含此掩码的 XZRefreshState 状态，表明视图 UIScrollView 正在刷新中。
    XZRefreshMaskRefreshing    = (1 << 9)
};

/// 刷新状态枚举，可通过掩码来区分状态。
typedef NS_ENUM(NSUInteger, XZRefreshState) {
    /// 普通状态，只有处于此状态时，才可进入刷新流程。
    ///
    /// 此状态时，UIScrollView 未修改 contentInset 属性。
    ///
    /// 此状态下，不处理 `scrollViewDidScroll:` 事件。
    XZRefreshStatePendinging                = (1 << 1),
    /// 已经开始刷新，但是由于仍然处于手势拖拽状态，尚未调整 UIScrollView 的 contentInset 属性。
    ///
    /// **在拖拽的过程中，改变 contentInset 可能会导致页面抖动。**
    /// 因为在 UIScrollView 的滚动区域内，手势平移的距离，就是页面滚动的距离，但是在弹性区域内，滚动的距离不等于平移的距离，
    /// 所以当 contentInset 改变后，手势平移的距离虽然没有变，但是由滚动区域发生了改变，在弹性区域的滚动距离就发生改变，从而页面滚动距离改变，发生页面抖动。
    /// 但是由于这个变化不是立即触发的，无法在改变后立即修复页面位置，所以无法在用户触摸的过程中调整 contentInset 属性，
    /// 需要在手势结束后，即 `-scrollViewWillEndDragging:` 才能更新 contentInset 属性。
    XZRefreshStateWillRefreshing            = (1 << 2) | XZRefreshMaskRefreshing,
    /// 正在刷新，但是尚未发送事件给代理，即刷新状态未同步给宿主，只是单方面进入了刷新状态，但已调整 contentInset 属性。
    ///
    /// 如果在进入刷新状态时，立即发送事件，那么：
    /// 1. 如果在事件方法中立即结束刷新，那么会导致结束刷新的“退场动画”丢失。
    ///    这是因为结束刷新动画是 UIView 动画，会立即设置 contentOffset 到目标位置，
    ///    而当前可能处于手势结束、进入减速前的准备状态中，设置 contentOffset 会触发“停止减速”方法，
    ///    而结束刷新，会在“停止减速”执行清理刷新动画的操作。即 -scrollViewDidEndDecelerating: 方法，
    ///    在结束刷新的 UIView 动画 completion 前执行。
    /// 2. 代理事件中，如果立即 reloadData 或调整了 contentSize 的话，处于回弹过程中的 scrollView 可能会出现抖动。
    XZRefreshStateRefreshingDelayedEvents   = (1 << 3) | XZRefreshMaskRefreshing | XZRefreshMaskContentInsets,
    /// 正在刷新，已经发送事件给代理。
    XZRefreshStateRefreshing                = (1 << 4) | XZRefreshMaskRefreshing | XZRefreshMaskContentInsets,
    /// 将要进入复原过程。已经退出刷新，但是仍在拖拽中，尚未恢复 UIScrollView 的 contentInsets 属性，需要在 willEndDragging 再执行恢复操作。
    XZRefreshStateWillRecovering            = (1 << 5) | XZRefreshMaskContentInsets,
    /// 正在复原。刷新已经结束，且恢复了 UIScrollView 的 contentInset 属性，但是页面仍然处于动画，或减速滚动的过程中。
    ///
    /// 处于此状态的过程包括：
    /// - 结束刷新的 UIView 动画过程中。
    /// - 如果 UIScrollView 处于拖拽状态，从结束刷新，到停止减速及滚动。
    ///
    /// 如此处理的原因：
    /// - 在手势的过程中，调整 contentInset 可能会造成页面抖动。
    /// - 在回弹减速的过程中，调整 contentSize 也可能会造成页面抖动。
    ///
    /// 所以将恢复 contentInset 的操作将在手势结束后，且避免在恢复的过程中，产生新的刷新造成页面调整。
    XZRefreshStateRecovering                = (1 << 6)
};

/// 记录刷新过程中的环境值，这是一个值对象，不负责任何事件逻辑。
/// 由于 refreshControl 的以下属性，会直接影响到刷新视图的布局，
/// 且在刷新的过程中，XZRefresh 需要根据这些值，来调整动画因此将它们的值缓存下来，
/// 以避免非法的更改，导致布局异常。
@interface XZRefreshContext : NSObject {
    @package
    XZRefreshView * _Nullable _refreshView;
    XZRefreshState _state;
    BOOL _needsLayout;
    BOOL _isAutomatic;
    CGFloat _automaticRefreshDistance;
    CGRect  _frame;
    CGFloat _contentOffsetY;
    
    // MARK: - 布局时，记录所使用的刷新视图属性
    CGFloat _refreshHeight;
    XZRefreshAdjustment _adjustment;
    CGFloat _offset;
}
- (BOOL)needsLayoutForBounds:(CGRect)bounds;
- (BOOL)needsLayoutForAxises:(UIScrollView *)scrollView;
@end

// 记录布局 header/footer 时所依赖的 UIScrollView 属性值。


@interface XZRefreshHeaderContext : XZRefreshContext {
    @package
    // MARK: - 布局时，记录所使用的滚动视图属性
    CGRect       _bounds;
    UIEdgeInsets _contentInsets;
    UIEdgeInsets _adjustedContentInsets;
}

@end

@interface XZRefreshFooterContext : XZRefreshContext {
    @package
    /// 是否需要跟随页面滚动进入刷新状态。
    ///
    /// 当 footer 进入刷新状态时，如果页面高度不满一屏，那么 footer 需要上移位置才能显示，
    /// 但是处于上拉状态的页面，需要下落恢复正常位置，造成的效果就是 footer 先向上动画，然后再向下动画。
    /// 为了避免这种情况，在进入刷新时，如果此属性为 YES，那么就先保持 footer 位置不变，
    /// 然后在页面下落的过程中，跟随页面滚动调整 footer 直到 footer 回到正确位置。
    BOOL _needsFollowPageScrollWhileRefreshing;
    // MARK: - 记录布局时，所使用的滚动视图属性
    CGRect       _bounds;
    CGSize       _contentSize;
    UIEdgeInsets _contentInsets;
    UIEdgeInsets _adjustedContentInsets;
}
- (BOOL)needsLayoutForContentSize:(CGSize)contentSize;
@end

UIKIT_STATIC_INLINE void UIViewAnimate(BOOL animated, void (^animations)(void), void (^completion)(BOOL finished)) {
    if (animated) {
        [UIView animateWithDuration:XZRefreshAnimationDuration animations:animations completion:completion];
    } else {
        animations();
        dispatch_main_async(completion, NO);
    }
}

UIKIT_STATIC_INLINE UIEdgeInsets UIEdgeInsetsIncreaseBottom(UIEdgeInsets insets, CGFloat bottom) {
    insets.bottom += bottom;
    return insets;
}

UIKIT_STATIC_INLINE UIEdgeInsets UIEdgeInsetsIncreaseTop(UIEdgeInsets insets, CGFloat top) {
    insets.top += top;
    return insets;
}


NS_ASSUME_NONNULL_END
