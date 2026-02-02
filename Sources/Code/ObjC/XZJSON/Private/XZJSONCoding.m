//
//  XZJSONCoding.m
//  XZKit
//
//  Created by 徐臻 on 2026/2/3.
//

#import "XZJSONCoding.h"
#import "XZJSONClass.h"
#import "XZJSONProperty.h"
#import "XZJSONDefines.h"

static inline NSString *XZSecureCodingClassKey(NSString *key) {
    return [NSString stringWithFormat:@"XZJSON.CodingClass.%@", key];
}

/// 解档时不能使用某些子类型，比如 NSTaggedString 类型。
static inline NSString *XZSecureCodingClassName(id value) {
    Class aClass = object_getClass(value);
    if ([aClass isSubclassOfClass:NSString.class]) {
        return NSStringFromClass(NSString.class);
    }
    if ([aClass isSubclassOfClass:NSNumber.class]) {
        return NSStringFromClass(NSNumber.class);
    }
    if ([aClass isSubclassOfClass:NSValue.class]) {
        return NSStringFromClass(NSValue.class);
    }
    if ([aClass isSubclassOfClass:NSMutableArray.class]) {
        return NSStringFromClass(NSMutableArray.class);
    }
    if ([aClass isSubclassOfClass:NSArray.class]) {
        return NSStringFromClass(NSArray.class);
    }
    if ([aClass isSubclassOfClass:NSMutableDictionary.class]) {
        return NSStringFromClass(NSMutableDictionary.class);
    }
    if ([aClass isSubclassOfClass:NSDictionary.class]) {
        return NSStringFromClass(NSDictionary.class);
    }
    if ([aClass isSubclassOfClass:NSMutableSet.class]) {
        return NSStringFromClass(NSMutableSet.class);
    }
    if ([aClass isSubclassOfClass:NSSet.class]) {
        return NSStringFromClass(NSSet.class);
    }
    return NSStringFromClass(aClass);
}

static inline void NSEncodeJSONValueForKey(NSCoder *coder, id JSONValue, NSString *key) {
    // 如果是安全归档，则同时将类型名用 NSString 归档，以方便解档时，先取出类型。
    if (coder.requiresSecureCoding) {
        NSString *classKey = XZSecureCodingClassKey(key);
        [coder encodeObject:XZSecureCodingClassName(JSONValue) forKey:classKey];
    }
    [coder encodeObject:JSONValue forKey:key];
}

static inline id NSDecodeJSONValueForKey(NSCoder *coder, NSString *key) {
    if (coder.requiresSecureCoding) {
        NSString *classKey = XZSecureCodingClassKey(key);
        NSString *className = [coder decodeObjectOfClass:NSString.class forKey:classKey];
        if (className == nil) {
            return nil;
        }
        Class CodingClass = NSClassFromString(className);
        if (CodingClass == Nil) {
            return nil;
        }
        return [coder decodeObjectOfClass:CodingClass forKey:key];
    }
    return [coder decodeObjectForKey:key];
}

void XZJSONModelEncodeWithCoder(id model, NSCoder *coder) {
    XZJSONClass * const JSONClass = [XZJSONClass classForClass:object_getClass(model)];
    if (JSONClass == nil) {
        return;
    }
    
    switch (JSONClass->_cocoaClass) {
        case XZJSONCocoaClassUnknown: {
            [JSONClass->_namedProperties enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, XZJSONProperty *property, BOOL * _Nonnull stop) {
                switch (property->_type) {
                    case XZStdcTypeUnknown:
                        break;
                    case XZStdcTypeChar:
                    case XZStdcTypeUnsignedChar: {
                        char const value = ((char(*)(id,SEL))objc_msgSend)(model, property->_getter);
                        [coder encodeInt:value forKey:key];
                        break;
                    }
                    case XZStdcTypeInt:
                    case XZStdcTypeUnsignedInt: {
                        int const value = ((int(*)(id,SEL))objc_msgSend)(model, property->_getter);
                        [coder encodeInt:value forKey:key];
                        break;
                    }
                    case XZStdcTypeShort:
                    case XZStdcTypeUnsignedShort: {
                        short const value = ((short(*)(id,SEL))objc_msgSend)(model, property->_getter);
                        [coder encodeInt:value forKey:key];
                        break;
                    }
                    case XZStdcTypeLong:
                    case XZStdcTypeUnsignedLong: {
                        long const value = ((long(*)(id,SEL))objc_msgSend)(model, property->_getter);
                        [coder encodeInt64:value forKey:key];
                        break;
                    }
                    case XZStdcTypeInt128:
                    case XZStdcTypeUnsignedInt128: {
                        id value = nil;
                        if (JSONClass->_usesPropertyJSONEncodingMethod) {
                            value = [model JSONEncodeValueForKey:key];
                        }
                        NSEncodeJSONValueForKey(coder, value, key);
                        break;
                    }
                    case XZStdcTypeLongLong:
                    case XZStdcTypeUnsignedLongLong: {
                        long long const value = ((long long(*)(id,SEL))objc_msgSend)(model, property->_getter);
                        [coder encodeInt64:value forKey:key];
                        break;
                    }
                    case XZStdcTypeFloat: {
                        float const value = ((float(*)(id,SEL))objc_msgSend)(model, property->_getter);
                        [coder encodeFloat:value forKey:key];
                        break;
                    }
                    case XZStdcTypeDouble: {
                        double const value = ((double(*)(id,SEL))objc_msgSend)(model, property->_getter);
                        [coder encodeDouble:value forKey:key];
                        break;
                    }
                    case XZStdcTypeLongDouble: {
                        long double const value = ((long double(*)(id,SEL))objc_msgSend)(model, property->_getter);
                        [coder encodeDouble:value forKey:key];
                        break;
                    }
                    case XZStdcTypeBool: {
                        BOOL const value = ((BOOL(*)(id,SEL))objc_msgSend)(model, property->_getter);
                        [coder encodeBool:value forKey:key];
                        break;
                    }
                    case XZStdcTypeVoid:
                    case XZStdcTypeString:
                    case XZStdcTypeSelector:
                    case XZStdcTypePointer:
                    case XZStdcTypeVector:
                    case XZStdcTypeArray:
                    case XZStdcTypeBitField:
                    case XZStdcTypeUnion: {
                        id value = nil;
                        if (JSONClass->_usesPropertyJSONEncodingMethod) {
                            value = [model JSONEncodeValueForKey:key];
                        }
                        NSEncodeJSONValueForKey(coder, value, key);
                        break;
                    }
                    case XZStdcTypeStruct: {
                        id<NSCoding> value = nil;
                        if (JSONClass->_usesPropertyJSONEncodingMethod) {
                            value = [model JSONEncodeValueForKey:key];
                        }
                        if (value == nil) {
                            value = XZJSONEncodeStructProperty(model, property);
                        }
                        NSEncodeJSONValueForKey(coder, value, key);
                        break;
                    }
                    case XZStdcTypeClass: {
                        Class const value = ((Class(*)(id,SEL))objc_msgSend)(model, property->_getter);
                        if (value) {
                            [coder encodeObject:NSStringFromClass(value) forKey:key];
                        }
                        break;
                    }
                    case XZStdcTypeObject: {
                        id const value = ((id(*)(id,SEL))objc_msgSend)(model, property->_getter);
                        if (value && property->_conformsToNSCoding) {
                            [coder encodeObject:value forKey:key];
                        }
                        break;
                    }
                }
            }];
            break;
        }
        case XZJSONCocoaClassNSString:
        case XZJSONCocoaClassNSMutableString:
        case XZJSONCocoaClassNSValue:
        case XZJSONCocoaClassNSNumber:
        case XZJSONCocoaClassNSDecimalNumber:
        case XZJSONCocoaClassNSData:
        case XZJSONCocoaClassNSMutableData:
        case XZJSONCocoaClassNSDate:
        case XZJSONCocoaClassNSURL:
        case XZJSONCocoaClassNSArray:
        case XZJSONCocoaClassNSMutableArray:
        case XZJSONCocoaClassNSSet:
        case XZJSONCocoaClassNSMutableSet:
        case XZJSONCocoaClassNSCountedSet:
        case XZJSONCocoaClassNSOrderedSet:
        case XZJSONCocoaClassNSMutableOrderedSet:
        case XZJSONCocoaClassNSDictionary:
        case XZJSONCocoaClassNSMutableDictionary: {
            [(id<NSCoding>)model encodeWithCoder:coder];
            break;
        }
    }
}

void XZJSONModelDecodeWithCoder(id model, NSCoder *coder) {
    XZJSONClass * const JSONClass = [XZJSONClass classForClass:object_getClass(model)];
    if (JSONClass == nil) {
        return;
    }
    
    switch (JSONClass->_cocoaClass) {
        case XZJSONCocoaClassUnknown: {
            [JSONClass->_namedProperties enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, XZJSONProperty *property, BOOL * _Nonnull stop) {
                switch (property->_type) {
                    case XZStdcTypeUnknown:
                        break;
                    case XZStdcTypeChar:
                    case XZStdcTypeUnsignedChar: {
                        char const value = (char)[coder decodeIntForKey:key];
                        ((void(*)(id,SEL,char))objc_msgSend)(model, property->_setter, value);
                        break;
                    }
                    case XZStdcTypeInt:
                    case XZStdcTypeUnsignedInt: {
                        int const value = [coder decodeIntForKey:key];
                        ((void(*)(id,SEL,int))objc_msgSend)(model, property->_setter, value);
                        break;
                    }
                    case XZStdcTypeShort:
                    case XZStdcTypeUnsignedShort: {
                        short const value = (short)[coder decodeIntForKey:key];
                        ((void(*)(id,SEL,short))objc_msgSend)(model, property->_setter, value);
                        break;
                    }
                    case XZStdcTypeLong:
                    case XZStdcTypeUnsignedLong: {
                        long const value = (long)[coder decodeInt64ForKey:key];
                        ((void(*)(id,SEL,long))objc_msgSend)(model, property->_setter, value);
                        break;
                    }
                    case XZStdcTypeInt128:
                    case XZStdcTypeUnsignedInt128: {
                        if (!JSONClass->_usesPropertyJSONDecodingMethod) {
                            break;
                        }
                        id value = NSDecodeJSONValueForKey(coder, key);
                        if (value) {
                            [model JSONDecodeValue:value forKey:key];
                        }
                        break;
                    }
                    case XZStdcTypeLongLong:
                    case XZStdcTypeUnsignedLongLong: {
                        long long const value = (long long)[coder decodeInt64ForKey:key];
                        ((void(*)(id,SEL,long long))objc_msgSend)(model, property->_setter, value);
                        break;
                    }
                    case XZStdcTypeFloat: {
                        float const value = [coder decodeFloatForKey:key];
                        ((void(*)(id,SEL,float))objc_msgSend)(model, property->_setter, value);
                        break;
                    }
                    case XZStdcTypeDouble: {
                        double const value = [coder decodeDoubleForKey:key];
                        ((void(*)(id,SEL,double))objc_msgSend)(model, property->_setter, value);
                        break;
                    }
                    case XZStdcTypeLongDouble: {
                        long double const value = (long double)[coder decodeDoubleForKey:key];
                        ((void(*)(id,SEL,long double))objc_msgSend)(model, property->_setter, value);
                        break;
                    }
                    case XZStdcTypeBool: {
                        BOOL const value = [coder decodeBoolForKey:key];
                        ((void(*)(id,SEL,BOOL))objc_msgSend)(model, property->_setter, value);
                        break;
                    }
                    case XZStdcTypeVoid:
                    case XZStdcTypeString:
                    case XZStdcTypeSelector:
                    case XZStdcTypePointer:
                    case XZStdcTypeVector:
                    case XZStdcTypeArray:
                    case XZStdcTypeBitField:
                    case XZStdcTypeUnion: {
                        if (!JSONClass->_usesPropertyJSONDecodingMethod) {
                            break;
                        }
                        id value = NSDecodeJSONValueForKey(coder, key);
                        if (value) {
                            [model JSONDecodeValue:value forKey:key];
                        }
                        break;
                    }
                    case XZStdcTypeStruct: {
                        id value = NSDecodeJSONValueForKey(coder, key);
                        
                        if (value) {
                            if (JSONClass->_usesPropertyJSONDecodingMethod) {
                                if ([model JSONDecodeValue:value forKey:key]) {
                                    break;
                                }
                            }
                            XZJSONModelDecodeStructProperty(model, property, value);
                        }
                        break;
                    }
                    case XZStdcTypeClass: {
                        NSString *const value = [coder decodeObjectForKey:key];
                        if ([value isKindOfClass:NSString.class]) {
                            Class aClass = NSClassFromString(value);
                            if (aClass) {
                                ((void(*)(id,SEL,Class))objc_msgSend)(model, property->_setter, aClass);
                            }
                        }
                        break;
                    }
                    case XZStdcTypeObject: {
                        id value = nil;
                        if (property->_supportsSecureCoding) {
                            if (property->_elementClassType) {
                                NSSet *classes = [NSSet setWithObjects:property->_classType, property->_elementClassType, nil];
                                value = [coder decodeObjectOfClasses:classes forKey:key];
                            } else {
                                value = [coder decodeObjectOfClass:property->_classType forKey:key];
                            }
                        } else {
                            value = [coder decodeObjectForKey:key];
                        }
                        if (value) {
                            ((void(*)(id,SEL, id))objc_msgSend)(model, property->_setter, value);
                        }
                        break;
                    }
                }
            }];
            break;
        }
        case XZJSONCocoaClassNSString:
        case XZJSONCocoaClassNSMutableString:
        case XZJSONCocoaClassNSValue:
        case XZJSONCocoaClassNSNumber:
        case XZJSONCocoaClassNSDecimalNumber:
        case XZJSONCocoaClassNSData:
        case XZJSONCocoaClassNSMutableData:
        case XZJSONCocoaClassNSDate:
        case XZJSONCocoaClassNSURL:
        case XZJSONCocoaClassNSArray:
        case XZJSONCocoaClassNSMutableArray:
        case XZJSONCocoaClassNSSet:
        case XZJSONCocoaClassNSMutableSet:
        case XZJSONCocoaClassNSCountedSet:
        case XZJSONCocoaClassNSOrderedSet:
        case XZJSONCocoaClassNSMutableOrderedSet:
        case XZJSONCocoaClassNSDictionary:
        case XZJSONCocoaClassNSMutableDictionary: {
            break;
        }
    }
}
