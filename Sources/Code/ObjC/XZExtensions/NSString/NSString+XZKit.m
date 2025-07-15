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
#import "XZLog.h"

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

+ (instancetype)xz_initWithBytesNoCopy:(void *)bytes from:(NSInteger)from to:(NSInteger)to encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)freeBuffer {
    NSInteger const length = to - from;
    if (length < 1) {
        return nil;
    }
    return [[self alloc] initWithBytesNoCopy:(bytes + from) length:length encoding:encoding freeWhenDone:freeBuffer];
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

static inline void AppendCStringWithLength(NSMutableString *mutableString, const char *string, NSInteger from, NSInteger length) {
    if (length < 1) {
        return;
    }
    NSString * const substring = [[NSString alloc] initWithBytesNoCopy:(void *)(string + from) length:length encoding:NSUTF8StringEncoding freeWhenDone:NO];
    [mutableString appendString:substring];
}

static inline void AppendCStringWithRange(NSMutableString *mutableString, const char *string, NSInteger from, NSInteger to) {
    NSInteger const length = to - from;
    AppendCStringWithLength(mutableString, string, from, length);
}

@implementation NSString (XZMarkupPredicate)

- (NSString *)xz_stringByReplacingMatchesOfPredicate:(XZMarkupPredicate)predicate usingBlock:(id  _Nonnull (^NS_NOESCAPE)(NSString * _Nonnull))transform {
    NSInteger const length = [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if (length < 1) {
        return self;
    }
    const char * const string = [self cStringUsingEncoding:NSUTF8StringEncoding];
    
    /// 匹配状态，表示是否处于收集匹配 predicate 的字符的过程中。
    typedef enum : NSUInteger {
        /// 0. 未进入匹配模式，前一个字符是普通字符
        NotMatchStateText  = 0,
        /// 1. 未进入匹配模式，前一个字符是开始字符
        NotMatchStateStart = 1,
        /// 2. 匹配模式，前一个字符是普通字符
        MatchingStateText  = 2,
        /// 3. 匹配模式，前一个字符是开始字符
        MatchingStateStart = 3,
        /// 4. 匹配模式，前一个字符是结束字符
        MatchingStateEnd   = 4,
        /// 5. 未进入匹配模式，前一个字符是结束字符
        NotMatchStateEnd   = 5
    } MatchState;
    
    NSInteger  from  = 0;
    NSInteger  to    = 0;
    MatchState state = NotMatchStateText;
    
    // 存放结果的字符串
    NSMutableString * const results = [NSMutableString stringWithCapacity:length * 2];
    // 存放匹配的字符串
    NSMutableString * const matches = [NSMutableString string];
    
    while (to < length) {
        char const character = string[to];
        
        // 1. 将字符分三类，普通字符、开始字符、结束字符。
        // 2. 遍历到字符不立即计算，而是切换到对应的状态，当遍历新的字符，要改变状态时，再结算前一个字符的值，这样可以获取该类字符的数量，从而计算逃逸字符。
        
        if (character == predicate.end) {
            switch (state) {
                case NotMatchStateText:
                    AppendCStringWithRange(results, string, from, to);
                    state = NotMatchStateEnd;
                    from = to;
                    to += 1;
                    continue;
                case NotMatchStateStart: {
                    NSInteger const count = to - from;
                    
                    AppendCStringWithLength(results, string, from, count / 2);
                    if (count % 2 == 0) {
                        // 偶数个开始字符，视为逃逸字符
                        state = NotMatchStateEnd;
                    } else {
                        // 奇数个开始字符，最后一个为开始字符，这里直接遇到结束字符，匹配值为空字符串
                        state = MatchingStateEnd;
                    }
                    
                    from = to;
                    to += 1;
                    continue;
                }
                case MatchingStateText:
                    AppendCStringWithRange(matches, string, from, to);
                    state = MatchingStateEnd;
                    from = to;
                    to += 1;
                    continue;
                case MatchingStateStart: {
                    NSInteger const count = to - from;
                    if (count % 2 == 0) {
                        // 偶数个开始字符，视为逃逸字符
                        AppendCStringWithLength(matches, string, from, count / 2);
                    } else {
                        // 匹配的过程中，遇到奇数个开始字符，那么匹配从新标记重新开始，前面匹配的作为普通字符加入结果
                        [results appendString:matches];
                        [matches setString:@""];
                        AppendCStringWithLength(results, string, from, count / 2);
                    }
                    state = MatchingStateEnd;
                    from = to;
                    to += 1;
                    continue;
                }
                case MatchingStateEnd:
                    to += 1;
                    continue;
                case NotMatchStateEnd:
                    to += 1;
                    continue;
            }
        }
        
        if (character == predicate.start) {
            switch (state) {
                case NotMatchStateText:
                    // 遇到开始字符，标记状态
                    AppendCStringWithRange(results, string, from, to);
                    state = NotMatchStateStart;
                    from = to;
                    to += 1;
                    continue;
                case NotMatchStateStart:
                    to += 1;
                    continue;
                case MatchingStateText: {
                    AppendCStringWithRange(matches, string, from, to);
                    state = MatchingStateStart;
                    from = to;
                    to += 1;
                    continue;
                }
                case MatchingStateStart:
                    to += 1;
                    continue;
                case MatchingStateEnd: {
                    NSInteger const count = to - from;
                    
                    AppendCStringWithLength(matches, string, from, count / 2);
                    if (count % 2 == 0) {
                        state = MatchingStateStart;
                    } else {
                        // 匹配的过程中遇到奇数个结束字符，那么前一个匹配成功结束
                        [results appendString:transform(matches)];
                        [matches setString:@""];
                        state = NotMatchStateStart;
                    }
                    
                    from = to;
                    to += 1;
                    continue;
                }
                case NotMatchStateEnd: {
                    NSInteger const count = to - from;
                    
                    AppendCStringWithLength(results, string, from, count / 2);
                    state = NotMatchStateStart;
                    
                    from = to;
                    to += 1;
                    continue;
                }
            }
        }
        
        switch (state) {
            case NotMatchStateText:
                to += 1;
                continue;
            case NotMatchStateStart: {
                NSInteger const count = to - from;
                
                AppendCStringWithLength(results, string, from, count / 2);
                if (count % 2 == 0) {
                    state = NotMatchStateText;
                } else {
                    state = MatchingStateText;
                }
                
                from = to;
                to += 1;
                continue;
            }
            case MatchingStateText:
                to += 1;
                continue;
            case MatchingStateStart: {
                NSInteger const count = to - from;
                
                AppendCStringWithLength(matches, string, from, count / 2);
                if (count % 2 == 0) {
                    state = NotMatchStateText;
                } else {
                    [results appendString:matches];
                    AppendCStringWithLength(results, string, from, count / 2);
                    [matches setString:@""];
                    state = MatchingStateText;
                }
                
                from = to;
                to += 1;
                continue;
            }
            case MatchingStateEnd: {
                NSInteger const count = to - from;
                
                if (count % 2 == 0) {
                    AppendCStringWithLength(matches, string, from, count / 2);
                    state = MatchingStateText;
                } else {
                    [results appendString:transform(matches)];
                    [matches setString:@""];
                    AppendCStringWithLength(results, string, from, count / 2);
                    state = NotMatchStateText;
                }
                
                from = to;
                to += 1;
                continue;
            }
            case NotMatchStateEnd: {
                NSInteger const count = to - from;
                
                AppendCStringWithLength(results, string, from, count / 2);
                state = NotMatchStateText;
                
                from = to;
                to += 1;
                continue;
            }
        }
    }
    
    switch (state) {
        case NotMatchStateText:
            AppendCStringWithRange(results, string, from, to);
            break;
        case NotMatchStateStart:
            AppendCStringWithLength(results, string, from, (to - from) / 2);
            break;
        case MatchingStateText:
            [results appendString:matches];
            AppendCStringWithRange(results, string, from, to);
            break;
        case MatchingStateStart:
            [results appendString:matches];
            AppendCStringWithLength(results, string, from, (to - from) / 2);
            break;
        case MatchingStateEnd: {
            NSInteger const count = to - from;
            if (count % 2 == 0) {
                [results appendString:matches];
                AppendCStringWithLength(results, string, from, count / 2);
            } else {
                [results appendString:transform(matches)];
                AppendCStringWithLength(results, string, from, count / 2);
            }
            break;
        }
        case NotMatchStateEnd:
            AppendCStringWithLength(results, string, from, (to - from) / 2);
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

+ (instancetype)xz_stringWithMarkup:(XZMarkupPredicate)markup format:(NSString *)format arguments:(va_list)arguments {
    NSMutableDictionary<NSString *, NSString *> * const map = [NSMutableDictionary dictionary];
    format = [format xz_stringByReplacingMatchesOfPredicate:markup usingBlock:^id(NSString * const matchedString) {
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

+ (instancetype)xz_stringWithMarkup:(XZMarkupPredicate)markup format:(NSString *)format, ... {
    va_list arguments;
    va_start(arguments, format);
    NSString *result = [self xz_stringWithMarkup:markup format:format arguments:arguments];
    va_end(arguments);
    return result;
}

+ (instancetype)xz_stringWithBracesFormat:(NSString *)format, ... {
    va_list arguments;
    va_start(arguments, format);
    NSString *result = [self xz_stringWithMarkup:XZBracesFormatMarkup format:format arguments:arguments];
    va_end(arguments);
    return result;
}

@end
