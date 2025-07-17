//
//  NSString+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/6/23.
//

#import <CoreText/CoreText.h>
#import <objc/NSObjCRuntime.h>
#import <CommonCrypto/CommonDigest.h>
#import "NSString+XZKit.h"
#import "XZLog.h"

@implementation NSString (XZKit)

- (CGFloat)xz_floatValue {
    return [self xz_floatValue:0];
}

- (CGFloat)xz_floatValue:(CGFloat)defaultValue {
    if (self.length == 0) {
        return defaultValue;
    }
    const char *str = self.UTF8String;
    char *ptr;
#if CGFLOAT_IS_DOUBLE
    CGFloat const value = strtod(str, &ptr);
#else
    CGFloat const value = strtof(str, &ptr);
#endif
    return ptr == NULL ? value : (ptr[0] == '\0' ? value : defaultValue);
}

- (NSInteger)xz_integerValue {
    return [self xz_integerValue:0 base:10];
}

- (NSInteger)xz_integerValue:(NSInteger)defaultValue base:(int)base {
    if (self.length == 0) {
        return defaultValue;
    }
    const char *str = self.UTF8String;
    char *ptr;
    long const value = strtol(str, &ptr, base);
    return (NSInteger)(ptr == NULL ? value : (ptr[0] == '\0' ? value : defaultValue));
}

+ (instancetype)xz_initWithBytesNoCopy:(void *)bytes from:(NSInteger)from to:(NSInteger)to encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)freeBuffer {
    NSInteger const length = to - from;
    if (length < 1) {
        return nil;
    }
    return [[self alloc] initWithBytesNoCopy:(bytes + from) length:length encoding:encoding freeWhenDone:freeBuffer];
}

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
