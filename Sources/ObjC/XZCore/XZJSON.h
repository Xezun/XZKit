//
//  XZJSON.h
//  XZKit
//
//  Created by Xezun on 2021/2/14.
//

#import <Foundation/Foundation.h>
#import <XZKit/XZLog.h>

NS_ASSUME_NONNULL_BEGIN

// JSON：字符串或二进制数据形式的 JSON 数据。
// JSONObject：可化为 JSON 的对象。

@class NSJSONSerialization;

#pragma mark - 对象转 JSON

@interface NSData (XZJSON)

/// 将对象 object 转换为 JSON 二进制数据。
/// @param object 可转换为 JSON 的对象
/// @param options 序列化选项
+ (nullable instancetype)xz_dataWithJSONObject:(nullable id)object options:(NSJSONWritingOptions)options;

/// 将对象 object 转换为 JSON 数据。
/// @note 使用 NSJSONWritingFragmentsAllowed 选项。
/// @param object 可转换为 JSON 的对象
+ (nullable instancetype)xz_dataWithJSONObject:(nullable id)object;

@end

@interface NSString (XZJSON)

/// 将对象 object 转换为 JSON 字符串。
/// @note `JSON`字符串使用`UTF-8`编码。
/// @param object 可转换为 JSON 的对象
/// @param options 序列化选项
+ (nullable instancetype)xz_stringWithJSONObject:(nullable id)object options:(NSJSONWritingOptions)options;

/// 将对象 object 转换为 JSON 字符串。
/// @note `JSON`字符串使用`UTF-8`编码，使用 NSJSONWritingFragmentsAllowed 选项。
/// @param object 可转换为 JSON 的对象
+ (nullable instancetype)xz_stringWithJSONObject:(nullable id)object;

/// 将二进制形式 JSON 转换为字符串形式。
/// @param json 二进制形式的`JSON`数据
+ (nullable instancetype)xz_stringWithJSON:(nullable NSData *)json;

@end


@interface NSArray (XZJSON)

/// 将二进制或字符串形式的 JSON 数据解析为 NSArray 对象。
/// @param json 待解析的 JSON 数据
/// @param options 序列化选项
+ (nullable instancetype)xz_arrayWithJSON:(nullable id)json options:(NSJSONReadingOptions)options;

/// 将二进制或字符串形式的 JSON 数据解析为 NSArray 对象。
/// @note 使用`NSJSONReadingAllowFragments`序列化选项。
/// @param json 待解析的 JSON 数据
+ (nullable instancetype)xz_arrayWithJSON:(nullable id)json;

@end


@interface NSDictionary (XZJSON)

/// 将 JSON 数据（NSData或NSString）解析为 NSDictionary 对象。
/// @param json 待解析的 JSON 数据或字符串
/// @param options 序列化选项
+ (nullable instancetype)xz_dictionaryWithJSON:(nullable id)json options:(NSJSONReadingOptions)options;
/// 将 JSON 数据（NSData或NSString）解析为 NSDictionary 对象。
/// @param json 待解析的 JSON 数据或字符串
+ (nullable instancetype)xz_dictionaryWithJSON:(nullable id)json;

@end


NS_ASSUME_NONNULL_END
