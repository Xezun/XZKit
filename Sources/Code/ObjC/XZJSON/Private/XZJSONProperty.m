//
//  XZJSONProperty.m
//  XZJSON
//
//  Created by Xezun on 2024/9/29.
//

#import "XZJSONProperty.h"
#import "XZJSONDefines.h"
#import "XZJSONClass.h"

@implementation XZJSONProperty

+ (XZJSONProperty *)descriptorWithProperty:(XZObjcProperty *)property mappingClass:(nullable Class)mappingClass class:(XZJSONClass *)aClass {
    XZStdcModifiers const modifiers = property.modifiers;
    
    // 必须是读写属性才参与 JSON 处理
    if (modifiers & XZStdcModifierReadonly) {
        return nil;
    }
    
    XZStdcType const _type = property.type.type;
    Class _classType = Nil;
    if (_type == XZStdcTypeObject) {
        // 不处理是无主引用或弱引用的属性。
        if ( (modifiers & XZStdcModifierWeak) || !(modifiers & (XZStdcModifierCopy | XZStdcModifierRetain)) ) {
            return nil;
        }
        _classType = property.type.classType;
        if (_classType == Nil) {
            // 未知类型，使用映射值
            _classType = mappingClass;
            mappingClass = nil;
        }
    } else {
        mappingClass = Nil;
    }
    
    SEL   const _setter    = property.setter;
    
    
    XZJSONProperty * const descriptor = [self new];
    descriptor->_owner       = aClass;
    descriptor->_raw         = property;
    descriptor->_name        = property.name;
    descriptor->_type        = _type;
    descriptor->_getter      = property.getter;
    descriptor->_setter      = _setter;
    descriptor->_classType   = _classType;
    descriptor->_cocoaClass  = XZJSONCocoaClassFromClass(_classType);
    descriptor->_elementType = mappingClass;
    descriptor->_structType  = property.type.structType;
    descriptor->_isKeyValueCodable = nil;
    
    // 不是以 set 开头的 setter 无法被 KVC 找到，不能使用 KVC 赋值。
    NSString * const setterName = NSStringFromSelector(_setter);
    if ([setterName hasPrefix:@"set"]) {
        if (setterName.length >= 5) {
            descriptor->_isKeyValueCodable = [setterName substringWithRange:NSMakeRange(3, setterName.length - 4)];
        }
    } else if ([setterName hasPrefix:@"_set"]) {
        if (setterName.length >= 6) {
            descriptor->_isKeyValueCodable = [setterName substringWithRange:NSMakeRange(4, setterName.length - 5)];
        }
    }
    
    switch (_type) {
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
            descriptor->_isCodable = (descriptor->_structType != XZStdcStructTypeUnknown);
            break;
        case XZStdcTypeClass:
            descriptor->_isCodable = YES;
            break;
        case XZStdcTypeObject:
            descriptor->_isCodable = YES;
            break;
    }
    
    return descriptor;
}
@end
