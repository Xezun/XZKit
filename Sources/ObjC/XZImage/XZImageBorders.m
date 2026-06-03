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
    [self.topIfLoaded setColorValue:color];
    [self.leftIfLoaded setColorValue:color];
    [self.bottomIfLoaded setColorValue:color];
    [self.rightIfLoaded setColorValue:color];
    
    [super setColor:color];
}

- (void)setWidth:(CGFloat)width {
    [self.topIfLoaded setWidthValue:width];
    [self.leftIfLoaded setWidthValue:width];
    [self.bottomIfLoaded setWidthValue:width];
    [self.rightIfLoaded setWidthValue:width];
    
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
        [self.topIfLoaded.dash updateLineDashValue:dash];
        [self.leftIfLoaded.dash updateLineDashValue:dash];
        [self.bottomIfLoaded.dash updateLineDashValue:dash];
        [self.rightIfLoaded.dash updateLineDashValue:dash];
    } else if (subAttribute == self.arrowIfLoaded) {
        XZImageArrow * const arrow = (id)subAttribute;
        if ([attribute isEqual:@"width"]) {
            [self.topIfLoaded.arrow setWidthValue:arrow.width];
            [self.leftIfLoaded.arrow setWidthValue:arrow.width];
            [self.bottomIfLoaded.arrow setWidthValue:arrow.width];
            [self.rightIfLoaded.arrow setWidthValue:arrow.width];
        } else if ([attribute isEqual:@"height"]) {
            [self.topIfLoaded.arrow setHeightValue:arrow.height];
            [self.leftIfLoaded.arrow setHeightValue:arrow.height];
            [self.bottomIfLoaded.arrow setHeightValue:arrow.height];
            [self.rightIfLoaded.arrow setHeightValue:arrow.height];
        } else if ([attribute isEqual:@"vector"]) {
            [self.topIfLoaded.arrow setVectorValue:arrow.vector];
            [self.leftIfLoaded.arrow setVectorValue:arrow.vector];
            [self.bottomIfLoaded.arrow setVectorValue:arrow.vector];
            [self.rightIfLoaded.arrow setVectorValue:arrow.vector];
        } else if ([attribute isEqual:@"anchor"]) {
            [self.topIfLoaded.arrow setAnchorValue:arrow.anchor];
            [self.leftIfLoaded.arrow setAnchorValue:arrow.anchor];
            [self.bottomIfLoaded.arrow setAnchorValue:arrow.anchor];
            [self.rightIfLoaded.arrow setAnchorValue:arrow.anchor];
        }
    }
    [super subAttribute:subAttribute didUpdateAttribute:attribute];
}

@end
