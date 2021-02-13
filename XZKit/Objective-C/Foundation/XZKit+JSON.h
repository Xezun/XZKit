//
//  XZKit+JSON.h
//  XZKit
//
//  Created by Xezun on 2021/2/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Swift String/Array/Dictionary 不能自动提示自定义拓展 OC 类目的方法了。

@interface NSData (XZJSON)
/// 将对象 object 转换为 JSON 数据。
+ (NSData *)xz_dataWithJSONObject:(id)object options:(NSJSONWritingOptions)options NS_SWIFT_NAME(init(json:options:));
/// 将对象 object 转换为 JSON 数据。
+ (NSData *)xz_dataWithJSONObject:(id)object NS_SWIFT_NAME(init(json:));
@end


@interface NSString (XZJSON)
/// 将对象 object 转换为 JSON 字符串。
+ (nullable NSString *)xz_stringWithJSONObject:(id)object encoding:(NSStringEncoding)encoding options:(NSJSONWritingOptions)options NS_SWIFT_NAME(init(json:encoding:options:));
/// 将对象 object 转换为 JSON 字符串。
+ (nullable NSString *)xz_stringWithJSONObject:(id)object encoding:(NSStringEncoding)encoding NS_SWIFT_NAME(init(json:encoding:));
/// 将对象 object 转换为 JSON 字符串。
+ (nullable NSString *)xz_stringWithJSONObject:(id)object options:(NSJSONWritingOptions)options NS_SWIFT_NAME(init(json:options:));
/// 将对象 object 转换为 JSON 字符串。
+ (nullable NSString *)xz_stringWithJSONObject:(id)object NS_SWIFT_NAME(init(json:));
@end


@interface NSArray (XZJSON)
/// 将 JSON 数据（NSData或NSArray）解析为 NSArray 对象。
+ (NSArray *)xz_arrayWithJSON:(id)json options:(NSJSONReadingOptions)options NS_SWIFT_NAME(init(json:options:));
/// 将 JSON 数据（NSData或NSArray）解析为 NSArray 对象。
+ (NSArray *)xz_arrayWithJSON:(id)json NS_SWIFT_NAME(init(json:));
@end



@interface NSDictionary (XZJSON)
/// 将 JSON 数据（NSData或NSArray）解析为 NSDictionary 对象。
+ (NSDictionary *)xz_dictionaryWithJSON:(id)json options:(NSJSONReadingOptions)options NS_SWIFT_NAME(init(json:options:));
/// 将 JSON 数据（NSData或NSArray）解析为 NSDictionary 对象。
+ (NSDictionary *)xz_dictionaryWithJSON:(id)json NS_SWIFT_NAME(init(json:));
@end


NS_ASSUME_NONNULL_END
