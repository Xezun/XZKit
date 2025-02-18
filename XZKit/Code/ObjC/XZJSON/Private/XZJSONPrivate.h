//
//  XZJSONPrivate.h
//  XZJSON
//
//  Created by Xezun on 2024/9/29.
//

#import "XZJSON.h"
#import <Foundation/Foundation.h>
#import "XZJSONDefines.h"
#import "XZJSONClassDescriptor.h"
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
/// 将 模型实例对象 编码进 JSON 字典中。
+ (nullable id)_model:(id)model encodeIntoDictionary:(nullable NSMutableDictionary *)dictionary descriptor:(XZJSONClassDescriptor *)descriptor;
@end

/// 将 JSON 值解析为模型属性值。
/// - Parameters:
///   - model: 模型
///   - property: 属性
///   - value: JSON 值
FOUNDATION_EXPORT void XZJSONModelDecodeProperty(id model, XZJSONPropertyDescriptor *property, id _Nonnull JSONValue);

/// 将模型结构体属性编码为字符串，仅针对已知的原生结构体。
/// - Parameters:
///   - model: 模型
///   - property: 属性
FOUNDATION_EXPORT NSString * _Nullable XZJSONModelEncodeStructProperty(id model, XZJSONPropertyDescriptor *property);

/// 当属性结构体为原生结构体时，可使用此函数将字符串解码为结构体。
/// - Parameters:
///   - model: 模型
///   - property: 属性
///   - JSONValue: 结构体编码后的字符串
FOUNDATION_EXPORT BOOL XZJSONModelDecodeStructProperty(id model, XZJSONPropertyDescriptor *property, id _Nonnull JSONValue);

/// 模型转字符串。
/// - Parameters:
///   - model: 模型对象
///   - hierarchies: 模型对象在集合中的层级
FOUNDATION_EXPORT NSString * _Nonnull XZJSONModelDescription(id model, NSUInteger hierarchies, NSArray *chain);


FOUNDATION_EXPORT void XZJSONModelEncodeWithCoder(id model, NSCoder *aCoder);
FOUNDATION_EXPORT id _Nullable XZJSONModelDecodeWithCoder(id model, NSCoder *aCoder);

NS_ASSUME_NONNULL_END
