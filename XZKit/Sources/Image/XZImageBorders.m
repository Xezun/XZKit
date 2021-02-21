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

- (XZImageBorder *)top {
    if (_top == nil) {
        _top = [[XZImageBorder alloc] initWithBorder:self];
        _top.superAttribute = self;
    }
    return _top;
}

- (XZImageBorder *)topIfLoaded {
    return _top;
}

- (XZImageBorder *)left {
    if (_left == nil) {
        _left = [[XZImageBorder alloc] initWithBorder:self];
        _left.superAttribute = self;
    }
    return _left;
}

- (XZImageBorder *)leftIfLoaded {
    return _left;
}

- (XZImageBorder *)bottom {
    if (_bottom == nil) {
        _bottom = [[XZImageBorder alloc] initWithBorder:self];
        _bottom.superAttribute = self;
    }
    return _bottom;
}

- (XZImageBorder *)bottomIfLoaded {
    return _bottom;
}

- (XZImageBorder *)right {
    if (_right == nil) {
        _right = [[XZImageBorder alloc] initWithBorder:self];
        _right.superAttribute = self;
    }
    return _right;
}

- (XZImageBorder *)rightIfLoaded {
    return _right;
}

#pragma mark - 同步属性到下级

- (void)setColor:(UIColor *)color {
    [self.topIfLoaded xz_setColor:color];
    [self.leftIfLoaded xz_setColor:color];
    [self.bottomIfLoaded xz_setColor:color];
    [self.rightIfLoaded xz_setColor:color];
    
    [super setColor:color];
}

- (void)setWidth:(CGFloat)width {
    [self.topIfLoaded xz_setWidth:width];
    [self.leftIfLoaded xz_setWidth:width];
    [self.bottomIfLoaded xz_setWidth:width];
    [self.rightIfLoaded xz_setWidth:width];
    
    [super setWidth:width];
}

- (void)subAttribute:(__kindof XZImageAttribute *)subAttribute didUpdateAttribute:(id)attribute {
    if (subAttribute == self.dashIfLoaded) {
        XZImageLineDash *dash = (id)subAttribute;
        [self.topIfLoaded.dash    updateWithLineDash:dash];
        [self.leftIfLoaded.dash   updateWithLineDash:dash];
        [self.bottomIfLoaded.dash updateWithLineDash:dash];
        [self.rightIfLoaded.dash  updateWithLineDash:dash];
    } else if (subAttribute == self.arrowIfLoaded) {
        XZImageBorderArrow * const arrow = (id)subAttribute;
        if ([attribute isEqual:@"width"]) {
            [self.topIfLoaded.arrow xz_setWidth:arrow.width];
            [self.leftIfLoaded.arrow xz_setWidth:arrow.width];
            [self.bottomIfLoaded.arrow xz_setWidth:arrow.width];
            [self.rightIfLoaded.arrow xz_setWidth:arrow.width];
        } else if ([attribute isEqual:@"height"]) {
            [self.topIfLoaded.arrow xz_setHeight:arrow.height];
            [self.leftIfLoaded.arrow xz_setHeight:arrow.height];
            [self.bottomIfLoaded.arrow xz_setHeight:arrow.height];
            [self.rightIfLoaded.arrow xz_setHeight:arrow.height];
        } else if ([attribute isEqual:@"vector"]) {
            [self.topIfLoaded.arrow xz_setVector:arrow.vector];
            [self.leftIfLoaded.arrow xz_setVector:arrow.vector];
            [self.bottomIfLoaded.arrow xz_setVector:arrow.vector];
            [self.rightIfLoaded.arrow xz_setVector:arrow.vector];
        } else if ([attribute isEqual:@"anchor"]) {
            [self.topIfLoaded.arrow xz_setAnchor:arrow.anchor];
            [self.leftIfLoaded.arrow xz_setAnchor:arrow.anchor];
            [self.bottomIfLoaded.arrow xz_setAnchor:arrow.anchor];
            [self.rightIfLoaded.arrow xz_setAnchor:arrow.anchor];
        }
    }
    [super subAttribute:subAttribute didUpdateAttribute:attribute];
}

@end
