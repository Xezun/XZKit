//
//  XZImageBorders.m
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import "XZImageBorders.h"
#import "XZImageBorders+Extension.h"
#import "XZImageBorder.h"
#import "XZImageLine+Extension.h"
#import "XZImageLineDash+Extension.h"
#import "XZImageBorder+Extension.h"

@implementation XZImageBorders

@synthesize top = _top;
@synthesize left = _left;
@synthesize bottom = _bottom;
@synthesize right = _right;

- (BOOL)isEffective {
    return (super.isEffective || self.topIfLoaded.isEffective || self.leftIfLoaded.isEffective || self.bottomIfLoaded.isEffective || self.rightIfLoaded.isEffective);
}

- (XZImageBorder *)top {
    if (_top == nil) {
        _top = [[XZImageBorder alloc] initWithImageBorders:self];
    }
    return _top;
}

- (XZImageBorder *)topIfLoaded {
    return _top;
}

- (XZImageBorder *)left {
    if (_left == nil) {
        _left = [[XZImageBorder alloc] initWithImageBorders:self];
    }
    return _left;
}

- (XZImageBorder *)leftIfLoaded {
    return _left;
}

- (XZImageBorder *)bottom {
    if (_bottom == nil) {
        _bottom = [[XZImageBorder alloc] initWithImageBorders:self];
    }
    return _bottom;
}

- (XZImageBorder *)bottomIfLoaded {
    return _bottom;
}

- (XZImageBorder *)right {
    if (_right == nil) {
        _right = [[XZImageBorder alloc] initWithImageBorders:self];
    }
    return _right;
}

- (XZImageBorder *)rightIfLoaded {
    return _right;
}

#pragma mark - 同步属性到下级

- (void)setColor:(UIColor *)color {
    [self.topIfLoaded setColorSilently:color];
    [self.leftIfLoaded setColorSilently:color];
    [self.bottomIfLoaded setColorSilently:color];
    [self.rightIfLoaded setColorSilently:color];
    
    [super setColor:color];
}

- (void)setWidth:(CGFloat)width {
    [self.topIfLoaded setWidthSilently:width];
    [self.leftIfLoaded setWidthSilently:width];
    [self.bottomIfLoaded setWidthSilently:width];
    [self.rightIfLoaded setWidthSilently:width];
    
    [super setWidth:width];
}

- (void)setMiterLimit:(CGFloat)miterLimit {
    [self.topIfLoaded setMiterLimit:miterLimit];
    [self.leftIfLoaded setMiterLimit:miterLimit];
    [self.bottomIfLoaded setMiterLimit:miterLimit];
    [self.rightIfLoaded setMiterLimit:miterLimit];
    
    [super setMiterLimit:miterLimit];
}

- (void)subAttribute:(__kindof XZImageAttribute *)subAttribute didUpdateAttribute:(id)attribute {
    if (subAttribute == self.dashIfLoaded) {
        XZImageLineDash *dash = (id)subAttribute;
        [self.topIfLoaded.dash updateWithLineDashSilently:dash];
        [self.leftIfLoaded.dash updateWithLineDashSilently:dash];
        [self.bottomIfLoaded.dash updateWithLineDashSilently:dash];
        [self.rightIfLoaded.dash updateWithLineDashSilently:dash];
    } else if (subAttribute == self.arrowIfLoaded) {
        XZImageArrow * const arrow = (id)subAttribute;
        if ([attribute isEqual:@"width"]) {
            [self.topIfLoaded.arrow setWidthSilently:arrow.width];
            [self.leftIfLoaded.arrow setWidthSilently:arrow.width];
            [self.bottomIfLoaded.arrow setWidthSilently:arrow.width];
            [self.rightIfLoaded.arrow setWidthSilently:arrow.width];
        } else if ([attribute isEqual:@"height"]) {
            [self.topIfLoaded.arrow setHeightSilently:arrow.height];
            [self.leftIfLoaded.arrow setHeightSilently:arrow.height];
            [self.bottomIfLoaded.arrow setHeightSilently:arrow.height];
            [self.rightIfLoaded.arrow setHeightSilently:arrow.height];
        } else if ([attribute isEqual:@"vector"]) {
            [self.topIfLoaded.arrow setVectorSilently:arrow.vector];
            [self.leftIfLoaded.arrow setVectorSilently:arrow.vector];
            [self.bottomIfLoaded.arrow setVectorSilently:arrow.vector];
            [self.rightIfLoaded.arrow setVectorSilently:arrow.vector];
        } else if ([attribute isEqual:@"anchor"]) {
            [self.topIfLoaded.arrow setAnchorSilently:arrow.anchor];
            [self.leftIfLoaded.arrow setAnchorSilently:arrow.anchor];
            [self.bottomIfLoaded.arrow setAnchorSilently:arrow.anchor];
            [self.rightIfLoaded.arrow setAnchorSilently:arrow.anchor];
        }
    }
    [super subAttribute:subAttribute didUpdateAttribute:attribute];
}

@end
