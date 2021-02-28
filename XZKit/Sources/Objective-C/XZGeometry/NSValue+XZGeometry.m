//
//  NSValue+XZGeometry.m
//  XZKit
//
//  Created by Xezun on 2021/2/28.
//

#import "NSValue+XZGeometry.h"

@implementation NSValue (XZGeometry)

+ (NSValue *)valueWithXZEdgeInsets:(XZEdgeInsets)insets {
    return [NSValue valueWithBytes:&insets objCType:@encode(XZEdgeInsets)];
}

- (XZEdgeInsets)XZEdgeInsetsValue {
    XZEdgeInsets insets = XZEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        [self getValue:&insets size:sizeof(XZEdgeInsets)];
    } else {
        [self getValue:&insets];
    }
    return insets;
}

@end
