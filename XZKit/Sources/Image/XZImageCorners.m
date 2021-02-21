//
//  XZImageCorners.m
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import "XZImageCorners.h"
#import "XZImageCorners+Extension.h"
#import "XZImageCorner.h"
#import "XZImageLine+Extension.h"
#import "XZImageLineDash+Extension.h"

@interface XZImageCorners () <XZImageLineDashDelegate>

@end

@implementation XZImageCorners

@synthesize topLeft     = _topLeft;
@synthesize bottomLeft  = _bottomLeft;
@synthesize bottomRight = _bottomRight;
@synthesize topRight    = _topRight;

- (XZImageCorner *)topLeft {
    if (_topLeft == nil) {
        _topLeft = [[XZImageCorner alloc] initWithCorner:self];
    }
    return _topLeft;
}

- (XZImageCorner *)topLeftIfLoaded {
    return _topLeft;
}

- (XZImageCorner *)bottomLeft {
    if (_bottomLeft == nil) {
        _bottomLeft = [[XZImageCorner alloc] initWithCorner:self];
    }
    return _bottomLeft;
}

- (XZImageCorner *)bottomLeftIfLoaded {
    return _bottomLeft;
}

- (XZImageCorner *)bottomRight {
    if (_bottomRight == nil) {
        _bottomRight = [[XZImageCorner alloc] initWithCorner:self];
    }
    return _bottomRight;
}

- (XZImageCorner *)bottomRightIfLoaded {
    return _bottomRight;
}

- (XZImageCorner *)topRight {
    if (_topRight == nil) {
        _topRight = [[XZImageCorner alloc] initWithCorner:self];
    }
    return _topRight;
}

- (XZImageCorner *)topRightIfLoaded {
    return _topRight;
}

- (void)dashDidLoad {
    self.dash.delegate = self;
}

#pragma mark - 同步属性到下级

- (void)setColor:(UIColor *)color {
    [super setColor:color];
    self.topLeftIfLoaded.color = color;
    self.bottomLeftIfLoaded.color = color;
    self.bottomRightIfLoaded.color = color;
    self.topRightIfLoaded.color = color;
}

- (void)setWidth:(CGFloat)width {
    [super setWidth:width];
    self.topLeftIfLoaded.width = width;
    self.bottomLeftIfLoaded.width = width;
    self.bottomRightIfLoaded.width = width;
    self.topRightIfLoaded.width = width;
}

- (void)setRadius:(CGFloat)radius {
    [super setRadius:radius];
    self.topLeftIfLoaded.radius     = radius;
    self.bottomLeftIfLoaded.radius  = radius;
    self.bottomRightIfLoaded.radius = radius;
    self.topRightIfLoaded.radius    = radius;
}

- (void)lineDashDidUpdate:(XZImageLineDash *)lineDash {
    [self.topLeftIfLoaded.dash     updateWithLineDash:self.dashIfLoaded];
    [self.bottomLeftIfLoaded.dash  updateWithLineDash:self.dashIfLoaded];
    [self.bottomRightIfLoaded.dash updateWithLineDash:self.dashIfLoaded];
    [self.topRightIfLoaded.dash    updateWithLineDash:self.dashIfLoaded];
}

@end
