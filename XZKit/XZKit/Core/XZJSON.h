//
//  XZJSON.h
//  XZKit
//
//  Created by Xezun on 2021/2/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// JSON：字符串或二进制数据。
// JSONObject：可化为 JSON 的对象。

#pragma mark - 对象转 JSON

@interface NSData (XZJSON)
/// 将对象 object 转换为 JSON 数据。
/// @param object 待转换为 JSON 数据的对象
/// @param options 序列化选项
+ (NSData *)xz_JSONWithObject:(id)object options:(NSJSONWritingOptions)options;
/// 将对象 object 转换为 JSON 数据。使用 NSJSONWritingFragmentsAllowed 选项。
/// @param object 待转换为 JSON 数据的对象
+ (NSData *)xz_JSONWithObject:(id)object;
@end


@interface NSString (XZJSON)

/// 将对象 object 转换为 JSON 字符串。
/// @param object 待转换为 JSON 的对象
/// @param encoding 字符串的编码格式
/// @param options 序列化选项
+ (nullable NSString *)xz_JSONWithObject:(id)object encoding:(NSStringEncoding)encoding options:(NSJSONWritingOptions)options;
/// 将对象 object 转换为 JSON 字符串。
/// @param object 待转换为 JSON 字符串的对象
/// @param encoding 字符编码
+ (nullable NSString *)xz_JSONWithObject:(id)object encoding:(NSStringEncoding)encoding;
/// 将对象 object 转换为 JSON 字符串。
/// @param object 待转换为 JSON 字符串的对象
/// @param options 序列化选项
+ (nullable NSString *)xz_JSONWithObject:(id)object options:(NSJSONWritingOptions)options;
/// 将对象 object 转换为 JSON 字符串。
/// @param object 待转换为 JSON 字符串的对象
+ (nullable NSString *)xz_JSONWithObject:(id)object;

/// 将 JSON 数据（NSData或NSString）解析为 NSString 对象。
/// @param json 待转换为 JSON 字符串的对象
/// @param options 序列化选项
+ (nullable NSString *)xz_stringWithJSON:(id)json options:(NSJSONReadingOptions)options;
/// 将 JSON 数据（NSData或NSString）解析为 NSString 对象。
/// @param json 待转换为 JSON 字符串的对象
+ (nullable NSString *)xz_stringWithJSON:(id)json;

@end


@interface NSArray (XZJSON)
/// 将 JSON 数据（NSData或NSString）解析为 NSArray 对象。
/// @param json 待解析的 JSON 数据或字符串
/// @param options 序列化选项
+ (nullable NSArray *)xz_arrayWithJSON:(id)json options:(NSJSONReadingOptions)options;
/// 将 JSON 数据（NSData或NSString）解析为 NSArray 对象。
/// @param json 待解析的 JSON 数据或字符串
+ (nullable NSArray *)xz_arrayWithJSON:(id)json;
@end


@interface NSDictionary (XZJSON)
/// 将 JSON 数据（NSData或NSString）解析为 NSDictionary 对象。
/// @param json 待解析的 JSON 数据或字符串
/// @param options 序列化选项
+ (nullable NSDictionary *)xz_dictionaryWithJSON:(id)json options:(NSJSONReadingOptions)options;
/// 将 JSON 数据（NSData或NSString）解析为 NSDictionary 对象。
/// @param json 待解析的 JSON 数据或字符串
+ (nullable NSDictionary *)xz_dictionaryWithJSON:(id)json;
@end


NS_ASSUME_NONNULL_END
