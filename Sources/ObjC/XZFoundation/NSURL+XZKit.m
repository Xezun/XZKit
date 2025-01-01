//
//  NSURL+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/5/9.
//

#import "NSURL+XZKit.h"

@implementation NSURL (XZKit)

- (XZURLQuery *)xz_query {
    return [XZURLQuery URLQueryForURL:self resolvingAgainstBaseURL:(self.baseURL != nil)];
}

@end

@interface XZURLQuery () {
    NSURLComponents * _Nonnull _urlComponents;
    NSMutableArray<NSURLQueryItem *> *_queryItems;
}
@end

@implementation XZURLQuery

- (instancetype)initWithURLComponents:(NSURLComponents *)urlComponents {
    NSParameterAssert(urlComponents != nil);
    self = [super init];
    if (self) {
        _urlComponents = urlComponents;
        _queryItems = nil;
    }
    return self;
}

+ (instancetype)URLQueryForURL:(NSURL *)url resolvingAgainstBaseURL:(BOOL)resolve {
    if (![url isKindOfClass:NSURL.class]) {
        return nil;
    }
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:resolve];
    if (urlComponents == nil) {
        return nil;
    }
    return [[self alloc] initWithURLComponents:urlComponents];
}

+ (instancetype)URLQueryForURL:(NSURL *)url {
    return [self URLQueryForURL:url resolvingAgainstBaseURL:NO];
}

+ (instancetype)URLQueryWithString:(NSString *)urlString {
    if (![urlString isKindOfClass:NSString.class]) {
        return nil;
    }
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:urlString];
    if (urlComponents == nil) {
        return nil;
    }
    return [[self alloc] initWithURLComponents:urlComponents];
}

/// 将任意对象解析为可做为查询字段的名或值。
+ (nullable NSString *)parseValueForField:(id)value {
    if (value == nil || value == NSNull.null) {
        return nil;
    }
    if ([value isKindOfClass:NSString.class]) {
        return value;
    }
    if ([value isKindOfClass:NSNumber.class]) {
        return [(NSNumber *)value stringValue];
    }
    if ([value isKindOfClass:NSDate.class]) {
        NSTimeInterval const timestamp = [(NSDate *)value timeIntervalSince1970];
        return [NSString stringWithFormat:@"%f", timestamp];
    }
    NSAssert(NO, @"对象 %@ 不可以作为 URL 的查询字段", value);
    return [value description];
}

+ (void)parseFieldValue:(id)value byUsingBlock:(void (^NS_NOESCAPE)(NSString * _Nullable))block {
    NSParameterAssert(block != nil);
    if ([value isKindOfClass:NSArray.class]) {
        NSArray * const array = value;
        if (array.count > 0) {
            for (id object in array) {
                block([self parseValueForField:object]);
            }
        } else {
            block(nil);
        }
    } else if ([value isKindOfClass:NSSet.class]) {
        NSSet * const set = value;
        if (set.count > 0) {
            for (id object in set) {
                block([self parseValueForField:object]);
            }
        } else {
            block(nil);
        }
    } else {
        block([self parseValueForField:value]);
    }
}

- (id)copyWithZone:(NSZone *)zone {
    return [[XZURLQuery alloc] initWithURLComponents:_urlComponents.copy];
}

- (NSMutableArray<NSURLQueryItem *> *)queryItemsLazyLoad {
    if (_queryItems != nil) {
        return _queryItems;
    }
    NSArray *queryItems = _urlComponents.queryItems;
    if (queryItems == nil) {
        _queryItems = [NSMutableArray array];
    } else {
        _queryItems = [NSMutableArray arrayWithArray:queryItems];
    }
    return _queryItems;
}

- (NSURL *)url {
    if (_queryItems) {
        if (_queryItems.count > 0) {
            _urlComponents.queryItems = _queryItems;
        } else {
            _urlComponents.queryItems = nil;
        }
    }
    return _urlComponents.URL;
}

- (NSDictionary<NSString *,id> *)dictionaryRepresentation {
    NSMutableDictionary       * const keyedValues = [NSMutableDictionary dictionary];
    NSArray<NSURLQueryItem *> * const queryItems  = [self queryItemsLazyLoad];
    for (NSURLQueryItem * const queryItem in queryItems) {
        NSString * const key   = queryItem.name;
        id         const value = (queryItem.value ?: NSNull.null);
        if (keyedValues[key] == nil) {
            keyedValues[key] = value;
        } else if ([keyedValues[key] isKindOfClass:NSMutableArray.class]) {
            [keyedValues[key] addObject:value];
        } else {
            keyedValues[key] = [NSMutableArray arrayWithObjects:keyedValues, value, nil];
        }
    }
    return keyedValues;
}

- (id)valueForField:(NSString *)field {
    NSParameterAssert([field isKindOfClass:NSString.class]);
    
    NSArray * const queryItems = [self queryItemsLazyLoad];
    id result = nil;
    for (NSURLQueryItem *item in queryItems) {
        if ([item.name isEqual:field]) {
            id const value = item.value ?: NSNull.null;
            if (result == nil) {
                result = value;
            } else if ([result isKindOfClass:NSMutableArray.class]) {
                [result addObject:value];
            } else {
                result = [NSMutableArray arrayWithObjects:result, value, nil];
            }
        }
    }
    
    if (result == NSNull.null) {
        return nil;
    }
    
    return result;
}

- (void)setValue:(id)value forField:(NSString *)field {
    [self removeField:field];
    [self addValue:value forField:field];
}

- (void)addValue:(id<NSObject>)value forField:(NSString *)field {
    NSMutableArray * const queryItems = [self queryItemsLazyLoad];
    [XZURLQuery parseFieldValue:value byUsingBlock:^(NSString * _Nullable value) {
        NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:field value:value];
        [queryItems addObject:item];
    }];
}

- (void)removeValue:(id)value forField:(NSString *)field {
    NSParameterAssert([field isKindOfClass:NSString.class]);
    
    value = [XZURLQuery parseValueForField:value];
    
    NSMutableArray * const queryItems = [self queryItemsLazyLoad];
    for (NSInteger index = queryItems.count - 1; index >= 0; index--) {
        NSURLQueryItem * const item = queryItems[index];
        if ([item.name isEqualToString:field]) {
            if (value == nil && item.value == nil) {
                [queryItems removeObjectAtIndex:index];
                continue;
            }
            if ([value isEqualToString:item.value]) {
                [queryItems removeObjectAtIndex:index];
                continue;
            }
        }
    }
}

- (void)removeField:(NSString *)field {
    NSParameterAssert([field isKindOfClass:NSString.class]);
    
    NSMutableArray * const queryItems = [self queryItemsLazyLoad];
    for (NSInteger index = queryItems.count - 1; index >= 0; index--) {
        NSURLQueryItem * const item = queryItems[index];
        if ([item.name isEqualToString:field]) {
            [queryItems removeObjectAtIndex:index];
            continue;
        }
    }
}

- (void)removeAllFields {
    if (_queryItems == nil) {
        _queryItems = [NSMutableArray array];
    } else {
        [_queryItems removeAllObjects];
    }
}

- (BOOL)containsField:(NSString *)field {
    NSParameterAssert([field isKindOfClass:NSString.class]);
    
    NSMutableArray * const queryItems = [self queryItemsLazyLoad];
    for (NSInteger index = queryItems.count - 1; index >= 0; index--) {
        NSURLQueryItem * const item = queryItems[index];
        if ([item.name isEqualToString:field]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)addValuesForFieldsFromObject:(id)object {
    if ([object isKindOfClass:NSDictionary.class]) {
        [(NSDictionary *)object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *field = [XZURLQuery parseValueForField:key];
            if (field != nil) {
                [self addValue:obj forField:key];
            }
        }];
    } else if ([object isKindOfClass:NSArray.class] || [object isKindOfClass:NSSet.class]) {
        for (id<NSObject> value in object) {
            NSString * const field = [XZURLQuery parseValueForField:value];
            if (field != nil) {
                [self addValue:nil forField:field];
            }
        }
    }
}

- (void)setValuesForFieldsWithObject:(id)object {
    if ([object isKindOfClass:NSDictionary.class]) {
        [(NSDictionary *)object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *field = [XZURLQuery parseValueForField:key];
            if (field != nil) {
                [self setValue:obj forField:key];
            }
        }];
    } else if ([object isKindOfClass:NSArray.class] || [object isKindOfClass:NSSet.class]) {
        for (id<NSObject> value in object) {
            NSString *field = [XZURLQuery parseValueForField:value];
            if (field != nil) {
                [self setValue:nil forField:field];
            }
        }
    }
}

- (id)objectForKeyedSubscript:(NSString *)field {
    return [self valueForField:field];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)field {
    [self setValue:obj forField:field];
}

@end
