//
//  XZURLQuery.h
//  XZURLQuery
//
//  Created by Xezun on 2023/7/30.
//

#import <Foundation/Foundation.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/NSURL+XZURLQuery.h>
#else
#import "NSURL+XZURLQuery.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// 处理 URL 查询字符串的对象。
__attribute__((objc_subclassing_restricted))
@interface XZURLQuery : NSObject

+ (nullable instancetype)queryForURL:(nullable NSURL *)url NS_SWIFT_NAME(init(for:));
+ (nullable instancetype)queryForURLString:(NSString *)URLString NS_SWIFT_NAME(init(forURLString:));
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithURL:(NSURL *)url NS_DESIGNATED_INITIALIZER;

/// 获取合并了 query 的 NSURL 对象。
@property (nonatomic, copy, readonly) NSURL *url;

/// 获取当前 query 的字典形式。
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *allValues;

/// 读取 name 字段的值。
/// @discussion
/// 如果没有调用任何修改字段的方法，那么此方法返回的是原始 URL 的 query 字段原始值，否则返回设置后的值。
/// @discussion
/// 原始值可能包含三种类型，以 key1=x&key2=&key3=x&key3=&key3&key4 为例。
/// @discussion
/// 1、不存在的字段，返回值为 nil 且 contains 方法返回 NO ，比如 key0 字段。
/// @discussion
/// 2、没有值的字段，返回值为 nil 且 contains 方法返回 YES，比如 key4 字段。
/// @discussion
/// 3、不重复的字段，返回值为 NSString 对象，比如 key1、key2 字段。
/// @discussion
/// 4、重复的字段，返回值 NSArray 对象，包含的元素为 NSString 或 NSNull 对象，比如 key3 字段值。
/// @code
/// XZLog(@"[%@], %d", query[@"key0"], [query containsValueForName:@"key0"]);
/// // prints: nil, 0
/// XZLog(@"[%@], %d", query[@"key1"], [query containsValueForName:@"key1"]);
/// // prints: "x", 1
/// XZLog(@"[%@], %d", query[@"key2"], [query containsValueForName:@"key2"]);
/// // prints: "", 1
/// XZLog(@"[%@], %d", query[@"key3"], [query containsValueForName:@"key3"]);
/// // prints: ["x", "", <NSNull>], 1
/// XZLog(@"[%@], %d", query[@"key4"], [query containsValueForName:@"key4"]);
/// // prints: nil, 1
/// @endcode
/// - Parameter name: 字段名
- (nullable id)valueForName:(NSString *)name;

/// 设置字段值。
/// @discussion
/// 任何值都可以设置为字段值，但是仅 NSString 会被原样保留到 URLQuery 中。
/// @discussion NSString => name=string
/// @discussion NSArray  => name=item0&name=item2
/// @discussion NSNull   => name
/// @param value 字段值，nil 表示删除字段，NSNull 表示设置空字段
/// @param name 字段名
- (void)setValue:(nullable id)value forName:(NSString *)name;

/// 添加字段值。
/// @param value 字段值
/// @param name 字段名
- (void)addValue:(nullable id)value forName:(NSString *)name;

/// 移除所有字段。
- (void)removeAllValues;

/// 下标取值方法。等同于 -valueForName: 方法。
- (nullable id)objectForKeyedSubscript:(NSString *)name;
/// 下标设值方法，效果等同于 -setValue:forName: 方法。
- (void)setObject:(nullable id)value forKeyedSubscript:(NSString *)name;

/// 是否包含字段。
/// - Parameter name: 字段名
- (BOOL)containsValueForName:(NSString *)name;

/// 获取字段字符串值，如果为重复字段，返回第一个字段。
/// - Parameter name: 字段名
- (nullable NSString *)stringValueForName:(NSString *)name;

/// 获取字段整数值，将字符串转为整数。
/// - Parameter name: 字段名
- (NSInteger)integerValueForName:(NSString *)name;

/// 获取字段浮点值，将字符串转为浮点值。
/// - Parameter name: 字段名
- (CGFloat)floatValueForName:(NSString *)name;

/// 获取字段 NSURL 值，将字符串构造为 NSURL 对象。
/// - Parameter name: 字段名
- (nullable NSURL *)urlValueForName:(NSString *)name;

/// 将字典的 key/value 分别作为字段的 name/value 添加到 query 中。
/// - Parameter dictionary: 要添加到 query 的字典
- (void)addValuesFromDictionary:(nullable NSDictionary<NSString *, id> *)dictionary NS_SWIFT_NAME(addValues(from:));

/// 将字典的 key/value 分别作为字段的 name/value 设置到 query 中。
/// - Parameter dictionary: 要添加到 query 的字典
- (void)setValuesWithDictionary:(nullable NSDictionary<NSString *, id> *)dictionary NS_SWIFT_NAME(setValues(with:));

@end

NS_ASSUME_NONNULL_END
