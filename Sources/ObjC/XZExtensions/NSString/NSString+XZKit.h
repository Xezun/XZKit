//
//  NSString+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/6/23.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMacros.h>
#import <XZKit/NSString+XZHexEncoding.h>
#import <XZKit/NSString+XZExtendedEncoding.h>
#import <XZKit/NSString+XZStringMarkup.h>
#else
#import "XZMacros.h"
#import "NSString+XZHexEncoding.h"
#import "NSString+XZExtendedEncoding.h"
#import "NSString+XZStringMarkup.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSString (XZKit)

/// 字符串转 CGFloat 值。
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

/// 用二进制流中，指定 range 范围内的数据，创建 NSString 对象。不会接管二进制流的内存管理权。
/// - Parameters:
///   - bytes: 二进制流
///   - range: 范围
///   - encoding: 字符串编码
+ (nullable instancetype)xz_initWithBytes:(void *)bytes range:(NSRange)range encoding:(NSStringEncoding)encoding NS_SWIFT_UNAVAILABLE("no bytes with swift");

/// 将对象 object 转换为 JSON 字符串。
/// @note JSON 字符串使用`UTF-8`编码。
/// @param object 可转换为 JSON 的对象
/// @param options 序列化选项
+ (nullable instancetype)xz_stringWithJSONObject:(nullable id)object options:(NSJSONWritingOptions)options NS_SWIFT_NAME(init(JSONObject:options:));

/// 将对象 object 转换为 JSON 字符串。
/// @note JSON 字符串使用`UTF-8`编码，使用 `NSJSONWritingFragmentsAllowed` 选项。
/// @param object 可转换为 JSON 的对象
+ (nullable instancetype)xz_stringWithJSONObject:(nullable id)object NS_SWIFT_NAME(init(JSONObject:));

/// 将二进制形式 JSON 转换为字符串形式。
/// @param json 二进制形式的 JSON 数据
+ (nullable instancetype)xz_stringWithJSON:(nullable NSData *)json NS_SWIFT_NAME(init(JSON:));

@end

#ifndef XZ_STRING_TO_NUMBER_DISABLED

/// 字符串类型数值转 CGFloat 数值。
/// @param aString 字符串类型数值
/// @param defaultValue 默认值
FOUNDATION_STATIC_INLINE CGFloat CGFloatMake(NSString * _Nullable aString, CGFloat defaultValue) XZ_ATTR_OVERLOAD {
    if (aString == nil || aString.length == 0) {
        return defaultValue;
    }
    const char *cString = aString.UTF8String;
    char *pointer;
#if CGFLOAT_IS_DOUBLE
    CGFloat const value = strtod(cString, &pointer);
#else
    CGFloat const value = strtof(cString, &pointer);
#endif
    return pointer == NULL ? value : (pointer[0] == '\0' ? value : defaultValue);
}

/// 字符串类型数值转 CGFloat 数值。
/// @param aString 字符串类型数值
FOUNDATION_STATIC_INLINE CGFloat CGFloatMake(NSString * _Nullable aString) XZ_ATTR_OVERLOAD {
    return CGFloatMake(aString, 0);
}

/// 对象类型的数值转 CGFloat 数值。
/// @param aValue 对象类型的数值
/// @param defaultValue 默认值
FOUNDATION_STATIC_INLINE CGFloat CGFloatMake(id _Nullable aValue, CGFloat defaultValue) NS_SWIFT_UNAVAILABLE("请遵循 Swift 类型安全编码规则") {
    if ([aValue isKindOfClass:NSNumber.class]) {
#if CGFLOAT_IS_DOUBLE
        return [(NSNumber *)aValue doubleValue];
#else
        return [(NSNumber *)aValue floatValue];
#endif
    }
    if ([aValue isKindOfClass:NSString.class]) {
        return CGFloatMake((NSString *)aValue, defaultValue);
    }
    return defaultValue;
}

/// 对象类型的数值转 CGFloat 数值。
/// @param aValue 对象类型的数值
FOUNDATION_STATIC_INLINE CGFloat CGFloatMake(id _Nullable aValue) XZ_ATTR_OVERLOAD {
    return CGFloatMake(aValue, 0);
}

/// 字符串类型整数值转 NSInteger 数值。
/// @param aString 字符串类型整数值
/// @param base 整数的进制
/// @param defaultValue 默认值
FOUNDATION_STATIC_INLINE NSInteger NSIntegerMake(NSString * _Nullable aString, int base, NSInteger defaultValue) XZ_ATTR_OVERLOAD {
    if (aString == nil || aString.length == 0) {
        return defaultValue;
    }
    const char *cString = aString.UTF8String;
    char *pointer;
    long const value = strtol(cString, &pointer, base);
    if ( pointer[0] == '\0' ) {
        return value;
    }
    return (NSInteger)CGFloatMake(aString, defaultValue);
}

/// 字符串类型整数值转 NSInteger 数值。
/// @param aString 字符串类型整数值
FOUNDATION_STATIC_INLINE NSInteger NSIntegerMake(NSString * _Nullable aString) XZ_ATTR_OVERLOAD {
    return NSIntegerMake(aString, 10, 0);
}

/// 字符串类型整数值转 NSInteger 数值。
/// @param aString 字符串类型整数值
/// @param defaultValue 默认值
FOUNDATION_STATIC_INLINE NSInteger NSIntegerMake(NSString * _Nullable aString, NSInteger defaultValue) XZ_ATTR_OVERLOAD {
    return NSIntegerMake(aString, 10, defaultValue);
}

/// 对象类型整数值转 NSInteger 数值。
/// @param aValue 对象类型的整数值
/// @param base 整数的进制
/// @param defaultValue 默认值
FOUNDATION_STATIC_INLINE NSInteger NSIntegerMake(id _Nullable aValue, int base, NSInteger defaultValue) NS_SWIFT_UNAVAILABLE("请遵循 Swift 类型安全编码规则") {
    if ( aValue == nil ) {
        return defaultValue;
    }
    if ([aValue isKindOfClass:NSNumber.class]) {
        return [(NSNumber *)aValue integerValue];
    }
    if ([aValue isKindOfClass:NSString.class]) {
        return NSIntegerMake((NSString *)aValue, base, defaultValue);
    }
    return defaultValue;
}

/// 对象类型整数值转十进制 NSInteger 数值。
/// @param aValue 对象类型的整数值
/// @param defaultValue 默认值
FOUNDATION_STATIC_INLINE NSInteger NSIntegerMake(id _Nullable aValue, NSInteger defaultValue) XZ_ATTR_OVERLOAD {
    return NSIntegerMake(aValue, 10, defaultValue);
}

/// 对象类型整数值转十进制 NSInteger 数值。
/// @param aValue 对象类型的整数值
FOUNDATION_STATIC_INLINE NSInteger NSIntegerMake(id _Nullable aValue) XZ_ATTR_OVERLOAD {
    return NSIntegerMake(aValue, 10, 0);
}

#endif

NS_ASSUME_NONNULL_END
