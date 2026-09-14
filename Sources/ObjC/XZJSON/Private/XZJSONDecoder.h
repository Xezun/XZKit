//
//  XZJSONDecoder.h
//  XZJSON
//
//  Created by Xezun on 2025/2/28.
//

#import <Foundation/Foundation.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZJSONClass.h>
#else
#import "XZJSONClass.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class XZJSONClass;

/// 对任意对象，执行 JSON 解析。
/// 在不确定 data 是否已经进行 JSON 解析时，用此方法。
FOUNDATION_EXPORT id _Nullable XZJSONDecodeData(id const _Untain data, NSJSONReadingOptions const options, Class const _Untain ModelClass);

/// 模型实例对象，解码 JSON 数据。
FOUNDATION_EXPORT void XZJSONModelDecodeFromDictionary(id const _Untain model, XZJSONClass * const _Untain JSONClass, NSDictionary * const _Untain dictionary);

NS_ASSUME_NONNULL_END
