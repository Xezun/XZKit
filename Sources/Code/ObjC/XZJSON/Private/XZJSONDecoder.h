//
//  XZJSONDecoder.h
//  XZJSON
//
//  Created by 徐臻 on 2025/2/28.
//

#import <Foundation/Foundation.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZJSONClass.h>
#else
#import "XZJSONClass.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class XZJSONClass;

/// 解析 JSON 数据流。
FOUNDATION_EXPORT id _Nullable XZJSONDecodeData(NSData * const _Unsafe data, NSJSONReadingOptions const options, Class const _Unsafe aClass);

/// 解析 JSON 数据对象。
FOUNDATION_EXPORT id _Nullable XZJSONDecodeObject(id const _Unsafe object, Class const _Unsafe ModelClass);

/// 模型实例对象，解码 JSON 数据。
FOUNDATION_EXPORT void XZJSONModelDecodeFromDictionary(id const _Unsafe model, XZJSONClass * const _Unsafe JSONClass, NSDictionary * const _Unsafe dictionary);

NS_ASSUME_NONNULL_END
