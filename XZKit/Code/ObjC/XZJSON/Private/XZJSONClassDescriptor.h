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
    
    /// 所有可模型化或序列化的属性，包括从超类继承的。
    NSArray<XZJSONPropertyDescriptor *> *_properties;
    /// 所有可模型化或序列化的属性的数量。
    NSUInteger _numberOfProperties;
    /// JSON 键与属性的映射。Key:mapped key and key path, Value:XZJSONObjcPropertyMeta.
    NSDictionary<NSString *, XZJSONPropertyDescriptor *> *_keyProperties;
    /// JSON 键值路径与属性的映射。Array<XZJSONObjcPropertyMeta>, property meta which is mapped to a key path.
    NSArray<XZJSONPropertyDescriptor *> *_keyPathProperties;
    /// 多个 JSON 键与属性的映射。Array<XZJSONObjcPropertyMeta>, property meta which is mapped to multi keys.
    NSArray<XZJSONPropertyDescriptor *> *_keyArrayProperties;
    /// 如果是，原生对象的类型。 Model class type.
    XZJSONEncodingNSType _nsType;
    
    /// 是否需要转发模型解析。
    BOOL _forwardsClassForDecoding;
    /// 是否校验数据。
    BOOL _verifiesValueForDecoding;
    /// 是否使用 XZJSONDecoding 指定的初始化方法。
    BOOL _usesDecodingInitializer;
    
    /// 是否自定义序列化过程
    BOOL _usesJSONEncodingMethod;
}

- (instancetype)init NS_UNAVAILABLE;
+ (nullable XZJSONClassDescriptor *)descriptorForClass:(nullable Class)aClass;

@end

NS_ASSUME_NONNULL_END
