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
            [self dashDidLoad];
        }
    }
    return self;
}

@synthesize dash = _dash;

- (XZImageLineDash *)dash {
    if (_dash == nil) {
        _dash = [XZImageLineDash lineDashWithLineDash:nil];
        [self dashDidLoad];
    }
    return _dash;
}

- (XZImageLineDash *)dashIfLoaded {
    return _dash;
}

- (void)dashDidLoad {
    
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




