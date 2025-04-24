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

/// 从 JSON 数据中通过 KVC 取值的方法。
typedef id _Nullable (^XZJSONValueDecoder)(NSDictionary *dictionary);

/// A property info in object model.
@interface XZJSONPropertyDescriptor : NSObject {
    @package
    /// 属性。 property's info
    XZObjcPropertyDescriptor *_raw;
    
    /// 属性映射链表，多属性映射单一数据的链表。 next meta if there are multiple properties mapped to the same key.
    XZJSONPropertyDescriptor *_next;
    
    /// 当前属性所属的 class 对象。
    XZJSONClassDescriptor * __unsafe_unretained _class;
    
    /// 属性名。property's name
    NSString *_name;
    /// 取值方法。必不为空。
    SEL _getter;
    /// 存值方法。必不为空。
    SEL _setter;
    
    /// 属性值类型。property's type
    XZObjcType _type;
    /// 属性值为对象时，对象的类。 property's class, or nil
    Class _Nullable _subtype;
    /// 属性为集合对象时，元素的类。 container's generic class, or nil if threr's no generic class
    Class _Nullable _elementType;
    /// 如果属性值是对象，判断对象的类型是否为已知类型（原生已定义的对象类型）。property's Foundation type
    XZJSONFoundationClassType _foundationClassType;
    /// 如果属性是结构体，判断结构体是否为已知的类型（原生已定义的类型）。
    XZJSONFoundationStructType _foundationStructType;

    /// 是否支持 kvc 键值编码。
    /// 根据 Key-Value Coding Programming Guide 属性的 setter 方法必须以 `set` 或 `_set` 开头。
    /// 值为调用 setter 方法可使用的 key 名（调用 getter 方法使用 `_name` 属性)。
    NSString *_isKeyValueCodable;
    
    /// 一对一映射：当前属性映射 JSON 键。
    NSString            *_JSONKey;
    /// 一对一映射：当前属性映射 JSON 键路径。
    NSArray<NSString *> * _Nullable _JSONKeyPath;
    /// 一对多映射：当前属性映射多 JSON 键或键路径，按数组顺序优先取值。
    NSArray             * _Nullable _JSONKeyArray;
    
    /// 当前属性从 JSON 数据中为取值的方法。
    XZJSONValueDecoder _valueDecoder;
    
    /// 是否为无主引用或弱引用的属性。 
    BOOL _isUnownedReferenceProperty;
}

+ (instancetype)descriptorWithProperty:(XZObjcPropertyDescriptor *)property elementType:(nullable Class)elementType ofClass:(XZJSONClassDescriptor *)aClass;

@end


/// 将 JSONValue 值写入模型的结构体属性。
/// - Parameters:
///   - model: 模型对象
///   - property: 结构体属性
///   - JSONValue: 字符串
/// - Returns: 是否成功写入
FOUNDATION_STATIC_INLINE BOOL XZJSONDecodeStructProperty(id model, XZJSONPropertyDescriptor *property, id _Nonnull JSONValue) {
    if ([JSONValue isKindOfClass:NSString.class]) {
        switch (property->_foundationStructType) {
            case XZJSONFoundationStructTypeUnknown: {
                return NO;
            }
            case XZJSONFoundationStructTypeCGRect: {
                CGRect const aValue = CGRectFromString(JSONValue);
                ((void (*)(id, SEL, CGRect))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
            case XZJSONFoundationStructTypeCGSize: {
                CGSize const aValue = CGSizeFromString(JSONValue);
                ((void (*)(id, SEL, CGSize))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
            case XZJSONFoundationStructTypeCGPoint: {
                CGPoint const aValue = CGPointFromString(JSONValue);
                ((void (*)(id, SEL, CGPoint))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
            case XZJSONFoundationStructTypeUIEdgeInsets: {
                UIEdgeInsets const aValue = UIEdgeInsetsFromString(JSONValue);
                ((void (*)(id, SEL, UIEdgeInsets))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
            case XZJSONFoundationStructTypeCGVector: {
                CGVector const aValue = CGVectorFromString(JSONValue);
                ((void (*)(id, SEL, CGVector))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
            case XZJSONFoundationStructTypeCGAffineTransform: {
                CGAffineTransform const aValue = CGAffineTransformFromString(JSONValue);
                ((void (*)(id, SEL, CGAffineTransform))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
            case XZJSONFoundationStructTypeNSDirectionalEdgeInsets: {
                NSDirectionalEdgeInsets const aValue = NSDirectionalEdgeInsetsFromString(JSONValue);
                ((void (*)(id, SEL, NSDirectionalEdgeInsets))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
            case XZJSONFoundationStructTypeUIOffset: {
                UIOffset const aValue = UIOffsetFromString(JSONValue);
                ((void (*)(id, SEL, UIOffset))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
        }
    }
    return NO;
}

/// 读取模型结构体属性为字符串。
/// - Parameters:
///   - model: 模型对象
///   - property: 模型结构体属性
FOUNDATION_STATIC_INLINE NSString * _Nullable XZJSONEncodeStructProperty(id model, XZJSONPropertyDescriptor *property) {
    switch (property->_foundationStructType) {
        case XZJSONFoundationStructTypeUnknown: {
            return nil;
        }
        case XZJSONFoundationStructTypeCGRect: {
            CGRect aValue = ((CGRect (*)(id, SEL))objc_msgSend)(model, property->_getter);
            return NSStringFromCGRect(aValue);
        }
        case XZJSONFoundationStructTypeCGSize: {
            CGSize aValue = ((CGSize (*)(id, SEL))objc_msgSend)(model, property->_getter);
            return NSStringFromCGSize(aValue);
        }
        case XZJSONFoundationStructTypeCGPoint: {
            CGPoint aValue = ((CGPoint (*)(id, SEL))objc_msgSend)(model, property->_getter);
            return NSStringFromCGPoint(aValue);
        }
        case XZJSONFoundationStructTypeUIEdgeInsets: {
            UIEdgeInsets aValue = ((UIEdgeInsets (*)(id, SEL))objc_msgSend)(model, property->_getter);
            return NSStringFromUIEdgeInsets(aValue);
        }
        case XZJSONFoundationStructTypeCGVector: {
            CGVector aValue = ((CGVector (*)(id, SEL))objc_msgSend)(model, property->_getter);
            return NSStringFromCGVector(aValue);
        }
        case XZJSONFoundationStructTypeCGAffineTransform: {
            CGAffineTransform aValue = ((CGAffineTransform (*)(id, SEL))objc_msgSend)(model, property->_getter);
            return NSStringFromCGAffineTransform(aValue);
        }
        case XZJSONFoundationStructTypeNSDirectionalEdgeInsets: {
            NSDirectionalEdgeInsets aValue = ((NSDirectionalEdgeInsets (*)(id, SEL))objc_msgSend)(model, property->_getter);
            return NSStringFromDirectionalEdgeInsets(aValue);
        }
        case XZJSONFoundationStructTypeUIOffset: {
            UIOffset aValue = ((UIOffset (*)(id, SEL))objc_msgSend)(model, property->_getter);
            return NSStringFromUIOffset(aValue);
        }
    }
}

NS_ASSUME_NONNULL_END
