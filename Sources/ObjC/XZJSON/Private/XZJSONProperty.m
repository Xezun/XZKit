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

+ (XZJSONProperty *)descriptorWithProperty:(XZObjcProperty *)property class:(XZJSONClass *)class mappingClass:(nullable Class)mappingClass {
    XZStdcModifiers const modifiers = property.modifiers;
    
    // 必须是读写属性才参与 JSON 处理
    if (modifiers & XZStdcModifierReadonly) {
        return nil;
    }
    
    Class classType    = Nil;
    Class elementType = mappingClass;
    
    if (property.type.type == XZStdcTypeObject) {
        // 不处理是无主引用或弱引用的属性。
        if ( (modifiers & XZStdcModifierWeak) || !(modifiers & (XZStdcModifierCopy | XZStdcModifierRetain)) ) {
            return nil;
        }
        classType = property.type.classType;
        // 未知类型，使用映射值
        if (classType == Nil) {
            classType = mappingClass;
            elementType = Nil;
        }
    } else {
        elementType = Nil;
    }
    
    return [[self alloc] initWithProperty:property class:class classType:classType elementType:elementType];
}

- (instancetype)initWithProperty:(XZObjcProperty *)property class:(XZJSONClass *)class classType:(Class)classType elementType:(Class)elementType {
    self = [super init];
    if (self) {
        _owner       = class;
        _raw         = property;
        _name        = property.name;
        _type        = property.type.type;
        _getter      = property.getter;
        _setter      = property.setter;
        _classType   = classType;
        _elementClassType = elementType;
        _structType  = property.type.structType;
        _cocoaClass  = XZJSONCocoaClassFromClass(_classType);
        
        // 不是以 set 开头的 setter 无法被 KVC 找到，不能使用 KVC 赋值。
        _isKeyValueCodable = nil;
        NSString * const setterName = NSStringFromSelector(_setter);
        if ([setterName hasPrefix:@"set"]) {
            if (setterName.length >= 5) {
                _isKeyValueCodable = [setterName substringWithRange:NSMakeRange(3, setterName.length - 4)];
            }
        } else if ([setterName hasPrefix:@"_set"]) {
            if (setterName.length >= 6) {
                _isKeyValueCodable = [setterName substringWithRange:NSMakeRange(4, setterName.length - 5)];
            }
        }
        
        switch (_type) {
            case XZStdcTypeUnknown:
                _isCodable = NO;
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
                _isCodable = YES;
                break;
            case XZStdcTypeVoid:
                _isCodable = NO;
                break;
            case XZStdcTypeString:
                _isCodable = NO;
                break;
            case XZStdcTypeSelector:
                _isCodable = YES;
                break;
            case XZStdcTypePointer:
                _isCodable = NO;
                break;
            case XZStdcTypeArray:
                _isCodable = NO;
                break;
            case XZStdcTypeVector:
                _isCodable = NO;
                break;
            case XZStdcTypeBitField:
                _isCodable = NO;
                break;
            case XZStdcTypeUnion:
                _isCodable = NO;
                break;
            case XZStdcTypeStruct:
                _isCodable = (_structType != XZStdcStructTypeUnknown);
                break;
            case XZStdcTypeClass:
                _isCodable = YES;
                break;
            case XZStdcTypeObject:
                _isCodable = YES;
                if (_elementClassType) {
                    _conformsToNSCoding = [_elementClassType conformsToProtocol:@protocol(NSCoding)];
                    _supportsSecureCoding = [_elementClassType conformsToProtocol:@protocol(NSSecureCoding)] && [_classType supportsSecureCoding];
                } else {
                    _conformsToNSCoding = [_classType conformsToProtocol:@protocol(NSCoding)];
                    _supportsSecureCoding = [_classType conformsToProtocol:@protocol(NSSecureCoding)] && [_classType supportsSecureCoding];
                }
                break;
        }
    }
    return self;
}

@end
