//
//  NSDictionary+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/6/23.
//

#import "NSDictionary+XZKit.h"
#import "NSArray+XZKit.h"
#import "NSString+XZKit.h"

@implementation NSDictionary (XZKit)

- (BOOL)xz_boolValueForKey:(id)aKey {
    id const object = [self objectForKey:aKey];
    if (object == nil) {
        return NO;
    }
    if ([object isKindOfClass:NSNumber.class]) {
        return [(NSNumber *)object boolValue];
    }
    if ([object isKindOfClass:NSString.class]) {
        return [(NSString *)object boolValue];
    }
    if ([object isEqual:NSNull.null]) {
        return NO;
    }
    return YES;
}

- (NSInteger)xz_integerValueForKey:(id)aKey defaultValue:(NSInteger)defaultValue {
    return XZMakeInteger([self objectForKey:aKey], defaultValue);
}

- (NSInteger)xz_integerValueForKey:(id)aKey {
    return XZMakeInteger([self objectForKey:aKey], 0);
}

- (CGFloat)xz_floatValueForKey:(id)aKey defaultValue:(NSInteger)defaultValue {
    return XZMakeFloat([self objectForKey:aKey], defaultValue);
}

- (CGFloat)xz_floatValueForKey:(id)aKey {
    return XZMakeFloat([self objectForKey:aKey], 0);
}

@end

@implementation NSMutableDictionary (XZKit)

- (id)xz_removeObjectForKey:(id)aKey {
    id const object = [self objectForKey:aKey];
    [self removeObjectForKey:aKey];
    return object;
}

- (NSArray *)xz_removeObjectsForKeys:(NSArray *)keyArray {
    return [keyArray xz_compactMap:^id _Nullable(id  _Nonnull obj, NSInteger idx, BOOL * _Nonnull stop) {
        return [self xz_removeObjectForKey:obj];
    }];
}

@end


@implementation NSDictionary (XZJSON)

+ (instancetype)xz_dictionaryWithJSON:(id)json options:(NSJSONReadingOptions)options {
    if (json == nil) {
        return nil;
    }
    NSParameterAssert([json isKindOfClass:NSString.class] || [json isKindOfClass:NSData.class]);
    NSData *data = json;
    if ([json isKindOfClass:NSString.class]) {
        data = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    }
    if (![data isKindOfClass:NSData.class]) {
        return nil;
    }
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:options error:&error];
    if (error.code != noErr) {
        return nil;
    }
    if ([dict isKindOfClass:NSDictionary.class]) {
        return dict;
    }
    return nil;
}

+ (instancetype)xz_dictionaryWithJSON:(id)json {
    return [self xz_dictionaryWithJSON:json options:(NSJSONReadingAllowFragments)];
}

@end

@implementation NSMutableDictionary (XZJSON)

+ (instancetype)xz_dictionaryWithJSON:(id)json options:(NSJSONReadingOptions)options {
    return [super xz_dictionaryWithJSON:json options:(options | NSJSONReadingMutableContainers)];
}

@end
