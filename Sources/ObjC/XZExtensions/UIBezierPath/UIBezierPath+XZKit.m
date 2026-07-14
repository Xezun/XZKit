//
//  UIBezierPath+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/9/24.
//

#import "UIBezierPath+XZKit.h"

@implementation UIBezierPath (XZKit)

+ (instancetype)xz_bezierPathWithPentacleCenter:(CGPoint)center circumcircle:(CGFloat)outerRadius incircle:(CGFloat)innerRadius {
    UIBezierPath *path = [[self alloc] init];
    
    if (outerRadius <= 0) {
        return path;
    }
    
    CGFloat const cos54 = cos(0.3 * M_PI);
    CGFloat const cos18 = cos(0.1 * M_PI);
    CGFloat const sin54 = sin(0.3 * M_PI);
    CGFloat const sin18 = sin(0.1 * M_PI);
    CGFloat const tan18 = pow(tan(0.1 * M_PI), 2.0);
    
    // 五角星外接圆半径
    CGFloat const r1 = outerRadius;
    // 内接圆半径
    CGFloat const r2 = (innerRadius > 0 ? innerRadius : (r1 * (1 + tan18) / (3 - tan18)));
    
    [path moveToPoint:   CGPointMake(center.x             , center.y - r1        )];
    [path addLineToPoint:CGPointMake(center.x + cos54 * r2, center.y - sin54 * r2)];
    [path addLineToPoint:CGPointMake(center.x + cos18 * r1, center.y - sin18 * r1)];
    [path addLineToPoint:CGPointMake(center.x + cos18 * r2, center.y + sin18 * r2)];
    [path addLineToPoint:CGPointMake(center.x + cos54 * r1, center.y + sin54 * r1)];
    [path addLineToPoint:CGPointMake(center.x,              center.y + r2        )];
    [path addLineToPoint:CGPointMake(center.x - cos54 * r1, center.y + sin54 * r1)];
    [path addLineToPoint:CGPointMake(center.x - cos18 * r2, center.y + sin18 * r2)];
    [path addLineToPoint:CGPointMake(center.x - cos18 * r1, center.y - sin18 * r1)];
    [path addLineToPoint:CGPointMake(center.x - cos54 * r2, center.y - sin54 * r2)];
    [path closePath];
    
    return path;
}

+ (instancetype)xz_bezierPathWithPentacleCenter:(CGPoint)center circumcircle:(CGFloat)outerRadius {
    return [self xz_bezierPathWithPentacleCenter:center circumcircle:outerRadius incircle:0];
}

@end
