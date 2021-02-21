//
//  XZImageLine.m
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import "XZImageLine.h"
#import "XZImageLine+Extension.h"


@implementation XZImageLine

- (instancetype)init {
    return [self initWithLine:nil];
}

- (instancetype)initWithLine:(XZImageLine *)line {
    self = [super init];
    if (self) {
        _color = line.color;
        _width = line.width;
        
        XZImageLineDash *dash = line.dashIfLoaded;
        if (dash) {
            _dash = [XZImageLineDash lineDashWithLineDash:dash];
            _dash.superAttribute = self;
        }
    }
    return self;
}

- (void)setColor:(UIColor *)color {
    if ([self xz_setColor:color]) {
        [self didUpdateAttribute:@"color"];
    }
}

- (BOOL)xz_setColor:(UIColor *)color {
    if ([_color isEqual:color]) {
        return NO;
    }
    _color = color;
    return YES;
}

- (void)setWidth:(CGFloat)width {
    if ([self xz_setWidth:width]) {
        [self didUpdateAttribute:@"width"];
    }
}

- (BOOL)xz_setWidth:(CGFloat)width {
    if (_width == width) {
        return NO;
    }
    _width = width;
    return YES;
}

@synthesize dash = _dash;

- (XZImageLineDash *)dash {
    if (_dash == nil) {
        _dash = [XZImageLineDash lineDashWithLineDash:nil];
        _dash.superAttribute = self;
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

@end




