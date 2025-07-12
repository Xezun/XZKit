//
//  NSString+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/6/23.
//

#import "NSString+XZKit.h"
#import "NSCharacterSet+XZKit.h"
#import <CoreText/CoreText.h>
#import <objc/NSObjCRuntime.h>
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (XZKit)

- (void)xz_enumerateSubstringsMatchedGlyphOfFont:(UIFont *)textFont usingBlock:(void (^)(NSRange range))block {
    if (block == nil || textFont == nil) {
        return;
    }
    
    CTFontRef const font = CTFontCreateWithName((__bridge CFStringRef)[textFont fontName], textFont.pointSize, NULL);
    UniChar * const cext = (UniChar *)[self cStringUsingEncoding:NSUTF16StringEncoding]; // CoreText 使用 UTF16 编码
    
    BOOL    __block start = NO;
    NSRange __block range = NSMakeRange(NSNotFound, 0);
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        CGGlyph glyph[10];
        if (CTFontGetGlyphsForCharacters(font, cext + enclosingRange.location, glyph, enclosingRange.length)) {
            if (start) {
                range.length += enclosingRange.length;
            } else {
                start = YES;
                range = enclosingRange;
            }
            return;
        }
        if (start) {
            block(range);
            range.location = NSNotFound;
            start = NO;
        }
    }];
    
    if (start) {
        block(range);
    }
}

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

- (NSString *)xz_stringByAddingPercentEncoding {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.xz_letterAndDigitCharacterSet];
}

- (NSString *)xz_stringByAddingURIEncoding {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.xz_URIAllowedCharacterSet];
}

- (NSString *)xz_stringByAddingURIComponentEncoding {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.xz_URIComponentAllowedCharacterSet];
}

- (NSString *)xz_stringByRemovingURIEncoding {
    return [self stringByRemovingPercentEncoding];
}

- (NSString *)xz_stringByRemovingURIComponentEncoding {
    return [self stringByRemovingPercentEncoding];
}

- (NSString *)xz_stringByTransformingMandarinToLatin {
    CFMutableStringRef mString = CFStringCreateMutableCopy(kCFAllocatorDefault, self.length, (__bridge CFStringRef)self);
    
    CFStringTransform(mString, nil, kCFStringTransformMandarinLatin, false);
    CFStringTransform(mString, nil, kCFStringTransformStripDiacritics, false);
    
    return (__bridge_transfer NSString *)mString;
}

@end



@implementation NSString (XZHexEncoding)

- (NSString *)xz_stringByAddingHexEncoding:(XZHexEncoding)hexEncoding usingEncoding:(NSStringEncoding)stringEncoding {
    NSData * const data = [self dataUsingEncoding:stringEncoding];
    return [data xz_hexEncodedString:hexEncoding];
}

- (NSString *)xz_stringByAddingHexEncodingUsingEncoding:(NSStringEncoding)stringEncoding {
    return [self xz_stringByAddingHexEncoding:(XZLowercaseHexEncoding) usingEncoding:stringEncoding];
}

- (NSString *)xz_stringByAddingHexEncoding:(XZHexEncoding)hexEncoding {
    return [self xz_stringByAddingHexEncoding:hexEncoding usingEncoding:NSUTF8StringEncoding];
}

- (NSString *)xz_stringByAddingHexEncoding {
    return [self xz_stringByAddingHexEncoding:(XZLowercaseHexEncoding)];
}

- (NSString *)xz_stringByRemovingHexEncodingUsingEncoding:(NSStringEncoding)dataEncoding {
    NSData *data = [NSData xz_dataWithHexEncodedString:self];
    return [[NSString alloc] initWithData:data encoding:dataEncoding];
}

- (NSString *)xz_stringByRemovingHexEncoding {
    return [self xz_stringByRemovingHexEncodingUsingEncoding:NSUTF8StringEncoding];
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

