//
//  XZMocoaDomain.m
//  XZMocoa
//
//  Created by Xezun on 2023/7/29.
//

#import "XZMocoaDomain.h"
#import "XZMocoaDefines.h"

static NSMutableDictionary<NSString *, XZMocoaDomain *> *_domainTable = nil;

@implementation XZMocoaDomain {
    // TODO: 缓存过期功能
    NSMutableDictionary<NSString *, id> *_keyedModules;
}

+ (id)moduleForURL:(NSURL *)url {
    NSString *path = url.path;
    if (path == nil || path.length == 0) {
        path = @"/";
    }
    return [[self doaminNamed:url.host] moduleForPath:path];
}

+ (XZMocoaDomain *)doaminForName:(NSString *)name {
    return [self doaminNamed:name];
}

+ (XZMocoaDomain *)doaminNamed:(NSString *)name {
    NSParameterAssert(name && name.length > 0);
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _domainTable = [NSMutableDictionary dictionary];
    });
    
    XZMocoaDomain *domain = _domainTable[name];
    if (domain == nil) {
        domain = [[XZMocoaDomain alloc] initWithName:name];
        _domainTable[name] = domain;
    }
    return domain;
}

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name.copy;
        _keyedModules = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)moduleForPath:(NSString *)path {
    NSAssert([XZMocoaDomain isValidPath:path], @"参数 path 不合法或不规范：%@", path);
    
    id module = _keyedModules[path];
    if (module != nil) {
        return module;
    }
    
    id<XZMocoaModuleProvider> const provider = self.provider;
    if (provider == nil) {
        return nil;
    }
    
    module = [provider domain:self moduleForPath:path];
    _keyedModules[path] = module;
    return module;
}

- (void)setModule:(id)module forPath:(NSString *)path {
    NSAssert([XZMocoaDomain isValidPath:path], @"参数 path 不合法或不规范：%@", path);
    _keyedModules[path] = module;
}

/// 验证 path 是否合法。
/// - Parameter path: 待验证的路径
+ (BOOL)isValidPath:(NSString *)path {
    switch (path.length) {
        case 0:
            return NO;
        case 1:
            if ([path isEqualToString:@"/"]) {
                return YES;
            }
            return NO;
        default:
            break;
    }
    
    static NSRegularExpression *_regularExpression = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // /kind:name | /kind: | /name | /:
        NSString *pattern = @"^((/\\w+\\:\\w*)|(/\\w+)|(/\\:))+$";
        _regularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    });
    
    NSRange range = NSMakeRange(0, path.length);
    range = [_regularExpression rangeOfFirstMatchInString:path options:0 range:range];
    return range.location == 0 && range.length == path.length;
}

@end
