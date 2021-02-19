//
//  XZImagePath.m
//  XZKit
//
//  Created by Xezun on 2021/2/19.
//

#import "XZImagePath.h"
#import "XZImagePathLineItem.h"
#import "XZImagePathArcItem.h"

@implementation XZImagePath {
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
    XZImagePathLineItem *border = [[XZImagePathLineItem alloc] init];
    border.endPoint = endPoint;
    [_items addObject:border];
}

- (void)addArcWithCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle {
    XZImagePathArcItem *corner = [[XZImagePathArcItem alloc] init];
    corner.radius = radius;
    corner.center = center;
    corner.startAngle = startAngle;
    corner.endAngle   = endAngle;
    [_items addObject:corner];
}

- (void)drawInContext:(CGContextRef)context {
    CGContextSetStrokeColorWithColor(context, _line.color.CGColor);
    CGContextSetLineWidth(context, _line.width);
    if (_line.dash.width > 0 && _line.dash.space > 0) {
        CGFloat const dashes[2] = {_line.dash.width, _line.dash.space};
        CGContextSetLineDash(context, 0, dashes, 2);
    }
    
    CGContextMoveToPoint(context, _startPoint.x, _startPoint.y);
    
    for (id<XZImagePathItem> image in _items) {
        [image drawInContext:context];
    }
}

- (UIBezierPath *)path {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    path.lineWidth = _line.width;
    if (_line.dash.width > 0 && _line.dash.space > 0) {
        CGFloat const dashes[2] = {_line.dash.width, _line.dash.space};
        [path setLineDash:dashes count:2 phase:0];
    }
    
    [path moveToPoint:_startPoint];
    
    for (id<XZImagePathItem> item in _items) {
        [item addToPath:path];
    }
    return  path;
}

@end




