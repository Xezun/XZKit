//
//  XZPageViewContext.h
//  XZPageView
//
//  Created by Xezun on 2024/9/24.
//

#import <Foundation/Foundation.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZPageViewDefines.h>
#else
#import "XZPageViewDefines.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// 计算 index 自增或子减后的值。
/// 非循环模式时，不能增加或减小返回 NSNotFound 循环模式时最大值自增返回最小值，最小值自减返回最大值。
/// @param index 当前值
/// @param increases YES自增，NO自减
/// @param max 最大值
/// @param isLooped 循环模式
UIKIT_STATIC_INLINE NSInteger XZLoopPage(NSInteger index, BOOL increases, NSInteger max, BOOL isLooped) {
    if (max <= 0) {
        return NSNotFound;
    }
    if (isLooped) {
        return (increases ? ((index >= max) ? 0 : (index + 1)) : ((index <= 0) ? max : (index - 1)));
    }
    return (increases ? ((index == max) ? NSNotFound : (index + 1)) : ((index == 0) ? NSNotFound : (index - 1)));
}

/// 判断 from => to 变化的应该执行的滚动方向，YES正向，NO反向。
/// @discussion 非循环模式，或者数量2个以下，`from < to` 正向。
/// @discussion 循环模式，且数量大于2个，`from < to` 或 `max => min` 正向。
UIKIT_STATIC_INLINE BOOL XZScrollDirection(NSInteger from, NSInteger to, NSInteger max, BOOL isLooped) {
    return (!isLooped || max < 2) ? (from < to) : ( (from == max && to == 0) || ((from < to) && !(from == 0 && to == max)) );
}

/// 交换两个变量的值
#define XZExchangeValue(var_1, var_2)   { typeof(var_1) temp = var_1; var_1 = var_2; var_2 = temp; }
#define XZCallBlock(block, ...)         if (block != nil) { block(__VA_ARGS__); }

/// 由于属性 isDragging/isDecelerating 的更新在 contentOffset/bounds.origin 更新之后，
/// 所以在无法判断 contentOffset/bounds.origin 变化时的滚动状态，继而无法判断翻页状态。
/// 因此 XZPageView 监听了代理方法来解决相关问题：
/// 默认 delegate 会被设置为自身；如果外部设置代理，则会通过运行时，向目标注入处理事件的逻辑。
@interface XZPageViewContext : NSObject <UIScrollViewDelegate> {
    @package
    XZPageView * __unsafe_unretained _view;
}

- (instancetype)init NS_UNAVAILABLE;
+ (XZPageViewContext *)contextForView:(XZPageView *)pageView orientation:(XZPageViewOrientation)orientation;

@property (nonatomic, readonly) XZPageViewOrientation orientation;

// 以下方法作为 XZPageView 的私有方法，子类不应重写它们。

- (void)layoutSubviews:(CGRect const)bounds;

/// 启动自动翻页计时器。
/// @discussion 1、若不满足启动条件，则销毁当前计时器；
/// @discussion 2、满足条件，若计时器已开始，则重置当前开始计时；
/// @discussion 3、满足条件，若计时器没创建，则自动创建。
- (void)scheduleAutoPagingTimerIfNeeded;
/// 倒计时事件。
/// @param timer 定时器
- (void)autoPagingTimerAction:(NSTimer *)timer;
/// 暂停自动翻页计时器。
- (void)suspendAutoPagingTimer;
/// 重置自动翻页计时器。
- (void)restartAutoPagingTimer;
        
/// 处理 aClass 使之可以作为代理对象。
- (void)handleDelegateOfClass:(nonnull Class)aClass;

// 调用代理方法

- (UIView *)viewForPageAtIndex:(NSInteger)index reusingView:(nullable UIView *)reusingView;
- (BOOL)shouldReuseView:(UIView *)reusingView;

- (void)willShowView:(UIView *)view animated:(BOOL)animated;
- (void)didShowView:(UIView *)view animated:(BOOL)animated;
- (void)willHideView:(UIView *)view animated:(BOOL)animated;
- (void)didHideView:(UIView *)view animated:(BOOL)animated;

- (void)didShowPageAtIndex:(NSInteger)index;

// 子类需要重写的方法。

/// 布局当前视图。
- (void)layoutCurrentView:(CGRect const)bounds;
/// 布局待显视图。
- (void)layoutPendingView:(CGRect const)bounds;
/// 适配调整边距。
- (void)adaptContentInset:(CGRect const)bounds;

- (void)didScroll:(BOOL)stopped;
/// 滚动到待显视图：待显视图变为当前视图。
/// 这个方法不需要重写。
- (void)didScrollToPendingPage:(CGRect const)bounds maxPage:(NSInteger const)maxPage direction:(BOOL const)direction;

/// 不处理、发送事件。
- (void)setCurrentPage:(NSInteger)newPage animated:(BOOL)animated;

@end

@interface XZPageViewVerticalContext : XZPageViewContext
@end

NS_ASSUME_NONNULL_END
