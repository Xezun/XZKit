//
//  XZImageCorner.m
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import "XZImageCorner.h"
#import "XZImageCorner+Extension.h"

@implementation XZImageCorner

- (instancetype)initWithCorner:(XZImageCorner *)corner {
    self = [super initWithLine:corner];
    if (self && corner) {
        _radius = corner.radius;
    }
    return self;
}

- (void)setRadius:(CGFloat)radius {
    if ([self xz_setRadius:radius]) {
        [self didUpdateAttribute:@"radius"];
    }
}

- (BOOL)xz_setRadius:(CGFloat)radius {
    if (_radius == radius) {
        return NO;
    }
    _radius = radius;
    return YES;
}

@end
