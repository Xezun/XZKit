//
//  XZURLQuery.m
//  XZURLQuery
//
//  Created by Xezun on 2023/7/30.
//

#import "XZURLQuery.h"

/// value 不能为数组。
FOUNDATION_STATIC_INLINE id XZURLQueryMakeValue(id value) {
    if (value == NSNull.null) {
        return nil;
    }
    if ([value isKindOfClass:NSString.class]) {
        return value;
    }
    if ([NSJSONSerialization isValidJSONObject:value]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingFragmentsAllowed error:nil];
        if (data) {
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    return [value description];
}

FOUNDATION_STATIC_INLINE void XZURLQueryParser(NSMutableDictionary *dictM, NSURLComponents *components) {
    [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * const name  = obj.name;
        id         const value = obj.value ?: NSNull.null;
        NSMutableArray * const oldValue = dictM[obj.name];
        if (oldValue == nil) {
            dictM[name] = value;
        } else if ([oldValue isKindOfClass:NSMutableArray.class]) {
            [oldValue addObject:value];
        } else {
            dictM[name] = [NSMutableArray arrayWithObjects:oldValue, value, nil];
        }
    }];
}

@interface XZURLQuery ()
@property (nonatomic, strong, readonly) NSURLComponents *components;
@property (nonatomic, strong, readonly) NSMutableDictionary *keyedValues;
@end

@implementation XZURLQuery {
    NSURL *_url;
    /// `_keyedValues` 是否已合并到 `_components` 中。
    /// 为 YES 时，表示 `_keyedValues` 已更新（可能为 nil)。
    BOOL _needsMergeKeyedValues;
    NSURLComponents * _Nullable _components;
    /// 值类型仅可能为 NSNull, NSMutableArray, NSString 三种类型。
    NSMutableDictionary<NSString *, id> * _Nullable _keyedValues;
}

+ (instancetype)queryForURL:(NSURL *)url {
    if (url == nil) return nil;
    return [[self alloc] initWithURL:url];
}

+ (instancetype)queryForURLString:(NSString *)URLString {
    NSURL *url = [NSURL URLWithString:URLString];
    if (url == nil) return nil;
    return [[self alloc] initWithURL:url];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _needsMergeKeyedValues = NO;
        _url = url.copy;
        _keyedValues = nil;
    }
    return self;
}

#pragma mark - 私有方法

/// 合并数据，并同时更新 `_keyedValues` 字典。
- (void)mergeKeyedValuesIfNeeded {
    if (!_needsMergeKeyedValues) {
        return;
    }
    _needsMergeKeyedValues = NO;
    if (_keyedValues.count == 0) {
        self.components.queryItems = nil;
    } else {
        NSMutableArray *queryItemsM = [NSMutableArray arrayWithCapacity:_keyedValues.count];
        [_keyedValues enumerateKeysAndObjectsUsingBlock:^(NSString *key, id _Nonnull value, BOOL * _Nonnull stop) {
            if ([value isKindOfClass:NSMutableArray.class]) {
                NSMutableArray * const newValue = value;
                for (NSInteger i = 0; i < newValue.count; i++) {
                    id const itemValue = XZURLQueryMakeValue(newValue[i]);
                    NSURLQueryItem *item = [[NSURLQueryItem alloc] initWithName:key value:itemValue];
                    [queryItemsM addObject:item];
                }
            } else {
                id const newValue = XZURLQueryMakeValue(value);
                NSURLQueryItem *item = [[NSURLQueryItem alloc] initWithName:key value:newValue];
                [queryItemsM addObject:item];
            }
        }];
        self.components.queryItems = queryItemsM;
    }
}

- (NSURLComponents *)components {
    if (_components == nil) {
        _components = [NSURLComponents componentsWithURL:_url resolvingAgainstBaseURL:NO];
    }
    return _components;
}

- (NSMutableDictionary *)keyedValues {
    if (_keyedValues == nil) {
        _keyedValues = [NSMutableDictionary dictionary];
        if (!_needsMergeKeyedValues) {
            XZURLQueryParser(_keyedValues, self.components);
        }
    }
    return _keyedValues;
}

- (void)addValue:(nonnull id)value forKey:(NSString *)key {
    NSMutableArray<NSURLQueryItem *> *oldValue = self.keyedValues[key];
    if ([oldValue isKindOfClass:NSMutableArray.class]) {
        [oldValue addObject:value];
    } else if (oldValue == nil) {
        self.keyedValues[key] = value;
    } else {
        oldValue = [NSMutableArray arrayWithObjects:oldValue, value, nil];
        self.keyedValues[key] = oldValue;
    }
}

#pragma mark - 公开方法

- (NSURL *)url {
    [self mergeKeyedValuesIfNeeded];
    if (_components == nil) {
        return _url;
    }
    return _components.URL;
}

- (NSDictionary<NSString *,id> *)allValues {
    [self mergeKeyedValuesIfNeeded];
    NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithCapacity:self.keyedValues.count];
    XZURLQueryParser(dictM, self.components);
    return dictM;
}

- (id)valueForName:(NSString *)name {
    id value = self.keyedValues[name];
    if (value == NSNull.null) {
        return nil;
    }
    return value;
}

- (void)setValue:(id)value forName:(NSString *)name {
    if (value == nil) {
        // 删除字段
        self.keyedValues[name] = nil;
    } else if ([value isKindOfClass:NSArray.class]) {
        // 设置为数组
        self.keyedValues[name] = [(NSArray *)value mutableCopy];
    } else {
        // 设置为值
        self.keyedValues[name] = value;
    }
    _needsMergeKeyedValues = YES;
}

- (void)addValue:(id)value forName:(NSString *)name {
    if (value == nil) {
        [self addValue:NSNull.null forKey:name];
    } else if ([value isKindOfClass:NSArray.class]) {
        for (NSObject *object in value) {
            [self addValue:object forKey:value];
        }
    } else {
        [self addValue:value forKey:name];
    }
    _needsMergeKeyedValues = YES;
}

- (void)removeAllValues {
    [_keyedValues removeAllObjects];
    _needsMergeKeyedValues = YES;
}

- (id)objectForKeyedSubscript:(NSString *)name {
    return [self valueForName:name];
}

- (void)setObject:(id)value forKeyedSubscript:(NSString *)name {
    [self setValue:value forName:name];
}

- (BOOL)containsValueForName:(NSString *)name {
    return [self.keyedValues objectForKey:name] != nil;
}

- (NSString *)stringValueForName:(NSString *)name {
    id value = self.keyedValues[name];
    if (value == nil) {
        return nil;
    }
    if ([value isKindOfClass:NSString.class]) {
        return value;
    }
    if (value == NSNull.null) {
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

- (NSInteger)integerValueForName:(NSString *)name {
    return [[self stringValueForName:name] integerValue];
}

- (CGFloat)floatValueForName:(NSString *)name {
#if CGFLOAT_IS_DOUBLE
    return [[self stringValueForName:name] doubleValue];
#else
    return [[self stringValueForName:name] floatValue];
#endif
}

- (NSURL *)urlValueForName:(NSString *)name {
    NSString *string = [self stringValueForName:name];
    if (string == nil) {
        return nil;
    }
    return [NSURL URLWithString:string];
}

- (void)addValuesFromDictionary:(NSDictionary<NSString *,id> *)dictionary {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self addValue:obj forName:key];
    }];
}

- (void)setValuesWithDictionary:(NSDictionary<NSString *,id> *)dictionary {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self setValue:obj forName:key];
    }];
}

@end


