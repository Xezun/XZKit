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

+ (XZJSONPropertyDescriptor *)descriptorWithProperty:(XZOBJCProperty *)property elementType:(nullable Class)elementType ofClass:(XZJSONClassDescriptor *)aClass {
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
    descriptor->_type        = property.type.raw;
    descriptor->_elementType = elementType;
    descriptor->_getter      = getter;
    descriptor->_setter      = setter;
    
    if (descriptor->_type == XZISOCTypeObject) {
        descriptor->_subtype = property.type.subtype;
        descriptor->_foundationClass = XZJSONFoundationClassFromClass(descriptor->_subtype);
        descriptor->_foundationStruct = XZJSONFoundationStructUnknown;
        XZISOCModifiers const modifiers = property.type.modifiers;
        descriptor->_isUnownedReference = (modifiers & XZISOCModifierWeak) || (!(modifiers & XZISOCModifierCopy) && !(modifiers & XZISOCModifierRetain));
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
    
    switch (property.type.raw) {
        case XZISOCTypeUnknown:
            descriptor->_isCodable = NO;
            break;
        case XZISOCTypeChar:
        case XZISOCTypeUnsignedChar:
        case XZISOCTypeInt:
        case XZISOCTypeUnsignedInt:
        case XZISOCTypeShort:
        case XZISOCTypeUnsignedShort:
        case XZISOCTypeLong:
        case XZISOCTypeUnsignedLong:
        case XZISOCTypeInt128:
        case XZISOCTypeUnsignedInt128:
        case XZISOCTypeLongLong:
        case XZISOCTypeUnsignedLongLong:
        case XZISOCTypeFloat:
        case XZISOCTypeDouble:
        case XZISOCTypeLongDouble:
        case XZISOCTypeBool:
            descriptor->_isCodable = YES;
            break;
        case XZISOCTypeVoid:
            descriptor->_isCodable = NO;
            break;
        case XZISOCTypeString:
            descriptor->_isCodable = NO;
            break;
        case XZISOCTypeSEL:
            descriptor->_isCodable = YES;
            break;
        case XZISOCTypePointer:
            descriptor->_isCodable = NO;
            break;
        case XZISOCTypeArray:
            descriptor->_isCodable = NO;
            break;
        case XZISOCTypeVector:
            descriptor->_isCodable = NO;
            break;
        case XZISOCTypeBitField:
            descriptor->_isCodable = NO;
            break;
        case XZISOCTypeUnion:
            descriptor->_isCodable = NO;
            break;
        case XZISOCTypeStruct:
            descriptor->_isCodable = (descriptor->_foundationStruct != XZJSONFoundationStructUnknown);
            break;
        case XZISOCTypeClass:
            descriptor->_isCodable = YES;
            break;
        case XZISOCTypeObject:
            descriptor->_isCodable = !descriptor->_isUnownedReference;
            break;
    }
    
    return descriptor;
}
@end
