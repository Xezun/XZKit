//
//  XZSegmentIndicatorView.h
//  XZSegmentedControl
//
//  Created by Xezun on 2024/7/9.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZSegmentedControlDefines.h>
#else
#import "XZSegmentedControlDefines.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class XZSegmentedControl, XZSegmentIndicatorLayoutAttributes;

NS_SWIFT_UI_ACTOR
NS_SWIFT_NAME(XZSegmentedControl.Layout)
@interface XZSegmentLayout : UICollectionViewFlowLayout
- (instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSegmentAtIndex:(NSInteger)index;
@end

/// 指示器视图基类
NS_SWIFT_NAME(XZSegmentedControl.IndicatorView)
@interface XZSegmentIndicatorView : UICollectionReusableView

/// 是否支持交互式转场，默认否。
@property (class, nonatomic, readonly) BOOL supportsInteractiveTransition;

/// 自定义指示器，可以通过此方法实时调整指示器的布局。此方法默认不执行任何操作。
/// 
/// 1. 默认情况下，当控件的 `selectedIndex` 发生改变时，将调用此方法刷新指示器的布局。
/// 2. 当类属性 `supportsInteractiveTransition` 返回 YES 时，此方法会在转场进度发生改变时同步调用，通过参数 `layoutAttributes` 的 `interactiveTransition` 属性获取进度值。
/// 3. 值 `interactiveTransition` 的正负，对应转场向前向后，转场的目标为 `selectedIndex + interactiveTransition` 趋向的值。
/// 4. 通过 `zIndex` 可以改变指示器视图的层级位置，请在此方法中处理，在 `-preferredLayoutAttributesFittingAttributes:` 方法中无效，因为这个方法的参数为复制份，值不会同步到原始对象。
/// 5. 计算 indicator 的布局，应该通过 `layout` 可以获取 segment 的布局信息，而不能使用如下方法来获取。
/// 
/// 不能在此方法中使用`-[UICollectionView layoutAttributesForItemAtIndexPath:]`方法获取布局信息，因为这个方法会强制 `layout` 立即计算布局，也包括 indicator 的布局，在控制台产生错误警告。
/// 
/// ```objc
/// // ❌ not do this
/// [_collectionView layoutAttributesForItemAtIndexPath:indexPath];
/// ```
/// 
/// > An attempt to prepare a layout while a prepareLayout call was already in progress (i.e. reentrant call) has been ignored.
/// 
/// - Parameters:
///   - segmentedControl: 指示器实例所属的控件
///   - layout: 负责布局的对象
///   - layoutAttributes: 指示器的布局信息
+ (void)segmentedControl:(XZSegmentedControl *)segmentedControl layout:(XZSegmentLayout *)layout prepareForLayoutAttributes:(XZSegmentIndicatorLayoutAttributes *)layoutAttributes NS_SWIFT_NAME(segmentedControl(_:layout:prepareForLayoutAttributes:));

- (void)willShowInSegmentedControl:(XZSegmentedControl *)segmentedControl;

@end

/// 指示器的外观及布局信息。
NS_SWIFT_NAME(XZSegmentedControl.IndicatorLayoutAttributes)
@interface XZSegmentIndicatorLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, strong, nullable, XZ_READONLY) UIColor *color;
@property (nonatomic, strong, nullable, XZ_READONLY) UIImage *image;
@property (nonatomic, XZ_READONLY) CGFloat interactiveTransition;

@property (nonatomic, XZ_READONLY) BOOL animated;

///
/// 在未修改 UICollectionViewLayoutAttributes 的核心属性，例如 frame 或 size 的情况下，
/// 不管是 invalidateIndicaotrLayout 还是 invalidateLayout 都无法重载视图，导致无法应用
/// color 或 image 等样式，无法更新指示器，因此需要指示器视图在 `-applyLayoutAttributes:` 方法中填充此属性。
///
/// 在 -setSelectedIndex:animated: 方法中，无法直接添加动画，也需要此属性执行动画。
@property (nonatomic, weak, XZ_READONLY) XZSegmentIndicatorView *indicatorView;
@end

NS_ASSUME_NONNULL_END
