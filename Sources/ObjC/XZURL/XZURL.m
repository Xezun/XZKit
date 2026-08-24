//
//  XZURL.m
//  XZURL
//
//  Created by Xezun on 2023/7/30.
//

#import "XZURL.h"
#import "XZUtils.h"

/// 将任意非 nil 的值，转化为 URL 字段可能的值，使用 kCFNull 表示 nil 值。
FOUNDATION_STATIC_INLINE id XZURLMakeQueryValue(id value) {
    if (value == (id)kCFNull) {
        return value;
    }
    if ([value isKindOfClass:NSString.class]) {
        return value;
    }
    if ([value isKindOfClass:NSNumber.class]) {
        return [(NSNumber *)value stringValue];
    }
    if ([NSJSONSerialization isValidJSONObject:value]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingFragmentsAllowed error:nil];
        if (data) {
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    return [value description];
}

FOUNDATION_STATIC_INLINE id XZURLMakeQueryValueWithArray(NSArray *anArray) {
    NSUInteger const count = anArray.count;
    switch (count) {
        case 0:
            return nil;
            
        case 1:
            return anArray[0];
            
        default: {
            NSMutableArray *items = [NSMutableArray arrayWithCapacity:count];
            for (id object in anArray) {
                [items addObject:XZURLMakeQueryValue(object)];
            }
            return items;
        }
    }
}

FOUNDATION_STATIC_INLINE id XZURLMakeQueryValueWithSet(NSSet *aSet) {
    NSUInteger const count = aSet.count;
    switch (count) {
        case 0:
            return nil;
            
        case 1:
            return aSet.anyObject;
            
        default: {
            NSMutableArray *items = [NSMutableArray arrayWithCapacity:count];
            for (id object in aSet) {
                [items addObject:XZURLMakeQueryValue(object)];
            }
            return items;
        }
    }
}

@interface XZURL ()
/// 值类型仅可能为 NSNull, NSMutableArray, NSString 三种类型。
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id> *queryValues;
/// 懒加载。通过 URL 构造的对象，并不立即生成此属性。
@property (nonatomic, strong, readonly) NSURLComponents *components;
- (BOOL)updateQueryIfNeeded;
@end

@implementation XZURL {
    @package
    NSURL           * _Nullable _url;
    NSURLComponents * _Nullable _components;
    /// 是否需要重新从 `_components` 中生成 NSURL 对象。
    BOOL _needsUpdateURL;
    /// 是否需要将 `_queryValues` 中的值，应用到 `_components` 中。
    BOOL _needsUpdateQuery;
}

@synthesize queryValues = _queryValues;

+ (instancetype)URLWithURL:(NSURL *)url {
    if (![url isKindOfClass:NSURL.class]) {
        return nil;
    }
    return [[self alloc] initWithURL:url components:nil];
}

+ (instancetype)URLWithURLString:(NSString *)URLString {
    return [self URLWithURL:NSURLFromString(URLString)];
}

+ (instancetype)URLWithComponents:(NSURLComponents *)components {
    NSParameterAssert(components != nil);
    return [[self alloc] initWithURL:nil components:components.copy];
}

- (instancetype)initWithURL:(NSURL *)url components:(NSURLComponents *)components {
    self = [super init];
    if (self) {
        _url = url;
        _components = components;
        _queryValues = nil;
        _needsUpdateURL = (_url == nil);
        _needsUpdateQuery = NO;
    }
    return self;
}

- (NSURLComponents *)components {
    if (_components == nil) {
        if (_url) {
            _components = [[NSURLComponents alloc] initWithURL:_url resolvingAgainstBaseURL:YES];
            if (_components == nil) {
                _components = [[NSURLComponents alloc] init];
                NSURL *absoluteURL = _url.absoluteURL;
                if (absoluteURL) {
                    _components.scheme = absoluteURL.scheme;
                    _components.host = absoluteURL.host;
                    _components.port = absoluteURL.port;
                    _components.user = absoluteURL.user;
                    _components.password = absoluteURL.password;
                    _components.path = absoluteURL.path;
                    _components.query = absoluteURL.query;
                    _components.fragment = absoluteURL.fragment;
                } else {
                    _components.scheme = _url.scheme;
                    _components.host = _url.host;
                    _components.port = _url.port;
                    _components.user = _url.user;
                    _components.password = _url.password;
                    _components.path = _url.path;
                    _components.query = _url.query;
                    _components.fragment = _url.fragment;
                }
                _needsUpdateURL = YES;
            }
        } else {
            _components = [[NSURLComponents alloc] init];
            _needsUpdateURL = YES;
        }
    }
    return _components;
}

#pragma mark - 公开方法

- (NSURL *)URL {
    if ([self updateQueryIfNeeded] || _needsUpdateURL) {
        _url = self.components.URL;
        _needsUpdateURL = NO;
    }
    return _url;
}

- (NSString *)scheme {
    return self.components.scheme;
}

- (void)setScheme:(NSString *)scheme {
    _needsUpdateURL = YES;
    self.components.scheme = scheme;
}

- (NSString *)user {
    return self.components.user;
}

- (void)setUser:(NSString *)user {
    _needsUpdateURL = YES;
    self.components.user = user;
}

- (NSString *)password {
    return self.components.password;
}

- (void)setPassword:(NSString *)password {
    _needsUpdateURL = YES;
    self.components.password = password;
}

- (NSString *)host {
    return self.components.host;
}

- (void)setHost:(NSString *)host {
    _needsUpdateURL = YES;
    self.components.host = host;
}

- (NSNumber *)port {
    return self.components.port;
}

- (void)setPort:(NSNumber *)port {
    _needsUpdateURL = YES;
    self.components.port = port;
}

- (NSString *)path {
    return self.components.path;
}

- (void)setPath:(NSString *)path {
    _needsUpdateURL = YES;
    self.components.path = path;
}

- (NSString *)query {
    [self updateQueryIfNeeded];
    return self.components.query;
}

- (void)setQuery:(NSString *)query {
    _needsUpdateURL = YES;
    self.components.query = query;
    // 清空以便重新生成
    _queryValues = nil;
    _needsUpdateQuery = NO;
}

- (NSString *)fragment {
    return self.components.fragment;
}

- (void)setFragment:(NSString *)fragment {
    _needsUpdateURL = YES;
    self.components.fragment = fragment;
}

- (NSString *)description {
    NSString *URLString = self.URL.absoluteString;
    return [NSString stringWithFormat:@"<%@: %p, %@>", [XZURL class], self, URLString];
}

// MARK: - URLQuery 私有方法

/// 合并数据，并同时更新 `_queryValues` 字典。
- (BOOL)updateQueryIfNeeded {
    if (!_needsUpdateQuery) {
        return NO;
    }
    _needsUpdateQuery = NO;
    if (_queryValues.count == 0) {
        self.components.queryItems = nil;
    } else {
        NSMutableArray *queryItemsM = [NSMutableArray arrayWithCapacity:_queryValues.count];
        [_queryValues enumerateKeysAndObjectsUsingBlock:^(NSString *key, id _Nonnull value, BOOL * _Nonnull stop) {
            if (value == (id)kCFNull) {
                NSURLQueryItem *item = [[NSURLQueryItem alloc] initWithName:key value:nil];
                [queryItemsM addObject:item];
            } else if ([value isKindOfClass:NSArray.class]) {
                for (id itemValue in value) {
                    NSURLQueryItem *item = nil;
                    if (itemValue == (id)kCFNull) {
                        item = [[NSURLQueryItem alloc] initWithName:key value:nil];
                    } else {
                        item = [[NSURLQueryItem alloc] initWithName:key value:itemValue];
                    }
                    [queryItemsM addObject:item];
                }
            } else {
                NSURLQueryItem *item = [[NSURLQueryItem alloc] initWithName:key value:value];
                [queryItemsM addObject:item];
            }
        }];
        self.components.queryItems = queryItemsM;
    }
    return YES;
}

- (NSMutableDictionary *)queryValues {
    if (_queryValues == nil) {
        _queryValues = [NSMutableDictionary dictionary];
        // 如果从未获取过 queryValues 就直接调用 removeAllQueryFields 方法，那么 nil 就是最新的状态。
        if (!_needsUpdateQuery) {
            for (NSURLQueryItem * _Nonnull obj in self.components.queryItems) {
                NSString * const name  = obj.name;
                id         const value = obj.value ?: (id)kCFNull;
                NSMutableArray * const oldValue = _queryValues[obj.name];
                if (oldValue == nil) {
                    _queryValues[name] = value;
                } else if ([oldValue isKindOfClass:NSMutableArray.class]) {
                    [oldValue addObject:value];
                } else {
                    _queryValues[name] = [NSMutableArray arrayWithObjects:oldValue, value, nil];
                }
            }
        }
    }
    return _queryValues;
}

// MARK: - URLQuery 公开方法

- (NSDictionary<NSString *,id> *)allQueryFields {
    if (_needsUpdateQuery) {
        return _queryValues.copy ?: @{};
    }
    return self.queryValues.copy;
}

- (id)valueForQueryField:(NSString *)field {
    id value = self.queryValues[field];
    if (value == (id)kCFNull) {
        return nil;
    }
    return value;
}

- (void)setValue:(id const)value forQueryField:(NSString * const)field {
    if (value == nil) {
        // 删除字段
        self.queryValues[field] = nil;
    } else if ([value isKindOfClass:NSArray.class]) {
        self.queryValues[field] = XZURLMakeQueryValueWithArray(value);
    } else if ([value isKindOfClass:NSSet.class]) {
        self.queryValues[field] = XZURLMakeQueryValueWithSet(value);
    } else {
        // 设置字段
        self.queryValues[field] = XZURLMakeQueryValue(value);
    }
    _needsUpdateQuery = YES;
}

- (void)addValue:(id const)value forQueryField:(NSString * const)field {
    NSMutableArray * const oldValue = self.queryValues[field];
    
    if (oldValue == nil) {
        if (value == nil) {
            self.queryValues[field] = (id)kCFNull;
        } else if ([value isKindOfClass:NSArray.class]) {
            self.queryValues[field] = XZURLMakeQueryValueWithArray(value);
        } else if ([value isKindOfClass:NSSet.class]) {
            self.queryValues[field] = XZURLMakeQueryValueWithSet(value);
        } else {
            self.queryValues[field] = XZURLMakeQueryValue(value);
        }
    } else if ([oldValue isKindOfClass:NSMutableArray.class]) {
        if (value == nil) {
            [oldValue addObject:(id)kCFNull];
        } else if ([value isKindOfClass:NSArray.class]) {
            for (id object in value) {
                [oldValue addObject:XZURLMakeQueryValue(object)];
            }
        } else if ([value isKindOfClass:NSSet.class]) {
            for (id object in value) {
                [oldValue addObject:XZURLMakeQueryValue(object)];
            }
        } else {
            [oldValue addObject:XZURLMakeQueryValue(value)];
        }
    } else {
        if (value == nil) {
            self.queryValues[field] = [NSMutableArray arrayWithObjects:oldValue, (id)kCFNull, nil];
        } else if ([value isKindOfClass:NSArray.class]) {
            NSUInteger const count = ((NSArray *)value).count;
            if (count > 0) {
                NSMutableArray *items = [NSMutableArray arrayWithCapacity:count + 1];
                [items addObject:oldValue];
                for (id object in value) {
                    [items addObject:XZURLMakeQueryValue(object)];
                }
                self.queryValues[field] = items;
            }
        } else if ([value isKindOfClass:NSSet.class]) {
            NSUInteger const count = ((NSArray *)value).count;
            if (count > 0) {
                NSMutableArray *items = [NSMutableArray arrayWithCapacity:count + 1];
                [items addObject:oldValue];
                for (id object in value) {
                    [items addObject:XZURLMakeQueryValue(object)];
                }
                self.queryValues[field] = items;
            }
        } else {
            self.queryValues[field] = [NSMutableArray arrayWithObjects:XZURLMakeQueryValue(oldValue), XZURLMakeQueryValue(value), nil];
        }
    }
    
    _needsUpdateQuery = YES;
}

- (void)removeAllQueryFields {
    [_queryValues removeAllObjects];
    _needsUpdateQuery = YES;
}

- (id)objectForKeyedSubscript:(NSString *)field {
    return [self valueForQueryField:field];
}

- (void)setObject:(id)value forKeyedSubscript:(NSString *)field {
    [self setValue:value forQueryField:field];
}

- (BOOL)containsValueForQueryField:(NSString *)field {
    return [self.queryValues objectForKey:field] != nil;
}

- (NSString *)stringValueForQueryField:(NSString *)field {
    id const value = self.queryValues[field];
    if (value == nil) {
        return nil;
    }
    if ([value isKindOfClass:NSString.class]) {
        return value;
    }
    if (value == (id)kCFNull) {
        return nil;
    }
    if ([value isKindOfClass:NSArray.class]) {
        for (id object in (NSArray *)value) {
            if ([object isKindOfClass:NSString.class]) {
                return object;
            }
        }
    }
    return nil;
}

- (NSArray *)arrayValueForQueryField:(NSString *)field {
    id const value = self.queryValues[field];
    
    if (!value) {
        return nil;
    }
    
    if ([value isKindOfClass:NSArray.class]) {
        return value;
    }
    
    return @[value];
}

- (NSInteger)integerValueForQueryField:(NSString *)name {
    return [[self stringValueForQueryField:name] integerValue];
}

- (CGFloat)floatValueForQueryField:(NSString *)name {
#if CGFLOAT_IS_DOUBLE
    return [[self stringValueForQueryField:name] doubleValue];
#else
    return [[self stringValueForQueryField:name] floatValue];
#endif
}

- (NSURL *)urlValueForQueryField:(NSString *)name {
    NSString * const string = [self stringValueForQueryField:name];
    if (string == nil) {
        return nil;
    }
    return [NSURL URLWithString:string];
}

- (void)addValuesForQueryFieldsWithDictionary:(NSDictionary<NSString *,id> *)dictionary {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self addValue:obj forQueryField:key];
    }];
}

- (void)setValuesForQueryFieldsWithDictionary:(NSDictionary<NSString *,id> *)dictionary {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self setValue:obj forQueryField:key];
    }];
}

@end


@implementation NSURL (XZURL)

- (XZURL *)XZURL {
    return [[XZURL alloc] initWithURL:self components:nil];
}

@end
