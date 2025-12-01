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

+ (XZJSONPropertyDescriptor *)descriptorWithProperty:(XZObjcPropertyDescriptor *)property elementType:(nullable Class)elementType ofClass:(XZJSONClassDescriptor *)aClass {
    // 必须是读写属性才参与 JSON 处理
    SEL const setter = property.setter;
    if (setter == nil || ![aClass->_raw.raw instancesRespondToSelector:setter]) {
        return nil;
    }
    
    SEL const getter = property.getter;
    if (getter == nil || ![aClass->_raw.raw instancesRespondToSelector:getter]) {
        return nil;
    }
    
    XZJSONPropertyDescriptor * const descriptor = [self new];
    descriptor->_owner       = aClass;
    descriptor->_raw         = property;
    descriptor->_name        = property.name;
    descriptor->_type        = property.type.type;
    descriptor->_elementType = elementType;
    descriptor->_getter      = getter;
    descriptor->_setter      = setter;
    
    if (descriptor->_type == XZObjcTypeObject) {
        descriptor->_subtype = property.type.subtype;
        descriptor->_foundationClass = XZJSONFoundationClassFromClass(descriptor->_subtype);
        descriptor->_foundationStruct = XZJSONFoundationStructUnknown;
        XZObjcModifiers const modifiers = property.type.modifiers;
        descriptor->_isUnownedReference = (modifiers & XZObjcModifierWeak) || (!(modifiers & XZObjcModifierCopy) && !(modifiers & XZObjcModifierRetain));
    } else {
        descriptor->_subtype = Nil;
        descriptor->_foundationClass = XZJSONFoundationClassUnknown;
        descriptor->_foundationStruct = XZJSONFoundationStructFromType(property.type);
        descriptor->_isUnownedReference = NO;
    }
    
    // 不是以 set 开头的 setter 无法被 KVC 找到。
    NSString * const setterName = NSStringFromSelector(descriptor->_setter);
    if ([setterName hasPrefix:@"set"]) {
        if (setterName.length >= 5) {
            descriptor->_isKeyValueCodable = [setterName substringWithRange:NSMakeRange(3, setterName.length - 4)];
        }
    } else if ([setterName hasPrefix:@"_set"]) {
        if (setterName.length >= 6) {
            descriptor->_isKeyValueCodable = [setterName substringWithRange:NSMakeRange(4, setterName.length - 5)];
        }
    }
    
    switch (property.type.type) {
        case XZObjcTypeUnknown:
            descriptor->_isCodable = NO;
            break;
        case XZObjcTypeChar:
        case XZObjcTypeUnsignedChar:
        case XZObjcTypeInt:
        case XZObjcTypeUnsignedInt:
        case XZObjcTypeShort:
        case XZObjcTypeUnsignedShort:
        case XZObjcTypeLong:
        case XZObjcTypeUnsignedLong:
        case XZObjcTypeInt128:
        case XZObjcTypeUnsignedInt128:
        case XZObjcTypeLongLong:
        case XZObjcTypeUnsignedLongLong:
        case XZObjcTypeFloat:
        case XZObjcTypeDouble:
        case XZObjcTypeLongDouble:
        case XZObjcTypeBool:
            descriptor->_isCodable = YES;
            break;
        case XZObjcTypeVoid:
            descriptor->_isCodable = NO;
            break;
        case XZObjcTypeString:
            descriptor->_isCodable = NO;
            break;
        case XZObjcTypeSEL:
            descriptor->_isCodable = YES;
            break;
        case XZObjcTypePointer:
            descriptor->_isCodable = NO;
            break;
        case XZObjcTypeArray:
            descriptor->_isCodable = NO;
            break;
        case XZObjcTypeVector:
            descriptor->_isCodable = NO;
            break;
        case XZObjcTypeBitField:
            descriptor->_isCodable = NO;
            break;
        case XZObjcTypeUnion:
            descriptor->_isCodable = NO;
            break;
        case XZObjcTypeStruct:
            descriptor->_isCodable = (descriptor->_foundationStruct != XZJSONFoundationStructUnknown);
            break;
        case XZObjcTypeClass:
            descriptor->_isCodable = YES;
            break;
        case XZObjcTypeObject:
            descriptor->_isCodable = !descriptor->_isUnownedReference;
            break;
    }
    
    return descriptor;
}
@end
