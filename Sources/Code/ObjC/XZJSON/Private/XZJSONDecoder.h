//
//  XZJSONDecoder.h
//  XZJSON
//
//  Created by 徐臻 on 2025/2/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class XZJSONClassDescriptor;

/// 解析 JSON 数据流。
FOUNDATION_EXPORT id _Nullable XZJSONDecodeJSONData(NSData * const __unsafe_unretained data, NSJSONReadingOptions const options, Class const __unsafe_unretained aClass);

/// 解析 JSON 数据对象。
FOUNDATION_EXPORT id _Nullable XZJSONDecodeJSONObject(id const __unsafe_unretained object, Class const __unsafe_unretained aClass);

/// 模型实例对象，解码 JSON 数据。
FOUNDATION_EXPORT void XZJSONModelDecodeFromDictionary(id const __unsafe_unretained model, XZJSONClassDescriptor * const __unsafe_unretained modelClass, NSDictionary * const __unsafe_unretained dictionary);

NS_ASSUME_NONNULL_END
