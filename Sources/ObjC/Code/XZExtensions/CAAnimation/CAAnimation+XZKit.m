//
//  CAAnimation+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/11/7.
//

#import "CAAnimation+XZKit.h"

@implementation CAAnimation (XZKit)

+ (CAAnimation *)xz_vibrateAnimation { 
    return [self xz_vibrateAnimationWithX:3 y:0 z:0];
}

+ (CAAnimation *)xz_vibrateAnimationWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.values = @[
        [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-x, y, z)],
        [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(+x, y, z)],
        [NSValue valueWithCATransform3D:CATransform3DIdentity]
    ];
    animation.keyTimes = @[@(0.25), @(0.75), @(1.0)];
    animation.timingFunctions = @[
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]
    ];
    animation.repeatCount = 3;
    animation.duration = 0.2;
    animation.removedOnCompletion = YES;
    return (id)animation;
}

@end
