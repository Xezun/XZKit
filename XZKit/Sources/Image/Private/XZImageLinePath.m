//
//  XZImageLinePath.m
//  XZKit
//
//  Created by Xezun on 2021/2/19.
//

#import "XZImageLinePath.h"
#import "XZImageLinePathPoint.h"
#import "XZImageLinePathArc.h"

@implementation XZImageLinePath {
    NSMutableArray<id<XZImagePathItem>> *_items;
}

+ (instancetype)imagePathWithLine:(XZImageLine *)line startPoint:(CGPoint)startPoint {
    return [[self alloc] initWithLine:line startPoint:startPoint];
}

- (instancetype)initWithLine:(XZImageLine *)line startPoint:(CGPoint)startPoint {
    self = [super init];
    if (self) {
        _line = line;
        _items = [NSMutableArray arrayWithCapacity:4];
        _startPoint = startPoint;
    }
    return self;
}

- (void)addLineToPoint:(CGPoint)endPoint {
    XZImageLinePathPoint *border = [[XZImageLinePathPoint alloc] init];
    border.endPoint = endPoint;
    [_items addObject:border];
}

- (void)addArcWithCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle {
    XZImageLinePathArc *corner = [[XZImageLinePathArc alloc] init];
    corner.radius = radius;
    corner.center = center;
    corner.startAngle = startAngle;
    corner.endAngle   = endAngle;
    [_items addObject:corner];
}

- (void)drawInContext:(CGContextRef)context {
    CGContextSetStrokeColorWithColor(context, _line.color.CGColor);
    CGContextSetLineWidth(context, _line.width);
    
    XZImageLineDash * const dash = _line.dash;
    if (!dash.isEmpty) {
        CGContextSetLineDash(context, dash.phase, dash.segments, dash.numberOfSegments);
    }
    
    CGContextMoveToPoint(context, _startPoint.x, _startPoint.y);
    
    for (id<XZImagePathItem> image in _items) {
        [image drawInContext:context];
    }
}

- (UIBezierPath *)path {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    path.lineWidth = _line.width;
    
    XZImageLineDash * const dash = _line.dash;
    if (!dash.isEmpty) {
        [path setLineDash:dash.segments count:dash.numberOfSegments phase:dash.phase];
    }
    
    [path moveToPoint:_startPoint];
    
    for (id<XZImagePathItem> item in _items) {
        [item addToPath:path];
    }
    return  path;
}

@end




