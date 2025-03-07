//
//  XZJSONPropertyDescriptor.m
//  XZJSON
//
//  Created by Xezun on 2024/9/29.
//

#import "XZJSONPropertyDescriptor.h"
#import "XZJSONDefines.h"
#import "XZJSONClassDescriptor.h"

@implementation XZJSONPropertyDescriptor

+ (XZJSONPropertyDescriptor *)descriptorWithClass:(XZJSONClassDescriptor *)aClass property:(XZObjcPropertyDescriptor *)property elementType:(Class)elementType {
    // 必须是读写属性才参与 JSON 处理
    SEL const setter = property.setter;
    if (setter == nil || ![aClass->_class.raw instancesRespondToSelector:setter]) {
        return nil;
    }
    SEL const getter = property.getter;
    if (getter == nil || ![aClass->_class.raw instancesRespondToSelector:getter]) {
        return nil;
    }
    
    // support pseudo generic class with protocol name
    if (!elementType && property.type.protocols) {
        for (Protocol *protocol in property.type.protocols) {
            Class cls = objc_getClass(protocol_getName(protocol));
            if ([cls conformsToProtocol:protocol]) {
                elementType = cls;
                break;
            }
        }
    }
    
    XZJSONPropertyDescriptor *descriptor = [self new];
    descriptor->_class       = aClass;
    descriptor->_property    = property;
    descriptor->_name        = property.name;
    descriptor->_type        = property.type.type;
    descriptor->_elementType = elementType;
    descriptor->_getter      = getter;
    descriptor->_setter      = setter;
    
    if (descriptor->_type == XZObjcTypeObject) {
        descriptor->_subtype = property.type.subtype;
        descriptor->_classType = XZJSONClassTypeFromClass(descriptor->_subtype);
        descriptor->_structType = XZJSONStructTypeUnknown;
        descriptor->_isScalarNumber = NO;
        XZObjcQualifiers const qualifiers = property.type.qualifiers;
        descriptor->_isUnownedReferenceProperty = (qualifiers & XZObjcQualifierWeak) || (!(qualifiers & XZObjcQualifierCopy) && !(qualifiers & XZObjcQualifierRetain));
    } else {
        descriptor->_subtype = Nil;
        descriptor->_classType = XZJSONClassTypeUnknown;
        descriptor->_structType = XZJSONStructTypeFromType(property.type);
        descriptor->_isScalarNumber = XZObjcIsScalarNumber(descriptor->_type);
        descriptor->_isUnownedReferenceProperty = NO;
    }
    
    // 不是以 set 开头的 setter 无法被 KVC 找到。
    NSString * const setterName = NSStringFromSelector(descriptor->_setter);
    if ([setterName hasPrefix:@"set"]) {
        descriptor->_isKeyValueCodable = [setterName substringWithRange:NSMakeRange(3, setterName.length - 4)];
    } else if ([setterName hasPrefix:@"_set"]) {
        descriptor->_isKeyValueCodable = [setterName substringWithRange:NSMakeRange(4, setterName.length - 5)];
    }
    
    return descriptor;
}
@end
