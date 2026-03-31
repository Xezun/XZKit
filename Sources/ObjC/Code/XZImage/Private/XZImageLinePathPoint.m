//
//  XZImageLinePathPoint.m
//  XZKit
//
//  Created by Xezun on 2021/2/19.
//

#import "XZImageLinePathPoint.h"
#import "XZLog.h"

@implementation XZImageLinePathPoint

- (void)drawInContext:(CGContextRef)context {
    CGContextAddLineToPoint(context, _endPoint.x, _endPoint.y);
    
    XZLog(@"addLine: (%.2f, %.2f)", _endPoint.x, _endPoint.y);
}

- (void)addToPath:(UIBezierPath *)path {
    [path addLineToPoint:_endPoint];
}

@end
