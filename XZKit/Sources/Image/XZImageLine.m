//
//  XZImageLine.m
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import "XZImageLine.h"
#import "XZImageLine+XZImage.h"

@implementation XZImageLine

- (instancetype)init {
    self = [super init];
    if (self) {
        _color = nil;
        _width = 0;
    }
    return self;
}

@synthesize dash = _dash;

- (XZImageLineDash *)dash {
    if (_dash == nil) {
        _dash = [XZImageLineDash lineDashWithSegments:NULL length:0];
    }
    return _dash;
}

- (void)setDash:(XZImageLineDash *)dash {
    if (_dash != dash) {
        _dash = dash.copy;
    }
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




