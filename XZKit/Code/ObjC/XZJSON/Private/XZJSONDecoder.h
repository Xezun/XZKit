//
//  XZJSONDecoder.h
//  XZJSON
//
//  Created by 徐臻 on 2025/2/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class XZJSONClassDescriptor;

/// JSON 数据流，调用此方法模型化。
FOUNDATION_EXPORT id _Nullable XZJSONDecodeJSONData(NSData * const __unsafe_unretained data, NSJSONReadingOptions const options, Class const __unsafe_unretained aClass);

/// JSON 序列化数据，调用此方法模型化。
FOUNDATION_EXPORT id _Nullable XZJSONDecodeJSONObject(id const __unsafe_unretained object, Class const __unsafe_unretained aClass);

/// 模型实例对象，解码 JSON 数据。
FOUNDATION_EXPORT void XZJSONModelDecodeFromDictionary(id const __unsafe_unretained model, XZJSONClassDescriptor * const __unsafe_unretained descriptor, NSDictionary * const __unsafe_unretained dictionary);

NS_ASSUME_NONNULL_END
