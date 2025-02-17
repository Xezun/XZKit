//
//  XZPageView.h
//  XZKit
//
//  Created by Xezun on 2021/9/7.
//

#import <UIKit/UIKit.h>
#import "XZPageViewDefines.h"

NS_ASSUME_NONNULL_BEGIN

/// 翻页视图：支持多视图横向滚动翻页的视图。
@interface XZPageView : UIScrollView

/// 指定初始化构造方法。
/// - Parameters:
///   - frame: 视图大小和位置
///   - orientation: 翻页方向
- (instancetype)initWithFrame:(CGRect)frame orientation:(XZPageViewOrientation)orientation NS_DESIGNATED_INITIALIZER;

/// 支持在 IB 中使用。
/// - Parameter coder: NSCoder 对象
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

// MARK: - 重写父类的方法
- (void)didMoveToWindow NS_REQUIRES_SUPER;

/// 翻页方向，默认横向。
/// @note
/// 在 IB 中，可通过 `User Defined Runtime Attributes` 设置 0 表示横向，设置 1 表示纵向。
/// @discussion
/// Xcode 16 取消了 `\@IBDesignable` 标记，不能使用宏 `TARGET_INTERFACE_BUILDER` 进行条件编译，无法为枚举属性添加 IBInspectable 标记。
@property (nonatomic) XZPageViewOrientation orientation;

/// 是否为循环模式。默认 YES 。
/// @discussion 循环模式下，不管在任何位置都可以向前或者向后翻页。
/// @discussion 在最大页向后翻页会到第一页，在第一页向前翻页则会到最后一页。
@property (nonatomic, setter=setLooped:) BOOL isLooped;

/// 自动翻到下一页的时间间隔，单位秒，不包括翻页动画时长。
@property (nonatomic) NSTimeInterval autoPagingInterval;

/// 页面的数量。
@property (nonatomic, readonly) NSInteger numberOfPages;

/// 当前页面。
/// @note 值 NSNotFound 表示当前没有内容。
/// @attention 设置此属性不会触发代理方法。
@property (nonatomic) NSInteger currentPage;

/// 设置当前展示视图。
/// @discussion 调用此方法改变当前页，会重置自动翻页计时。
/// @discussion 调用此方法不会触发代理事件。
/// @discussion 翻页动画时长 XZPageViewAnimationDuration 为 0.35 秒，与原生控制器转场时长相同。
/// @discussion 动画时长，可以通过如下方式覆盖。
/// @code
/// [UIView animateWithDuration:1.0 animations:^{
///     [self.pageView setCurrentPage:3 animated:YES];
/// }];
/// @endcode
/// @param currentPage 待展示的视图的索引
/// @param animated 是否动画
- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated;

/// 事件代理。
@property (nonatomic, weak) id<XZPageViewDelegate> delegate;
/// 数据源。
@property (nonatomic, weak) id<XZPageViewDataSource> dataSource;

/// 重新加载。
/// @discussion
/// 当前页数 currentPage 可能会发生改变，以适配新的数据，但是不会发送事件。
/// @discussion
/// 自动翻页计时会重置。
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
