//
//  XZImageCorner.m
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import "XZImageCorner.h"

@implementation XZImageCorner

- (instancetype)initWithCorner:(XZImageCorner *)corner {
    self = [super initWithLine:corner];
    if (self && corner) {
        _radius = corner.radius;
    }
    return self;
}

@end
