//
//  XZJSONPrivate.h
//  XZJSON
//
//  Created by Xezun on 2024/9/29.
//

#import "XZJSON.h"
#import <Foundation/Foundation.h>
#import "XZJSONClassDescriptor.h"
#import "XZJSONDefines.h"
#import "XZJSONPropertyDescriptor.h"
@import ObjectiveC;

// 从 JSON 解析数据时，如果无法转换为需要的类型，则认为该值不存在，不使用默认值或 nil 填充。

NS_ASSUME_NONNULL_BEGIN

@interface XZJSON (XZJSONDecodingPrivate)
/// JSON 数据流，调用此方法模型化。
+ (nullable id)_decodeData:(nonnull NSData *)data options:(NSJSONReadingOptions)options class:(Class)aClass;
/// JSON 序列化数据，调用此方法模型化。
+ (nullable id)_decodeObject:(nonnull id)object class:(nonnull Class)aClass;
/// 模型实例对象，解码 JSON 数据。
+ (void)_model:(id)model decodeFromDictionary:(NSDictionary *)dictionary descriptor:(XZJSONClassDescriptor *)descriptor;
@end

@interface XZJSON (XZJSONEncodingPrivate)
/// 将实例对象 object 编码为 JSON 数据。如果提供了 dictionary 参数，将数据编码到该字典中。
/// - Parameters:
///   - object: 非空，实例对象，可能为模型，也可能为原生类型
///   - property: 当实例对象为属性值时，提供此参数
///   - dictionary: 如果提供此参数，那么表示需要将模型的属性序列化到此 JSON 字典中，比如一个 JSONKey 对应多个属性时
+ (id)_encodeObject:(nonnull id)object forProperty:(nullable XZJSONPropertyDescriptor *)property dictionary:(nullable NSMutableDictionary *)dictionary;
/// 将数组中的元素，全编码为 JSON 数据。不能编码的元素将被丢弃。
+ (NSArray *)_encodeArray:(nonnull NSArray *)array;
/// 将 模型实例对象 编码进 JSON 字典中。
+ (void)_model:(id)model encodeIntoDictionary:(NSMutableDictionary *)dictionary descriptor:(XZJSONClassDescriptor *)descriptor;
@end

FOUNDATION_EXPORT void XZJSONModelDecodeScalarNumberForProperty(__unsafe_unretained id _Nonnull model, __unsafe_unretained XZJSONPropertyDescriptor *_Nonnull descriptor, __unsafe_unretained id _Nonnull value);
FOUNDATION_EXPORT void XZJSONModelDecodeValueForProperty(__unsafe_unretained id _Nonnull model, __unsafe_unretained XZJSONPropertyDescriptor *_Nonnull property, __unsafe_unretained id _Nonnull value);

/// 将模型的数值属性值转换为 JSON 数据中
/// @param model 模型对象
/// @param property 属性
FOUNDATION_EXPORT NSNumber * _Nullable XZJSONModelEncodeScalarNumberForProperty(__unsafe_unretained id _Nonnull model, __unsafe_unretained XZJSONPropertyDescriptor * _Nonnull property);
/// 模型转字符串。
/// @param model 模型对象
/// @param hierarchies 模型对象在集合中的层级
FOUNDATION_EXPORT NSString * _Nonnull XZJSONModelDescription(NSObject *_Nonnull model, NSUInteger hierarchies, NSArray *chain);

NS_ASSUME_NONNULL_END
