//
//  XZImageCorners.m
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import "XZImageCorners.h"
#import "XZImageCorner.h"
#import "XZImageLine+XZImage.h"
#import "XZImageLineDash+XZImage.h"

@interface XZImageCorners () <XZImageLineDashDelegate>

@end

@implementation XZImageCorners

@synthesize topLeft = _topLeft;
@synthesize bottomLeft = _bottomLeft;
@synthesize bottomRight = _bottomRight;
@synthesize topRight = _topRight;

- (XZImageCorner *)topLeft {
    if (_topLeft == nil) {
        _topLeft = [[XZImageCorner alloc] init];
    }
    return _topLeft;
}

- (XZImageCorner *)bottomLeft {
    if (_bottomLeft == nil) {
        _bottomLeft = [[XZImageCorner alloc] init];
    }
    return _bottomLeft;
}

- (XZImageCorner *)bottomRight {
    if (_bottomRight == nil) {
        _bottomRight = [[XZImageCorner alloc] init];
    }
    return _bottomRight;
}

- (XZImageCorner *)topRight {
    if (_topRight == nil) {
        _topRight = [[XZImageCorner alloc] init];
    }
    return _topRight;
}

- (void)setColor:(UIColor *)color {
    [super setColor:color];
    self.topLeft.color = color;
    self.bottomLeft.color = color;
    self.bottomRight.color = color;
    self.topRight.color = color;
}

- (UIColor *)color {
    return _topLeft.color ?: _bottomLeft.color ?: _bottomRight.color ?: _topRight.color;
}

- (void)setWidth:(CGFloat)width {
    self.topLeft.width = width;
    self.bottomLeft.width = width;
    self.bottomRight.width = width;
    self.topRight.width = width;
}

- (CGFloat)width {
    return _topLeft.width ?: _bottomLeft.width ?: _bottomRight.width ?: _topRight.width;
}

- (void)setDash:(XZImageLineDash *)dash {
    if (_dash != dash) {
        _dash.delegate = nil;
        [super setDash:dash];
        _dash.delegate = self;
        
        [self lineDashDidChange:_dash];
    }
}

- (XZImageLineDash *)dash {
    if (_dash != nil) {
        return _dash;
    }
    XZImageLineDash *dash = [super dash];
    dash.delegate = self;
    [self lineDashDidChange:dash];
    return dash;
}

- (void)lineDashDidChange:(XZImageLineDash *)dash {
    [self.topLeft.dash     setPhase:dash.phase segments:dash.segments length:dash.numberOfSegments];
    [self.bottomLeft.dash  setPhase:dash.phase segments:dash.segments length:dash.numberOfSegments];
    [self.bottomRight.dash setPhase:dash.phase segments:dash.segments length:dash.numberOfSegments];
    [self.topRight.dash    setPhase:dash.phase segments:dash.segments length:dash.numberOfSegments];
}

- (void)setRadius:(CGFloat)radius {
    [super setRadius:radius];
    self.topLeft.radius     = radius;
    self.bottomLeft.radius  = radius;
    self.bottomRight.radius = radius;
    self.topRight.radius    = radius;
}

- (CGFloat)radius {
    return [super radius] ?: _topLeft.radius ?: _bottomLeft.radius ?: _bottomRight.radius ?: _topRight.radius;
}

@end
