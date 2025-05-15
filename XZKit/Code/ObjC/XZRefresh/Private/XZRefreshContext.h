//
//  XZRefreshContext.h
//  XZRefresh
//
//  Created by Xezun on 2023/8/12.
//

#import <UIKit/UIKit.h>
#import "XZRefreshView.h"
#import "XZRuntime.h"
#import "XZMacro.h"

NS_ASSUME_NONNULL_BEGIN

@class XZRefreshView;
@protocol XZRefreshDelegate;

typedef NS_ENUM(NSUInteger, XZRefreshMask) {
    /// 包含此掩码的 XZRefreshState 状态，为将 refreshHeight 合并到 .contentInset 中的状态。
    XZRefreshMaskContentInsets = (1 << 8),
    /// 包含此掩码的 XZRefreshState 状态，为 UIScrollView 正在刷新中的状态。
    XZRefreshMaskRefreshing    = (1 << 9)
};

/// 刷新状态枚举，可通过掩码来区分状态。
typedef NS_ENUM(NSUInteger, XZRefreshState) {
    /// 普通状态，非刷新状态。
    ///
    /// 此状态时，UIScrollView 未修改 contentInset 属性。
    ///
    /// 此状态下，不处理 `scrollViewDidScroll:` 事件。
    XZRefreshStatePendinging     = (1 << 1),
    /// 已经开始刷新，但是由于仍然处于手势拖拽状态，尚未调整 UIScrollView 的 contentInset 属性。
    ///
    /// **在拖拽的过程中，改变 contentInset 可能会导致页面抖动。**
    /// 因为在 UIScrollView 的滚动区域内，手势平移的距离，就是页面滚动的距离，但是在弹性区域内，滚动的距离不等于平移的距离，
    /// 所以当 contentInset 改变后，手势平移的距离虽然没有变，但是由滚动区域发生了改变，在弹性区域的滚动距离就发生改变，从而页面滚动距离改变，发生页面抖动。
    /// 但是由于这个变化不是立即触发的，无法在改变后立即修复页面位置，所以无法在用户触摸的过程中调整 contentInset 属性，
    /// 需要在手势结束后，即 `-scrollViewWillEndDragging:` 才能更新 contentInset 属性。
    XZRefreshStateWillRefreshing = (1 << 2) | XZRefreshMaskRefreshing,
    /// 正在刷新。
    /// 为展示刷新视图，调整了 UIScrollView 的 contentInset 属性。
    XZRefreshStateRefreshing     = (1 << 3) | XZRefreshMaskRefreshing | XZRefreshMaskContentInsets,
    /// 正在恢复状态，但是仍在拖拽中，尚未恢复 UIScrollView 的 contentInsets 属性，需要在 willEndDragging 再执行恢复操作。
    XZRefreshStateWillRecovering = (1 << 4) | XZRefreshMaskContentInsets,
    /// 正在复原。刷新已经结束，且恢复了 UIScrollView 的 contentInset 属性，但是页面仍然处于动画，或减速滚动的过程中。
    /// > 结束刷新状态时，如果 UIScrollView 处于拖拽状态，由于修改 contentInset 属性可能会造成页面抖动，所以恢复 contentInset 的操作将在手势结束后。
    /// > 结束刷新的动画过程中，也是此状态。
    XZRefreshStateRecovering     = (1 << 5)
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
    CGRect _frame;
    BOOL _needsAnimatedTransitioning;
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
// 理论上在需要的地方，比如 frameSize/contentSize/adjustedContentInsets 发生改变后，触发布局方法是最经济、最效率的方案。
// 但是由于 Apple 原生逻辑的混乱，在上述这些状态改变后，相应的事件触发时机不固定：
// 1. 当 adjustedContentInset 发生改变后，方法 -scrollViewDidScroll: 先于 -adjustedContentInsetDidChange: 调用。
//    这将导致在 -scrollViewDidScroll: 方法中，由于 context 未更新而不能判断  header/footer 的正确状态。
// 2. 无法向 -layoutSubviews 方法注入代码，即使在 +load 中添加或交换方法实现，被注入的代码不执行。
//    猜测是原生提前获取了 -layoutSubviews 方法的实现，以优化性能，因为在滚动时，方法 layoutSubviews 会一直调用。
// 3. 当视图大小发生改变时，不一定会触发 -scrollViewDidScroll: 方法，所以需要监听 bounds 属性（KVO）。
//    比如从 sb/xib 中初始化的大小和最终大小不一致时，初始以 xib/sb 中预设的大小进行布局，但是在 scrollView 调整
//    到最终大小后，虽然 frame.size/bounds.size 发生了改变，但是并没有触发滚动方法。
//    因为对 bounds.x 进行了依赖，所有监听了 bounds 属性而不是 frame 属性，另外监听 frame 似乎无效。
// 基于以上原因，在  中通过判断以下关键值，实时重新计算 header/footer 布局。

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
