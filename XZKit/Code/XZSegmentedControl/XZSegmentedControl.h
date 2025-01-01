//
//  XZSegmentedControl.h
//  XZSegmentedControl
//
//  Created by M. X. Z. on 2016/10/7.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XZSegmentedControlSegment.h"
#import "XZSegmentedControlIndicator.h"

NS_ASSUME_NONNULL_BEGIN

@class UITableView, UISegmentedControl;

/// 控件中 Segment 的布局方向。
typedef NS_ENUM(NSUInteger, XZSegmentedControlDirection) {
    /// 控件中 segment 在水平方向上布局。
    XZSegmentedControlDirectionHorizontal = 0,
    /// 控件中 segment 在垂直方向上布局。
    XZSegmentedControlDirectionVertical = 1
};

/// 指示器样式。
typedef NS_ENUM(NSUInteger, XZSegmentedControlIndicatorStyle) {
    /// 线形色块指示器。
    /// 1. 横向滚动时，指示器在 segment 底部；
    /// 2. 纵向滚动时，指示器在 segment 右侧。
    XZSegmentedControlIndicatorStyleMarkLine,
    /// 线形色块指示器。
    /// 1. 横向滚动时，指示器在 segment 顶部；
    /// 2. 纵向滚动时，指示器在 segment 左侧。
    XZSegmentedControlIndicatorStyleNoteLine,
    /// 使用自定义指示器。
    XZSegmentedControlIndicatorStyleCustom,
};

@protocol XZSegmentedControlDataSource;
@class UISegmentedControl, UINavigationController;

/// 一种分段的控件，一般用于菜单。
@interface XZSegmentedControl : UIControl

/// 指示器方向。支持在 IB 中设置，使用 0 表示横向，使用 0 表示纵向。
#if TARGET_INTERFACE_BUILDER
@property (nonatomic) IBInspectable NSInteger direction;
#else
@property (nonatomic) XZSegmentedControlDirection direction;
#endif

- (instancetype)initWithFrame:(CGRect)frame direction:(XZSegmentedControlDirection)direction NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

/// 横向时，展示在左侧的视图；纵向时，展示在顶部的视图。
@property (nonatomic, strong, nullable) __kindof UIView *headerView;
/// 横向时，展示在右侧的视图；纵向时，展示在底部的视图。
@property (nonatomic, strong, nullable) __kindof UIView *footerView;

/// item 的大小。优先使用代理方法返回的大小。
/// @discussion 使用 titles 时 item 的大小会根据字体自动计算，此属性将作为最小值使用。
@property (nonatomic) CGSize itemSize;
/// item 间距。
@property (nonatomic) CGFloat interitemSpacing;

/// 指定长宽，若为零，则使用默认值。
/// @li 横向滚动时，宽度默认为 item 的宽度，高度为 3.0 点。
/// @li 纵向滚动时，高度默认为 item 的高度，宽度为 3.0 点。
/// @li 正数表示使用值，负数表示与默认值的差。
@property (nonatomic) CGSize indicatorSize;
/// 指示器样式。
@property (nonatomic) XZSegmentedControlIndicatorStyle indicatorStyle;
/// 使用内置样式时，使用 `.blueColor` 色块作为指示器。
/// @note 设置为 `nil` 表示没有颜色，适合设置图片。
@property (nonatomic, strong, nullable) UIColor *indicatorColor;
/// 使用内置式时，使用图片作为指示器。
/// @note 图片展示受 `indicatorSize` 属性影响。
/// @note 如果设置时 `indicatorSize` 为空，则将 `indicatorImage.size` 设置为 `indicatorSize` 的值。
/// @note 本属性与 `indicatorColor` 是同时生效的，但是可以将 `indicatorColor` 置空。
@property (nonatomic, strong, nullable) UIImage *indicatorImage;
/// 注册自定义的指示器的类，必须是 `XZSegmentedControlIndicator` 的子类。
/// @note
/// 必须先设置 `indicatorStyle` 属性为 `XZSegmentedControlIndicatorStyleCustom` 才能设置此属性。
/// @discussion
/// 自定义指示器，可以通过 `XZSegmentedControlIndicator` 提供的方法实现自定义布局及交互式转场。
@property (nonatomic, null_resettable) Class indicatorClass;

/// 交互式转场时，可通过此方法，通知控件当前的转场进度。
/// @discussion
/// 跨值转场时 `selectedIndex + interactiveTransition` 为趋向转场目标的值。
/// @param interactiveTransition 转场进度
- (void)updateInteractiveTransition:(CGFloat)interactiveTransition;

@property (nonatomic, readonly) NSInteger numberOfSegments;

@property (nonatomic) NSInteger selectedIndex;
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

@property (nonatomic, weak) id<XZSegmentedControlDataSource> dataSource;

/// 当使用数据源时，必须使用此方法更新视图。
/// @note 刷新操作是异步的，如需在视图更新后执行操作，可使用 `reloadData:completion:` 方法。
- (void)reloadData;
- (void)reloadData:(BOOL)animated completion:(void (^_Nullable)(BOOL finished))completion;
- (void)insertSegmentAtIndex:(NSInteger)index;
- (void)removeSegmentAtIndex:(NSInteger)index;

- (nullable __kindof XZSegmentedControlSegment *)segmentForItemAtIndex:(NSInteger)index;

/// 使用 item 标题文本作为数据源。
/// @note 设置此属性，将取消 dataSource 的设置。
/// @note 每个 item 的宽度，将根据字体自动计算，同时受 itemSize 属性约束。
/// @note 设置此属性，并不会立即刷新视图，需要的话，请调用 `-reloadData:completion:` 方法，并在回调中处理。
@property (nonatomic, copy, nullable) NSArray<NSString *> *titles;
- (void)setTitles:(NSArray<NSString *> * _Nullable)titles animated:(BOOL)animated;

/// 普通 item 文本颜色。该属性仅在使用 titles 时生效。
@property (nonatomic, strong, null_resettable) UIColor *titleColor;
/// 被选择的 item 的文本颜色。该属性仅在使用 titles 时生效。
@property (nonatomic, strong, null_resettable) UIColor *selectedTitleColor;
/// 普通 item 文本字体。该属性仅在使用 titles 时生效。
@property (nonatomic, strong, null_resettable) UIFont  *titleFont;
/// 被选中的 item 文本字体。该属性仅在使用 titles 时生效。
@property (nonatomic, strong, null_resettable) UIFont  *selectedTitleFont;

- (void)registerClass:(nullable Class)segmentClass forSegmentWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(nullable UINib *)segmentNib forSegmentWithReuseIdentifier:(NSString *)identifier;
- (__kindof UICollectionViewCell *)dequeueReusableSegmentWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index;

@end


/// 使用自定义视图时的数据源协议。
NS_SWIFT_UI_ACTOR @protocol XZSegmentedControlDataSource <NSObject>
/// 获取 item 的数量。
/// - Parameter segmentedControl: 调用此方法的对象
- (NSInteger)numberOfSegmentsInSegmentedControl:(XZSegmentedControl *)segmentedControl;
/// 数据源应在此方法中返回 item 的自定义视图。
/// - Parameters:
///   - segmentedControl: 调用此方法的对象
///   - index: item 的位置索引
///   - reusingView: 可供重用的视图
- (__kindof UICollectionViewCell *)segmentedControl:(XZSegmentedControl *)segmentedControl segmentForItemAtIndex:(NSInteger)index;
/// 返回 item 的大小。
/// - Parameters:
///   - segmentedControl: 调用此方法的对象
///   - index: item 的位置索引
- (CGSize)segmentedControl:(XZSegmentedControl *)segmentedControl sizeForSegmentAtIndex:(NSInteger)index;
@end






NS_ASSUME_NONNULL_END
