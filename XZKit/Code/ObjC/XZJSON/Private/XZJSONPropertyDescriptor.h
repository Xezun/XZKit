//
//  XZJSONPropertyDescriptor.h
//  XZJSON
//
//  Created by Xezun on 2024/9/29.
//

#import <Foundation/Foundation.h>
#import "XZObjcDescriptor.h"
#import "XZJSONDescriptor.h"

NS_ASSUME_NONNULL_BEGIN

@class XZJSONClassDescriptor;

/// A property info in object model.
@interface XZJSONPropertyDescriptor : NSObject {
    @package
    /// 当前属性所在的 class 描述对象
    XZJSONClassDescriptor * __unsafe_unretained _class;
    /// 属性。 property's info
    XZObjcPropertyDescriptor *_property;
    /// 属性映射链表。 next meta if there are multiple properties mapped to the same key.
    XZJSONPropertyDescriptor *_next;
    
    /// 属性名。property's name
    NSString *_name;
    /// 属性值类型。property's type
    XZObjcType _type;
    /// 如果是，属性值原生类型。property's Foundation type
    XZJSONClassType _classType;
    /// 属性是否为 c 数值。is c number type
    BOOL _isScalarNumber;
    /// 属性值为对象时，对象的类。 property's class, or nil
    Class _Nullable _subtype;
    /// 属性为集合对象时，元素的类。 container's generic class, or nil if threr's no generic class
    Class _Nullable _elementType;
    /// 取值方法。必不为空。
    SEL _getter;
    /// 存值方法。必不为空。
    SEL _setter;
    /// 是否支持 kvc 键值编码。
    /// 根据 Key-Value Coding Programming Guide 属性的 setter 方法必须以 `set` 或 `_set` 开头。
    /// 值为调用 setter 方法可使用的 key 名（调用 getter 方法使用 `_name` 属性)。
    NSString *_isKeyValueCodable;
    
    /// 映射到当前属性的 JSON 键名。可能是 keyPath 或 keyArray 的第一个元素。
    NSString            * _Nonnull _JSONKey;
    /// 映射到当前属性的 JSON 键路径。
    NSArray<NSString *> * _Nullable _JSONKeyPath;
    /// 映射到当前属性的 JSON 键数组。值为 `NSString *` 类型或者 `NSArray<NSString *> *` 类型。
    NSArray             * _Nullable _JSONKeyArray;
}

+ (XZJSONPropertyDescriptor *)descriptorWithClass:(XZJSONClassDescriptor *)aClass property:(XZObjcPropertyDescriptor *)property elementType:(nullable Class)elementType;

@end

NS_ASSUME_NONNULL_END
