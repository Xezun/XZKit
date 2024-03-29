//
//  XZImageLine.m
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import "XZImageLine.h"
#import "XZImageLine+Extension.h"

@implementation XZImageLine

- (instancetype)initWithSuperAttribute:(id<XZImageSuperAttribute>)superAttribute {
    self = [super initWithSuperAttribute:superAttribute];
    if (self) {
        _width      = 0;
        _color      = nil;
        _miterLimit = 10;
        _dash       = nil;
    }
    return self;
}

- (BOOL)isEffective {
    return self.width > 0 || self.color != nil || self.dashIfLoaded.isEffective;
}

- (void)setColor:(UIColor *)color {
    if ([self setColorValue:color]) {
        [self didUpdateAttribute:@"color"];
    }
}

- (BOOL)setColorValue:(UIColor *)color {
    if ([_color isEqual:color]) {
        return NO;
    }
    _color = color;
    return YES;
}

- (void)setWidth:(CGFloat)width {
    if ([self setWidthValue:width]) {
        [self didUpdateAttribute:@"width"];
    }
}

- (BOOL)setWidthValue:(CGFloat)width {
    if (_width == width || width < 0) {
        return NO;
    }
    _width = width;
    return YES;
}

- (void)setMiterLimit:(CGFloat)miterLimit {
    if ([self setMiterLimitValue:miterLimit]) {
        [self didUpdateAttribute:@"miterLimit"];
    }
}

- (BOOL)setMiterLimitValue:(CGFloat)miterLimit {
    if (_miterLimit == miterLimit || miterLimit < 0) {
        return NO;
    }
    _miterLimit = miterLimit;
    return YES;
}

@synthesize dash = _dash;

- (XZImageLineDash *)dash {
    if (_dash == nil) {
        _dash = [[XZImageLineDash alloc] initWithLine:self];
    }
    return _dash;
}

- (XZImageLineDash *)dashIfLoaded {
    return _dash;
}

- (BOOL)isEqual:(XZImageLine *)object {
    if ([object isKindOfClass:[XZImageLine class]]) {
        if (self.width != object.width) {
            return NO;
        }
        
        if (self.color == nil) {
            if (object.color != nil) {
                return NO;
            }
        } else if (![self.color isEqual:object.color]) {
            return NO;
        }
        
        return [self.dash isEqual:object.dash];
    }
    return NO;
}

- (void)updateWithLineValue:(XZImageLine *)line {
    if (self == line) {
        return;
    }
    [self setColorValue:line.color];
    [self setWidthValue:line.width];
    
    XZImageLineDash *dash = line.dashIfLoaded;
    if (dash == nil) {
        [self.dashIfLoaded updateLineDashValue:nil];
    } else {
        [self.dash updateLineDashValue:dash];
    }
}

@end




