//
//  XZSegmentDefines.h
//  XZSegmentedControl
//
//  Created by Xezun on 2024/7/18.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMacros.h>
#else
#import "XZMacros.h"
#endif


/// 控件中 Segment 的布局方向。
typedef NS_ENUM(NSUInteger, XZSegmentOrientation) {
    /// 控件中 segment 在水平方向上布局。
    XZSegmentOrientationHorizontal = UICollectionViewScrollDirectionHorizontal,
    /// 控件中 segment 在垂直方向上布局。
    XZSegmentOrientationVertical = UICollectionViewScrollDirectionVertical
} NS_SWIFT_NAME(XZSegmentedControl.Orientation);

/// 指示器样式。
typedef NS_ENUM(NSUInteger, XZSegmentIndicatorStyle) {
    /// 线形色块指示器。
    /// 1. 横向滚动时，指示器在 segment 底部；
    /// 2. 纵向滚动时，指示器在 segment 右侧。
    XZSegmentIndicatorStyleMarkLine,
    /// 线形色块指示器。
    /// 1. 横向滚动时，指示器在 segment 顶部；
    /// 2. 纵向滚动时，指示器在 segment 左侧。
    XZSegmentIndicatorStyleNoteLine,
    /// 使用自定义指示器。
    XZSegmentIndicatorStyleCustom,
} NS_SWIFT_NAME(XZSegmentedControl.IndicatorStyle);

@protocol XZSegmentDataSource;
@class UISegmentedControl, UIPageViewController;
