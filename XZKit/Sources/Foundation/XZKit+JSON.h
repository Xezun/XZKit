//
//  XZKit+JSON.h
//  XZKit
//
//  Created by Xezun on 2021/2/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Swift String/Array/Dictionary 不能自动提示自定义拓展 OC 类目的方法了。
// JSON：字符串或二进制数据。
// JSONObject：可化为 JSON 的对象。

#pragma mark - 对象转 JSON

@interface NSData (XZJSON)
/// 将对象 object 转换为 JSON 数据。
+ (NSData *)xz_JSONWithObject:(id)object options:(NSJSONWritingOptions)options;
/// 将对象 object 转换为 JSON 数据。
+ (NSData *)xz_JSONWithObject:(id)object;
@end


@interface NSString (XZJSON)

/// 将对象 object 转换为 JSON 字符串。
+ (nullable NSString *)xz_JSONWithObject:(id)object encoding:(NSStringEncoding)encoding options:(NSJSONWritingOptions)options;
/// 将对象 object 转换为 JSON 字符串。
+ (nullable NSString *)xz_JSONWithObject:(id)object encoding:(NSStringEncoding)encoding;
/// 将对象 object 转换为 JSON 字符串。
+ (nullable NSString *)xz_JSONWithObject:(id)object options:(NSJSONWritingOptions)options;
/// 将对象 object 转换为 JSON 字符串。
+ (nullable NSString *)xz_JSONWithObject:(id)object;

/// 将 JSON 数据（NSData或NSString）解析为 NSString 对象。
+ (nullable NSString *)xz_stringWithJSON:(id)json options:(NSJSONReadingOptions)options;
/// 将 JSON 数据（NSData或NSString）解析为 NSString 对象。
+ (nullable NSString *)xz_stringWithJSON:(id)json;

@end


@interface NSArray (XZJSON)
/// 将 JSON 数据（NSData或NSString）解析为 NSArray 对象。
+ (nullable NSArray *)xz_arrayWithJSON:(id)json options:(NSJSONReadingOptions)options;
/// 将 JSON 数据（NSData或NSString）解析为 NSArray 对象。
+ (nullable NSArray *)xz_arrayWithJSON:(id)json;
@end


@interface NSDictionary (XZJSON)
/// 将 JSON 数据（NSData或NSString）解析为 NSDictionary 对象。
+ (nullable NSDictionary *)xz_dictionaryWithJSON:(id)json options:(NSJSONReadingOptions)options;
/// 将 JSON 数据（NSData或NSString）解析为 NSDictionary 对象。
+ (nullable NSDictionary *)xz_dictionaryWithJSON:(id)json;
@end


NS_ASSUME_NONNULL_END
