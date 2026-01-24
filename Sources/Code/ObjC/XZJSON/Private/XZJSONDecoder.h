//
//  XZJSONDecoder.h
//  XZJSON
//
//  Created by 徐臻 on 2025/2/28.
//

#import <Foundation/Foundation.h>
#import "XZJSONType.h"

NS_ASSUME_NONNULL_BEGIN

@class XZJSONClass;

/// 解析 JSON 数据流。
FOUNDATION_EXPORT id _Nullable XZJSONDecodeJSONData(NSData * const _Unsafe data, NSJSONReadingOptions const options, Class const _Unsafe aClass);

/// 解析 JSON 数据对象。
FOUNDATION_EXPORT id _Nullable XZJSONDecodeJSONObject(id const _Unsafe object, Class const _Unsafe aClass);

/// 模型实例对象，解码 JSON 数据。
FOUNDATION_EXPORT void XZJSONModelDecodeFromDictionary(id const _Unsafe model, XZJSONClass * const _Unsafe modelClass, NSDictionary * const _Unsafe dictionary);

NS_ASSUME_NONNULL_END
