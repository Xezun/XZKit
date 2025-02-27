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

typedef id _Nullable (^XZJSONKeyValueCoder)(id object);

/// A property info in object model.
@interface XZJSONPropertyDescriptor : NSObject {
    @package
    /// 当前属性所在的 class 描述对象
    XZJSONClassDescriptor * __unsafe_unretained _class;
    /// 属性。 property's info
    XZObjcPropertyDescriptor *_property;
    /// 属性映射链表，多属性映射单一数据的链表。 next meta if there are multiple properties mapped to the same key.
    XZJSONPropertyDescriptor *_next;
    
    /// 属性名。property's name
    NSString *_name;
    /// 属性值类型。property's type
    XZObjcType _type;
    /// 如果属性值是对象，判断对象的类型是否为已知类型（原生已定义的对象类型）。property's Foundation type
    XZJSONClassType _classType;
    /// 如果属性是结构体，判断结构体是否为已知的类型（原生已定义的类型）。
    XZJSONStructType _structType;
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
    
    /// 一对一映射：当前属性映射 JSON 键。
    NSString            * _Nonnull _JSONKey;
    /// 一对一映射：当前属性映射 JSON 键路径。
    NSArray<NSString *> * _Nullable _JSONKeyPath;
    /// 一对多映射：当前属性映射多 JSON 键或键路径，按数组顺序优先取值。
    NSArray             * _Nullable _JSONKeyArray;
    
    /// 通过 KVC 取值的方法。
    XZJSONKeyValueCoder _keyValueCoder;
    
    /// 是否为无主引用或弱引用的属性。 
    BOOL _isUnownedReferenceProperty;
}

+ (XZJSONPropertyDescriptor *)descriptorWithClass:(XZJSONClassDescriptor *)aClass property:(XZObjcPropertyDescriptor *)property elementType:(nullable Class)elementType;

@end

NS_ASSUME_NONNULL_END
