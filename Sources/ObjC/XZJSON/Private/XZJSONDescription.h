//
//  XZJSONDescription.h
//  XZJSON
//
//  Created by Xezun on 2024/9/29.
//

#import <Foundation/Foundation.h>

// 从 JSON 解析数据时，如果无法转换为需要的类型，则认为该值不存在，不使用默认值或 nil 填充。

NS_ASSUME_NONNULL_BEGIN

/// 模型转字符串。
/// - Parameters:
///   - model: 任意对象
///   - indent: 换行后的缩进等级
FOUNDATION_EXPORT NSString * _Nonnull XZJSONObjectDescription(id object, NSUInteger indent);

NS_ASSUME_NONNULL_END
