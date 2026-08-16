//
//  XZContentStatus.m
//  XZKit
//
//  Created by Mac on 2026/8/16.
//

#import "XZContentStatus.h"

@implementation XZContentStatus

- (instancetype)initWithRawValue:(NSString *)rawValue configuration:(id)configuration {
    self = [super init];
    if (self) {
        _rawValue = rawValue.copy;
        _configuration = configuration;
    }
    return self;
}

+ (XZContentStatus *)empty {
    return [[XZContentStatus alloc] initWithRawValue:@"empty" configuration:nil];
}

+ (XZContentStatus *)error {
    return [[XZContentStatus alloc] initWithRawValue:@"error" configuration:nil];
}

+ (XZContentStatus *)loading {
    return [[XZContentStatus alloc] initWithRawValue:@"loading" configuration:nil];
}

+ (XZContentStatus *)unreachable {
    return [[XZContentStatus alloc] initWithRawValue:@"unreachable" configuration:nil];
}

+ (XZContentStatus *)unavailable {
    return [[XZContentStatus alloc] initWithRawValue:@"unavailable" configuration:nil];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[self.class alloc] initWithRawValue:_rawValue configuration:_configuration];
}

@end
