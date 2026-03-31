//
//  XZPageControlIndicatorView.h
//  XZPageControl
//
//  Created by Xezun on 2024/6/10.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZPageControlDefines.h>
#else
#import "XZPageControlDefines.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// 默认指示器样式实现，支持图片和形状路径。
@interface XZPageControlIndicatorView : UIView <XZPageControlIndicator>
@end

NS_ASSUME_NONNULL_END
