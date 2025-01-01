//
//  XZJSON.m
//  XZKit
//
//  Created by Xezun on 2021/2/14.
//

#import "XZJSON.h"

@implementation NSData (XZJSON)

+ (instancetype)xz_dataWithJSONObject:(id)object options:(NSJSONWritingOptions)options {
    if (object == nil) {
        return nil;
    }
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:options error:&error];
    if (error.code != noErr) {
        XZLog(@"对象转 JSON 发生错误：%@", error);
        return nil;
    }
    return [self dataWithData:data];
}

+ (instancetype)xz_dataWithJSONObject:(id)object {
    return [self xz_dataWithJSONObject:object options:(NSJSONWritingFragmentsAllowed)];
}

@end


@implementation NSString (XZJSON)

+ (instancetype)xz_stringWithJSONObject:(id)object options:(NSJSONWritingOptions)options {
    NSData *data = [NSData xz_dataWithJSONObject:object options:options];
    if (data == nil) {
        return nil;
    }
    return [[self alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (instancetype)xz_stringWithJSONObject:(id)object {
    return [self xz_stringWithJSONObject:object options:(NSJSONWritingFragmentsAllowed)];
}

+ (instancetype)xz_stringWithJSON:(NSData *)json {
    if (json == nil) {
        return nil;
    }
    NSParameterAssert([json isKindOfClass:NSData.class]);
    return [[self alloc] initWithData:json encoding:NSUTF8StringEncoding];
}

@end


@implementation NSArray (XZJSON)

+ (NSArray *)xz_arrayWithJSON:(id const)json options:(NSJSONReadingOptions const)options {
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
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:options error:&error];
    if (error.code != noErr) {
        XZLog(@"JSON 数据转数组发生错误：%@", error);
        return nil;
    }
    if (![array isKindOfClass:NSArray.class]) {
        XZLog(@"JSON 数据并非数组：%@", array);
        return nil;
    }
    return [[self alloc] initWithArray:array];
}


+ (instancetype)xz_arrayWithJSON:(id)json {
    return [self xz_arrayWithJSON:json options:(NSJSONReadingAllowFragments)];
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
        XZLog(@"JSON 数据转数组发生错误：%@", error);
        return nil;
    }
    if (![dict isKindOfClass:NSDictionary.class]) {
        XZLog(@"JSON 数据并非字典：%@", dict);
        return nil;
    }
    return [[self alloc] initWithDictionary:dict];
}

+ (instancetype)xz_dictionaryWithJSON:(id)json {
    return [self xz_dictionaryWithJSON:json options:(NSJSONReadingAllowFragments)];
}

@end
