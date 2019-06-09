//
//  XZCarouselView.h
//  XZCarouselView
//
//  Created by mlibai on 2017/2/13.
//  Copyright © 2017年 mlibai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XZCarouselView;

/// XZCarouselView 数据源协议，定义了作为 XZCarouselView 数据源的对象需要实现的方法。
NS_SWIFT_NAME(CarouselViewDataSource)
@protocol XZCarouselViewDataSource <NSObject>

/// XZCarouselView 通过此方法获取待显示视图的数量。
/// @note 如果视图数量发生改变，需调用 -reloadData 来刷新轮播图。
///
/// @param carouselView 调用此方法的 XZCarouselView 对象。
/// @return XZCarouselView 中视图的数量。
- (NSInteger)numberOfViewsInCarouselView:(XZCarouselView *)carouselView;
/// XZCarouselView 获取指定位置 index 上待显示的视图。
///
/// @note 如果待显示的视图具有不同的大小，请在此方法中设定视图的初始大小，当轮播图大小或 contentMode 改变时，将以此大小为偏好值对视图进行适配。
/// @note 更新已显示视图的偏好大小请使用 `-setPreferredSize:forViewAtIndex:animated:` 方法；但是每次视图重新加载，依然以此方法返回的初始大小为偏好大小。
///
/// @param carouselView 调用此方法的 XZCarouselView 对象。
/// @param index 指定索引位置。
/// @param reusingView 重用的视图。
/// @return 待显示的视图。
- (UIView *)carouselView:(XZCarouselView *)carouselView viewForIndex:(NSInteger)index reusingView:(nullable UIView *)reusingView;

@optional
/// XZCarouselView 是否可以将视图加入重用列表。
///
/// @note 如果此方法不没有实现或返回 YES，那么视图 view 会被加入临时重用池；临时重用池的视图如果没有被重用，则最后会进入永久重用池（属性 reusingModeEnabled 为 YES 时）。
/// @note 可以在此方法中，进行重用的准备工作，如卸载视图内容，释放内存。
/// @note 如果此方法返回 NO，即使 reusingModeEnabled 为 YES，视图也不会加入重用池。
/// @note 自定义重用机制请返回 NO 并在此方法中进行回收视图的操作。
///
/// @param carouselView 调用此方法的 XZCarouselView 对象。
/// @param view 已经从 XZCarouselView 上移除的视图。
/// @param index 视图的 index 。
/// @return 是否能否重用。
- (BOOL)carouselView:(XZCarouselView *)carouselView shouldEnqueueView:(UIView *)view atIndex:(NSInteger)index;

@end


/// XZCarouselView 的事件代理协议。
NS_SWIFT_NAME(CarouselViewDelegate)
@protocol XZCarouselViewDelegate <NSObject>

@optional
/// 视图将要被添加到 XZCarouselView 上。
///
/// @param carouselView 调用此方法的 XZCarouselView 对象。
/// @param view 将要添加的视图。
/// @param index 视图的 index 。
/// @param animated 此方法被调用时，是否处于动画或滚动过程中。
- (void)carouselView:(XZCarouselView *)carouselView willBeginTransitioningView:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated;
/// 视图已被添加到 carouselView 上参与切换过程。
///
/// @param carouselView 调用此方法的 XZCarouselView 对象。
/// @param view 被添加的视图。
/// @param index 视图的 index 。
/// @param animated 此方法被调用时，是否处于动画或滚动过程中。
- (void)carouselView:(XZCarouselView *)carouselView didBeginTransitioningView:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated;
/// 视图将要从 carouselView 上移除。
///
/// @param carouselView 调用此方法的 XZCarouselView 对象。
/// @param view 被移除的视图。
/// @param index 被移除的视图的 index 。
/// @param animated 此方法被调用时，是否处于动画或滚动过程中。
- (void)carouselView:(XZCarouselView *)carouselView willEndTransitioningView:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated;
/// 视图已从 XZCarouselView 上移除。在重用模式下，此方法调用后，视图将被加入重用池。
///
/// @param carouselView 调用此方法的 XZCarouselView 对象。
/// @param view 被移除的视图。
/// @param index 被移除的视图的 index 。
- (void)carouselView:(XZCarouselView *)carouselView didEndTransitioningView:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated;
/// 当 XZCarouselView 发生横向滚动或当前视图发生改变时，此方法会被调用。
/// @note 参数 transition 始终表示是当前视图的位置关系：
///         等于 0 时表示 XZCarouselView 当前正好全部显示的当前视图，其它视图都在 XZCarouselView 有效显示区域外；
///         大于 0 一般表示正向滚动，XZCarouselView 上显示的是当前视图和下一个视图；
///         小于 0 一般表示反向滚动，XZCarouselView 上显示的是当前视图和上一个视图。
/// @note 发生正向滚动，transition 不一定是大于 0，比如使用 setCurrentIndex(_:animated:) 方法，设置一个更大的 newIndex 且第二个参数为 true 时，
///         虽然发生是正向滚动，但是此方法被调用时 transition 参数的值小于 0 。不过，这并不与上面的规则相冲突，而因为对于 newIndex 而言，当前正显示的视图
///         是它的上一个视图。
/// @note 在无限轮播模式下，视图 0 的上一个视图为最后一个视图，最后一个视图的下一个视图为视图 0 。
///
/// @param carouselView 调用此方法的 XZCarouselView 对象。
/// @param transition 当前视图向目标视图过渡进度。
- (void)carouselView:(XZCarouselView *)carouselView didTransition:(CGFloat)transition animated:(BOOL)animated;

/// 当 XZCarouselView 的 currentIndex 发生改变时，此方法会被调用。
/// @note 调用 -setCurrentIndex:animated: 方法不会触发此方法。
/// @note 子视图全部移除，currentIndex 变更为 XZCarouselViewNotFound 时不会调用此方法。
///
/// @param carouselView 调用此方法的 XZCarouselView 对象。
/// @param currentIndex 视图所在的索引。
- (void)carouselView:(XZCarouselView *)carouselView didShowView:(UIView *)currentView atIndex:(NSInteger)currentIndex;

/// XZCarouselView 将要缩放指定的视图。
///
/// @param carouselView 调用此方法的 XZCarouselView 对象。
/// @param index 将要被缩放的视图的索引。
- (void)carouselView:(XZCarouselView *)carouselView willBeginZoomingView:(UIView *)view atIndex:(NSInteger)index;
/// XZCarouselView 缩放了指定的视图。
///
/// @param carouselView 调用此方法的 XZCarouselView 对象。
/// @param index 正在被缩放的视图的索引。
- (void)carouselView:(XZCarouselView *)carouselView didZoomView:(UIView *)view atIndex:(NSInteger)index;
/// XZCarouselView 完成了缩放指定的视图。
///
/// @param carouselView 调用此方法的 XZCarouselView 对象。
/// @param index 被缩放的视图 index 值。
/// @param scale 缩放比。
- (void)carouselView:(XZCarouselView *)carouselView didEndZoomingView:(UIView *)view atIndex:(NSInteger)index atScale:(CGFloat)scale;

@end

@protocol XZCarouselViewTransitioningDelegate;

/// XZCarouselView 中的动画效果的默认时长，0.3 秒。
UIKIT_EXTERN NSTimeInterval const XZCarouselViewAnimationDuration NS_SWIFT_NAME(XZCarouselView.animationDuration);
/// 自定义转场动画限定的时长。
UIKIT_EXTERN NSTimeInterval const XZCarouselViewTransitioningAnimationDuration NS_SWIFT_NAME(XZCarouselView.transitioningAnimationDuration);
/// 当 XZCarouselView 中没有视图时，currentIndex 的取值 -1 。
UIKIT_EXTERN NSInteger const XZCarouselViewNotFound NS_SWIFT_NAME(XZCarouselView.notFound);

/// XZCarouselView 计算内容视图 frame 的函数。
/// @note UIViewContentModeScaleToFill: 拉伸铺满整个显示区域。
/// @note UIViewContentModeScaleAspectFill: 保持宽高比缩放至填充整个视图，视图可能会超出有效显示区域。
/// @note UIViewContentModeCenter: 居中显示，视图可能会超出有效显示区域。
/// @note UIViewContentModeScaleAspectFit: 保持宽高比缩放，使宽或高与有效区域的宽高相等且整个视图在有效区域内，然后居中显示。
/// @note UIViewContentModeRedraw：默认适配模式；该模式下，如果视图的宽高都不超过显示区域的宽高，那么视图按照 UIViewContentModeCenter 模式适配，否则按照 UIViewContentModeScaleAspectFit 模式适配。
/// @note UIViewContentModeTop：按视图实际大小，与可视区域顶边对齐。
/// @note UIViewContentModeBottom：按视图实际大小，与可视区域底边对齐。
/// @note UIViewContentModeLeft：按视图实际大小，与可视区域左边对齐。
/// @note UIViewContentModeRight：按视图实际大小，与可视区域右边对齐。
/// @note UIViewContentModeTopLeft：按视图实际大小，与可视区域顶边和左边对齐。
/// @note UIViewContentModeTopRight：按视图实际大小，与可视区域顶边和右边对齐。
/// @note UIViewContentModeBottomLeft：按视图实际大小，与可视区域下边和左边对齐。
/// @note UIViewContentModeBottomRight：按视图实际大小，与可视区域下边和右边对齐。
/// @note 另外还支持使用 XZCarouselViewExtendingContentMode 函数计算的拓展模式。
UIKIT_EXTERN CGRect XZCarouselViewFittingContentWithMode(CGRect bounds, CGSize contentSize, UIViewContentMode contentMode) NS_SWIFT_NAME(XZCarouselView.fitting(_:contentSize:contentMode:));
/// XZCarouselView 额外支持的 UIViewContentMode 模式的计算方式：1000 * (fitMode + 1) + alignMode 。
/// @note 适配模式 fitMode 包括：ScaleToFill、ScaleAspectFill、ScaleAspectFit、Redraw 。
/// @note 对齐模式 alignMode 包括：Top、Left、Bottom、Right 。
UIKIT_EXTERN UIViewContentMode XZCarouselViewExtendingContentMode(UIViewContentMode fitMode, UIViewContentMode alignMode) NS_SWIFT_NAME(XZCarouselView.extending(_:at:));

@class UIPageViewController;

/// 自动轮播的方向。
typedef NS_ENUM(NSInteger, XZCarouselViewPagingDirection) {
    /// 正向轮播。
    XZCarouselViewPagingDirectionForward = 1,
    /// 反向轮播。
    XZCarouselViewPagingDirectionBackward = -1
} NS_SWIFT_NAME(CarouselView.PagingDirection);

/// 描述轮播视图的布局方向的枚举：水平或垂直。
typedef NS_ENUM(NSInteger, XZCarouselViewPagingOrientation) {
    /// 水平轮播视图。
    XZCarouselViewPagingOrientationHorizontal = 0,
    /// 垂直轮播视图。
    XZCarouselViewPagingOrientationVertical
} NS_SWIFT_NAME(CarouselView.PagingOrientation);

/// XZCarouselView 轮播视图。
/// @note 使用三图轮播机制，并支持缩放功能。
/// @note 支持自动轮播，以及无限轮播（首位相连）。
/// @note 使用代理获取轮播的视图，并且提供了重用机制，降低资源消耗。
/// @note 支持缩放状态记忆功能。
/// @note 为了方便子类或调用方控制视图刷新的时机，XZCarouselView 不会自动执行刷新，即设置了数据源后，需要调用 -reloadData 或 -setCurrentIndex:animated: 才会显示视图。
NS_SWIFT_NAME(CarouselView)
@interface XZCarouselView : UIView <UIScrollViewDelegate>

- (instancetype)initWithFrame:(CGRect)frame pagingOrientation:(XZCarouselViewPagingOrientation)pagingOrientation NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFrame:(CGRect)frame;

/// 水平/垂直滚动的 UIScrollView 对象。
@property (nonatomic, readonly) UIScrollView *scrollView;

/// 当前正在显示的视图的索引。
/// @note 如果没有视图，返回 XZCarouselViewNotFound 。
@property (nonatomic) NSInteger currentIndex;

/// 该属性会影响内容视图的布局。
/// @see 详见 XZCarouselViewFittingContentWithMode()
@property (nonatomic) UIViewContentMode contentMode;

/// 显示指定 newIndex 的视图。
/// @note 调用该方法不会触发 -carouselView:didShowViewAtIndex: 代理事件。
/// @note 该方法不检查 newIndex 的合法性，调用此方法时，务必保证其值正确。
/// @note 该方法总是会立即改变 currentIndex 的值，且会触发 -carouselView:didTransition:animated: 方法。当 animated 为 YES 时，transition 可能是从接近 +1 或 -1 的值开始（取决于当前的滚动方向）。
/// @note 该动画为 UIScrollView.setContentOffset:animated: 动画，时长由 UIScrollView 决定。
///
/// @param newIndex 待显示的视图的索引。
/// @param animated 是否动画切换。
- (void)setCurrentIndex:(NSInteger)newIndex animated:(BOOL)animated;

/// 是否无限轮播。默认 YES 。
/// @note 更改此属性会刷新轮播图。
@property (nonatomic, getter=isWrapped) BOOL wrapped;

/// 事件代理。
@property (nonatomic, weak, nullable) id<XZCarouselViewDelegate> delegate;
/// 数据源代理。
/// @note 更新数据源后，必须调用 reloadData() 或 setCurrentIndex(_:animated:) 方法才能显示视图。
@property (nonatomic, weak, nullable) id<XZCarouselViewDataSource> dataSource;

/// 双击缩放/恢复缩放手势。
/// @note 如果当前视图已经被缩放，则双击手势为恢复默认状态，否则双击手势为放大到双击点到最大缩放比。
/// @note 缩放时，自动轮播会暂停。
@property (strong, nonatomic, readonly) UITapGestureRecognizer *doubleTapGestureRecognizer;
/// 最小缩放倍数，默认 1.0 。
/// @note 该属性总是返回当前正在显示的视图的最小缩放倍数。
@property (nonatomic) CGFloat minimumZoomScale;
/// 最大缩放倍数，默认 1.0 。
/// @note 该属性总是返回当前正在显示的视图的最大缩放倍数。
@property (nonatomic) CGFloat maximumZoomScale;
- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale maximumZoomScale:(CGFloat)maximumZoomScale;
/// 当前缩放倍数。
/// @note 该属性总是返回当前正在显示的视图的缩放倍数。
@property (nonatomic) CGFloat zoomScale;
- (void)setZoomScale:(CGFloat)scale animated:(BOOL)animated;
@property (nonatomic) BOOL bouncesZoom;
/// 是否锁定缩放状态。为 YES 时，如果处于缩放状态，左右滚动禁用。默认 YES 。
@property (nonatomic, getter=isZoomingLockEnabled) BOOL zoomingLockEnabled;
/// 记录缩放状态。在缩放锁关闭时，如果视图在处于缩放状态被切换时，是否记录其缩放状态，默认 false 。
@property (nonatomic) BOOL remembersZoomingState;

/// 自动轮播时间间隔，0 表示不自动轮播。
/// @note 建议时长 3 秒，时长太短，可能影响某些动画效果。
/// @note 缩放或拖拽时，自动轮播会暂停。
@property (nonatomic) NSTimeInterval timeInterval;
/// 自动轮播方向，默认 forward 。
/// @note 无限轮播时，设置此值会影响轮播方向。
/// @note 非无限轮播时，此属性会自动改变，即正向轮播到最后一个就会开始逆向轮播。
@property (nonatomic) XZCarouselViewPagingDirection pagingDirection;
/// 垂直滚动或水平滚动。
/// @note 由于 IB_DESIGNABLE、IBInspectable 体验不好，在 xib 或 storyboard 中，设置 tag 为 -1 表示视图为垂直方向轮播。
@property (nonatomic) XZCarouselViewPagingOrientation pagingOrientation;

/// 刷新视图。当数据源发生改变时，应该调用此方法通知轮播视图。
- (void)reloadData;

/// 是否启用重用机制，即永久重用池，默认 NO 。
/// @note 当数据源代理方法 -carouselView:shouldEnqueueView:atIndex: 实现了且返回 NO 时，视图不会进入重用池；
///       没有实现或返回 YES 时，视图首先进入临时重用池；
///       如果在视图移除的同时也有新的视图要添加，那么临时重用池的视图会被优先重用；
///       临时重用池的视图如果没有被重用，会被加入到永久重用池。
/// @note 不论此属性为何值，临时重用池始终存在，且只受数据源代理方法影响；永久重用池则可以将已移除但是可以重用的视图保存起来，再次展示新视图时拿出来以供重用（如果没有重用，不会从重用池移除）。
/// @note 默认提供的重用池适合单一类型视图的重用，多种类型视图的重用需要自行实现。
@property (nonatomic, getter=isReusingModeEnabled) BOOL reusingModeEnabled;

/// 当前所显示的视图数量。
@property (nonatomic, readonly) NSInteger numberOfViews;

/// 获取指定 index 的视图。如果视图没有加载到轮播图上，返回 nil 。
///
/// @param index 视图的 index 。
/// @return 视图。
- (nullable UIView *)viewForIndex:(NSInteger)index;

/// 重新设置指定视图的偏好大小，仅当前生效。
/// @note 轮播图会优化视图的显示：居中显示，且大小不会超过 XZCarouselView，也不会不超过其偏好大小。
/// @note 在默认情况下，视图的初始大小为其偏好的大小。
/// @note 如果指定的视图当前未显示，则调用此方法无效，且当视图刷新时，偏好大小仍然以数据源给定的为准。
///
/// @param preferredSize 视图的偏好大小。
/// @param index 指定的位置。
/// @param animated 是否动画效果。
- (void)setPreferredSize:(CGSize)preferredSize forViewAtIndex:(NSInteger)index animated:(BOOL)animated;

/// 过渡动画，时长固定 7.0 秒，包括四个有效的动画区间。
///
/// @note 区间 0.0 ~ 1.0 为 currentIndex 增加，当前视图隐藏的动画过程。
/// @note 区间 2.0 ~ 3.0 为 currentIndex 减小，当前视图隐藏的动画过程。
/// @note 区间 4.0 ~ 5.0 为 currentIndex 增加，下一个视图入场的动画过程。
/// @note 区间 6.0 ~ 7.0 为 currentIndex 减小，上一个视图入场的动画过程。
/// @note 其它区间为动画过渡区间，无实际效果。
///
/// @code
/// // Swift 代码。自定义转场效果，使轮播图的过渡效果类似于导航控制的 Push/Pop 效果。
/// let width = UIScreen.main.bounds.width
/// let transitionAnimation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.transform));
/// transitionAnimation.values = [
///     CATransform3DIdentity, CATransform3DMakeTranslation(+width, 0, 0),
///     CATransform3DIdentity, CATransform3DMakeTranslation(-width, 0, 0),
///     CATransform3DMakeTranslation(-width, 0, 0), CATransform3DIdentity,
///     CATransform3DMakeTranslation(+width, 0, 0), CATransform3DIdentity
/// ]
/// carouselView.transitionAnimation = transitionAnimation
/// carouselView.hierarchy = .navigation
/// @endcode
@property (nonatomic, strong, nullable) CAAnimation *transitioningAnimation;
/// 转场代理，如果设置了此属性，transitioningAnimation 设置的转场动画将被忽略。
@property (nonatomic, weak) id<XZCarouselViewTransitioningDelegate> transitioningDelegate;

/// 保持当前视图的上一个视图和下一个视图始终显示状态，默认 NO 。
/// @note 在默认情况下，非切换状态 XZCarouselView 只显示当前视图，设置此属性为 YES 会保持左右视图保持显示状态。
/// @note 如果此属性为 YES ，那么在切换时 XZCarouselView 上最多显示 4 个视图（当前视图、目标视图以及它们的左右视图）；如果为 NO 则只显示当前视图和目标视图。
@property (nonatomic) BOOL keepsTransitioningViews;
/// 视图左右之间的距离。
@property (nonatomic) CGFloat interitemSpacing;

/// 轮播视图大小改变时，同时优化调整所有内容视图。
- (void)layoutSubviews NS_REQUIRES_SUPER;
/// 当视图从 window 上移除时，自动轮播会暂停，如果再次添加会自动恢复。
/// 当添加到 window 上时，会尝试恢复自动轮播。
- (void)didMoveToWindow NS_REQUIRES_SUPER;

// 已实现的 UIScrollViewDelegate 方法。
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView NS_REQUIRES_SUPER;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate NS_REQUIRES_SUPER;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView NS_REQUIRES_SUPER;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView NS_REQUIRES_SUPER;
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView NS_REQUIRES_SUPER;

@end

/// 描述轮播视图子视图的层级关系。
typedef NS_ENUM(NSInteger, XZCarouselViewTransitionViewHierarchy) {
    /// 当前视图 zIndex 大于左右视图，默认。
    XZCarouselViewTransitionViewHierarchyCarousel,
    /// 当前视图 zIndex 小于左右视图。
    XZCarouselViewTransitionViewHierarchyInvertedCarousel,
    /// 视图 zIndex 按前中后视图依次降低，跟书一样，页数越小的在上面。
    XZCarouselViewTransitionViewHierarchyPageCurl,
    /// 视图 zIndex 按左中右视图依次升高，类似导航栈。
    XZCarouselViewTransitionViewHierarchyNavigation
} NS_SWIFT_NAME(CarouselView.TransitionViewHierarchy);

@interface XZCarouselView (XZCarouselViewContextTransitioning)

/// 子视图层级关系。轮播图的子视图并不在相同的直接父视图上，可以通过此属性可以改变子视图的层级关系，来适配自定义过渡动画效果。
/// @note 层级关系可能会被 XZCarouselViewContextTransitioning 方法改变，此属性反映只是通过此属性最后设置的层级关系。
@property (nonatomic) XZCarouselViewTransitionViewHierarchy transitionViewHierarchy;

/// The view at currentIndex - 2, no animations.
@property (nonatomic, readonly, nullable) UIView *backwardSupplementaryView;
/// The view at currentIndex - 1.
@property (nonatomic, readonly) UIView *backwardTransitioningView;
/// The view at currentIndex.
@property (nonatomic, readonly) UIView *transitioningView;
/// The view at currentIndex + 1.
@property (nonatomic, readonly) UIView *forwardTransitioningView;
/// The view at currentIndex + 2, no animations.
@property (nonatomic, readonly, nullable) UIView *forwardSupplementaryView;

// Use the following methods to change the transition views's hierarchy.

- (void)bringTransitionViewToFront:(UIView *)transitionView;
- (void)sendTransitionViewToBack:(UIView *)transitionView;
- (void)insertTransitionView:(UIView *)transitionView1 belowTransitionView:(UIView *)transitionView2;
- (void)insertTransitionView:(UIView *)transitionView1 aboveTransitionView:(UIView *)transitionView2;

@end

@protocol UIViewControllerAnimatedTransitioning;
@protocol UIViewControllerTransitioningDelegate;

NS_SWIFT_NAME(CarouselViewTransitioningDelegate)
@protocol XZCarouselViewTransitioningDelegate <NSObject>

/// 当转场开始时，通过此方法为 transitioningView 添加动画。
///
/// @note 当 currentIndex 增加，transitioningView 隐藏的动画时间段为 0.0 ~ 1.0 。
/// @note 当 currentIndex 减小，transitioningView 隐藏的动画时间段为 2.0 ~ 3.0 。
/// @note 当 currentIndex 增加，forwardTransitioningView 入场的动画时间段为 4.0 ~ 5.0 。
/// @note 当 currentIndex 减小，backwardTransitioningView 入场的动画时间段为 6.0 ~ 7.0 。
///
/// @note 只能使用 CAAnimation 动画。
///
/// @param carouselView 调用此方法的 XZCarouselView 对象。
/// @param isInteractive 该转场是否是由为交互式的。
- (void)carouselView:(XZCarouselView *)carouselView beginTransitioning:(BOOL)isInteractive;

/// 当转场结束时，此方法会被调用，在此方法中移除已添的转场动画。
/// @note 如果转场动画将 transitionView 添加到别的视图上，那么此方法触发前，会将其放回原始父视图上；
///       如果转场动画改变了 frame、transform 等属性，也应该此方法中恢复。
///
/// @param carouselView 调用此方法的 XZCarouselView 对象。
/// @param transitionCompleted 转场是否完成。
- (void)carouselView:(XZCarouselView *)carouselView endTransitioning:(BOOL)transitionCompleted;

@end

NS_ASSUME_NONNULL_END
