//
//  CALayer+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/9/26.
//

#import "CALayer+XZKit.h"

@implementation CALayer (XZKit)

+ (void)xz_animateWithDuration:(NSTimeInterval)duration animations:(void (^NS_NOESCAPE)(void))animations {
    if (duration <= 0) {
        if ([CATransaction disableActions]) {
            animations();
        } else {
            [CATransaction setDisableActions:YES];
            animations();
            [CATransaction setDisableActions:NO];
        }
    } else {
        NSTimeInterval const oldDuration = [CATransaction animationDuration];
        if ([CATransaction disableActions]) {
            [CATransaction setDisableActions:NO];
            [CATransaction setAnimationDuration:duration];
            animations();
            [CATransaction setAnimationDuration:oldDuration];
            [CATransaction setDisableActions:YES];
        } else {
            [CATransaction setAnimationDuration:duration];
            animations();
            [CATransaction setAnimationDuration:oldDuration];
        }
    }
}

@end
