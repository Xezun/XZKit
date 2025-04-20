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
        id const JSONObject = XZJSONEncodeObjectIntoDictionary(item, itemClass, itemClass->_foundationClass, nil);
        if (JSONObject != nil) {
            [newArray addObject:JSONObject];
        }
    }
    return newArray;
}

id XZJSONEncodeObjectIntoDictionary(id const __unsafe_unretained object, XZJSONClassDescriptor * _Nullable __unsafe_unretained objectClass, XZJSONFoundationClass const classType, NSMutableDictionary * _Nullable dictionary) {
    switch (classType) {
        case XZJSONFoundationClassNSString:
        case XZJSONFoundationClassNSMutableString: {
            return object;
        }
        case XZJSONFoundationClassNSValue: {
            if ([object isKindOfClass:NSNumber.class]) {
                return object;
            }
            
            NSValue    * const nsValue  = object;
            const char * const encoding = nsValue.objCType;
            
            XZObjcType *type = [XZObjcType typeWithEncoding:encoding];
            if (type == nil) {
                return nil;
            }
            
            NSString *value = nil;
            
            switch (XZJSONFoundationStructFromType(type)) {
                case XZJSONFoundationStructUnknown:
                    return nil;
                case XZJSONFoundationStructCGRect:
                    value = NSStringFromCGRect(nsValue.CGRectValue);
                    break;
                case XZJSONFoundationStructCGSize:
                    value = NSStringFromCGSize(nsValue.CGSizeValue);
                    break;
                case XZJSONFoundationStructCGPoint:
                    value = NSStringFromCGPoint(nsValue.CGPointValue);
                    break;
                case XZJSONFoundationStructUIEdgeInsets:
                    value = NSStringFromUIEdgeInsets(nsValue.UIEdgeInsetsValue);
                    break;
                case XZJSONFoundationStructCGVector:
                    value = NSStringFromCGVector(nsValue.CGVectorValue);
                    break;
                case XZJSONFoundationStructCGAffineTransform:
                    value = NSStringFromCGAffineTransform(nsValue.CGAffineTransformValue);
                    break;
                case XZJSONFoundationStructNSDirectionalEdgeInsets:
                    value = NSStringFromDirectionalEdgeInsets(nsValue.directionalEdgeInsetsValue);
                    break;
                case XZJSONFoundationStructUIOffset:
                    value = NSStringFromUIOffset(nsValue.UIOffsetValue);
                    break;
            }
            
            return @{ @"type": type.name, @"value": value };
        }
        case XZJSONFoundationClassNSNumber: {
            return object;
        }
        case XZJSONFoundationClassNSDecimalNumber: {
            return [(NSDecimalNumber *)object stringValue];
        }
        case XZJSONFoundationClassNSData:
        case XZJSONFoundationClassNSMutableData: {
            NSString *base64 = [(NSData *)object base64EncodedStringWithOptions:kNilOptions];
            return [NSString stringWithFormat:@"data:base64,%@", base64];
        }
        case XZJSONFoundationClassNSDate: {
            return @([(NSDate *)object timeIntervalSince1970]);
        }
        case XZJSONFoundationClassNSURL: {
            return [(NSURL *)object absoluteString];
        }
        case XZJSONFoundationClassNSArray:
        case XZJSONFoundationClassNSMutableArray: {
            return XZJSONEncodeCollection(object, [(NSArray *)object count]);
        }
        case XZJSONFoundationClassNSDictionary:
        case XZJSONFoundationClassNSMutableDictionary: {
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
                id const JSONValue = XZJSONEncodeObjectIntoDictionary(obj, objClass, objClass->_foundationClass, nil);
                if (JSONValue != nil) {
                    dictM[JSONKey] = JSONValue;
                }
            }];
            return dictM;
        }
        case XZJSONFoundationClassNSSet:
        case XZJSONFoundationClassNSMutableSet:
        case XZJSONFoundationClassNSCountedSet: {
            NSSet * const set = object;
            return XZJSONEncodeCollection(set.allObjects, set.count);
        }
        case XZJSONFoundationClassNSOrderedSet:
        case XZJSONFoundationClassNSMutableOrderedSet: {
            NSOrderedSet * const orderedSet = object;
            return XZJSONEncodeCollection(orderedSet.array.copy, orderedSet.count);
        }
        case XZJSONFoundationClassUnknown: {
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
    CFRange const range = CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelClass->_properties));
    CFArrayApplyFunction((CFArrayRef)modelClass->_properties, range, XZJSONEncodePropertyArrayEnumerator, &context);
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
    switch (property->_foundationClass) {
        case XZJSONFoundationClassNSDate:
        case XZJSONFoundationClassNSData:
        case XZJSONFoundationClassNSMutableData:
        case XZJSONFoundationClassNSValue: {
            id const value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
            // value 类型已验证，不一致的情况已提前转换为 kCFNull 不会进入此方法
            return XZJSONEncodeObjectIntoDictionary(value, nil, property->_foundationClass, nil);
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
        case XZObjcRawUnknown:
            break;
        case XZObjcRawChar:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                JSONValue = @(((char (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            }
            break;
        case XZObjcRawUnsignedChar:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO))
                JSONValue = @(((unsigned char (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcRawInt:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO))
                JSONValue = @(((int (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcRawUnsignedInt:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO))
                JSONValue = @(((unsigned int (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcRawShort:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO))
                JSONValue = @(((short (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcRawUnsignedShort:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO))
                JSONValue = @(((unsigned short (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcRawLong:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO))
                JSONValue = @(((long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcRawUnsignedLong:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO))
                JSONValue = @(((unsigned long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcRawLongLong:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO))
                JSONValue = @(((long long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcRawUnsignedLongLong:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO))
                JSONValue = @(((unsigned long long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcRawFloat:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO))
                JSONValue = @(((float (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcRawDouble:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO))
                JSONValue = @(((double (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcRawLongDouble: {
            // 目前 long double 只能用字符串承接 宏 TYPE_LONGDOUBLE_IS_DOUBLE 没用
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                long double const aValue = ((long double (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                JSONValue = [NSString stringWithFormat:@"%Lf", aValue];
            }
            break;
        }
        case XZObjcRawBool:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO))
                JSONValue = @(((BOOL (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        case XZObjcRawVoid:
        case XZObjcRawString:
        case XZObjcRawArray:
        case XZObjcRawBitField:
        case XZObjcRawPointer:
        case XZObjcRawUnion:
            break;
        case XZObjcRawStruct:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                JSONValue = NSStringFromStructProperty(model, property);
            }
            break;
        case XZObjcRawClass: {
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                Class const aClass = ((Class (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                JSONValue = aClass ? NSStringFromClass(aClass) : (id)kCFNull;
            }
            break;
        }
        case XZObjcRawSEL: {
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                SEL const aSelector = ((SEL (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                JSONValue = aSelector ? NSStringFromSelector(aSelector) : (id)kCFNull;
            }
            break;
        }
        case XZObjcRawObject: {
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
            
            switch (property->_foundationClass) {
                case XZJSONFoundationClassNSDate:
                case XZJSONFoundationClassNSData:
                case XZJSONFoundationClassNSMutableData: {
                    // 发送模型处理，然后再在 fallback 中处理
                    break;
                }
                case XZJSONFoundationClassNSValue: {
                    if ([value isKindOfClass:NSNumber.class]) {
                        JSONValue = value;
                    }
                    // 发送模型处理，然后再在 fallback 中处理
                    break;
                }
                case XZJSONFoundationClassNSString:
                case XZJSONFoundationClassNSMutableString:
                case XZJSONFoundationClassNSNumber:
                case XZJSONFoundationClassNSDecimalNumber:
                case XZJSONFoundationClassNSURL:
                case XZJSONFoundationClassNSArray:
                case XZJSONFoundationClassNSMutableArray:
                case XZJSONFoundationClassNSSet:
                case XZJSONFoundationClassNSMutableSet:
                case XZJSONFoundationClassNSCountedSet:
                case XZJSONFoundationClassNSOrderedSet:
                case XZJSONFoundationClassNSMutableOrderedSet:
                case XZJSONFoundationClassNSDictionary:
                case XZJSONFoundationClassNSMutableDictionary: {
                    if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, NO)) {
                        // 已经判断 value 的类型与声明的类型一致
                        JSONValue = XZJSONEncodeObjectIntoDictionary(value, nil, property->_foundationClass, nil);
                    }
                    break;
                }
                case XZJSONFoundationClassUnknown: {
                    if (XZJSONModelEncodePropertyPrepare(property, &key, &keyInDictionary, YES)) {
                        JSONValue = XZJSONEncodeObjectIntoDictionary(value, nil, XZJSONFoundationClassUnknown, keyInDictionary[key]);
                    } else {
                        JSONValue = XZJSONEncodeObjectIntoDictionary(value, nil, XZJSONFoundationClassUnknown, nil);
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
