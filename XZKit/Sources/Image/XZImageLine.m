//
//  XZImageLine.m
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import "XZImageLine.h"

@implementation XZImageLine

- (instancetype)init {
    self = [super init];
    if (self) {
        _color = nil;
        _width = 0;
        _dash.width = 0;
        _dash.space = 0;
    }
    return self;
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
        
        return XZImageLineDashEqualToLineDash(self.dash, object.dash);
    }
    return NO;
}

@end
