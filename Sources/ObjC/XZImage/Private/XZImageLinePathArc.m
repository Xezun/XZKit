//
//  XZImageLinePathArc.m
//  XZKit
//
//  Created by Xezun on 2021/2/19.
//

#import "XZImageLinePathArc.h"

@implementation XZImageLinePathArc

- (void)drawInContext:(CGContextRef)context {
    // CG 的坐标系 顺时针方向 跟 UI 是反的
    CGContextAddArc(context, _center.x, _center.y, _radius, _startAngle, _endAngle, NO);
}

- (void)addToPath:(UIBezierPath *)path {
    [path addArcWithCenter:_center radius:_radius startAngle:_startAngle endAngle:_endAngle clockwise:YES];
}

@end
