//
//  NSCoder+XZGeometry.m
//  XZKit
//
//  Created by Xezun on 2021/2/28.
//

#import "NSCoder+XZGeometry.h"
#import "NSValue+XZGeometry.h"

@implementation NSCoder (XZGeometry)

- (void)encodeXZEdgeInsets:(XZEdgeInsets)insets forKey:(NSString *)key {
    NSValue *value = [NSValue valueWithXZEdgeInsets:insets];
    [self encodeObject:value forKey:key];
}

- (XZEdgeInsets)decodeXZEdgeInsetsForKey:(NSString *)key {
    NSValue *value = [self decodeObjectForKey:key];
    return [value XZEdgeInsetsValue];
}

@end
