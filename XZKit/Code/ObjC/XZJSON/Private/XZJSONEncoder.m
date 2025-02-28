//
//  XZJSONEncoder.m
//  XZJSON
//
//  Created by 徐臻 on 2025/2/28.
//

#import "XZJSONEncoder.h"
#import "XZJSONClassDescriptor.h"
#import "XZJSONPropertyDescriptor.h"
#import "XZJSONDefines.h"
#import "XZMacro.h"

typedef id _Nullable (*XZJSONGetter)(id _Nonnull, SEL _Nonnull);
static void XZJSONModelEncodeProperty(id model, XZJSONPropertyDescriptor *property, NSMutableDictionary *modelDictionary);

FOUNDATION_STATIC_INLINE id XZJSONEncodeCollection(id<NSFastEnumeration> collection, NSUInteger count) {
    if ([NSJSONSerialization isValidJSONObject:collection]) {
        return collection;
    }
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:count];
    for (id item in collection) {
        XZJSONClassDescriptor *itemClass = [XZJSONClassDescriptor descriptorForClass:object_getClass(item)];
        if (itemClass == nil) {
            continue;
        }
        id const JSONObject = XZJSONEncodeObjectIntoDictionary(item, itemClass, nil);
        if (JSONObject != nil) {
            [newArray addObject:JSONObject];
        }
    }
    return newArray;
}

id XZJSONEncodeObjectIntoDictionary(id const object, XZJSONClassDescriptor * const objectClass, NSMutableDictionary * _Nullable dictionary) {
    switch (objectClass->_classType) {
        case XZJSONClassTypeNSString:
        case XZJSONClassTypeNSMutableString: {
            return object;
        }
        case XZJSONClassTypeNSValue: {
            if ([object isKindOfClass:NSNumber.class]) {
                return object;
            }
            
            NSValue    * const nsValue  = object;
            const char * const encoding = nsValue.objCType;
            
            XZObjcTypeDescriptor *type = [XZObjcTypeDescriptor descriptorForTypeEncoding:encoding];
            if (type == nil) {
                return nil;
            }
            
            NSString *value = nil;
            
            switch (XZJSONStructTypeFromType(type)) {
                case XZJSONStructTypeUnknown:
                    return nil;
                case XZJSONStructTypeCGRect:
                    value = NSStringFromCGRect(nsValue.CGRectValue);
                    break;
                case XZJSONStructTypeCGSize:
                    value = NSStringFromCGSize(nsValue.CGSizeValue);
                    break;
                case XZJSONStructTypeCGPoint:
                    value = NSStringFromCGPoint(nsValue.CGPointValue);
                    break;
                case XZJSONStructTypeUIEdgeInsets:
                    value = NSStringFromUIEdgeInsets(nsValue.UIEdgeInsetsValue);
                    break;
                case XZJSONStructTypeCGVector:
                    value = NSStringFromCGVector(nsValue.CGVectorValue);
                    break;
                case XZJSONStructTypeCGAffineTransform:
                    value = NSStringFromCGAffineTransform(nsValue.CGAffineTransformValue);
                    break;
                case XZJSONStructTypeNSDirectionalEdgeInsets:
                    value = NSStringFromDirectionalEdgeInsets(nsValue.directionalEdgeInsetsValue);
                    break;
                case XZJSONStructTypeUIOffset:
                    value = NSStringFromUIOffset(nsValue.UIOffsetValue);
                    break;
            }
            
            return @{ @"type": type.name, @"value": value };
        }
        case XZJSONClassTypeNSNumber: {
            return object;
        }
        case XZJSONClassTypeNSDecimalNumber: {
            return [(NSDecimalNumber *)object stringValue];
        }
        case XZJSONClassTypeNSData:
        case XZJSONClassTypeNSMutableData: {
            return [(NSData *)object base64EncodedStringWithOptions:kNilOptions];
        }
        case XZJSONClassTypeNSDate: {
            return @([(NSDate *)object timeIntervalSince1970]);
        }
        case XZJSONClassTypeNSURL: {
            return [(NSURL *)object absoluteString];
        }
        case XZJSONClassTypeNSArray:
        case XZJSONClassTypeNSMutableArray: {
            return XZJSONEncodeCollection(object, [(NSArray *)object count]);
        }
        case XZJSONClassTypeNSDictionary:
        case XZJSONClassTypeNSMutableDictionary: {
            if ([NSJSONSerialization isValidJSONObject:object]) {
                return object;
            }
            NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
            [(NSDictionary *)object enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
                NSString * const JSONKey = [key description];
                if (!JSONKey) return;
                XZJSONClassDescriptor *objClass = [XZJSONClassDescriptor descriptorForClass:object_getClass(obj)];
                if (objClass == nil) {
                    return;
                }
                id const JSONValue = XZJSONEncodeObjectIntoDictionary(obj, objClass, nil);
                if (JSONValue != nil) {
                    dictM[JSONKey] = JSONValue;
                }
            }];
            return dictM;
        }
        case XZJSONClassTypeNSSet:
        case XZJSONClassTypeNSMutableSet:
        case XZJSONClassTypeNSCountedSet: {
            NSSet * const set = object;
            return XZJSONEncodeCollection(set.allObjects, set.count);
        }
        case XZJSONClassTypeNSOrderedSet:
        case XZJSONClassTypeNSMutableOrderedSet: {
            NSOrderedSet * const orderedSet = object;
            return XZJSONEncodeCollection(orderedSet.array.copy, orderedSet.count);
        }
        case XZJSONClassTypeUnknown: {
            if (object == (id)kCFNull) {
                return object;
            }
            
            if (dictionary == nil) {
                dictionary = [NSMutableDictionary dictionaryWithCapacity:objectClass->_numberOfProperties];
            }
            
            // 自定义序列化
            if (objectClass->_usesJSONEncodingInitializer) {
                return [(id<XZJSONCoding>)object encodeIntoJSONDictionary:dictionary];
            }
            
            // 其它对象，视为模型。
            XZJSONModelEncodeIntoDictionary(object, objectClass, dictionary);
            
            return dictionary;
        }
    }
}

void XZJSONModelEncodeIntoDictionary(id const model, XZJSONClassDescriptor * const modelClass, NSMutableDictionary * const dictionary) {
    [modelClass->_properties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor * _Nonnull property, NSUInteger idx, BOOL * _Nonnull stop) {
        XZJSONModelEncodeProperty(model, property, dictionary);
    }];
}

/// 读取 JSON 字典中 keyPath 中最后一个 key 所在的字典，如果中间值不存在，则创建。
/// - Parameters:
///   - dictionary: JSON 字典
///   - keyPath: 键路径
FOUNDATION_STATIC_INLINE NSMutableDictionary *NSDictionaryForLastKeyInKeyPath(NSMutableDictionary *dictionary, NSArray<NSString *> *keyPath) {
    for (NSUInteger i = 0, max = keyPath.count - 1; i < max; i++) {
        NSString * const subKey = keyPath[i];
        NSMutableDictionary *subDict = [dictionary valueForKey:subKey];
        if (subDict == nil) {
            subDict = [NSMutableDictionary dictionary];
            dictionary[subKey] = subDict;
            continue;
        }
        if ([subDict isKindOfClass:NSMutableDictionary.class]) {
            dictionary = subDict;
            continue;
        }
        // 对应的 key 已经有其它值，不支持设置 keyPath
        return nil;
    }
    return dictionary;
}

FOUNDATION_STATIC_INLINE id _Nullable XZJSONModelEncodePropertyFallback(id model, XZJSONPropertyDescriptor *property) {
    switch (property->_classType) {
        case XZJSONClassTypeNSDate:
        case XZJSONClassTypeNSData:
        case XZJSONClassTypeNSMutableData:
        case XZJSONClassTypeNSValue: {
            id const value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
            XZJSONClassDescriptor *valueClass = [XZJSONClassDescriptor descriptorForClass:object_getClass(value)];
            return XZJSONEncodeObjectIntoDictionary(value, valueClass, nil);
        }
        default: {
            return nil;
        }
    }
}

void XZJSONModelEncodeProperty(id model, XZJSONPropertyDescriptor *property, NSMutableDictionary *modelDictionary) {
    NSString            *key  = nil;
    NSMutableDictionary *keyInDictionary = nil;
    
    // 先判断是否映射到 keyPath 或 keyArray
    if (property->_JSONKeyPath) {
        keyInDictionary = NSDictionaryForLastKeyInKeyPath(modelDictionary, property->_JSONKeyPath);
        if (keyInDictionary == nil) {
            return;
        }
        key = property->_JSONKeyPath.lastObject;
    } else if (property->_JSONKeyArray) {
        for (NSUInteger i = 0, count = property->_JSONKeyArray.count; i < count; i++) {
            id const someKey = property->_JSONKeyArray[i];
            
            if ([someKey isKindOfClass:NSString.class]) {
                if (modelDictionary[(NSString *)someKey]) {
                    continue; // 对应的 key 已经有值，继续遍历，尝试其它 key
                }
                key = someKey;
                keyInDictionary = modelDictionary;
                break;
            }
            
            keyInDictionary = NSDictionaryForLastKeyInKeyPath(modelDictionary, someKey);
            if (keyInDictionary) {
                key = ((NSArray *)someKey).lastObject;
                break;
            }
        }
        if (key == nil) {
            return;
        }
    } else {
        if (modelDictionary[property->_JSONKey]) {
            return; // 值已存在，不覆盖。
        }
        key = property->_JSONKey;
        keyInDictionary = modelDictionary;
    }
    
    id JSONValue = nil;
    
    switch (property->_type) {
        case XZObjcTypeUnknown:
            break;
        case XZObjcTypeChar:
            JSONValue = @(((char (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcTypeUnsignedChar:
            JSONValue = @(((unsigned char (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcTypeInt:
            JSONValue = @(((int (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcTypeUnsignedInt:
            JSONValue = @(((unsigned int (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcTypeShort:
            JSONValue = @(((short (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcTypeUnsignedShort:
            JSONValue = @(((unsigned short (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcTypeLong:
            JSONValue = @(((long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcTypeUnsignedLong:
            JSONValue = @(((unsigned long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcTypeLongLong:
            JSONValue = @(((long long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcTypeUnsignedLongLong:
            JSONValue = @(((unsigned long long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcTypeFloat:
            JSONValue = @(((float (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcTypeDouble:
            JSONValue = @(((double (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcTypeLongDouble: {
            // 目前 long double 只能用字符串承接 宏 TYPE_LONGDOUBLE_IS_DOUBLE 没用
            long double const aValue = ((long double (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
            JSONValue = [NSString stringWithFormat:@"%Lf", aValue];
            break;
        }
        case XZObjcTypeBool:
            JSONValue = @(((BOOL (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcTypeVoid:
        case XZObjcTypeString:
        case XZObjcTypeArray:
        case XZObjcTypeBitField:
        case XZObjcTypePointer:
        case XZObjcTypeUnion:
            break;
        case XZObjcTypeStruct:
            JSONValue = NSStringFromStructProperty(model, property);
            break;
        case XZObjcTypeClass: {
            Class const aClass = ((Class (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
            JSONValue = aClass ? NSStringFromClass(aClass) : (id)kCFNull;
            break;
        }
        case XZObjcTypeSEL: {
            SEL const aSelector = ((SEL (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
            JSONValue = aSelector ? NSStringFromSelector(aSelector) : (id)kCFNull;
            break;
        }
        case XZObjcTypeObject: {
            if (property->_isUnownedReferenceProperty) {
                break;
            }
            
            id const value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
            
            // 所有参与转换的属性，都将输出到 JSON 中
            if (value == nil) {
                JSONValue = (id)kCFNull;
                break;
            }
            
            // 属性 实际值与声明值 不一致
            if (property->_subtype && ![value isKindOfClass:property->_subtype]) {
                JSONValue = (id)kCFNull;
                break;
            }
            
            switch (property->_classType) {
                case XZJSONClassTypeNSDate:
                case XZJSONClassTypeNSData:
                case XZJSONClassTypeNSMutableData: {
                    // 发送模型处理，然后再在 fallback 中处理
                    break;
                }
                case XZJSONClassTypeNSValue: {
                    if ([value isKindOfClass:NSNumber.class]) {
                        JSONValue = value;
                    }
                    // 发送模型处理，然后再在 fallback 中处理
                    break;
                }
                case XZJSONClassTypeNSString:
                case XZJSONClassTypeNSMutableString:
                case XZJSONClassTypeNSNumber:
                case XZJSONClassTypeNSDecimalNumber:
                case XZJSONClassTypeNSURL:
                case XZJSONClassTypeNSArray:
                case XZJSONClassTypeNSMutableArray:
                case XZJSONClassTypeNSSet:
                case XZJSONClassTypeNSMutableSet:
                case XZJSONClassTypeNSCountedSet:
                case XZJSONClassTypeNSOrderedSet:
                case XZJSONClassTypeNSMutableOrderedSet:
                case XZJSONClassTypeNSDictionary:
                case XZJSONClassTypeNSMutableDictionary:
                case XZJSONClassTypeUnknown: {
                    XZJSONClassDescriptor *valueClass = [XZJSONClassDescriptor descriptorForClass:object_getClass(value)];
                    id dict = keyInDictionary[key];
                    // 如果 key 已经有值，则可能合并，不能合并则覆盖
                    if ([dict isKindOfClass:NSMutableDictionary.class]) {
                        JSONValue = XZJSONEncodeObjectIntoDictionary(value, valueClass, dict);
                    } else {
                        JSONValue = XZJSONEncodeObjectIntoDictionary(value, valueClass, nil);
                    }
                    break;
                }
            }
            break;
        }
    }
    
    if (JSONValue == nil && property->_class->_usesPropertyJSONEncodingMethod) {
        JSONValue = [model JSONEncodeValueForKey:property->_name];
    }
    
    if (JSONValue == nil) {
        JSONValue = XZJSONModelEncodePropertyFallback(model, property);
    }
    
    if (JSONValue) {
        keyInDictionary[key] = JSONValue;
        return;
    }
    
    XZLog(@"[XZJSON] Can not encode property `%@` of `%@`", property->_name, property->_class->_class.name);
}
