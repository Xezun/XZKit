//
//  XZJSONPrivate.h
//  XZJSON
//
//  Created by Xezun on 2024/9/29.
//

@import ObjectiveC;
#import <Foundation/Foundation.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZJSONDecoder.h>
#import <XZKit/XZJSONDefines.h>
#import <XZKit/XZJSONClassDescriptor.h>
#import <XZKit/XZJSONPropertyDescriptor.h>
#import <XZKit/XZJSONEncoder.h>
#else
#import "XZJSONDefines.h"
#import "XZJSONClassDescriptor.h"
#import "XZJSONPropertyDescriptor.h"
#import "XZJSONEncoder.h"
#import "XZJSONDecoder.h"
#endif

// 从 JSON 解析数据时，如果无法转换为需要的类型，则认为该值不存在，不使用默认值或 nil 填充。

NS_ASSUME_NONNULL_BEGIN

/// 模型转字符串。
/// - Parameters:
///   - model: 模型对象
///   - indent: 模型对象在集合中的层级
FOUNDATION_EXPORT NSString * _Nonnull XZJSONModelDescription(id model, NSUInteger indent);

/// 将模型使用原生归档方法归档。
/// - Parameters:
///   - model: 模型对象
///   - aCoder: 原生归档对象
FOUNDATION_EXPORT void XZJSONModelEncodeWithCoder(id model, NSCoder *aCoder);

/// 从原生归档对象中解档模型。
/// - Parameters:
///   - model: 模型对象
///   - aCoder: 原生归档对象
FOUNDATION_EXPORT id _Nullable XZJSONModelDecodeWithCoder(id model, NSCoder *aCoder);

NS_ASSUME_NONNULL_END
