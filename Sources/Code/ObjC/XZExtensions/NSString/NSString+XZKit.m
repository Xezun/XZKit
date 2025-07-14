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


XZMarkupPredicate const XZMarkupPredicateBraces = { '{', '}' };

static inline void appendBytes(NSMutableString *results, const char *string, NSInteger from, NSInteger to) {
    NSInteger const length = to - from;
    if (length < 1) {
        return;
    }
    NSString * const substring = [[NSString alloc] initWithBytesNoCopy:(void *)(string + from) length:length encoding:NSUTF8StringEncoding freeWhenDone:NO];
    [results appendString:substring];
}

@implementation NSString (XZMarkupPredicate)

+ (instancetype)xz_stringWithBytesInBytes:(void *)bytes from:(NSInteger)from to:(NSInteger)to encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)freeBuffer {
    NSInteger const length = to - from;
    if (length < 1) {
        return nil;
    }
    return [[self alloc] initWithBytesNoCopy:(bytes + from) length:length encoding:encoding freeWhenDone:freeBuffer];
}


- (NSString *)xz_stringByReplacingMatchesOfPredicate:(XZMarkupPredicate)predicate usingBlock:(id  _Nonnull (^NS_NOESCAPE)(NSString * _Nonnull))transform {
    NSInteger const length = [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if (length < 3) {
        return self;
    }
    const char * const string = [self cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSInteger from  = 0;
    NSInteger to    = 0;
    NSInteger state = 0; ///< 0，未遇到开始字符，也未遇到结束字符; 1，已遇到开始字符；2，已遇到结束字符；3，前一个字符是结束字符
    
    NSMutableString * const results = [NSMutableString stringWithCapacity:length * 2];
    NSMutableString * const matched = [NSMutableString string];
    
    while (to < length) {
        char const character = string[to];
        
        // 在 UTF-8 编码中 ASCII 字符是首位为 0 的字节
        if (character & 0b10000000) {
            continue;
        }
        
        // 1. 遇到标记字符就结算
        // 2. 结算不包括标记字符
        // 3. 连续两个标记字符，视为一个普通字符
        
        if (character == predicate.end) {
            switch (state) {
                case 0:
                    // 没有遇到开始字符，就遇到结束字符
                    state = 3;
                    appendBytes(results, string, from, to);
                    from = to + 1;
                    to = from;
                    break;
                case 1:
                    // 遇到开始字符后，再遇到结束字符，先标记遇到结束字符，如果紧接着遇到
                    // 1. 结束字符，视为结束字符逃逸
                    // 2. 其他字符，结算
                    state = 2;
                    appendBytes(matched, string, from, to);
                    from = to + 1;
                    to = from;
                    break;
                case 2:
                    // 遇到开始字符后，遇到连续的结束字符，逃逸一个结束字符为普通字符
                    state = 1; // 字符逃逸，恢复没有遇到结束字符状态
                    [matched appendFormat:@"%c", character];
                    from = to + 1;
                    to = from;
                    break;
                case 3:
                    // 没开始遇到结束字符，
                    if (from == to) {
                        // 连续遇到结束字符，第二个结束字符，当普通字符
                        state = 0;
                        to += 1;
                    } else {
                        // 不连续遇到结束字符
                        appendBytes(results, string, from, to);
                        from = to + 1;
                        to = from;
                    }
                    break;
                default:
                    NSAssert(NO, @"Never");
                    break;
            }
        } else if (character == predicate.start) {
            switch (state) {
                case 0:
                    // 遇到开始字符，标记状态
                    state = 1;
                    [results xz_appendBytesInBytes:(void *)string from:from to:to encoding:NSUTF8StringEncoding freeWhenDone:NO];
                    from = to + 1;
                    to = from;
                    break;
                case 1:
                    if (from == to) {
                        // 连续遇到开始字符，逃逸一个开始字符为普通字符
                        state = 0;
                        [results appendFormat:@"%c", character];
                    } else {
                        // 不连续遇到开始字符，重新开始
                        //  [results appendFormat:@"%c", character];
                        [results xz_appendBytesInBytes:(void *)string from:from to:to encoding:NSUTF8StringEncoding freeWhenDone:NO];
                    }
                    from = to + 1;
                    to = from;
                    break;
                case 2:
                    // 遇到开始字符时，前面时配对的匹配字符，结算
                    [results appendString:transform(matched)];
                    [matched setString:@""];
                    // 标记状态
                    state = 1;
                    from = to + 1;
                    to = from;
                    break;
                case 3:
                    // 忽略前面这个结束字符
                    state = 1;
                    from = to + 1;
                    to = from;
                    break;
                default:
                    NSAssert(NO, @"Never");
                    break;
            }
        } else if (state == 1) {
            to += 1;
        } else if (state == 2) {
            // 普通字符，前面是配对的匹配字符，结算
            [results appendString:transform(matched)];
            [matched setString:@""];
            // 标记状态
            state = 0;
            from = to;
            to += 1;
        } else if (state == 3) {
            // 没开始就遇到结束字符，后遇到普通字符
            state = 0;
            from = to;
            to += 1;
        } else {
            // 普通字符
            to += 1;
        }
    }
    
    // 最终结算，如果是遇到标记字符，则加上标记字符
    switch (state) {
        case 0:
            [results xz_appendBytesInBytes:(void *)string from:from to:to encoding:NSUTF8StringEncoding freeWhenDone:NO];
            break;
        case 1:
            from -= 1;
            [results xz_appendBytesInBytes:(void *)string from:from to:to encoding:NSUTF8StringEncoding freeWhenDone:NO];
            break;
        case 2:
            [results appendString:transform(matched)];
            break;
        default:
            NSAssert(NO, @"Never");
            break;
    }
    
    return results;
}

- (NSString *)xz_stringByReplacingMatchesOfPredicate:(XZMarkupPredicate)predicate usingDictionary:(NSDictionary<NSString *,id> *)aDictionary {
    return [self xz_stringByReplacingMatchesOfPredicate:predicate usingBlock:^NSString * _Nonnull(NSString * _Nonnull string) {
        id const value = aDictionary[string];
        return value ?: [NSString stringWithFormat:@"%c%@%c", predicate.start, string, predicate.end];
    }];
}

+ (instancetype)xz_stringWithPredicate:(XZMarkupPredicate)predicate format:(NSString *)format arguments:(va_list)arguments {
    NSMutableDictionary<NSString *, NSString *> * const map = [NSMutableDictionary dictionary];
    format = [format xz_stringByReplacingMatchesOfPredicate:predicate usingBlock:^id(NSString * const matchedString) {
        NSRange const range = [matchedString rangeOfString:@"%"];
        if (range.location == NSNotFound) {
            NSString * const format = map[matchedString];
            if (format) {
                return [NSString stringWithFormat:@"%%%@$%@", matchedString, format];
            }
            return [NSString stringWithFormat:@"%%%@$@", matchedString];
        }
        NSString *index = [matchedString substringToIndex:range.location];
        NSString *format = [matchedString substringFromIndex:range.location + 1];
        map[index] = format;
        return [NSString stringWithFormat:@"%%%@$%@", index, format];
    }];
    return [[NSString alloc] initWithFormat:format arguments:arguments];
}

+ (instancetype)xz_stringWithPredicate:(XZMarkupPredicate)predicate format:(NSString *)format, ... {
    va_list arguments;
    va_start(arguments, format);
    NSString *result = [self xz_stringWithPredicate:predicate format:format arguments:arguments];
    va_end(arguments);
    return result;
}

+ (instancetype)xz_stringWithBracesFormat:(NSString *)format, ... {
    va_list arguments;
    va_start(arguments, format);
    NSString *result = [self xz_stringWithPredicate:XZMarkupPredicateBraces format:format arguments:arguments];
    va_end(arguments);
    return result;
}

@end


@implementation NSMutableString (XZKit)

- (void)xz_appendBytesInBytes:(void *)bytes from:(NSInteger)from to:(NSInteger)to encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)freeBuffer {
    NSString *string = [NSString xz_stringWithBytesInBytes:bytes from:from to:to encoding:encoding freeWhenDone:freeBuffer];
    if (string == nil) {
        return;
    }
    [self appendString:string];
}

@end
