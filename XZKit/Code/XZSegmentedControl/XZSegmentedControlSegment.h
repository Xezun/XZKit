//
//  XZSegmentedControlSegment.h
//  XZSegmentedControl
//
//  Created by Xezun on 2024/7/15.
//

#import <UIKit/UIKit.h>
#import "XZSegmentedControlDefines.h"

NS_ASSUME_NONNULL_BEGIN

@class XZSegmentedControl;

/// 分段视图基类。
@interface XZSegmentedControlSegment : UICollectionViewCell

/// 交互式转场通知转场进度。
/// @discussion
/// 进度值范围为 [0, 1] 之间，其中 0 表示未选中，值 1 表示已选中。
/// @discussion
/// 因为 indicator 的转场与目标 segment 相关，所以此属性与指示器的 interactiveTransition 值不一定相同，
/// @discussion
/// 默认该方法不执行任何操作。
/// @param interactiveTransition 转场进度
- (void)updateInteractiveTransition:(CGFloat)interactiveTransition;

@end

NS_ASSUME_NONNULL_END
