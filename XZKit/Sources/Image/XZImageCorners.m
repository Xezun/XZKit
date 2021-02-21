//
//  XZImageCorners.m
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import "XZImageCorners.h"
#import "XZImageCorners+Extension.h"

@interface XZImageCorners ()

@end

@implementation XZImageCorners

@synthesize topLeft     = _topLeft;
@synthesize bottomLeft  = _bottomLeft;
@synthesize bottomRight = _bottomRight;
@synthesize topRight    = _topRight;

- (XZImageCorner *)topLeft {
    if (_topLeft == nil) {
        _topLeft = [[XZImageCorner alloc] initWithCorner:self];
        _topLeft.superAttribute = self;
    }
    return _topLeft;
}

- (XZImageCorner *)topLeftIfLoaded {
    return _topLeft;
}

- (XZImageCorner *)bottomLeft {
    if (_bottomLeft == nil) {
        _bottomLeft = [[XZImageCorner alloc] initWithCorner:self];
        _bottomLeft.superAttribute = self;
    }
    return _bottomLeft;
}

- (XZImageCorner *)bottomLeftIfLoaded {
    return _bottomLeft;
}

- (XZImageCorner *)bottomRight {
    if (_bottomRight == nil) {
        _bottomRight = [[XZImageCorner alloc] initWithCorner:self];
        _bottomRight.superAttribute = self;
    }
    return _bottomRight;
}

- (XZImageCorner *)bottomRightIfLoaded {
    return _bottomRight;
}

- (XZImageCorner *)topRight {
    if (_topRight == nil) {
        _topRight = [[XZImageCorner alloc] initWithCorner:self];
        _topRight.superAttribute = self;
    }
    return _topRight;
}

- (XZImageCorner *)topRightIfLoaded {
    return _topRight;
}

#pragma mark - 同步属性到下级

- (void)setColor:(UIColor *)color {
    [self.topLeftIfLoaded xz_setColor:color];
    [self.bottomLeftIfLoaded xz_setColor:color];
    [self.bottomRightIfLoaded xz_setColor:color];
    [self.topRightIfLoaded xz_setColor:color];
    
    [super setColor:color];
}

- (void)setWidth:(CGFloat)width {
    [self.topLeftIfLoaded xz_setWidth:width];
    [self.bottomLeftIfLoaded xz_setWidth:width];
    [self.bottomRightIfLoaded xz_setWidth:width];
    [self.topRightIfLoaded xz_setWidth:width];
    
    [super setWidth:width];
}

- (void)setRadius:(CGFloat)radius {
    [self.topLeftIfLoaded xz_setRadius:radius];
    [self.bottomLeftIfLoaded xz_setRadius:radius];
    [self.bottomRightIfLoaded xz_setRadius:radius];
    [self.topRightIfLoaded xz_setRadius:radius];
    
    [super setRadius:radius];
}

- (void)subAttribute:(__kindof XZImageAttribute *)subAttribute didUpdateAttribute:(id)attribute {
    if (subAttribute == self.dashIfLoaded) {
        XZImageLineDash *dash = (id)subAttribute;
        [self.topLeftIfLoaded.dash     updateWithLineDash:dash];
        [self.bottomLeftIfLoaded.dash  updateWithLineDash:dash];
        [self.bottomRightIfLoaded.dash updateWithLineDash:dash];
        [self.topRightIfLoaded.dash    updateWithLineDash:dash];
    }
    
    [super subAttribute:subAttribute didUpdateAttribute:attribute];
}

@end
