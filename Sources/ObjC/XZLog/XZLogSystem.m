//
//  XZLogSystem.m
//  XZKit
//
//  Created by Xezun on 2025/7/3.
//

#import "XZLogSystem.h"

@implementation XZLogSystem {
    os_log_t _oslog;
}

+ (XZLogSystem *)defaultSystem {
    static XZLogSystem *_system = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle * const mainBundle = NSBundle.mainBundle;
        NSString * const identifier = mainBundle.bundleIdentifier ?: @"com.unknown.App";
        NSString * const name = mainBundle.infoDictionary[@"CFBundleExecutable"] ?: @"App";
        _system = [[XZLogSystem alloc] initWithName:name domain:identifier];
        _system->_oslog = OS_LOG_DEFAULT;
        _system.isEnabled = YES;
    });
    return _system;
}

+ (XZLogSystem *)XZKitSystem {
    static XZLogSystem *_system = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _system = [[XZLogSystem alloc] initWithName:@"XZKit" domain:@"com.xezun.XZKit"];
    });
    return _system;
}

- (instancetype)initWithName:(NSString *)name domain:(NSString *)domain {
    self = [super init];
    if (self) {
        _name = name.copy;
        _domain = domain.copy;
        _isEnabled = NO;
        _oslog = nil;
    }
    return self;
}

- (os_log_t)oslog {
    if (!_isEnabled) {
        return OS_LOG_DISABLED;
    }
    if (_oslog == nil) {
        const char * const subsystem = [_domain cStringUsingEncoding:NSISOLatin1StringEncoding];
        const char * const category = [_name cStringUsingEncoding:NSISOLatin1StringEncoding];
        _oslog = os_log_create(subsystem, category);
    }
    return _oslog;
}

@end
