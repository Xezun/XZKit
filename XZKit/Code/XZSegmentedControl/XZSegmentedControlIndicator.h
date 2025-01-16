//
//  XZSegmentedControlIndicator.h
//  XZSegmentedControl
//
//  Created by Xezun on 2024/7/9.
//

#import <UIKit/UIKit.h>
#import "XZSegmentedControlDefines.h"

NS_ASSUME_NONNULL_BEGIN

@class XZSegmentedControl, XZSegmentedControlIndicatorLayoutAttributes;

NS_SWIFT_UI_ACTOR
@protocol XZSegmentedControlLayout <NSObject>
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndex:(NSInteger)index;
@end

typedef UICollectionViewLayout<XZSegmentedControlLayout> *XZSegmentedControlLayout;

/// 指示器视图基类
@interface XZSegmentedControlIndicator : UICollectionReusableView

/// 是否支持交互式转场，默认否。
@property (class, nonatomic, readonly) BOOL supportsInteractiveTransition;

/// 自定义指示器，可以通过此方法实时调整指示器的布局。此方法默认不执行任何操作。
/// @discussion
/// 1、默认情况下，当控件的 `selectedIndex` 发生改变时，将调用此方法刷新指示器的布局。
/// @discussion
/// 2、当类属性 `supportsInteractiveTransition` 返回 YES 时，此方法会在转场进度发生改变时同步调用，通过参数 `layoutAttributes` 的 `interactiveTransition` 属性获取进度值。
/// @discussion
/// 3、值 `interactiveTransition` 的正负，对应转场向前向后，转场的目标为 `selectedIndex + interactiveTransition` 趋向的值。
/// @discussion
/// 4、通过 `zIndex` 可以改变指示器视图的层级位置，请在此方法中处理，在 `-preferredLayoutAttributesFittingAttributes:` 方法中无效，因为这个方法的参数为复制份，值不会同步到原始对象。
/// @note
/// 5、计算 indicator 的布局，应该通过 `layout` 可以获取 segment 的布局信息，而不能使用如下方法来获取。
/// @code
/// // not do this
/// [_collectionView layoutAttributesForItemAtIndexPath:indexPath];
/// @endcode
/// 因为该方法，会强制 `layout` 立即计算布局，而 `layout` 在计算布局时，也会计算 indicator 布局，所以如果调用该方法，就会在 `layout` 计算布局时，触发强制计算布局，在控制台产生错误警告。
/// @discussion
/// An attempt to prepare a layout while a prepareLayout call was already in progress (i.e. reentrant call) has been ignored.
///
/// @param segmentedControl 指示器实例所属的控件
/// @param layout 负责布局的对象
/// @param layoutAttributes 指示器的布局信息
+ (void)segmentedControl:(XZSegmentedControl *)segmentedControl layout:(XZSegmentedControlLayout)layout prepareForLayoutAttributes:(XZSegmentedControlIndicatorLayoutAttributes *)layoutAttributes NS_SWIFT_NAME(segmentedControl(_:layout:prepareForLayoutAttributes:));

/// 非交互式的转场时，原生为指示器布局变化只有一个淡出淡入的过渡效果，所以组件提供此方法，为指示器应用新布局前，提供了一个自定义转场动画的机会。
/// @discussion
/// 此动画效果应用于，用户点击 segment 或方法 `-setSelectedIndex:animated:` 被调用时。
/// @discussion
/// 默认情况下，该方法默认仅执行了一个平移动画，代码如下。
/// @code
/// [UIView animateWithDuration:0.35 animations:^{
///     self.frame = layoutAttributes.frame;
/// }];
/// @endcode
/// @discussion
/// 一般情况下，子类重写此方法，不需要调用父类实现。
/// @param layoutAttributes 指示器布局信息。
- (void)animateTransition:(XZSegmentedControlIndicatorLayoutAttributes *)layoutAttributes;

/// 在此方法中，设置了 layoutAttributes 的 indicatorView 属性为当前视图。
/// @param layoutAttributes 指示器布局信息。
- (void)applyLayoutAttributes:(XZSegmentedControlIndicatorLayoutAttributes *)layoutAttributes NS_REQUIRES_SUPER;

@end



/// 指示器的外观及布局信息。
@interface XZSegmentedControlIndicatorLayoutAttributes : UICollectionViewLayoutAttributes
@property (nonatomic, strong, nullable, XZ_SEGMENTEDCONTROL_READONLY) UIColor *color;
@property (nonatomic, strong, nullable, XZ_SEGMENTEDCONTROL_READONLY) UIImage *image;
@property (nonatomic, XZ_SEGMENTEDCONTROL_READONLY) CGFloat interactiveTransition;
/// 在未修改 UICollectionViewLayoutAttributes 的核心属性，例如 frame 或 size 的情况下，
/// 不管是 invalidateIndicaotrLayout 还是 invalidateLayout 都无法重载视图，导致无法应用
/// color 或 image 等样式，无法更新指示器，因此需要指示器视图在 `-applyLayoutAttributes:` 方法中填充此属性。
///
/// 在 -setSelectedIndex:animated: 方法中，无法直接添加动画，也需要此属性执行动画。
@property (nonatomic, weak, XZ_SEGMENTEDCONTROL_READONLY) XZSegmentedControlIndicator *indicatorView;
@end

NS_ASSUME_NONNULL_END
