//
//  XZLogSystem.m
//  XZKit
//
//  Created by 徐臻 on 2025/7/3.
//

#import "XZLogSystem.h"

@implementation XZLogSystem

+ (XZLogSystem *)XZKitLogSystem {
    static XZLogSystem *_system = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _system = [[XZLogSystem alloc] initWithDomain:@"com.xezun.XZKit"];
    });
    return _system;
}

- (instancetype)initWithDomain:(NSString *)domain {
    self = [super init];
    if (self) {
        _isEnabled = NO;
        _domain = domain.copy;
    }
    return self;
}

@end
