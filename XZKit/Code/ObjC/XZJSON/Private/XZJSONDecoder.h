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
FOUNDATION_EXPORT id _Nullable XZJSONDecodeJSONData(NSData *data, NSJSONReadingOptions options, Class aClass);

/// JSON 序列化数据，调用此方法模型化。
FOUNDATION_EXPORT id _Nullable XZJSONDecodeJSONObject(id object, Class aClass);

/// 模型实例对象，解码 JSON 数据。
FOUNDATION_EXPORT void XZJSONModelDecodeFromDictionary(id model, XZJSONClassDescriptor *descriptor, NSDictionary *dictionary);

NS_ASSUME_NONNULL_END
