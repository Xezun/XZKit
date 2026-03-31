//
//  XZJSONEncoder.m
//  XZJSON
//
//  Created by 徐臻 on 2025/2/28.
//

#import "XZJSONEncoder.h"
#import "XZJSONClass.h"
#import "XZJSONProperty.h"
#import "XZJSONDefines.h"
#import "XZMacros.h"
#import "XZLog.h"

typedef id _Nullable (*XZJSONGetter)(id _Nonnull, SEL _Nonnull);
static void XZJSONModelEncodeProperty(id model, XZJSONProperty *property, NSMutableDictionary *modelDictionary);

FOUNDATION_STATIC_INLINE id XZJSONEncodeCollection(id<NSFastEnumeration> const _Untain collection, NSUInteger count) {
    if ([NSJSONSerialization isValidJSONObject:collection]) {
        return collection;
    }
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:count];
    for (id item in collection) {
        XZJSONClass *itemClass = [XZJSONClass classForClass:object_getClass(item)];
        if (itemClass == nil) {
            continue;
        }
        id const JSONObject = XZJSONObjectEncodeIntoDictionary(item, itemClass, itemClass->_cocoaClass, nil);
        if (JSONObject != nil) {
            [newArray addObject:JSONObject];
        }
    }
    return newArray;
}

id XZJSONObjectEncodeIntoDictionary(id const _Untain object, XZJSONClass * _Nullable _Untain JSONClass, XZJSONCocoaClass const cocoaClass, NSMutableDictionary * _Nullable dictionary) {
    switch (cocoaClass) {
        case XZJSONCocoaClassNSString:
        case XZJSONCocoaClassNSMutableString: {
            return object;
        }
        case XZJSONCocoaClassNSValue: {
            if ([object isKindOfClass:NSNumber.class]) {
                return object;
            }
            
            NSValue    * const nsValue  = object;
            const char * const encoding = nsValue.objCType;
            
            XZObjcType *type = [XZObjcType typeForEncoding:encoding];
            if (type == nil) {
                return nil;
            }
            
            NSString *value = nil;
            
            switch (XZStdcStructTypeFromType(type)) {
                case XZStdcStructTypeUnknown:
                    return nil;
                case XZStdcStructTypeCGRect:
                    value = NSStringFromCGRect(nsValue.CGRectValue);
                    break;
                case XZStdcStructTypeCGSize:
                    value = NSStringFromCGSize(nsValue.CGSizeValue);
                    break;
                case XZStdcStructTypeCGPoint:
                    value = NSStringFromCGPoint(nsValue.CGPointValue);
                    break;
                case XZStdcStructTypeCGVector:
                    value = NSStringFromCGVector(nsValue.CGVectorValue);
                    break;
                case XZStdcStructTypeCGAffineTransform:
                    value = NSStringFromCGAffineTransform(nsValue.CGAffineTransformValue);
                    break;
                case XZStdcStructTypeNSDirectionalEdgeInsets:
                    value = NSStringFromDirectionalEdgeInsets(nsValue.directionalEdgeInsetsValue);
                    break;
                case XZStdcStructTypeNSRange:
                    value = NSStringFromRange(nsValue.rangeValue);
                    break;
                case XZStdcStructTypeUIEdgeInsets:
                    value = NSStringFromUIEdgeInsets(nsValue.UIEdgeInsetsValue);
                    break;
                case XZStdcStructTypeUIOffset:
                    value = NSStringFromUIOffset(nsValue.UIOffsetValue);
                    break;
            }
            
            return @{ @"type": type.name, @"value": value };
        }
        case XZJSONCocoaClassNSNumber: {
            return object;
        }
        case XZJSONCocoaClassNSDecimalNumber: {
            return [(NSDecimalNumber *)object stringValue];
        }
        case XZJSONCocoaClassNSData:
        case XZJSONCocoaClassNSMutableData: {
            NSString *base64 = [(NSData *)object base64EncodedStringWithOptions:kNilOptions];
            return [NSString stringWithFormat:@"data:base64,%@", base64];
        }
        case XZJSONCocoaClassNSDate: {
            return @([(NSDate *)object timeIntervalSince1970]);
        }
        case XZJSONCocoaClassNSURL: {
            return [(NSURL *)object absoluteString];
        }
        case XZJSONCocoaClassNSArray:
        case XZJSONCocoaClassNSMutableArray: {
            return XZJSONEncodeCollection(object, [(NSArray *)object count]);
        }
        case XZJSONCocoaClassNSDictionary:
        case XZJSONCocoaClassNSMutableDictionary: {
            if ([NSJSONSerialization isValidJSONObject:object]) {
                return object;
            }
            NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
            [(NSDictionary *)object enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
                NSString * const JSONKey = [key description];
                if (!JSONKey) return;
                XZJSONClass *JSONClass = [XZJSONClass classForClass:object_getClass(obj)];
                if (JSONClass == nil) {
                    return;
                }
                id const JSONValue = XZJSONObjectEncodeIntoDictionary(obj, JSONClass, JSONClass->_cocoaClass, nil);
                if (JSONValue != nil) {
                    dictM[JSONKey] = JSONValue;
                }
            }];
            return dictM;
        }
        case XZJSONCocoaClassNSSet:
        case XZJSONCocoaClassNSMutableSet:
        case XZJSONCocoaClassNSCountedSet: {
            NSSet * const set = object;
            return XZJSONEncodeCollection(set.allObjects, set.count);
        }
        case XZJSONCocoaClassNSOrderedSet:
        case XZJSONCocoaClassNSMutableOrderedSet: {
            NSOrderedSet * const orderedSet = object;
            return XZJSONEncodeCollection(orderedSet.array, orderedSet.count);
        }
        case XZJSONCocoaClassUnknown: {
            if (object == (id)kCFNull) {
                return object;
            }
            
            if (!JSONClass) {
                JSONClass = [XZJSONClass classForClass:object_getClass(object)];
            }
            
            if (JSONClass->_numberOfProperties == 0) {
                return [NSDictionary dictionary];
            }
            
            if (dictionary == nil) {
                dictionary = [NSMutableDictionary dictionaryWithCapacity:JSONClass->_numberOfProperties];
            }
            
            // 自定义序列化
            if (JSONClass->_usesModelEncodingMethod) {
                return [(id<XZJSONCoding>)object encodeIntoJSONDictionary:dictionary];
            }
            
            // 其它对象，视为模型。
            XZJSONModelEncodeIntoDictionary(object, JSONClass, dictionary);
            
            return dictionary;
        }
    }
}

typedef struct XZJSONModelEncodeContext {
    void *model;
    void *JSONClass;
    void *dictionary;
} XZJSONModelEncodeContext;

/// 用于遍历模型属性数组的函数。
static void XZJSONModelEncodePropertiesEnumerator(const void * const propertyRef, void * const contextRef) {
    XZJSONModelEncodeContext * const         context    = contextRef;
    NSMutableDictionary      * const _Untain dictionary = (__bridge NSMutableDictionary *)(context->dictionary);
    XZJSONProperty           * const _Untain property   = (__bridge XZJSONProperty *)(propertyRef);
    id                         const _Untain model      = (__bridge id)(context->model);
    XZJSONModelEncodeProperty(model, property, dictionary);
}

void XZJSONModelEncodeIntoDictionary(id const _Untain model, XZJSONClass * const _Untain JSONClass, NSMutableDictionary * const _Untain dictionary) {
    XZJSONModelEncodeContext context = (XZJSONModelEncodeContext){
        (__bridge void *)model,
        (__bridge void *)JSONClass,
        (__bridge void *)dictionary
    };
    CFRange const range = CFRangeMake(0, CFArrayGetCount((CFArrayRef)JSONClass->_sortedProperties));
    CFArrayApplyFunction((CFArrayRef)JSONClass->_sortedProperties, range, XZJSONModelEncodePropertiesEnumerator, &context);
}

/// 读取 JSON 字典中 keyPath 中最后一个 key 所在的字典，如果中间值不存在，则创建。
/// - Parameters:
///   - dictionary: JSON 字典
///   - keyPath: 键路径
FOUNDATION_STATIC_INLINE NSMutableDictionary *NSDictionaryForLastKeyInKeyPath(NSMutableDictionary * _Nonnull _Untain dictionary, NSArray<NSString *> * const _Untain keyPath) {
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

FOUNDATION_STATIC_INLINE id _Nullable XZJSONModelEncodePropertyFallback(id const _Untain model, XZJSONProperty * const _Untain property) {
    // 对于模型的属性，如果其值为如下类型，默认先由模型自定义处理，如果模型没有自定义处理过程，则执行 fallback 过程。
    // fallback 则将属性视为一般对象，执行默认的对象 JSON 序列化过程。
    switch (property->_cocoaClass) {
        case XZJSONCocoaClassNSDate:
        case XZJSONCocoaClassNSData:
        case XZJSONCocoaClassNSMutableData:
        case XZJSONCocoaClassNSValue: {
            id const value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
            // value 类型已验证，不一致的情况已提前转换为 kCFNull 不会进入此方法
            return XZJSONObjectEncodeIntoDictionary(value, nil, property->_cocoaClass, nil);
        }
        default: {
            return nil;
        }
    }
}

/// 根据映射找到 JSONKey 以及 JSONKey 所在的字典。
FOUNDATION_STATIC_INLINE BOOL XZJSONModelEncodePropertyPrepare(XZJSONProperty * const _Untain property, NSString **key, NSMutableDictionary **keyInDictionary, BOOL merges) {
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

void XZJSONModelEncodeProperty(id const _Untain model, XZJSONProperty * const _Untain property, NSMutableDictionary * const _Untain modelDictionary) {
    NSString            *key = nil;
    NSMutableDictionary *keysDictionary = modelDictionary; // key 所在的字典。
    id JSONValue = nil;
    
    switch (property->_type) {
        case XZStdcTypeUnknown:
            break;
        case XZStdcTypeChar:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keysDictionary, NO)) {
                JSONValue = @(((char (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter));
            }
            break;
        case XZStdcTypeUnsignedChar:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keysDictionary, NO)) {
                JSONValue = @(((unsigned char (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter));
            }
            break;
        case XZStdcTypeInt:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keysDictionary, NO)) {
                JSONValue = @(((int (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter));
            }
            break;
        case XZStdcTypeUnsignedInt:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keysDictionary, NO)) {
                JSONValue = @(((unsigned int (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter));
            }
            break;
        case XZStdcTypeShort:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keysDictionary, NO)) {
                JSONValue = @(((short (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter));
            }
            break;
        case XZStdcTypeUnsignedShort:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keysDictionary, NO)) {
                JSONValue = @(((unsigned short (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter));
            }
            break;
        case XZStdcTypeLong:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keysDictionary, NO)) {
                JSONValue = @(((long (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter));
            }
            break;
        case XZStdcTypeUnsignedLong:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keysDictionary, NO)) {
                JSONValue = @(((unsigned long (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter));
            }
            break;
        case XZStdcTypeLongLong:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keysDictionary, NO)) {
                JSONValue = @(((long long (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter));
            }
            break;
        case XZStdcTypeUnsignedLongLong:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keysDictionary, NO)) {
                JSONValue = @(((unsigned long long (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter));
            }
            break;
        case XZStdcTypeFloat:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keysDictionary, NO)) {
                JSONValue = @(((float (*)(id, SEL))(void *)xz_objc_msgSend_ftret)(model, property->_getter));
            }
            break;
        case XZStdcTypeDouble:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keysDictionary, NO)) {
                JSONValue = @(((double (*)(id, SEL))(void *)xz_objc_msgSend_dbret)(model, property->_getter));
            }
            break;
        case XZStdcTypeLongDouble: {
            // 目前 long double 只能用字符串承接 宏 TYPE_LONGDOUBLE_IS_DOUBLE 没用
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keysDictionary, NO)) {
                long double const aValue = ((long double (*)(id, SEL))(void *)xz_objc_msgSend_ldret)(model, property->_getter);
                JSONValue = [NSString stringWithFormat:@"%Lf", aValue];
            }
            break;
        }
        case XZStdcTypeBool:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keysDictionary, NO)) {
                JSONValue = @(((BOOL (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter));
            }
            break;
        case XZStdcTypeVoid:
        case XZStdcTypeString:
        case XZStdcTypeArray:
        case XZStdcTypeBitField:
        case XZStdcTypePointer:
        case XZStdcTypeUnion:
            break;
        case XZStdcTypeStruct:
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keysDictionary, NO)) {
                JSONValue = XZJSONEncodeStructProperty(model, property);
            }
            break;
        case XZStdcTypeClass: {
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keysDictionary, NO)) {
                Class const aClass = ((Class (*)(id, SEL))(void *)objc_msgSend)((id)model, property->_getter);
                JSONValue = aClass ? NSStringFromClass(aClass) : (id)kCFNull;
            }
            break;
        }
        case XZStdcTypeSelector: {
            if (XZJSONModelEncodePropertyPrepare(property, &key, &keysDictionary, NO)) {
                SEL const aSelector = ((SEL (*)(id, SEL))(void *)objc_msgSend)((id)model, property->_getter);
                JSONValue = aSelector ? NSStringFromSelector(aSelector) : (id)kCFNull;
            }
            break;
        }
        case XZStdcTypeObject: {
            id const value = ((id (*)(id, SEL))(void *)objc_msgSend)((id)model, property->_getter);
            
            // 所有参与转换的属性，都将输出到 JSON 中
            if (value == nil) {
                JSONValue = (id)kCFNull;
                break;
            }
            
            // 属性 实际值与声明值 不一致
            if (property->_classType && ![value isKindOfClass:property->_classType]) {
                JSONValue = (id)kCFNull;
                break;
            }
            
            switch (property->_cocoaClass) {
                case XZJSONCocoaClassNSDate:
                case XZJSONCocoaClassNSData:
                case XZJSONCocoaClassNSMutableData: {
                    // 发送模型处理，然后再在 fallback 中处理
                    break;
                }
                case XZJSONCocoaClassNSValue: {
                    if ([value isKindOfClass:NSNumber.class]) {
                        JSONValue = value;
                    }
                    // 发送模型处理，然后再在 fallback 中处理
                    break;
                }
                case XZJSONCocoaClassNSString:
                case XZJSONCocoaClassNSMutableString:
                case XZJSONCocoaClassNSNumber:
                case XZJSONCocoaClassNSDecimalNumber:
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
                    if (XZJSONModelEncodePropertyPrepare(property, &key, &keysDictionary, NO)) {
                        // 已经判断 value 的类型与声明的类型一致
                        JSONValue = XZJSONObjectEncodeIntoDictionary(value, nil, property->_cocoaClass, nil);
                    }
                    break;
                }
                case XZJSONCocoaClassUnknown: {
                    if (XZJSONModelEncodePropertyPrepare(property, &key, &keysDictionary, YES)) {
                        JSONValue = XZJSONObjectEncodeIntoDictionary(value, nil, XZJSONCocoaClassUnknown, keysDictionary[key]);
                    } else {
                        JSONValue = XZJSONObjectEncodeIntoDictionary(value, nil, XZJSONCocoaClassUnknown, nil);
                    }
                    break;
                }
            }
            break;
        }
        case XZStdcTypeInt128:
        case XZStdcTypeUnsignedInt128:
        case XZStdcTypeVector:
            XZLog(@"[XZJSON] 目前平台不支持该数据类型");
            break;
    }
    
    if (key == nil) {
        return;
    }
    
    if (JSONValue == nil && property->_owner->_usesPropertyEncodingMethod) {
        JSONValue = [model JSONEncodeValueForKey:property->_name];
    }
    
    if (JSONValue == nil) {
        JSONValue = XZJSONModelEncodePropertyFallback(model, property);
    }
    
    if (JSONValue) {
        keysDictionary[key] = JSONValue;
        return;
    }
    
    XZLog(@"[XZJSON] Can not encode property `%@` of `%@`", property->_name, property->_owner->_raw.name);
}
