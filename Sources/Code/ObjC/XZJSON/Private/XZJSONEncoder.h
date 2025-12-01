//
//  XZJSONEncoder.h
//  XZJSON
//
//  Created by 徐臻 on 2025/2/28.
//

#import <Foundation/Foundation.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZJSONDescriptor.h>
#else
#import "XZJSONDescriptor.h"
#endif

@class XZJSONClassDescriptor;

NS_ASSUME_NONNULL_BEGIN

/// 将非空任意对象进行 JSON 序列化。调用此方法前，必须判断 object 不为 nil 空值，可以是 NSNull 对象。
/// 
/// 返回值可能为 NSNull 对象，因为 null 是合法的 JSON 组成元素，但是不能作为顶层元素。
/// 所以在序列化时，如果没有 NSJSONWritingFragmentsAllowed 选项，序列化会失败。
/// 
/// - Parameters:
///   - model: 待序列化的模型对象或包含模型的集合
///   - descriptor: 模型的描述信息
///   - dictionary: 如果是模型对象，提供此参数，模型的属性将合并到此字典中
///   - classType: 模型的 Class 类型
/// - Returns: 可使用 NSJSONSerialization 序列化的对象
FOUNDATION_EXPORT id XZJSONEncodeModelIntoDictionary(id const _Unsafe model, XZJSONClassDescriptor * _Nullable _Unsafe descriptor, XZJSONFoundationClass classType, NSMutableDictionary * _Nullable dictionary);

/// 将模型实例对象进行 JSON 序列化。调用此方法，表明已经判断 model 属于一般模型对象，而不是基础数据对象，特别是原生对象。
/// - Parameters:
///   - model: 模型实例对象，不为 nil 且不可为 NSNull 对象
///   - dictionary: 模型实例对象的属性，将合并到此字典中
///   - descriptor: 模型的描述对象
FOUNDATION_EXPORT void XZJSONModelEncodeIntoDictionary(id const _Unsafe model, XZJSONClassDescriptor * const _Unsafe descriptor, NSMutableDictionary * const _Unsafe dictionary);

NS_ASSUME_NONNULL_END



