//
//  XZImageCorners.m
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import "XZImageCorners.h"
#import "XZImageCorners+Extension.h"

@implementation XZImageCorners

- (BOOL)isEffective {
    return (super.isEffective
            || self.topLeftIfLoaded.isEffective
            || self.bottomLeftIfLoaded.isEffective
            || self.bottomRightIfLoaded.isEffective
            || self.topRightIfLoaded.isEffective);
}

@synthesize topLeft     = _topLeft;
@synthesize bottomLeft  = _bottomLeft;
@synthesize bottomRight = _bottomRight;
@synthesize topRight    = _topRight;

- (XZImageCorner *)topLeft {
    if (_topLeft == nil) {
        _topLeft = [[XZImageCorner alloc] initWithImageCorners:self];
    }
    return _topLeft;
}

- (XZImageCorner *)topLeftIfLoaded {
    return _topLeft;
}

- (XZImageCorner *)bottomLeft {
    if (_bottomLeft == nil) {
        _bottomLeft = [[XZImageCorner alloc] initWithImageCorners:self];
    }
    return _bottomLeft;
}

- (XZImageCorner *)bottomLeftIfLoaded {
    return _bottomLeft;
}

- (XZImageCorner *)bottomRight {
    if (_bottomRight == nil) {
        _bottomRight = [[XZImageCorner alloc] initWithImageCorners:self];
    }
    return _bottomRight;
}

- (XZImageCorner *)bottomRightIfLoaded {
    return _bottomRight;
}

- (XZImageCorner *)topRight {
    if (_topRight == nil) {
        _topRight = [[XZImageCorner alloc] initWithImageCorners:self];
    }
    return _topRight;
}

- (XZImageCorner *)topRightIfLoaded {
    return _topRight;
}

#pragma mark - 同步属性到下级

- (void)setColor:(UIColor *)color {
    [self.topLeftIfLoaded setColorValue:color];
    [self.bottomLeftIfLoaded setColorValue:color];
    [self.bottomRightIfLoaded setColorValue:color];
    [self.topRightIfLoaded setColorValue:color];
    
    [super setColor:color];
}

- (void)setWidth:(CGFloat)width {
    [self.topLeftIfLoaded setWidthValue:width];
    [self.bottomLeftIfLoaded setWidthValue:width];
    [self.bottomRightIfLoaded setWidthValue:width];
    [self.topRightIfLoaded setWidthValue:width];
    
    [super setWidth:width];
}

- (void)setMiterLimit:(CGFloat)miterLimit {
    [self.topLeftIfLoaded setMiterLimitValue:miterLimit];
    [self.bottomLeftIfLoaded setMiterLimitValue:miterLimit];
    [self.bottomRightIfLoaded setMiterLimitValue:miterLimit];
    [self.topRightIfLoaded setMiterLimitValue:miterLimit];
    
    [super setMiterLimit:miterLimit];
}

- (void)setRadius:(CGFloat)radius {
    [self.topLeftIfLoaded setRadiusValue:radius];
    [self.bottomLeftIfLoaded setRadiusValue:radius];
    [self.bottomRightIfLoaded setRadiusValue:radius];
    [self.topRightIfLoaded setRadiusValue:radius];
    
    [super setRadius:radius];
}

- (void)subAttribute:(__kindof XZImageAttribute *)subAttribute didUpdateAttribute:(id)attribute {
    if (subAttribute == self.dashIfLoaded) {
        XZImageLineDash *dash = (id)subAttribute;
        [self.topLeftIfLoaded.dash     updateWithLineDashValue:dash];
        [self.bottomLeftIfLoaded.dash  updateWithLineDashValue:dash];
        [self.bottomRightIfLoaded.dash updateWithLineDashValue:dash];
        [self.topRightIfLoaded.dash    updateWithLineDashValue:dash];
    }
    
    [super subAttribute:subAttribute didUpdateAttribute:attribute];
}

@end
