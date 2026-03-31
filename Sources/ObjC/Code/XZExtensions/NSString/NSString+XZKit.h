//
//  NSString+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/6/23.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/NSString+XZHexEncoding.h>
#import <XZKit/NSString+XZExtendedEncoding.h>
#import <XZKit/NSString+XZStringMarkup.h>
#else
#import "NSString+XZHexEncoding.h"
#import "NSString+XZExtendedEncoding.h"
#import "NSString+XZStringMarkup.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSString (XZKit)

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

/// 用二进制流 bytes 中，从 from 字节到 to 字节的数据，并按指定编码转换为字符串。
/// - Parameters:
///   - bytes: 二进制流
///   - from: 待创建字符串的开始字节（从 0 开始计算）位置
///   - to: 待创建字符串的结束字节（从 0 开始计算）位置，不包含 to 位置的字节
///   - encoding: 字符串编码
///   - freeBuffer: 是否自动释放二进制流
+ (nullable instancetype)xz_initWithBytesNoCopy:(void *)bytes from:(NSInteger)from to:(NSInteger)to encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)freeBuffer NS_SWIFT_UNAVAILABLE("no bytes with swift");

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

/// 将`NSNumber`对象或`纯数字字符串`对象转换为十进制整数，否则返回默认值。
FOUNDATION_STATIC_INLINE NSInteger NSIntegerFromValue(id _Nullable aValue, NSInteger defaultValue) NS_SWIFT_UNAVAILABLE("请遵循 Swift 类型安全编码规则") {
    if ( aValue == nil )                       return defaultValue;
    if ([aValue isKindOfClass:NSNumber.class]) return [(NSNumber *)aValue integerValue];
    if ([aValue isKindOfClass:NSString.class]) return [(NSString *)aValue xz_integerValue:defaultValue base:10];
    return defaultValue;
}

/// 将`NSNumber`对象或`纯数字字符串`对象转换为十进制小数，否则返回默认值。
FOUNDATION_STATIC_INLINE CGFloat CGFloatFromValue(id _Nullable aValue, NSInteger defaultValue) NS_SWIFT_UNAVAILABLE("请遵循 Swift 类型安全编码规则") {
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

NS_ASSUME_NONNULL_END
