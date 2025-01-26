//
//  XZJSON.h
//  XZJSON
//
//  Created by Xezun on 2024/9/28.
//

#import <Foundation/Foundation.h>
#import "XZJSONDefines.h"

NS_ASSUME_NONNULL_BEGIN

/// 支持 模型 与 JSON 互相转换的工具类。
@interface XZJSON : NSObject
/// 默认的日期格式：yyyy-MM-dd HH:mm:ss
@property (class, nonatomic, readonly) NSDateFormatter *dateFormatter;
@end

@interface XZJSON (XZJSONDecoding)
/// JSON 数据模型化。
///
/// JSON 数据包括 JSON 字符串 NSString 数据，或 JSON 二进制 NSData 数据，或者二者组成的数组。
///
/// - Parameters:
///   - json: JSON 数据
///   - options: JSON 读取选项，如果 JSON 已解析，则此参数忽略
///   - class: 模型的类对象
+ (nullable id)decode:(nullable id)json options:(NSJSONReadingOptions)options class:(Class)aClass;

/// 使用指定模型实例 model 将 JSON 数据字典模型化。
/// - Parameters:
///   - model: 模型实例对象
///   - dictionary: JSON 数据字典
+ (void)model:(id)model decodeFromDictionary:(NSDictionary *)dictionary;
@end

@interface XZJSON (XZJSONEncoding)
/// 模型实例 JSON 数据化。
/// - Parameters:
///   - object: 模型对象
///   - options: JSON 生成选项
///   - error: 错误输出
+ (nullable NSData *)encode:(nullable id)object options:(NSJSONWritingOptions)options error:(NSError **)error;

/// 将模型实例 model 数据化为指定 JSON 数据字典。
/// - Parameters:
///   - model: 模型实例对象
///   - dictionary: 数据字典
+ (void)model:(id)model encodeIntoDictionary:(NSMutableDictionary *)dictionary;
@end

@interface XZJSON (NSCoding)
+ (void)model:(id)model encodeWithCoder:(NSCoder *)aCoder;
+ (nullable id)model:(id)model decodeWithCoder:(NSCoder *)aCoder;
@end

@interface XZJSON (NSCopying)
+ (id)modelCopy:(id)model;
@end

@interface XZJSON (NSDescription)
+ (NSString *)modelDescription:(id)model;
@end

@interface XZJSON (NSHashable)
+ (NSUInteger)modelHash:(id)model;
@end

@interface XZJSON (NSEquatable)
+ (BOOL)model:(id)model1 isEqualToModel:(id)model2;
@end

NS_ASSUME_NONNULL_END
