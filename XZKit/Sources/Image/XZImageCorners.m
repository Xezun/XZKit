//
//  XZImageCorners.m
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import "XZImageCorners.h"
#import "XZImageCorner.h"

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

- (void)setDash:(XZImageLineDash)dash {
    [super setDash:dash];
    self.topLeft.dash = dash;
    self.bottomLeft.dash = dash;
    self.bottomRight.dash = dash;
    self.topRight.dash = dash;
}

- (XZImageLineDash)dash {
    if ([super dash].width && [super dash].space) {
        return [super dash];
    }
    if ([_topLeft dash].width && [_topLeft dash].space) {
        return [_topLeft dash];
    }
    if ([_bottomLeft dash].width && [_bottomLeft dash].space) {
        return [_bottomLeft dash];
    }
    if ([_bottomRight dash].width && [_bottomRight dash].space) {
        return [_bottomRight dash];
    }
    return [_topRight dash];
}

- (void)setRadius:(CGFloat)radius {
    [super setRadius:radius];
    self.topLeft.radius = radius;
    self.bottomLeft.radius = radius;
    self.bottomRight.radius = radius;
    self.topRight.radius = radius;
}

- (CGFloat)radius {
    return [super radius] ?: _topLeft.radius ?: _bottomLeft.radius ?: _bottomRight.radius ?: _topRight.radius;
}

@end
