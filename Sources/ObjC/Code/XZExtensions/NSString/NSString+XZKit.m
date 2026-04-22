//
//  NSString+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/6/23.
//

#undef XZ_STRING_TO_NUMBER_DISABLED
#import <CoreText/CoreText.h>
#import <objc/NSObjCRuntime.h>
#import <CommonCrypto/CommonDigest.h>
#import "NSString+XZKit.h"
#import "XZLog.h"

@implementation NSString (XZKit)

- (CGFloat)xz_floatValue {
    return CGFloatMake(self);
}

- (CGFloat)xz_floatValue:(CGFloat)defaultValue {
    return CGFloatMake(self, defaultValue);
}

- (NSInteger)xz_integerValue {
    return NSIntegerMake(self);
}

- (NSInteger)xz_integerValue:(NSInteger)defaultValue base:(int)base {
    return NSIntegerMake(self, defaultValue);
}

+ (instancetype)xz_initWithBytes:(void *)bytes range:(NSRange)range encoding:(NSStringEncoding)encoding {
    return [[self alloc] initWithBytesNoCopy:(bytes + range.location) length:range.length encoding:encoding freeWhenDone:NO];
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
