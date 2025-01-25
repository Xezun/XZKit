//
//  CAAnimation+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/11/7.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CAAnimation (XZKit)

/// 抖动动画。
@property (class, nonatomic, readonly) CAAnimation *xz_vibrateAnimation NS_SWIFT_NAME(vibration);

/// 抖动动画。效果为 transform 动画，默认抖动三次，单次抖动 0.2 秒，动画结束自动移除。
/// @param x 水平方向的抖动幅度
/// @param y 垂直方向的抖动幅度
/// @param z 前后方向的抖动幅度
+ (CAAnimation *)xz_vibrateAnimationWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z NS_SWIFT_NAME(vibration(x:y:z:));

@end


NS_ASSUME_NONNULL_END
