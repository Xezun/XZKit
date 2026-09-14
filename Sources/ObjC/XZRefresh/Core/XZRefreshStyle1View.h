//
//  XZRefreshStyle1View.h
//  XZRefresh
//
//  Created by Xezun on 2019/10/12.
//  Copyright © 2019 Xezun. All rights reserved.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZRefreshView.h>
#else
#import "XZRefreshView.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class UIActivityIndicatorView;

/// 环形的刷新动画。
@interface XZRefreshStyle1View : XZRefreshView

/// 动画进度条的颜色，默认与 tintColor 一致。
@property (nonatomic, strong, null_resettable) UIColor *color;

/// 动画进度条的背景色。
@property (nonatomic, strong, null_resettable) UIColor *trackColor;

/// 动画速度：旋转一圈的时间，默认 0.6 秒。
@property (nonatomic) CGFloat animationDuration;

@end

NS_ASSUME_NONNULL_END
