//
//  NSString+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/6/23.
//

#import <UIKit/UIKit.h>
#import "NSData+XZKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSString (XZKit)

/// 遍历字符串所有符合条件的子串：子串所有字符都在字体 font 存在字形。
/// @param font 字体。
/// @param block 符合条件的（最长）子串在字符串中的位置 range 将通过 block 的参数提供。
- (void)xz_enumerateSubstringsMatchedGlyphOfFont:(UIFont *)font usingBlock:(void (^)(NSRange range))block NS_SWIFT_NAME(enumerateSubstringsMatchedGlyph(of:using:));

/// 字符串转 CGFloat 值。字符串必须是纯数字值，否则返回零。
/// @code
/// NSLog(@"%f", @"0.12".xz_CGFloatValue); // 0.12
/// NSLog(@"%f", @"a.12".xz_CGFloatValue); // 0.00
/// NSLog(@"%f", @"0.1a".xz_CGFloatValue); // 0.00
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

NS_ASSUME_NONNULL_END
