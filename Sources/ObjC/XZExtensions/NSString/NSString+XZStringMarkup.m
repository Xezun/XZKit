//
//  NSString+XZStringMarkup.m
//  XZKit
//
//  Created by Xezun on 2025/7/17.
//

#import "NSString+XZStringMarkup.h"

XZStringMarkup const XZStringMarkupBraces = { '{', '}' };

FOUNDATION_STATIC_INLINE void NSMutableStringAppendCString(NSMutableString *mutableString, const char *string, NSInteger from, NSInteger length) {
    if (length < 1) {
        return;
    }
    NSString * const substring = [[NSString alloc] initWithBytesNoCopy:(void *)(string + from) length:length encoding:NSUTF8StringEncoding freeWhenDone:NO];
    [mutableString appendString:substring];
}

@implementation NSString (XZMarkupReplacing)

- (NSString *)xz_stringByReplacingOccurrencesWithMarkup:(XZStringMarkup const)markup usingBlock:(NSString *(^NS_NOESCAPE const)(NSString *))transform {
    NSInteger const length = [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if (length < 1) {
        return self;
    }
    const char * const UTF8String = [self cStringUsingEncoding:NSUTF8StringEncoding];
    
    /// 匹配状态，表示是否处于收集匹配 predicate 的字符的过程中。
    typedef enum : NSUInteger {
        /// 0. 普通模式，前一个字符是普通字符
        OrdinaryStateText  = 0,
        /// 1. 普通模式，前一个字符是开始字符
        OrdinaryStateStart = 1,
        /// 2. 匹配模式，前一个字符是普通字符
        MatchingStateText  = 2,
        /// 3. 匹配模式，前一个字符是开始字符
        MatchingStateStart = 3,
        /// 4. 匹配模式，前一个字符是结束字符
        MatchingStateEnd   = 4,
        /// 5. 普通模式，前一个字符是结束字符
        OrdinaryStateEnd   = 5
    } MatchState;
    
    NSInteger  from  = 0;
    NSInteger  to    = 0;
    MatchState state = OrdinaryStateText;
    
    // 存放结果的字符串
    NSMutableString * const results = [NSMutableString stringWithCapacity:length * 2];
    // 存放匹配的字符串
    NSMutableString * const matches = [NSMutableString stringWithCapacity:length];
    
    while (to < length) {
        // 取出当前遍历到的字符
        char character = UTF8String[to];
        
        // 1. 将字符分三类，普通字符、开始字符、结束字符。
        // 2. 为了计算逃逸字符，所以同类字符遍历，不立即计算，而是等状态改变时，才执行结算。
        
        // 遇到了结束字符
        if (character == markup.end) {
            switch (state) {
                case OrdinaryStateText: {
                    // 结算普通字符
                    NSMutableStringAppendCString(results, UTF8String, from, to - from);
                    // 标记遇到结束字符，并从将指针移动到该字符。由于需要计算逃逸，这里并不跳过孤立的结束字符。
                    state = OrdinaryStateEnd;
                    from = to;
                    to += 1;
                    continue;
                }
                case OrdinaryStateStart: {
                    NSInteger const count = to - from;
                    
                    // 结算开始字符的逃逸字符（取一半）
                    NSMutableStringAppendCString(results, UTF8String, from, count / 2);
                    
                    // 判断开始字符数量
                    if (count % 2 == 0) {
                        // 为偶数，那么前面的开始字符全部逃逸
                        state = OrdinaryStateEnd;
                    } else {
                        // 为奇数，那么最后一个为开始字符，这里遇到结束字符，不立即结算，因为需要判断结束字符是否为逃逸。
                        state = MatchingStateEnd;
                    }
                    
                    from = to;
                    to += 1;
                    continue;
                }
                case MatchingStateText: {
                    // 结算匹配字符
                    NSMutableStringAppendCString(matches, UTF8String, from, to - from);
                    // 不能立即结束，因为需要判断结束字符是否逃逸
                    state = MatchingStateEnd;
                    from = to;
                    to += 1;
                    continue;
                }
                case MatchingStateStart: {
                    NSInteger const count = to - from;
                    if (count % 2 == 0) {
                        // 数量偶数个开始字符，视为逃逸字符
                        NSMutableStringAppendCString(matches, UTF8String, from, count / 2);
                    } else {
                        // 匹配的过程中，遇到奇数个开始字符，那么匹配从新标记重新开始，前面匹配的作为普通字符加入结果
                        [results appendString:matches];
                        [matches setString:@""];
                        NSMutableStringAppendCString(results, UTF8String, from, count / 2);
                    }
                    state = MatchingStateEnd;
                    from = to;
                    to += 1;
                    continue;
                }
                case MatchingStateEnd: {
                    to += 1;
                    continue;
                }
                case OrdinaryStateEnd: {
                    to += 1;
                    continue;
                }
            }
        }
        
        // 遇到开始字符
        if (character == markup.start) {
            switch (state) {
                case OrdinaryStateText: {
                    // 遇到开始字符，标记状态
                    NSMutableStringAppendCString(results, UTF8String, from, to - from);
                    state = OrdinaryStateStart;
                    from = to;
                    to += 1;
                    continue;
                }
                case OrdinaryStateStart: {
                    to += 1;
                    continue;
                }
                case MatchingStateText: {
                    NSMutableStringAppendCString(matches, UTF8String, from, to - from);
                    state = MatchingStateStart;
                    from = to;
                    to += 1;
                    continue;
                }
                case MatchingStateStart: {
                    to += 1;
                    continue;
                }
                case MatchingStateEnd: {
                    NSInteger const count = to - from;
                    
                    NSMutableStringAppendCString(matches, UTF8String, from, count / 2);
                    if (count % 2 == 0) {
                        state = MatchingStateStart;
                    } else {
                        // 匹配的过程中遇到奇数个结束字符，那么前一个匹配成功结束
                        [results appendString:transform(matches)];
                        [matches setString:@""];
                        state = OrdinaryStateStart;
                    }
                    
                    from = to;
                    to += 1;
                    continue;
                }
                case OrdinaryStateEnd: {
                    NSInteger const count = to - from;
                    
                    NSMutableStringAppendCString(results, UTF8String, from, count / 2);
                    state = OrdinaryStateStart;
                    
                    from = to;
                    to += 1;
                    continue;
                }
            }
        }
        
        // 普通字符
        switch (state) {
            case OrdinaryStateText: {
                to += 1;
                break;
            }
            case OrdinaryStateStart: {
                NSInteger const count = to - from;
                
                NSMutableStringAppendCString(results, UTF8String, from, count / 2);
                if (count % 2 == 0) {
                    state = OrdinaryStateText;
                } else {
                    state = MatchingStateText;
                }
                
                from = to;
                to += 1;
                break;
            }
            case MatchingStateText: {
                to += 1;
                break;
            }
            case MatchingStateStart: {
                NSInteger const count = to - from;
                
                NSMutableStringAppendCString(matches, UTF8String, from, count / 2);
                if (count % 2 == 0) {
                    state = OrdinaryStateText;
                } else {
                    [results appendString:matches];
                    NSMutableStringAppendCString(results, UTF8String, from, count / 2);
                    [matches setString:@""];
                    state = MatchingStateText;
                }
                
                from = to;
                to += 1;
                break;
            }
            case MatchingStateEnd: {
                NSInteger const count = to - from;
                
                if (count % 2 == 0) {
                    NSMutableStringAppendCString(matches, UTF8String, from, count / 2);
                    state = MatchingStateText;
                } else {
                    [results appendString:transform(matches)];
                    [matches setString:@""];
                    NSMutableStringAppendCString(results, UTF8String, from, count / 2);
                    state = OrdinaryStateText;
                }
                
                from = to;
                to += 1;
                break;
            }
            case OrdinaryStateEnd: {
                NSInteger const count = to - from;
                
                NSMutableStringAppendCString(results, UTF8String, from, count / 2);
                state = OrdinaryStateText;
                
                from = to;
                to += 1;
                break;
            }
        }
        
        // 跳过非 ASCII 字符
        while (character & 0b10000000) {
            to += 1;
            character = UTF8String[to];
        }
    }
    
    switch (state) {
        case OrdinaryStateText: {
            NSMutableStringAppendCString(results, UTF8String, from, to - from);
            break;
        }
        case OrdinaryStateStart: {
            NSMutableStringAppendCString(results, UTF8String, from, (to - from) / 2);
            break;
        }
        case MatchingStateText: {
            [results appendString:matches];
            NSMutableStringAppendCString(results, UTF8String, from, to - from);
            break;
        }
        case MatchingStateStart: {
            [results appendString:matches];
            NSMutableStringAppendCString(results, UTF8String, from, (to - from) / 2);
            break;
        }
        case MatchingStateEnd: {
            NSInteger const count = to - from;
            if (count % 2 == 0) {
                [results appendString:matches];
                NSMutableStringAppendCString(results, UTF8String, from, count / 2);
            } else {
                NSString *value = transform(matches);
                if (value) {
                    [results appendString:value];
                } else {
                    
                }
                
                NSMutableStringAppendCString(results, UTF8String, from, count / 2);
            }
            break;
        }
        case OrdinaryStateEnd: {
            NSMutableStringAppendCString(results, UTF8String, from, (to - from) / 2);
            break;
        }
    }
    
    return results;
}

- (NSString *)xz_stringByReplacingOccurrencesWithMarkup:(XZStringMarkup const)markup usingDictionary:(NSDictionary<NSString *, id> * const)aDictionary {
    return [self xz_stringByReplacingOccurrencesWithMarkup:markup usingBlock:^NSString * _Nonnull(NSString * _Nonnull substring) {
        NSString * const replacement = aDictionary[substring];
        if (!replacement) {
            return [NSString stringWithFormat:@"%c%@%c", markup.start, substring, markup.end];
        }
        if ([replacement isKindOfClass:NSString.class]) {
            return replacement;
        }
        return [NSString stringWithFormat:@"%@", replacement];
    }];
}

@end

@implementation NSString (XZMarkupFormatting)

+ (instancetype)xz_stringWithMarkup:(XZStringMarkup const)markup format:(NSString *)format arguments:(va_list)arguments {
    NSMutableDictionary<NSString *, NSString *> * const map = [NSMutableDictionary dictionary];
    format = [format xz_stringByReplacingOccurrencesWithMarkup:markup usingBlock:^id(NSString * const matchedString) {
        NSRange const range = [matchedString rangeOfString:@"%"];
        if (range.location == NSNotFound) {
            NSString * const format = map[matchedString];
            if (format) {
                // {2%.2f} => %2$.2f
                return [NSString stringWithFormat:@"%%%@$%@", matchedString, format];
            }
            // {2} => %2$@
            return [NSString stringWithFormat:@"%%%@$@", matchedString];
        }
        NSString *index = [matchedString substringToIndex:range.location];
        NSString *format = [matchedString substringFromIndex:range.location + 1];
        map[index] = format;
        // {2%.2f} => %2$.2f
        return [NSString stringWithFormat:@"%%%@$%@", index, format];
    }];
    return [[NSString alloc] initWithFormat:format arguments:arguments];
}

+ (instancetype)xz_stringWithMarkup:(XZStringMarkup const)markup format:(NSString * const)format, ... {
    va_list arguments;
    va_start(arguments, format);
    NSString *result = [self xz_stringWithMarkup:markup format:format arguments:arguments];
    va_end(arguments);
    return result;
}

+ (instancetype)xz_stringWithBracesFormat:(NSString * const)format, ... {
    va_list arguments;
    va_start(arguments, format);
    NSString *result = [self xz_stringWithMarkup:XZStringMarkupBraces format:format arguments:arguments];
    va_end(arguments);
    return result;
}

@end

