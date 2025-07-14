//
//  NSString+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/6/23.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/NSData+XZKit.h>
#else
#import "NSData+XZKit.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSString (XZKit)

/// 遍历字符串所有符合条件的子串：子串所有字符都在字体 font 存在字形。
/// @param font 字体。
/// @param block 符合条件的（最长）子串在字符串中的位置 range 将通过 block 的参数提供。
- (void)xz_enumerateSubstringsMatchedGlyphOfFont:(UIFont *)font usingBlock:(void (^)(NSRange range))block NS_SWIFT_NAME(enumerateSubstringsMatchedGlyph(of:using:));

/// 字符串转 CGFloat 值。字符串必须是纯数字值，否则返回零。
/// @code
/// XZLog(@"%f", @"0.12".xz_CGFloatValue); // 0.12
/// XZLog(@"%f", @"a.12".xz_CGFloatValue); // 0.00
/// XZLog(@"%f", @"0.1a".xz_CGFloatValue); // 0.00
/// @endcode
@property (nonatomic, readonly) CGFloat xz_floatValue OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");

/// 字符串转 CGFloat 值。字符串必须是纯数字值，则返回默认值。
/// @param defaultValue 默认值
- (CGFloat)xz_floatValue:(CGFloat)defaultValue OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");

/// 字符串转 NSInteger 值。字符串必须是纯十进制数字值，否则返回零。
/// @discussion 即使小数也会被认为非法。
@property (nonatomic, readonly) NSInteger xz_integerValue OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");

/// 字符串转 NSInteger 值。字符串必须是纯整数数字，否则返回零。
/// @discussion 即使小数也会被认为非法。
/// @param defaultValue 默认值
/// @param base 数值的进制
- (NSInteger)xz_integerValue:(NSInteger)defaultValue base:(int)base OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");

/// 将字符串中除字母和数字以外的字符，都应用 URI 百分号编码。
/// @attention 因为不被编码的字符范围较少，因此需考虑新字符串长度增加可能会带来的影响。
/// @discussion 本方法一般用于构造 JavaScript 代码时，避免特殊字符带来的语义问题。
@property (nonatomic, readonly) NSString *xz_stringByAddingPercentEncoding NS_SWIFT_NAME(addingPercentEncoding);
/// 与 `JavaScript.encodeURI()` 函数作用相同。
/// @discussion 使用 `-stringByRemovingPercentEncoding` 方法移除 URI 编码。
/// @discussion 在不清楚 URL 保留字符是否会造成影响的情况下，推荐使用更安全的 `-xz_stringByAddingPercentEncoding` 方法。
/// @discussion 本方法一般用于转义 URL 中的非法字符，使 URL 变得可用。
@property (nonatomic, readonly) NSString *xz_stringByAddingURIEncoding NS_SWIFT_NAME(addingURIEncoding);
/// 与 `JavaScript.encodeURIComponent()` 函数作用相同。
/// @discussion 使用 `-stringByRemovingPercentEncoding` 方法移除 URI 编码。
/// @discussion 在不清楚 URL 保留字符是否会造成影响的情况下，推荐使用更安全的 `-xz_stringByAddingPercentEncoding` 方法。
/// @discussion 本方法一般用于将字符串拼接到 URL 参数中。
@property (nonatomic, readonly) NSString *xz_stringByAddingURIComponentEncoding NS_SWIFT_NAME(addingURIComponentEncoding);

@property (nonatomic, readonly) NSString *xz_stringByRemovingURIEncoding NS_SWIFT_NAME(removingURIEncoding);
@property (nonatomic, readonly) NSString *xz_stringByRemovingURIComponentEncoding NS_SWIFT_NAME(removingURIComponentEncoding);

@property (nonatomic, readonly) NSString *xz_stringByTransformingMandarinToLatin NS_SWIFT_NAME(transformingMandarinToLatin);

@end

/// 将`NSNumber`对象或`纯数字字符串`对象转换为十进制整数，否则返回默认值。
FOUNDATION_STATIC_INLINE NSInteger XZMakeInteger(id _Nullable aValue, NSInteger defaultValue) NS_SWIFT_UNAVAILABLE("请遵循 Swift 类型安全编码规则") {
    if ( aValue == nil )                       return defaultValue;
    if ([aValue isKindOfClass:NSNumber.class]) return [(NSNumber *)aValue integerValue];
    if ([aValue isKindOfClass:NSString.class]) return [(NSString *)aValue xz_integerValue:defaultValue base:10];
    return defaultValue;
}


/// 将`NSNumber`对象或`纯数字字符串`对象转换为十进制小数，否则返回默认值。
FOUNDATION_STATIC_INLINE CGFloat XZMakeFloat(id _Nullable aValue, NSInteger defaultValue) NS_SWIFT_UNAVAILABLE("请遵循 Swift 类型安全编码规则") {
    if ([aValue isKindOfClass:NSNumber.class]) {
#if CGFLOAT_IS_DOUBLE
        return [(NSNumber *)aValue doubleValue];
#else
        return [(NSNumber *)aValue floatValue];
#endif
    }
    if ([aValue isKindOfClass:NSString.class]) {
        return [(NSString *)aValue xz_floatValue:defaultValue];
    }
    return defaultValue;
}



@interface NSString (XZHexEncoding)

/// 对当前字符串的二进制数据，进行十六进制编码。
/// @param stringEncoding 字符串二进制形式的编码
/// @param hexEncoding 十六进制字符的大小写
- (NSString *)xz_stringByAddingHexEncoding:(XZHexEncoding)hexEncoding usingEncoding:(NSStringEncoding)stringEncoding NS_SWIFT_NAME(addingHexEncoding(_:using:));

/// 对当前字符串的二进制数据，使用小写字母，进行十六进制编码。
/// @param stringEncoding 字符串二进制形式的编码
- (NSString *)xz_stringByAddingHexEncodingUsingEncoding:(NSStringEncoding)stringEncoding NS_SWIFT_NAME(addingHexEncoding(using:));

/// 对当前字符串 UTF-8 编码形式的二进制数据，进行十六进制编码。
/// @param hexEncoding 十六进制字符的大小写
- (NSString *)xz_stringByAddingHexEncoding:(XZHexEncoding)hexEncoding NS_SWIFT_NAME(addingHexEncoding(_:));

/// 对当前字符串 UTF-8 编码形式的二进制数据，使用小写字母，进行十六进制编码。
@property (nonatomic, readonly) NSString *xz_stringByAddingHexEncoding NS_SWIFT_NAME(addingHexEncoding);

/// 对原始字符串的十六进制编码字符串进行解码。
/// @param dataEncoding 原始字符串的二进制编码
- (NSString *)xz_stringByRemovingHexEncodingUsingEncoding:(NSStringEncoding)dataEncoding NS_SWIFT_NAME(removingHexEncoding(using:));

/// 对使用 UTF-8 编码的原始字符串的十六进制编码字符串进行解码。
@property (nonatomic, readonly) NSString *xz_stringByRemovingHexEncoding NS_SWIFT_NAME(removingHexEncoding);

@end


@interface NSString (XZJSON)

/// 将对象 object 转换为 JSON 字符串。
/// @note JSON 字符串使用`UTF-8`编码。
/// @param object 可转换为 JSON 的对象
/// @param options 序列化选项
+ (nullable instancetype)xz_stringWithJSONObject:(nullable id)object options:(NSJSONWritingOptions)options;

/// 将对象 object 转换为 JSON 字符串。
/// @note JSON 字符串使用`UTF-8`编码，使用 `NSJSONWritingFragmentsAllowed` 选项。
/// @param object 可转换为 JSON 的对象
+ (nullable instancetype)xz_stringWithJSONObject:(nullable id)object;

/// 将二进制形式 JSON 转换为字符串形式。
/// @param json 二进制形式的 JSON 数据
+ (nullable instancetype)xz_stringWithJSON:(nullable NSData *)json;

@end


/// 以指定字符作为开始结束标记的判断模式。
typedef struct XZMarkupPredicate {
    /// 开始字符。两个连续的开始字符，视为一个逃逸了的开始字符。
    char start;
    /// 结束字符。没有匹配开始字符的结束字符，作为普通字符处理。
    char end;
} XZMarkupPredicate;

/// 构造占位分隔符。
/// - Parameters:
///   - start: 起始字符
///   - end: 终止字符
FOUNDATION_STATIC_INLINE XZMarkupPredicate XZMarkupPredicateMake(char start, char end) {
    return (XZMarkupPredicate){ start, end };
}

/// 本地化字符串中，默认以大括号 `{}` 作为参数分隔符。
FOUNDATION_EXPORT XZMarkupPredicate const XZMarkupPredicateBraces;

@interface NSString (XZLocalization)

/// 以 bytes 中从 from 到 to 的读取字节创建字符串。
/// - Parameters:
///   - bytes: 二进制流
///   - from: 待创建字符串的开始字节（从 0 开始计算）位置
///   - to: 待创建字符串的结束字节（从 0 开始计算）位置，不包含 to 位置的字节
///   - encoding: 字符串编码
///   - freeBuffer: 是否自动释放二进制流
+ (nullable instancetype)xz_stringWithBytesInBytes:(void *)bytes from:(NSInteger)from to:(NSInteger)to encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)freeBuffer NS_SWIFT_NAME(init(inBytes:from:to:freeWhenDone:));

/// 替换字符串中被分隔符分割的占位符。
/// - Parameters:
///   - predicate: 分隔符
///   - transform: 获取占位符的替换内容的块函数
- (NSString *)xz_stringByReplacingMatchesOfPredicate:(XZMarkupPredicate)predicate usingBlock:(id(^NS_NOESCAPE)(NSString *matchedString))transform NS_SWIFT_NAME(replacingMatches(of:using:));

/// 替换字符串中被分隔符分割的占位符。
/// - Parameters:
///   - predicate: 分隔符
///   - aDictionary: key 为占位符，value 为替换内容
- (NSString *)xz_stringByReplacingMatchesOfPredicate:(XZMarkupPredicate)predicate usingDictionary:(NSDictionary<NSString *, id> *)aDictionary NS_SWIFT_NAME(replacingMatches(of:using:));

+ (instancetype)xz_stringWithPredicate:(XZMarkupPredicate)predicate format:(NSString *)format arguments:(va_list)arguments;

/// 使用标记字符作为占位符的字符串格式化创建方式。
///
/// 以花括号作为标记字符为例。
/// ```objc
/// // 使用数字 n 表示第 n 个参数
/// [NSString xz_stringWithBracesFormat:@"{1}{2}{1}", @"A", @"B"] // equals @"ABA"
/// // 支持 c 字符串格式，且只需要指明第一个
/// [NSString xz_stringWithBracesFormat:@"{1%.2f}{2}{1}", M_PI, @"B"] // equals @"3.14B3.14"
/// ```
/// - 使用自然数（从 1 开始）作为代表列表中指定位置的参数。
/// - 支持 c 字符串格式
/// - 两个连续的标记，将视为一个普通字符逃逸
/// - 没有匹配结束字符的开始字符，自动逃逸
/// - 没有匹配开始字符的结束字符，自动逃逸
///
/// - Parameters:
///   - predicate: 标记字符
///   - format: 字符串格式
+ (instancetype)xz_stringWithPredicate:(XZMarkupPredicate)predicate format:(NSString *)format, ...;
+ (instancetype)xz_stringWithBracesFormat:(NSString *)format, ...;

@end

@interface NSMutableString (XZKit)
- (void)xz_appendBytesInBytes:(void *)bytes from:(NSInteger)from to:(NSInteger)to encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)freeBuffer;
@end

NS_ASSUME_NONNULL_END
