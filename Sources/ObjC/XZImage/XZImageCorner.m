//
//  XZImageCorner.m
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import "XZImageCorner.h"
#import "XZImageCorner+Extension.h"
#import "XZImageCorners+Extension.h"

@implementation XZImageCorner

- (instancetype)initWithImageCorners:(XZImageCorners *)imageCorners {
    self = [super initWithSuperAttribute:imageCorners];
    if (self) {
        [self updateWithLineValue:imageCorners];
        
        _radius = imageCorners.radius;
    }
    return self;
}

- (BOOL)isEffective {
    return super.isEffective || self.radius > 0;
}

- (void)setRadius:(CGFloat)radius {
    if ([self setRadiusValue:radius]) {
        [self didUpdateAttribute:@"radius"];
    }
}

- (BOOL)setRadiusValue:(CGFloat)radius {
    if (_radius == radius) {
        return NO;
    }
    _radius = radius;
    return YES;
}

@end
