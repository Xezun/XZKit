//
//  XZJSONClassDescriptor.h
//  XZJSON
//
//  Created by Xezun on 2024/9/29.
//

#import <Foundation/Foundation.h>
#import "XZObjcDescriptor.h"
#import "XZJSONDescriptor.h"

NS_ASSUME_NONNULL_BEGIN

@class XZJSONPropertyDescriptor;

/// 用于描述进行 JSON 模型化或序列化的 Class 信息。
@interface XZJSONClassDescriptor : NSObject {
    @package
    /// 描述类基本信息的对象。
    XZObjcClassDescriptor *_class;
    
    /// 所有可模型化或序列化的属性的数量。
    NSUInteger _numberOfProperties;
    /// 所有可模型化或序列化的属性，包括从超类继承的。已按名称排序。
    NSArray<XZJSONPropertyDescriptor *> *_properties;
    /// JSON 键（包括键路径、键数组）与属性的映射关系字典。
    NSDictionary<NSString *, XZJSONPropertyDescriptor *> *_keyProperties;
    /// 使用 keyPath 映射的属性。
    NSArray<XZJSONPropertyDescriptor *> *_keyPathProperties;
    /// 使用 keyArray 映射的属性。
    NSArray<XZJSONPropertyDescriptor *> *_keyArrayProperties;
    /// 如果是，原生对象的类型。 Model class type.
    XZJSONClassType _classType;
    
    /// 是否需要转发模型解析。
    BOOL _forwardsClassForDecoding;
    /// 是否校验数据。
    BOOL _verifiesValueForDecoding;
    
    /// 是否使用自定义模型化方法，即 -initWithJSONDictionary: 方法。
    BOOL _usesJSONDecodingMethod;
    /// 是否使用自定义序列化方法，即 -encodeIntoJSONDictionary: 方法。
    BOOL _usesJSONEncodingMethod;
    
    /// 是否使用自定义属性模型化方法，即 -decodeDateFromJSONValue:forKey: 方法。
    BOOL _usesPropertyDecodingMethod;
    /// 是否使用自定义属性序列化方法，即 -encodeDateIntoJSONValue:forKey: 方法。
    BOOL _usesPropertyEncodingMethod;
    
    /// 是否定义了自定义复制方法。即 -copyIvar: 方法。
    BOOL _usesIvarCopyingMethod;
}

- (instancetype)init NS_UNAVAILABLE;
+ (nullable XZJSONClassDescriptor *)descriptorForClass:(nullable Class)aClass;

@end

NS_ASSUME_NONNULL_END
