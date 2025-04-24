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

FOUNDATION_STATIC_INLINE id XZJSONEncodeCollection(id<NSFastEnumeration> const __unsafe_unretained collection, NSUInteger count) {
    if ([NSJSONSerialization isValidJSONObject:collection]) {
        return collection;
    }
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:count];
    for (id item in collection) {
        XZJSONClassDescriptor *itemClass = [XZJSONClassDescriptor descriptorWithClass:object_getClass(item)];
        if (itemClass == nil) {
            continue;
        }
        id const JSONObject = XZJSONEncodeObjectIntoDictionary(item, itemClass, itemClass->_foundationClassType, nil);
        if (JSONObject != nil) {
            [newArray addObject:JSONObject];
        }
    }
    return newArray;
}

id XZJSONEncodeObjectIntoDictionary(id const __unsafe_unretained object, XZJSONClassDescriptor * _Nullable __unsafe_unretained objectClass, XZJSONFoundationClassType const classType, NSMutableDictionary * _Nullable dictionary) {
    switch (classType) {
        case XZJSONFoundationClassTypeNSString:
        case XZJSONFoundationClassTypeNSMutableString: {
            return object;
        }
        case XZJSONFoundationClassTypeNSValue: {
            if ([object isKindOfClass:NSNumber.class]) {
                return object;
            }
            
            NSValue    * const nsValue  = object;
            const char * const encoding = nsValue.objCType;
            
            XZObjcTypeDescriptor *type = [XZObjcTypeDescriptor descriptorForObjcType:encoding];
            if (type == nil) {
                return nil;
            }
            
            NSString *value = nil;
            
            switch (XZJSONFoundationStructTypeFromType(type)) {
                case XZJSONFoundationStructTypeUnknown:
                    return nil;
                case XZJSONFoundationStructTypeCGRect:
                    value = NSStringFromCGRect(nsValue.CGRectValue);
                    break;
                case XZJSONFoundationStructTypeCGSize:
                    value = NSStringFromCGSize(nsValue.CGSizeValue);
                    break;
                case XZJSONFoundationStructTypeCGPoint:
                    value = NSStringFromCGPoint(nsValue.CGPointValue);
                    break;
                case XZJSONFoundationStructTypeUIEdgeInsets:
                    value = NSStringFromUIEdgeInsets(nsValue.UIEdgeInsetsValue);
                    break;
                case XZJSONFoundationStructTypeCGVector:
                    value = NSStringFromCGVector(nsValue.CGVectorValue);
                    break;
                case XZJSONFoundationStructTypeCGAffineTransform:
                    value = NSStringFromCGAffineTransform(nsValue.CGAffineTransformValue);
                    break;
                case XZJSONFoundationStructTypeNSDirectionalEdgeInsets:
                    value = NSStringFromDirectionalEdgeInsets(nsValue.directionalEdgeInsetsValue);
                    break;
                case XZJSONFoundationStructTypeUIOffset:
                    value = NSStringFromUIOffset(nsValue.UIOffsetValue);
                    break;
            }
            
            return @{ @"type": type.name, @"value": value };
        }
        case XZJSONFoundationClassTypeNSNumber: {
            return object;
        }
        case XZJSONFoundationClassTypeNSDecimalNumber: {
            return [(NSDecimalNumber *)object stringValue];
        }
        case XZJSONFoundationClassTypeNSData:
        case XZJSONFoundationClassTypeNSMutableData: {
            NSString *base64 = [(NSData *)object base64EncodedStringWithOptions:kNilOptions];
            return [NSString stringWithFormat:@"data:base64,%@", base64];
        }
        case XZJSONFoundationClassTypeNSDate: {
            return @([(NSDate *)object timeIntervalSince1970]);
        }
        case XZJSONFoundationClassTypeNSURL: {
            return [(NSURL *)object absoluteString];
        }
        case XZJSONFoundationClassTypeNSArray:
        case XZJSONFoundationClassTypeNSMutableArray: {
            return XZJSONEncodeCollection(object, [(NSArray *)object count]);
        }
        case XZJSONFoundationClassTypeNSDictionary:
        case XZJSONFoundationClassTypeNSMutableDictionary: {
            if ([NSJSONSerialization isValidJSONObject:object]) {
                return object;
            }
            NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
            [(NSDictionary *)object enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
                NSString * const JSONKey = [key description];
                if (!JSONKey) return;
                XZJSONClassDescriptor *objClass = [XZJSONClassDescriptor descriptorWithClass:object_getClass(obj)];
                if (objClass == nil) {
                    return;
                }
                id const JSONValue = XZJSONEncodeObjectIntoDictionary(obj, objClass, objClass->_foundationClassType, nil);
                if (JSONValue != nil) {
                    dictM[JSONKey] = JSONValue;
                }
            }];
            return dictM;
        }
        case XZJSONFoundationClassTypeNSSet:
        case XZJSONFoundationClassTypeNSMutableSet:
        case XZJSONFoundationClassTypeNSCountedSet: {
            NSSet * const set = object;
            return XZJSONEncodeCollection(set.allObjects, set.count);
        }
        case XZJSONFoundationClassTypeNSOrderedSet:
        case XZJSONFoundationClassTypeNSMutableOrderedSet: {
            NSOrderedSet * const orderedSet = object;
            return XZJSONEncodeCollection(orderedSet.array.copy, orderedSet.count);
        }
        case XZJSONFoundationClassTypeUnknown: {
            if (object == (id)kCFNull) {
                return object;
            }
            
            if (!objectClass) {
                objectClass = [XZJSONClassDescriptor descriptorWithClass:object_getClass(object)];
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

typedef struct XZJSONEncodeEnumeratorContext {
    void *modelClass;
    void *model;
    void *dictionary;
} XZJSONEncodeEnumeratorContext;

/// 用于遍历模型属性数组的函数。
static void XZJSONEncodePropertyArrayEnumerator(const void * const propertyRef, void * const contextRef) {
    XZJSONEncodeEnumeratorContext * const                     context    = contextRef;
    NSMutableDictionary           * const __unsafe_unretained dictionary = (__bridge NSMutableDictionary *)(context->dictionary);
    XZJSONPropertyDescriptor      * const __unsafe_unretained property   = (__bridge XZJSONPropertyDescriptor *)(propertyRef);
    id                              const __unsafe_unretained model      = (__bridge id)(context->model);
    XZJSONModelEncodeProperty(model, property, dictionary);
}

void XZJSONModelEncodeIntoDictionary(id const __unsafe_unretained model, XZJSONClassDescriptor * const __unsafe_unretained modelClass, NSMutableDictionary * const __unsafe_unretained dictionary) {
    XZJSONEncodeEnumeratorContext context = (XZJSONEncodeEnumeratorContext){
        (__bridge void *)modelClass,
        (__bridge void *)model,
        (__bridge void *)dictionary
    };
    CFRange const range = CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelClass->_sortedProperties));
    CFArrayApplyFunction((CFArrayRef)modelClass->_sortedProperties, range, XZJSONEncodePropertyArrayEnumerator, &context);
}

/// 读取 JSON 字典中 keyPath 中最后一个 key 所在的字典，如果中间值不存在，则创建。
/// - Parameters:
///   - dictionary: JSON 字典
///   - keyPath: 键路径
FOUNDATION_STATIC_INLINE NSMutableDictionary *NSDictionaryForLastKeyInKeyPath(NSMutableDictionary * _Nonnull __unsafe_unretained dictionary, NSArray<NSString *> * const __unsafe_unretained keyPath) {
    for (NSUInteger i = 0, max = keyPath.count - 1; i < max; i++) {
        NSString * const subKey = keyPath[i];
        NSMutableDictionary *subDict = [dictionary valueForKey:subKey];
        if (subDict == nil) {
            subDict = [NSMutableDictionary dictionary];
            dictionary[subKey] = subDict;
            dictionary = subDict;
            continue;
        }
        if ([subDict isKindOfClass:NSMutableDictionary.class]) {
            dictionary = subDict;
            continue;
        }
        // 中间 key 非字典值，不支持设置 keyPath
        return nil;
    }
    return dictionary;
}

FOUNDATION_STATIC_INLINE id _Nullable XZJSONModelEncodePropertyFallback(id const __unsafe_unretained model, XZJSONPropertyDescriptor * const __unsafe_unretained property) {
    switch (property->_foundationClassType) {
        case XZJSONFoundationClassTypeNSDate:
        case XZJSONFoundationClassTypeNSData:
        case XZJSONFoundationClassTypeNSMutableData:
        case XZJSONFoundationClassTypeNSValue: {
            id const value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
            // value 类型已验证，不一致的情况已提前转换为 kCFNull 不会进入此方法
            return XZJSONEncodeObjectIntoDictionary(value, nil, property->_foundationClassType, nil);
        }
        default: {
            return nil;
        }
    }
}

/// 根据映射找到 JSONKey 以及 JSONKey 所在的字典。
FOUNDATION_STATIC_INLINE BOOL XZJSONModelEncodePropertyPrepare(XZJSONPropertyDescriptor * const __unsafe_unretained property, NSString **key, NSMutableDictionary **keyInDictionary, BOOL merges) {
    // 映射 key
    if (property->_JSONKey) {
        id const value = (*keyInDictionary)[property->_JSONKey];
        
        if (value == nil || (merges && [value isKindOfClass:NSMutableDictionary.class])) {
            *key = property->_JSONKey;
            return YES;
        }
        
        return NO;
    }
    
    // 映射 keyPath
    if (property->_JSONKeyPath) {
        // 映射 keyPath
        NSMutableDictionary *dict = NSDictionaryForLastKeyInKeyPath(*keyInDictionary, property->_JSONKeyPath);
        if (*keyInDictionary == nil) {
            return NO;
        }
        NSString * const lastKey = property->_JSONKeyPath.lastObject;
        id         const value = dict[lastKey];
        if (value == nil || (merges && [value isKindOfClass:NSMutableDictionary.class])) {
            *key = lastKey;
            *keyInDictionary = dict;
            return YES;
        }
        return NO;
    }
    
    // 映射 keyArray
    for (NSUInteger i = 0, count = property->_JSONKeyArray.count; i < count; i++) {
        id const someKey = property->_JSONKeyArray[i];
        
        // key 映射
        if ([someKey isKindOfClass:NSString.class]) {
            id const value = (*keyInDictionary)[(NSString *)someKey];
            
            // 无值，可直接使用；有值，融合模式，仅字典可融合
            if (value == nil || (merges && [value isKindOfClass:NSMutableDictionary.class])) {
                *key = (NSString *)someKey;
                return YES;
            }
            continue;
        }
        
        // keyPath 映射
        NSMutableDictionary *dict = NSDictionaryForLastKeyInKeyPath(*keyInDictionary, someKey);
        if (dict) {
            NSString * const lastKey = ((NSArray *)someKey).lastObject;
            id         const value   = dict[lastKey];
            // 无值，可直接使用；有值，融合模式，仅字典可融合
            if (value == nil || (merges && [value isKindOfClass:NSMutableDictionary.class])) {
                *key = lastKey;
                *keyInDictionary = dict;
                return YES;
            }
            continue;
        }
    }
    
    return NO;
}

void XZJSONModelEncodeProperty(id const __unsafe_unretained model, XZJSONPropertyDescriptor * const __unsafe_unretained property, NSMutableDictionary * const __unsafe_unretained modelDictionary) {
    NSString            *key = nil;
    NSMutableDictionary *keyInDictionary = modelDictionary;
    id JSONValue = nil;
    
    switch (property->_type) {
        case XZObjcTypeUnknown:
            break;
        case XZObjcTypeChar:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                JSONValue = @(((char (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            }
            break;
        case XZObjcTypeUnsignedChar:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                JSONValue = @(((unsigned char (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            }
            break;
        case XZObjcTypeInt:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                JSONValue = @(((int (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            }
            break;
        case XZObjcTypeUnsignedInt:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                JSONValue = @(((unsigned int (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            }
            break;
        case XZObjcTypeShort:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                JSONValue = @(((short (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            }
            break;
        case XZObjcTypeUnsignedShort:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                JSONValue = @(((unsigned short (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            }
            break;
        case XZObjcTypeLong:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                JSONValue = @(((long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            }
            break;
        case XZObjcTypeUnsignedLong:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                JSONValue = @(((unsigned long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            }
            break;
        case XZObjcTypeLongLong:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                JSONValue = @(((long long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            }
            break;
        case XZObjcTypeUnsignedLongLong:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                JSONValue = @(((unsigned long long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            }
            break;
        case XZObjcTypeFloat:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                JSONValue = @(((float (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            }
            break;
        case XZObjcTypeDouble:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                JSONValue = @(((double (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            }
            break;
        case XZObjcTypeLongDouble: {
            // 目前 long double 只能用字符串承接 宏 TYPE_LONGDOUBLE_IS_DOUBLE 没用
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                long double const aValue = ((long double (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                JSONValue = [NSString stringWithFormat:@"%Lf", aValue];
            }
            break;
        }
        case XZObjcTypeBool:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                JSONValue = @(((BOOL (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            }
            break;
        case XZObjcTypeVoid:
        case XZObjcTypeString:
        case XZObjcTypeArray:
        case XZObjcTypeBitField:
        case XZObjcTypePointer:
        case XZObjcTypeUnion:
            break;
        case XZObjcTypeStruct:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                JSONValue = XZJSONEncodeStructProperty(model, property);
            }
            break;
        case XZObjcTypeClass: {
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                Class const aClass = ((Class (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                JSONValue = aClass ? NSStringFromClass(aClass) : (id)kCFNull;
            }
            break;
        }
        case XZObjcTypeSEL: {
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                SEL const aSelector = ((SEL (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                JSONValue = aSelector ? NSStringFromSelector(aSelector) : (id)kCFNull;
            }
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
            
            switch (property->_foundationClassType) {
                case XZJSONFoundationClassTypeNSDate:
                case XZJSONFoundationClassTypeNSData:
                case XZJSONFoundationClassTypeNSMutableData: {
                    // 发送模型处理，然后再在 fallback 中处理
                    break;
                }
                case XZJSONFoundationClassTypeNSValue: {
                    if ([value isKindOfClass:NSNumber.class]) {
                        JSONValue = value;
                    }
                    // 发送模型处理，然后再在 fallback 中处理
                    break;
                }
                case XZJSONFoundationClassTypeNSString:
                case XZJSONFoundationClassTypeNSMutableString:
                case XZJSONFoundationClassTypeNSNumber:
                case XZJSONFoundationClassTypeNSDecimalNumber:
                case XZJSONFoundationClassTypeNSURL:
                case XZJSONFoundationClassTypeNSArray:
                case XZJSONFoundationClassTypeNSMutableArray:
                case XZJSONFoundationClassTypeNSSet:
                case XZJSONFoundationClassTypeNSMutableSet:
                case XZJSONFoundationClassTypeNSCountedSet:
                case XZJSONFoundationClassTypeNSOrderedSet:
                case XZJSONFoundationClassTypeNSMutableOrderedSet:
                case XZJSONFoundationClassTypeNSDictionary:
                case XZJSONFoundationClassTypeNSMutableDictionary: {
                    if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                        // 已经判断 value 的类型与声明的类型一致
                        JSONValue = XZJSONEncodeObjectIntoDictionary(value, nil, property->_foundationClassType, nil);
                    }
                    break;
                }
                case XZJSONFoundationClassTypeUnknown: {
                    if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, YES)) {
                        JSONValue = XZJSONEncodeObjectIntoDictionary(value, nil, XZJSONFoundationClassTypeUnknown, keyInDictionary[key]);
                    } else {
                        JSONValue = XZJSONEncodeObjectIntoDictionary(value, nil, XZJSONFoundationClassTypeUnknown, nil);
                    }
                    break;
                }
            }
            break;
        }
    }
    
    if (key == nil) {
        return;
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
