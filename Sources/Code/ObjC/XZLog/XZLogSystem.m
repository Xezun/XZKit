//
//  XZLogSystem.m
//  XZKit
//
//  Created by 徐臻 on 2025/7/3.
//

#import "XZLogSystem.h"

@implementation XZLogSystem {
    BOOL _isDebugLogEnabled;
    BOOL _isErrorLogEnabled;
    BOOL _isFaultLogEnabled;
}

+ (XZLogSystem *)defaultLogSystem {
    static XZLogSystem *_system = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle * const mainBundle = NSBundle.mainBundle;
        NSString * const identifier = mainBundle.bundleIdentifier ?: @"com.unknown.App";
        NSString * const name = mainBundle.infoDictionary[@"CFBundleExecutable"] ?: @"App";
        _system = [[XZLogSystem alloc] initWithName:name domain:identifier];
        _system.isEnabled = YES;
    });
    return _system;
}

+ (XZLogSystem *)XZKitLogSystem {
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
        _oslogSystem = nil;
        _isDebugLogEnabled = NO;
        _isErrorLogEnabled = NO;
        _isFaultLogEnabled = NO;
    }
    return self;
}

- (BOOL)isLogEnabledForType:(XZLogType)type {
    switch (type) {
        case XZLogTypeDebug:
            return _isDebugLogEnabled;
        case XZLogTypeError:
            return _isErrorLogEnabled;
        case XZLogTypeFault:
            return _isFaultLogEnabled;
    }
}

- (void)setLogEnabled:(BOOL)isLogEnabled forType:(XZLogType)type {
    switch (type) {
        case XZLogTypeDebug:
            _isDebugLogEnabled = isLogEnabled;
            break;
        case XZLogTypeError:
            _isErrorLogEnabled = isLogEnabled;
            break;
        case XZLogTypeFault:
            _isFaultLogEnabled = isLogEnabled;
            break;
    }
}

@synthesize oslogSystem = _oslogSystem;

- (os_log_t)oslogSystem {
    if (_oslogSystem == nil) {
        const char * const subsystem = [_domain cStringUsingEncoding:NSISOLatin1StringEncoding];
        const char * const category = [_name cStringUsingEncoding:NSISOLatin1StringEncoding];
        _oslogSystem = os_log_create(subsystem, category);
    }
    return _oslogSystem;
}

@end
