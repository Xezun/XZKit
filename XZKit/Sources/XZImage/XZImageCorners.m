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
    [self.topLeftIfLoaded setColorSilently:color];
    [self.bottomLeftIfLoaded setColorSilently:color];
    [self.bottomRightIfLoaded setColorSilently:color];
    [self.topRightIfLoaded setColorSilently:color];
    
    [super setColor:color];
}

- (void)setWidth:(CGFloat)width {
    [self.topLeftIfLoaded setWidthSilently:width];
    [self.bottomLeftIfLoaded setWidthSilently:width];
    [self.bottomRightIfLoaded setWidthSilently:width];
    [self.topRightIfLoaded setWidthSilently:width];
    
    [super setWidth:width];
}

- (void)setRadius:(CGFloat)radius {
    [self.topLeftIfLoaded setRadiusSilently:radius];
    [self.bottomLeftIfLoaded setRadiusSilently:radius];
    [self.bottomRightIfLoaded setRadiusSilently:radius];
    [self.topRightIfLoaded setRadiusSilently:radius];
    
    [super setRadius:radius];
}

- (void)subAttribute:(__kindof XZImageAttribute *)subAttribute didUpdateAttribute:(id)attribute {
    if (subAttribute == self.dashIfLoaded) {
        XZImageLineDash *dash = (id)subAttribute;
        [self.topLeftIfLoaded.dash     updateWithLineDashSilently:dash];
        [self.bottomLeftIfLoaded.dash  updateWithLineDashSilently:dash];
        [self.bottomRightIfLoaded.dash updateWithLineDashSilently:dash];
        [self.topRightIfLoaded.dash    updateWithLineDashSilently:dash];
    }
    
    [super subAttribute:subAttribute didUpdateAttribute:attribute];
}

@end
