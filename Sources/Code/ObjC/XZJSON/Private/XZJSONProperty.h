//
//  XZJSONProperty.h
//  XZJSON
//
//  Created by Xezun on 2024/9/29.
//

#import <Foundation/Foundation.h>
#import "XZObjcRuntime.h"
#import "XZJSONPrivateDefines.h"
#import "XZMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class XZJSONClass;

/// 从 JSON 数据中通过 KVC 取值的方法。
typedef id _Nullable (^XZJSONPropertyValueDecoder)(NSDictionary *dictionary);

/// A property info in object model.
@interface XZJSONProperty : NSObject {
    @package
    /// 属性。
    XZObjcProperty *_raw;
    
    /// 当多个属性映射到同一个 JSONKey 时，将会创建此链表。
    /// 在数据转模型时，将按照链表顺序，将 JSONKey 的值，逐一解析为对应的属性。
    XZJSONProperty *_next;
    
    /// 当前属性所属的 class 对象。
    XZJSONClass * __unsafe_unretained _owner;
    
    // 当前属性是否支持 XZJSON 编码解码。如果不能，可能需要转发编码解码。
    BOOL _isCodable;
    
    /// 属性名。
    NSString *_name;
    
    /// 取值方法。必不为空。
    SEL _getter;
    /// 存值方法。必不为空。
    SEL _setter;
    
    /// 属性值类型。
    XZStdcType _type;
    /// 属性值为对象时，对象的类。
    Class _Nullable _classType;
    /// 属性为集合对象时，元素的类。
    Class _Nullable _elementType;
    /// 如果属性值是对象，判断对象的类型是否为已知类型（原生已定义的对象类型）。
    XZJSONCocoaClass _cocoaClass;
    /// 如果属性是结构体，判断结构体是否为已知的类型（原生已定义的类型）。
    XZStdcStructType _structType;

    /// 是否支持 kvc 键值编码。
    /// - 根据 Key-Value Coding Programming Guide 属性的 setter 方法必须以 `set` 或 `_set` 开头。
    /// - 值为调用 setter 方法可使用的 key 名（调用 getter 方法使用 `_name` 属性)。
    NSString *_isKeyValueCodable;
    
    /// 一对一映射：当前属性映射 JSON 键。
    NSString            *_JSONKey;
    /// 一对一映射：当前属性映射 JSON 键路径。
    NSArray<NSString *> * _Nullable _JSONKeyPath;
    /// 一对多映射：当前属性映射多 JSON 键或键路径，按数组顺序优先取值。
    NSArray             * _Nullable _JSONKeyArray;
    
    /// 当前属性从 JSON 数据中为取值的方法。
    XZJSONPropertyValueDecoder _valueDecoder;
}

+ (nullable instancetype)descriptorWithProperty:(XZObjcProperty *)property class:(XZJSONClass *)class mappingClass:(nullable Class)mappingClass;

@end


/// 将 JSONValue 值写入模型的结构体属性。
/// - Parameters:
///   - model: 模型对象
///   - property: 结构体属性
///   - JSONValue: 字符串
/// - Returns: 是否成功写入
FOUNDATION_STATIC_INLINE BOOL XZJSONModelDecodeStructProperty(id model, XZJSONProperty *property, id _Nonnull JSONValue) {
    if ([JSONValue isKindOfClass:NSString.class]) {
        switch (property->_structType) {
            case XZStdcStructTypeUnknown: {
                return NO;
            }
            case XZStdcStructTypeCGRect: {
                CGRect const aValue = CGRectFromString(JSONValue);
                ((void (*)(id, SEL, CGRect))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
            case XZStdcStructTypeCGSize: {
                CGSize const aValue = CGSizeFromString(JSONValue);
                ((void (*)(id, SEL, CGSize))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
            case XZStdcStructTypeCGPoint: {
                CGPoint const aValue = CGPointFromString(JSONValue);
                ((void (*)(id, SEL, CGPoint))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
            case XZStdcStructTypeCGVector: {
                CGVector const aValue = CGVectorFromString(JSONValue);
                ((void (*)(id, SEL, CGVector))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
            case XZStdcStructTypeCGAffineTransform: {
                CGAffineTransform const aValue = CGAffineTransformFromString(JSONValue);
                ((void (*)(id, SEL, CGAffineTransform))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
            case XZStdcStructTypeNSDirectionalEdgeInsets: {
                NSDirectionalEdgeInsets const aValue = NSDirectionalEdgeInsetsFromString(JSONValue);
                ((void (*)(id, SEL, NSDirectionalEdgeInsets))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
            case XZStdcStructTypeNSRange: {
                NSRange const aValue = NSRangeFromString(JSONValue);
                ((void (*)(id, SEL, NSRange))objc_msgSend)(model, property->_setter, aValue);
                break;
            }
            case XZStdcStructTypeUIEdgeInsets: {
                UIEdgeInsets const aValue = UIEdgeInsetsFromString(JSONValue);
                ((void (*)(id, SEL, UIEdgeInsets))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
            case XZStdcStructTypeUIOffset: {
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
FOUNDATION_STATIC_INLINE NSString * _Nullable XZJSONEncodeStructProperty(id model, XZJSONProperty *property) {
    switch (property->_structType) {
        case XZStdcStructTypeUnknown: {
            return nil;
        }
        case XZStdcStructTypeCGRect: {
            CGRect const aValue = ((CGRect (*)(id, SEL))xz_objc_msgSend_stret)(model, property->_getter);
            return NSStringFromCGRect(aValue);
        }
        case XZStdcStructTypeCGSize: {
            CGSize const aValue = ((CGSize (*)(id, SEL))objc_msgSend)(model, property->_getter);
            return NSStringFromCGSize(aValue);
        }
        case XZStdcStructTypeCGPoint: {
            CGPoint const aValue = ((CGPoint (*)(id, SEL))objc_msgSend)(model, property->_getter);
            return NSStringFromCGPoint(aValue);
        }
        case XZStdcStructTypeCGVector: {
            CGVector const aValue = ((CGVector (*)(id, SEL))objc_msgSend)(model, property->_getter);
            return NSStringFromCGVector(aValue);
        }
        case XZStdcStructTypeCGAffineTransform: {
            CGAffineTransform const aValue = ((CGAffineTransform (*)(id, SEL))xz_objc_msgSend_stret)(model, property->_getter);
            return NSStringFromCGAffineTransform(aValue);
        }
        case XZStdcStructTypeNSDirectionalEdgeInsets: {
            NSDirectionalEdgeInsets const aValue = ((NSDirectionalEdgeInsets (*)(id, SEL))xz_objc_msgSend_stret)(model, property->_getter);
            return NSStringFromDirectionalEdgeInsets(aValue);
        }
        case XZStdcStructTypeNSRange: {
            NSRange const aValue = ((NSRange (*)(id, SEL))objc_msgSend)(model, property->_getter);
            return NSStringFromRange(aValue);
        }
        case XZStdcStructTypeUIEdgeInsets: {
            UIEdgeInsets const aValue = ((UIEdgeInsets (*)(id, SEL))xz_objc_msgSend_stret)(model, property->_getter);
            return NSStringFromUIEdgeInsets(aValue);
        }
        case XZStdcStructTypeUIOffset: {
            UIOffset const aValue = ((UIOffset (*)(id, SEL))objc_msgSend)(model, property->_getter);
            return NSStringFromUIOffset(aValue);
        }
    }
}

NS_ASSUME_NONNULL_END
