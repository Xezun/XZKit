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

+ (XZJSONPropertyDescriptor *)descriptorWithProperty:(XZObjcProperty *)property elementType:(nullable Class)elementType ofClass:(XZJSONClassDescriptor *)aClass {
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
    
    if (descriptor->_type == XZStdcTypeObject) {
        descriptor->_subtype = property.type.subtype;
        descriptor->_foundationClass = XZJSONFoundationClassFromClass(descriptor->_subtype);
        descriptor->_foundationStruct = XZJSONFoundationStructUnknown;
        XZStdcModifiers const modifiers = property.type.modifiers;
        descriptor->_isUnownedReference = (modifiers & XZStdcModifierWeak) || (!(modifiers & XZStdcModifierCopy) && !(modifiers & XZStdcModifierRetain));
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
        case XZStdcTypeUnknown:
            descriptor->_isCodable = NO;
            break;
        case XZStdcTypeChar:
        case XZStdcTypeUnsignedChar:
        case XZStdcTypeInt:
        case XZStdcTypeUnsignedInt:
        case XZStdcTypeShort:
        case XZStdcTypeUnsignedShort:
        case XZStdcTypeLong:
        case XZStdcTypeUnsignedLong:
        case XZStdcTypeInt128:
        case XZStdcTypeUnsignedInt128:
        case XZStdcTypeLongLong:
        case XZStdcTypeUnsignedLongLong:
        case XZStdcTypeFloat:
        case XZStdcTypeDouble:
        case XZStdcTypeLongDouble:
        case XZStdcTypeBool:
            descriptor->_isCodable = YES;
            break;
        case XZStdcTypeVoid:
            descriptor->_isCodable = NO;
            break;
        case XZStdcTypeString:
            descriptor->_isCodable = NO;
            break;
        case XZStdcTypeSelector:
            descriptor->_isCodable = YES;
            break;
        case XZStdcTypePointer:
            descriptor->_isCodable = NO;
            break;
        case XZStdcTypeArray:
            descriptor->_isCodable = NO;
            break;
        case XZStdcTypeVector:
            descriptor->_isCodable = NO;
            break;
        case XZStdcTypeBitField:
            descriptor->_isCodable = NO;
            break;
        case XZStdcTypeUnion:
            descriptor->_isCodable = NO;
            break;
        case XZStdcTypeStruct:
            descriptor->_isCodable = (descriptor->_foundationStruct != XZJSONFoundationStructUnknown);
            break;
        case XZStdcTypeClass:
            descriptor->_isCodable = YES;
            break;
        case XZStdcTypeObject:
            descriptor->_isCodable = !descriptor->_isUnownedReference;
            break;
    }
    
    return descriptor;
}
@end
