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
    /// 如果是，原生对象的类型。 Model class type.
    XZJSONFoundationClass _foundationClass;
    
    /// 所有可模型化或序列化的属性的数量。
    NSUInteger _numberOfProperties;
    
    /// 所有可模型化或序列化的属性，包括从超类继承的。已按名称排序。
    NSArray<XZJSONPropertyDescriptor *> *_properties;
    /// 以“属性名”为键的所有可模型化属性组成的字典。
    NSDictionary<NSString *, XZJSONPropertyDescriptor *> *_namedProperties;
    
    /// 使用 key 映射的属性。
    NSDictionary<NSString *, XZJSONPropertyDescriptor *> *_keyProperties;
    /// 使用 keyPath 映射的属性。
    NSArray<XZJSONPropertyDescriptor *> *_keyPathProperties;
    /// 使用 keyArray 映射的属性。
    NSArray<XZJSONPropertyDescriptor *> *_keyArrayProperties;
    
    /// 是否需要转发模型解析。
    BOOL _forwardsClassForDecoding;
    /// 是否校验数据。
    BOOL _verifiesValueForDecoding;
    
    /// 是否使用自定义模型化方法，即 -initWithJSONDictionary: 方法。
    BOOL _usesJSONDecodingInitializer;
    /// 是否使用自定义序列化方法，即 -encodeIntoJSONDictionary: 方法。
    BOOL _usesJSONEncodingInitializer;
    
    /// 是否使用自定义属性模型化方法，即 -decodeDateFromJSONValue:forKey: 方法。
    BOOL _usesPropertyJSONDecodingMethod;
    /// 是否使用自定义属性序列化方法，即 -encodeDateIntoJSONValue:forKey: 方法。
    BOOL _usesPropertyJSONEncodingMethod;
}

- (instancetype)init NS_UNAVAILABLE;
+ (nullable XZJSONClassDescriptor *)descriptorWithClass:(nullable Class)aClass;

@end

NS_ASSUME_NONNULL_END
