//
//  CALayer+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/9/26.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (XZKit)

/// 控制隐式动画。
/// @discussion 根据需要设置 CATransaction 的 disableActions/animationDuration 属性，并在执行  animations 后恢复。
/// @param duration 动画时长，如果小于或等于零，则认为关闭隐式动画
/// @param animations 在此块函数设置会产生隐式动画的属性
+ (void)xz_animateWithDuration:(NSTimeInterval)duration animations:(void (^NS_NOESCAPE)(void))animations NS_SWIFT_NAME(animate(withDuration:animations:));

@end

NS_ASSUME_NONNULL_END
