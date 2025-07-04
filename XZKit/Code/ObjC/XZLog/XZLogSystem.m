//
//  XZLogSystem.m
//  XZKit
//
//  Created by 徐臻 on 2025/7/3.
//

#import "XZLogSystem.h"

@implementation XZLogSystem

+ (XZLogSystem *)defaultLogSystem {
    static XZLogSystem *_system = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = NSBundle.mainBundle;
        NSString *identifier = NSBundle.mainBundle.bundleIdentifier ?: @"com.unknown.App";
        NSString *name = bundle.infoDictionary[@"CFBundleExecutable"] ?: @"App";
        _system = [[XZLogSystem alloc] initWithName:name domain:identifier type:OS_LOG_TYPE_DEFAULT];
        _system.isEnabled = YES;
    });
    return _system;
}

+ (XZLogSystem *)XZKitLogSystem {
    static XZLogSystem *_system = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _system = [[XZLogSystem alloc] initWithName:@"XZKit" domain:@"com.xezun.XZKit" type:OS_LOG_TYPE_DEFAULT];
    });
    return _system;
}

- (instancetype)initWithName:(NSString *)name domain:(NSString *)domain type:(os_log_type_t)type {
    self = [super init];
    if (self) {
        _isEnabled = NO;
        _name = name.copy;
        _domain = domain.copy;
        _OSLogSystem = nil;
        _OSLogType = OS_LOG_TYPE_DEFAULT;
    }
    return self;
}

+ (XZLogSystem *)debugLogSystem {
    static XZLogSystem *_system = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _system = [[XZLogSystem alloc] initWithName:@"DEBUG" domain:@"com.xezun.XZKit" type:OS_LOG_TYPE_DEBUG];
    });
    return _system;
}

+ (XZLogSystem *)errorLogSystem {
    static XZLogSystem *_system = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _system = [[XZLogSystem alloc] initWithName:@"ERROR" domain:@"com.xezun.XZKit" type:OS_LOG_TYPE_ERROR];
    });
    return _system;
}

+ (XZLogSystem *)faultLogSystem {
    static XZLogSystem *_system = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _system = [[XZLogSystem alloc] initWithName:@"FAULT" domain:@"com.xezun.XZKit" type:OS_LOG_TYPE_FAULT];
    });
    return _system;
}

@synthesize OSLogSystem = _OSLogSystem;

- (os_log_t)OSLogSystem {
    if (_OSLogSystem == nil) {
        const char *subsystem = [_domain cStringUsingEncoding:NSISOLatin1StringEncoding];
        const char *category = [_name cStringUsingEncoding:NSISOLatin1StringEncoding];
        _OSLogSystem = os_log_create(subsystem, category);
    }
    return _OSLogSystem;
}

@end
