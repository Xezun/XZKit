//
//  XZJSONPrivate.m
//  XZJSON
//
//  Created by Xezun on 2024/12/3.
//

#import "XZJSONPrivate.h"
@import ObjectiveC;

/// 读取 JSON 字典中 keyPath 中最后一个 key 所在的字典，如果中间值不存在，则创建。
/// - Parameters:
///   - dictionary: JSON 字典
///   - keyPath: 键路径
static NSMutableDictionary *NSDictionaryForLastKeyInKeyPath(NSMutableDictionary *dictionary, NSArray<NSString *> *keyPath) {
    for (NSUInteger i = 0, max = keyPath.count - 1; i < max; i++) {
        NSString * const subKey = keyPath[i];
        NSMutableDictionary *subDict = dictionary[subKey];
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

@implementation XZJSON (XZJSONDecodingPrivate)

+ (nullable id)_decodeJSONData:(nonnull NSData *)data options:(NSJSONReadingOptions)options class:(Class)aClass {
    NSError *error = nil;
    id const object = [NSJSONSerialization JSONObjectWithData:data options:options error:&error];
    if ((error == nil || error.code == noErr) && object != nil) {
        return [self _decodeJSONObject:object class:aClass];
    }
    return nil;
}

+ (nullable id)_decodeJSONObject:(nonnull id const)object class:(Class)aClass {
    if (object == NSNull.null) {
        return nil;
    }
    // 如果为字典，则认为是模型数据。
    if ([object isKindOfClass:NSDictionary.class]) {
        NSDictionary *dictionary = object;
        XZJSONClassDescriptor *descriptor = [XZJSONClassDescriptor descriptorForClass:aClass];
        // 转发解析
        if (descriptor->_forwardsClassForDecoding) {
            Class const newClass = [aClass forwardingClassForJSONDictionary:dictionary];
            if (newClass == Nil) {
                return nil;
            }
            if (newClass != aClass) {
                aClass = newClass;
                descriptor = [XZJSONClassDescriptor descriptorForClass:aClass];
            }
        }
        // 数据校验
        if (descriptor->_verifiesValueForDecoding) {
            dictionary = [aClass canDecodeFromJSONDictionary:dictionary];
            if (dictionary == nil) {
                return nil;
            }
        }
        // 自定义初始化过程
        if (descriptor->_usesJSONDecodingInitializer) {
            return [[aClass alloc] initWithJSONDictionary:dictionary];
        }
        // 通用初始化方法
        id const model = [aClass new];
        if (model != nil) {
            [self _model:model decodeFromDictionary:dictionary descriptor:descriptor];
        }
        return model;
    }
    // 如果是数组，则对数组元素是模型数据（也可能是模型数据数组）。
    if ([object isKindOfClass:NSArray.class]) {
        NSArray * const array = object;
        if (array.count == 0) {
            return array;
        }
        
        NSMutableArray * const models = [NSMutableArray arrayWithCapacity:array.count];
        for (id item in array) {
            id const model = [self _decodeJSONObject:item class:aClass];
            if (model) {
                [models addObject:model];
            }
        }
        return models;
    }
    // 如果已经模型对象，直接使用。
    if ([object isKindOfClass:aClass]) {
        return object;
    }
    // 模型化失败。
    return nil;
}

+ (void)_model:(id)model decodeFromDictionary:(NSDictionary *)dictionary descriptor:(XZJSONClassDescriptor *)descriptor {
    // 没有可用的属性
    if (descriptor->_numberOfProperties == 0) {
        return;
    }
   
    // 遍历数量少的集合，可以提高通用模型的解析效率。
    if (descriptor->_numberOfProperties >= dictionary.count) {
        // 遍历 JSON 数据，只能找到通过 key 映射的属性，所以需要单独遍历 keyPath 和 keyArray
        [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL * _Nonnull stop) {
            XZJSONPropertyDescriptor *property = descriptor->_keyProperties[key];
            while (property) {
                XZJSONModelDecodeProperty(model, property, value);
                property = property->_next;
            }
        }];
        
        [descriptor->_keyPathProperties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor * _Nonnull property, NSUInteger idx, BOOL * _Nonnull stop) {
            id const JSONValue = (property->_keyValueCoder)(dictionary);
            if (JSONValue) {
                XZJSONModelDecodeProperty(model, property, JSONValue);
            }
        }];
        
        [descriptor->_keyArrayProperties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor *property, NSUInteger idx, BOOL *stop) {
            id const JSONValue = (property->_keyValueCoder)(dictionary);
            if (JSONValue) {
                XZJSONModelDecodeProperty(model, property, JSONValue);
            }
        }];
    } else {
        [descriptor->_properties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor *property, NSUInteger idx, BOOL *stop) {
            id const JSONValue = (property->_keyValueCoder)(dictionary);
            if (JSONValue) {
                XZJSONModelDecodeProperty(model, property, JSONValue);
            }
        }];
    }
}

@end

@implementation XZJSON (XZJSONEncodingPrivate)

+ (id)_encodeObject:(id)object intoDictionary:(nullable NSMutableDictionary *)dictionary {
    XZJSONClassDescriptor * const modelClass = [XZJSONClassDescriptor descriptorForClass:[object class]];
    switch (modelClass->_classType) {
        case XZJSONClassTypeNSString:
        case XZJSONClassTypeNSMutableString: {
            return object;
        }
        case XZJSONClassTypeNSValue: {
            return object;
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
            if ([NSJSONSerialization isValidJSONObject:object]) {
                return object;
            }
            NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:((NSArray *)object).count];
            for (id item in (NSArray *)object) {
                id const JSONObject = [self _encodeObject:item intoDictionary:nil];
                if (JSONObject != nil) {
                    [newArray addObject:JSONObject];
                }
            }
            return newArray;
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
                id const JSONValue = [self _encodeObject:obj intoDictionary:nil];
                if (JSONValue != nil) {
                    dictM[JSONKey] = JSONValue;
                }
            }];
            return dictM;
        }
        case XZJSONClassTypeNSSet:
        case XZJSONClassTypeNSMutableSet: {
            NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:((NSSet *)object).count];
            for (id item in (NSSet *)object) {
                id const JSONObject = [self _encodeObject:item intoDictionary:nil];
                if (JSONObject != nil) {
                    [newArray addObject:JSONObject];
                }
            }
            return newArray;
        }
        case XZJSONClassTypeUnknown: {
            if (object == (id)kCFNull) {
                return object;
            }
            
            if (dictionary == nil) {
                dictionary = [NSMutableDictionary dictionaryWithCapacity:modelClass->_numberOfProperties];
            }
            
            // 自定义序列化
            if (modelClass->_usesJSONEncodingInitializer) {
                return [(id<XZJSONCoding>)object encodeIntoJSONDictionary:dictionary];
            }
            
            // 其它对象，视为模型。
            [self _model:object encodeIntoDictionary:dictionary descriptor:modelClass];
            
            return dictionary;
        }
    }
}

+ (void)_model:(id)model encodeIntoDictionary:(NSMutableDictionary *)dictionary descriptor:(XZJSONClassDescriptor *)descriptor {
    [descriptor->_properties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor * _Nonnull property, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString            *key  = nil;
        NSMutableDictionary *dict = dictionary;
        
        // 先判断是否映射到 keyPath 或 keyArray
        if (property->_JSONKeyPath) {
            dict = NSDictionaryForLastKeyInKeyPath(dict, property->_JSONKeyPath);
            if (dict == nil) {
                return;
            }
            key = property->_JSONKeyPath.lastObject;
        } else if (property->_JSONKeyArray) {
            for (NSUInteger i = 0, count = property->_JSONKeyArray.count; i < count; i++) {
                id const aKey = property->_JSONKeyArray[i];
                
                if ([aKey isKindOfClass:NSString.class]) {
                    if (dictionary[(NSString *)aKey]) {
                        continue; // 对应的 key 已经有值，继续遍历，尝试其它 key
                    }
                    key = aKey;
                    break;
                }
                
                NSMutableDictionary *temp = NSDictionaryForLastKeyInKeyPath(dict, aKey);
                if (temp) {
                    dict = temp;
                    key = ((NSArray *)aKey).lastObject;
                    break;
                }
            }
            if (key == nil) {
                return;
            }
        } else {
            if (dictionary[property->_JSONKey]) {
                return; // 值已存在，不覆盖。
            }
            key = property->_JSONKey;
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
                long double const aValue = ((long double (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                JSONValue = [[NSNumber alloc] initWithBytes:&aValue objCType:@encode(long double)];
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
                JSONValue = XZJSONModelEncodeStructProperty(model, property);
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
                                        
                if (value == nil) {
                    // 所有参与转换的属性，都将输出到 JSON 中
                    JSONValue = (id)kCFNull;
                } else {
                    // 如果 key 已经有值，则进行合并，不能合并则覆盖
                    NSMutableDictionary *dictionay = dict[key];
                    if (![dictionay isKindOfClass:NSMutableDictionary.class]) {
                        dictionay = [NSMutableDictionary dictionary];
                    }
                    JSONValue = [self _encodeObject:value intoDictionary:dictionary];
                }
                break;
            }
        }
        
        if (JSONValue == nil) {
            if (property->_class->_usesPropertyJSONEncodingMethod) {
                JSONValue = [model JSONEncodeValueForKey:property->_name];
            } else {
                NSLog(@"[XZJSON] Can not encode property `%@` of `%@`", property->_name, descriptor->_class.name);
            }
        }
        
        if (JSONValue) {
            dict[key] = JSONValue;
        }
    }];
}

@end

typedef id _Nullable (*XZJSONGetter)(id _Nonnull, SEL _Nonnull);
typedef void         (*XZJSONSetter)(id _Nonnull, SEL _Nonnull, id _Nullable);

static NSNumber * _Nullable NSNumberObjectFromJSONValue(id _Nonnull JSONValue) {
    if (JSONValue == (id)kCFNull) {
        return nil;
    }

    if ([JSONValue isKindOfClass:[NSNumber class]]) {
        return JSONValue;
    }

    static NSDictionary<NSString *, NSNumber *> *_boolStrings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _boolStrings = @{
            @"Y": @(YES), @"N": @(NO), @"T": @(YES), @"F": @(NO),
            @"y": @(YES), @"n": @(NO), @"t": @(YES), @"f": @(NO),
            @"TRUE": @(YES), @"FALSE": @(NO), @"YES": @(YES), @"NO": @(NO),
            @"True": @(YES), @"False": @(NO), @"Yes": @(YES), @"No": @(NO),
            @"true": @(YES), @"false": @(NO), @"yes": @(YES), @"no": @(NO),
        };
    });

    if ([JSONValue isKindOfClass:[NSString class]]) {
        NSNumber *const number = _boolStrings[JSONValue];
        if (number) {
            return number;
        }

        const char *const string = [((NSString *)JSONValue) cStringUsingEncoding:NSASCIIStringEncoding];

        if (string == NULL) {
            return nil;
        }
        
        if (strchr(string, '.')) {
            char *error = NULL;
            double const number = strtod(string, &error);
            if (isnan(number) || isinf(number)) {
                return nil;
            }
            return @(number);
        }

        return @(atoll(string));
    }

    return nil;
}

/// 将 JSON 值转换为 NSDecimalNumber 值。
/// - Parameter value: JSON 值
static NSDecimalNumber * _Nullable NSDecimalNumberFromJSONValue(id _Nonnull JSONValue) {
    if ([JSONValue isKindOfClass:[NSNumber class]]) {
        NSNumber *number = JSONValue;
        return [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
    } else if ([JSONValue isKindOfClass:[NSString class]]) {
        NSDecimalNumber *const number = [NSDecimalNumber decimalNumberWithString:JSONValue];
        NSDecimal const numberValue = number.decimalValue;
        if (numberValue._length == 0 && numberValue._isNegative) {
            return nil;
        }
        return number;
    } else if ([JSONValue isKindOfClass:[NSDecimalNumber class]]) {
        return JSONValue;
    }
    return nil;
}

/// 将 JSON 值 value 转换为 NSDate 对象。
/// - Parameter JSONValue: JSON 值
static NSDate *NSDateFromJSONValue(__unsafe_unretained id _Nonnull JSONValue) {
    if (JSONValue == (id)kCFNull) {
        return nil;
    }
    
    // 日期
    if ([JSONValue isKindOfClass:NSDate.class]) {
        return JSONValue;
    }
    
    // 时间戳，默认秒
    if ([JSONValue isKindOfClass:NSNumber.class]) {
        NSTimeInterval const timeInterval = [(NSNumber *)JSONValue doubleValue];
        return [NSDate dateWithTimeIntervalSince1970:timeInterval];
    }
    
    // 字符串当作默认时间格式
    if ([JSONValue isKindOfClass:NSString.class]) {
        return [XZJSON.dateFormatter dateFromString:JSONValue];
    }
    
    return nil;
}

/// 将 JSON 值转换为 NSString 值。
/// - Parameter value: JSON 值
static NSString * _Nullable NSStringFromJSONValue(id JSONValue) {
    if (JSONValue == (id)kCFNull) {
        return nil;
    }
    
    if ([JSONValue isKindOfClass:NSString.class]) {
        return JSONValue;
    }

    if ([JSONValue isKindOfClass:NSNumber.class]) {
        NSNumber *const number = JSONValue;
        return number.stringValue;
    }
    
    return nil;
}

/// 将 JSON 值转换为 NSData 值。
/// - Parameter JSONValue: JSON 值
static NSData * _Nullable NSDataFromJSONValue(id _Nullable const value) {
    if ([value isKindOfClass:NSData.class]) {
        return value;
    }
    
    if (![value isKindOfClass:NSString.class]) {
        return nil;
    }
    NSString * const string = value;
    
    NSString *type = nil;
    NSString *data = nil;
    
    // RFC2397 URL Data
    // data:[<mediatype>][;base64],<data>
    // https://datatracker.ietf.org/doc/html/rfc2397
    if ([string hasPrefix:@"data:"] && string.length > 5) {
        NSUInteger const max = [string rangeOfString:@"," options:0 range:NSMakeRange(0, MIN(1024, string.length))].location;
        if (max != NSNotFound) {
            NSUInteger const min = [string rangeOfString:@";" options:(NSBackwardsSearch) range:NSMakeRange(5, max - 5)].location;
            
            if (min == NSNotFound) {
                type = [string substringWithRange:NSMakeRange(5, max - 5)];
            } else {
                type = [string substringWithRange:NSMakeRange(min + 1, max - min - 1)];
            }
            type = [type lowercaseString];
            
            data = [string substringFromIndex:max + 1];
        } else {
            type = @"base64";
            data = [string substringFromIndex:5];
        }
    }
    
    if ([type isEqualToString:@"base64"]) {
        return [[NSData alloc] initWithBase64EncodedString:value options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
    }
    
    return [data dataUsingEncoding:NSUTF8StringEncoding];
}

static NSArray * _Nullable NSArrayFromJSONValue(id _Nonnull const JSONValue, Class _Nullable const elementClass) {
    if (elementClass) {
        NSArray *array = NSArrayFromJSONValue(JSONValue, Nil);

        if (array) {
            NSMutableArray * const arrayM = [NSMutableArray arrayWithCapacity:array.count];
            for (id data in array) {
                id const model = [XZJSON _decodeJSONObject:data class:elementClass];
                if (model) {
                    [arrayM addObject:model];
                }
            }
            return arrayM;
        }
        return nil;
    }
    
    if ([JSONValue isKindOfClass:[NSArray class]]) {
        return JSONValue;
    }
    if ([JSONValue isKindOfClass:[NSSet class]]) {
        return ((NSSet *)JSONValue).allObjects;
    }
    return [NSMutableArray arrayWithObject:JSONValue];
}

static NSDictionary * _Nullable NSDictionaryFromJSONValue(id _Nonnull const JSONValue, Class _Nullable const elementClass) {
    if (elementClass) {
        if ([JSONValue isKindOfClass:NSDictionary.class]) {
            NSMutableDictionary *dictM = [NSMutableDictionary new];
            [((NSDictionary *)JSONValue) enumerateKeysAndObjectsUsingBlock:^(NSString *oneKey, id oneValue, BOOL *stop) {
                dictM[oneKey] = [XZJSON _decodeJSONObject:oneValue class:elementClass];
            }];
            return dictM;
        }
        
        if ([JSONValue isKindOfClass:NSArray.class]) {
            NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
            [(NSArray *)JSONValue enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *key = [NSString stringWithFormat:@"%ld", (long)idx];
                dictM[key] = [XZJSON _decodeJSONObject:obj class:elementClass];
            }];
            return dictM;
        }
        return nil;
    }
    
    if ([JSONValue isKindOfClass:NSDictionary.class]) {
        return JSONValue;
    }
    
    if ([JSONValue isKindOfClass:NSArray.class]) {
        NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
        [(NSArray *)JSONValue enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *key = [NSString stringWithFormat:@"%ld", (long)idx];
            dictM[key] = obj;
        }];
        return dictM;
    }
    
    return nil;
}

static NSSet * _Nullable NSSetFromJSONValue(id _Nonnull const JSONValue, Class _Nullable const elementClass) {
    if (elementClass) {
        if ([JSONValue isKindOfClass:NSDictionary.class]) {
            id model = [XZJSON _decodeJSONObject:JSONValue class:elementClass];
            if (model) {
                return [NSMutableSet setWithObject:model];
            }
            return nil;
        }
        
        if ([JSONValue isKindOfClass:[NSArray class]] || [JSONValue isKindOfClass:NSSet.class]) {
            NSMutableSet *setM = [NSMutableSet new];
            for (id data in JSONValue) {
                id const model = [XZJSON _decodeJSONObject:data class:elementClass];
                if (model) {
                    [setM addObject:model];
                }
            }
            return setM;
        }
        
        return nil;
    }
    
    if ([JSONValue isKindOfClass:NSArray.class]) {
        return [NSMutableSet setWithArray:JSONValue];
    }
    
    if ([JSONValue isKindOfClass:NSSet.class]) {
        return JSONValue;
    }
    
    return [NSMutableSet setWithObject:JSONValue];
}

static NSNumber * _Nullable NSNumberCharFromJSONValue(id _Nonnull JSONValue) {
    NSNumber *number = nil;
    if ([JSONValue isKindOfClass:NSNumber.class]) {
        number = JSONValue;
    } else if ([JSONValue isKindOfClass:NSString.class]) {
        NSString *string = JSONValue;
        if (string.length > 0) {
            number = @([(NSString *)number characterAtIndex:0]);
        }
    }
    return number;
}

static NSNumber * _Nullable NSNumberIntegerFromJSONValue(id _Nonnull JSONValue) {
    NSNumber *number = nil;
    if ([JSONValue isKindOfClass:NSNumber.class]) {
        number = JSONValue;
    } else if ([JSONValue isKindOfClass:NSString.class]) {
        NSString *string = JSONValue;
        if (string.length > 0) {
            number = @(atoll([string cStringUsingEncoding:NSASCIIStringEncoding]));
        }
    }
    return number;
}

static NSNumber * _Nullable NSNumberDoubleFromJSONValue(id _Nonnull JSONValue) {
    NSNumber *number = nil;
    if ([JSONValue isKindOfClass:NSNumber.class]) {
        number = JSONValue;
    } else if ([JSONValue isKindOfClass:NSString.class]) {
        NSString *string = JSONValue;
        if (string.length > 0) {
            char *error = NULL;
            long double const aValue = strtold([string cStringUsingEncoding:NSASCIIStringEncoding], &error);
            if (!isnan(aValue) && !isinf(aValue)) {
                number = [[NSNumber alloc] initWithBytes:&aValue objCType:@encode(long double)];
            }
        }
    }
    return number;
}

static NSNumber * _Nullable NSNumberBoolFromJSONValue(id _Nonnull JSONValue) {
    NSNumber *number = nil;
    if ([JSONValue isKindOfClass:NSNumber.class]) {
        number = JSONValue;
    } else if ([JSONValue isKindOfClass:NSString.class]) {
        NSString *string = JSONValue;
        string = [string stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        if (string.length > 0) {
            number = @([string boolValue]);
        }
    }
    return number;
}

void XZJSONModelDecodeProperty(id model, XZJSONPropertyDescriptor *property, id _Nonnull JSONValue) {
    switch (property->_type) {
        case XZObjcTypeUnknown:
        case XZObjcTypeVoid:
        case XZObjcTypeString:
        case XZObjcTypeArray:
        case XZObjcTypeBitField:
        case XZObjcTypePointer:
        case XZObjcTypeUnion: {
            // 无法处理的类型
            break;
        }
        case XZObjcTypeChar: {
            NSNumber *number = NSNumberCharFromJSONValue(JSONValue);
            if (number) {
                ((void (*)(id, SEL, char))objc_msgSend)((id)model, property->_setter, number.charValue);
                return;
            }
            break;
        }
        case XZObjcTypeUnsignedChar: {
            NSNumber *number = NSNumberCharFromJSONValue(JSONValue);
            if (number) {
                ((void (*)(id, SEL, unsigned char))objc_msgSend)((id)model, property->_setter, number.unsignedCharValue);
                return;
            }
            break;
        }
        case XZObjcTypeInt: {
            NSNumber *number = NSNumberIntegerFromJSONValue(JSONValue);
            if (number) {
                ((void (*)(id, SEL, int))objc_msgSend)((id)model, property->_setter, number.intValue);
                return;
            }
            break;
        }
        case XZObjcTypeUnsignedInt: {
            NSNumber *number = NSNumberIntegerFromJSONValue(JSONValue);
            if (number) {
                ((void (*)(id, SEL, unsigned int))objc_msgSend)((id)model, property->_setter, number.unsignedIntValue);
                return;
            }
            return;
        }
        case XZObjcTypeShort: {
            NSNumber *number = NSNumberIntegerFromJSONValue(JSONValue);
            if (number) {
                ((void (*)(id, SEL, short))objc_msgSend)((id)model, property->_setter, number.shortValue);
                return;
            }
            break;
        }
        case XZObjcTypeUnsignedShort: {
            NSNumber *number = NSNumberIntegerFromJSONValue(JSONValue);
            if (number) {
                ((void (*)(id, SEL, unsigned short))objc_msgSend)((id)model, property->_setter, number.unsignedShortValue);
                return;
            }
            break;
        }
        case XZObjcTypeLong: {
            NSNumber *number = NSNumberIntegerFromJSONValue(JSONValue);
            if (number) {
                ((void (*)(id, SEL, long))objc_msgSend)((id)model, property->_setter, number.longValue);
                return;
            }
            break;
        }
        case XZObjcTypeUnsignedLong: {
            NSNumber *number = NSNumberIntegerFromJSONValue(JSONValue);
            if (number) {
                ((void (*)(id, SEL, unsigned long))objc_msgSend)((id)model, property->_setter, number.unsignedLongValue);
                return;
            }
            break;;
        }
        case XZObjcTypeLongLong: {
            NSNumber *number = NSNumberIntegerFromJSONValue(JSONValue);
            if (number) {
                ((void (*)(id, SEL, long long))objc_msgSend)((id)model, property->_setter, number.longLongValue);
                return;
            }
            break;
        }
        case XZObjcTypeUnsignedLongLong: {
            NSNumber *number = NSNumberIntegerFromJSONValue(JSONValue);
            if (number) {
                ((void (*)(id, SEL, unsigned long long))objc_msgSend)((id)model, property->_setter, number.unsignedLongLongValue);
                return;
            }
            break;;
        }
        case XZObjcTypeFloat: {
            NSNumber *number = NSNumberDoubleFromJSONValue(JSONValue);
            if (number) {
                ((void (*)(id, SEL, float))objc_msgSend)((id)model, property->_setter, number.floatValue);
                return;
            }
            break;
        }
        case XZObjcTypeDouble: {
            NSNumber *number = NSNumberDoubleFromJSONValue(JSONValue);
            if (number) {
                ((void (*)(id, SEL, long long))objc_msgSend)((id)model, property->_setter, number.doubleValue);
                return;
            }
            break;
        }
        case XZObjcTypeLongDouble: {
            NSNumber *number = NSNumberDoubleFromJSONValue(JSONValue);
            if (number) {
                long double aValue = 0;
                [number getValue:&aValue size:sizeof(long double)];
                ((void (*)(id, SEL, long long))objc_msgSend)((id)model, property->_setter, aValue);
                return;
            }
            break;
        }
        case XZObjcTypeBool: {
            NSNumber *number = NSNumberBoolFromJSONValue(JSONValue);
            if (number) {
                ((void (*)(id, SEL, BOOL))objc_msgSend)((id)model, property->_setter, number.boolValue);
                return;
            }
            break;
        }
        case XZObjcTypeStruct: {
            if (XZJSONModelDecodeStructProperty(model, property, JSONValue)) {
                return;
            }
            break;
        }
        case XZObjcTypeClass: {
            if (JSONValue == (id)kCFNull) {
                ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, property->_setter, Nil);
            } else if ([JSONValue isKindOfClass:[NSString class]]) {
                Class aClass = NSClassFromString(JSONValue);
                if (aClass) {
                    ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, property->_setter, aClass);
                    return;
                }
            }
            break;
        }
        case XZObjcTypeSEL: {
            if (JSONValue == (id)kCFNull) {
                ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model, property->_setter, (SEL)NULL);
            } else if ([JSONValue isKindOfClass:[NSString class]]) {
                SEL selector = NSSelectorFromString(JSONValue);
                if (selector) {
                    ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model, property->_setter, selector);
                    return;
                }
            }
            break;
        }
        case XZObjcTypeObject: {
            // 空值
            if (JSONValue == (id)kCFNull) {
                ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, (id)nil);
                return;
            }
            
            if (property->_isUnownedReferenceProperty) {
                break;
            }
            
            id value = nil;
            
            switch (property->_classType) {
                case XZJSONClassTypeNSString: {
                    value = NSStringFromJSONValue(JSONValue);
                    break;
                }
                case XZJSONClassTypeNSMutableString: {
                    value = NSStringFromJSONValue(JSONValue);
                    if (value && ![value isKindOfClass:NSMutableString.class]) {
                        value = [NSMutableString stringWithString:value];
                    }
                    break;
                }
                case XZJSONClassTypeNSValue: {
                    if ([JSONValue isKindOfClass:[NSValue class]]) {
                        value = JSONValue;
                    }
                    break;
                }
                case XZJSONClassTypeNSNumber: {
                    value = NSNumberObjectFromJSONValue(JSONValue);
                    break;
                }
                case XZJSONClassTypeNSDecimalNumber: {
                    value = NSDecimalNumberFromJSONValue(JSONValue);
                    break;
                }
                case XZJSONClassTypeNSData: {
                    value = NSDataFromJSONValue(JSONValue);
                    break;
                }
                case XZJSONClassTypeNSMutableData: {
                    value = NSDataFromJSONValue(JSONValue);
                    if (value && ![value isKindOfClass:[NSMutableData class]]) {
                        value = [NSMutableData dataWithData:value];
                    }
                    break;
                }
                case XZJSONClassTypeNSDate: {
                    value = NSDateFromJSONValue(JSONValue);
                    break;
                }
                case XZJSONClassTypeNSURL: {
                    if ([JSONValue isKindOfClass:[NSURL class]]) {
                        value = JSONValue;
                    } else if ([JSONValue isKindOfClass:[NSString class]]) {
                        NSString *string = JSONValue;
                        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                        string = [string stringByTrimmingCharactersInSet:set];
                        value = [NSURL URLWithString:string];
                    }
                    break;
                }
                case XZJSONClassTypeNSArray: {
                    value = NSArrayFromJSONValue(JSONValue, property->_elementType);
                    break;
                }
                case XZJSONClassTypeNSMutableArray: {
                    value = NSArrayFromJSONValue(JSONValue, property->_elementType);
                    if (value && ![value isKindOfClass:NSMutableArray.class]) {
                        value = [NSMutableArray arrayWithArray:value];
                    }
                    break;
                }
                case XZJSONClassTypeNSDictionary: {
                    value = NSDictionaryFromJSONValue(JSONValue, property->_elementType);
                    break;
                }
                case XZJSONClassTypeNSMutableDictionary: {
                    value = NSDictionaryFromJSONValue(JSONValue, property->_elementType);
                    if (value && ![value isKindOfClass:NSMutableDictionary.class]) {
                        value = [NSMutableDictionary dictionaryWithDictionary:value];
                    }
                    break;
                }
                case XZJSONClassTypeNSSet: {
                    value = NSSetFromJSONValue(JSONValue, property->_elementType);
                    break;
                }
                case XZJSONClassTypeNSMutableSet: {
                    value = NSSetFromJSONValue(JSONValue, property->_elementType);
                    if (value && ![value isKindOfClass:NSMutableSet.class]) {
                        value = [NSMutableSet setWithSet:value];
                    }
                    break;
                }
                case XZJSONClassTypeUnknown: {
                    // 自定义类型
                    if (!property->_subtype || [JSONValue isKindOfClass:property->_subtype]) {
                        // 未指定对象类型，或者已经是指定的自定义对象类型，直接赋值
                        value = JSONValue;
                    } else {
                        // JSON 数据模型化为指定的自定义对象类型
                        if (![JSONValue isKindOfClass:[NSDictionary class]]) {
                            JSONValue = @{ @"rawValue": JSONValue }; // 非字典数据，包装为字典
                        }
                        // 如果属性已有值，直接更新它。
                        value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);;
                        if (value) {
                            [XZJSON model:value decodeFromDictionary:JSONValue];
                        } else {
                            value = [XZJSON _decodeJSONObject:JSONValue class:property->_subtype];
                        }
                    }
                    break;
                }
            }
            
            if (value) {
                ((XZJSONSetter)objc_msgSend)(model, property->_setter, value);
                return;
            }
            break;
        }
    }
    
    // JSONValue 无法解析为目标属性值
    if (property->_class->_usesPropertyJSONDecodingMethod) {
        [(id<XZJSONCoding>)model JSONDecodeValue:JSONValue forKey:property->_name];
    } else {
        NSLog(@"[XZJSON] Can not decode value `%@` for property `%@` of `%@`", JSONValue, property->_name, property->_class->_class.name);
    }
}

BOOL XZJSONModelDecodeStructProperty(id model, XZJSONPropertyDescriptor *property, id _Nonnull JSONValue) {
    if ([JSONValue isKindOfClass:NSString.class]) {
        NSString * const name = property->_property.type.name;
        if ([name isEqualToString:@"CGRect"]) {
            CGRect aValue = CGRectFromString(JSONValue);
            ((void (*)(id, SEL, CGRect))objc_msgSend)(model, property->_setter, aValue);
            return YES;
        }
        if ([name isEqualToString:@"CGSize"]) {
            CGSize aValue = CGSizeFromString(JSONValue);
            ((void (*)(id, SEL, CGSize))objc_msgSend)(model, property->_setter, aValue);
            return YES;
        }
        if ([name isEqualToString:@"CGPoint"]) {
            CGPoint aValue = CGPointFromString(JSONValue);
            ((void (*)(id, SEL, CGPoint))objc_msgSend)(model, property->_setter, aValue);
            return YES;
        }
        if ([name isEqualToString:@"UIEdgeInsets"]) {
            UIEdgeInsets aValue = UIEdgeInsetsFromString(JSONValue);
            ((void (*)(id, SEL, UIEdgeInsets))objc_msgSend)(model, property->_setter, aValue);
            return YES;
        }
        if ([name isEqualToString:@"CGVector"]) {
            CGVector aValue = CGVectorFromString(JSONValue);
            ((void (*)(id, SEL, CGVector))objc_msgSend)(model, property->_setter, aValue);
            return YES;
        }
        if ([name isEqualToString:@"CGAffineTransform"]) {
            CGAffineTransform aValue = CGAffineTransformFromString(JSONValue);
            ((void (*)(id, SEL, CGAffineTransform))objc_msgSend)(model, property->_setter, aValue);
            return YES;
        }
        if ([name isEqualToString:@"NSDirectionalEdgeInsets"]) {
            NSDirectionalEdgeInsets aValue = NSDirectionalEdgeInsetsFromString(JSONValue);
            ((void (*)(id, SEL, NSDirectionalEdgeInsets))objc_msgSend)(model, property->_setter, aValue);
            return YES;
        }
        if ([name isEqualToString:@"UIOffset"]) {
            UIOffset aValue = UIOffsetFromString(JSONValue);
            ((void (*)(id, SEL, UIOffset))objc_msgSend)(model, property->_setter, aValue);
            return YES;
        }
    }
    return NO;
}

NSString * _Nullable XZJSONModelEncodeStructProperty(id model, XZJSONPropertyDescriptor *property) {
    NSString *name = property->_property.type.name;
    if ([name isEqualToString:@"CGRect"]) {
        CGRect aValue = ((CGRect (*)(id, SEL))objc_msgSend)(model, property->_getter);
        return NSStringFromCGRect(aValue);
    }
    if ([name isEqualToString:@"CGSize"]) {
        CGSize aValue = ((CGSize (*)(id, SEL))objc_msgSend)(model, property->_getter);
        return NSStringFromCGSize(aValue);
    }
    if ([name isEqualToString:@"CGPoint"]) {
        CGPoint aValue = ((CGPoint (*)(id, SEL))objc_msgSend)(model, property->_getter);
        return NSStringFromCGPoint(aValue);
    }
    if ([name isEqualToString:@"UIEdgeInsets"]) {
        UIEdgeInsets aValue = ((UIEdgeInsets (*)(id, SEL))objc_msgSend)(model, property->_getter);
        return NSStringFromUIEdgeInsets(aValue);
    }
    if ([name isEqualToString:@"CGVector"]) {
        CGVector aValue = ((CGVector (*)(id, SEL))objc_msgSend)(model, property->_getter);
        return NSStringFromCGVector(aValue);
    }
    if ([name isEqualToString:@"CGAffineTransform"]) {
        CGAffineTransform aValue = ((CGAffineTransform (*)(id, SEL))objc_msgSend)(model, property->_getter);
        return NSStringFromCGAffineTransform(aValue);
    }
    if ([name isEqualToString:@"NSDirectionalEdgeInsets"]) {
        NSDirectionalEdgeInsets aValue = ((NSDirectionalEdgeInsets (*)(id, SEL))objc_msgSend)(model, property->_getter);
        return NSStringFromDirectionalEdgeInsets(aValue);
    }
    if ([name isEqualToString:@"UIOffset"]) {
        UIOffset aValue = ((UIOffset (*)(id, SEL))objc_msgSend)(model, property->_getter);
        return NSStringFromUIOffset(aValue);
    }
    return nil;
}

#pragma mark - NSDescription

NSString * _Nonnull XZJSONModelDescriptionOfClassType(id model, XZJSONClassType const classType, NSUInteger hierarchies) {
    switch (classType) {
        case XZJSONClassTypeNSString:
        case XZJSONClassTypeNSMutableString: {
            NSString *aString = model;
            aString = [aString stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
            return [NSString stringWithFormat:@"\"%@\"", aString];
        }
        case XZJSONClassTypeNSValue:
        case XZJSONClassTypeNSData:
        case XZJSONClassTypeNSMutableData: {
            NSString *tmp = [model description];
            if (tmp.length > 50) {
                tmp = [tmp substringToIndex:50];
                tmp = [tmp stringByAppendingString:@"..."];
            }
            return tmp;
        }
        case XZJSONClassTypeNSNumber:
        case XZJSONClassTypeNSDecimalNumber:
        case XZJSONClassTypeNSDate:
        case XZJSONClassTypeNSURL: {
            return [NSString stringWithFormat:@"%@", model];
        }
        case XZJSONClassTypeNSSet:
        case XZJSONClassTypeNSMutableSet: {
            model = ((NSSet *)model).allObjects;
        }
        case XZJSONClassTypeNSArray:
        case XZJSONClassTypeNSMutableArray: {
            NSArray *  const array = (id)model;
            NSUInteger const count = array.count;
            if (count == 0) {
                return @"[]";
            }
            NSString * const padding = [@"" stringByPaddingToLength:hierarchies * 4 withString:@" " startingAtIndex:0];
            hierarchies += 1;
            
            NSMutableString *desc = [NSMutableString stringWithString:@"[\n"];
            for (id obj in (NSArray *)array) {
                [desc appendFormat:@"%@    %@,\n", padding, XZJSONModelDescription(obj, hierarchies)];
            }
            [desc deleteCharactersInRange:NSMakeRange(desc.length - 2, 1)];
            [desc appendFormat:@"%@]", padding];
            
            return desc;
        }
            
        case XZJSONClassTypeNSDictionary:
        case XZJSONClassTypeNSMutableDictionary: {
            NSDictionary * const dict  = (id)model;
            NSUInteger     const count = dict.count;
            if (count == 0) {
                return @"{}";
            }
            NSString * const padding = [@"" stringByPaddingToLength:hierarchies * 4 withString:@" " startingAtIndex:0];
            hierarchies += 1;
            
            NSMutableString *desc = [NSMutableString stringWithString:@"{\n"];
            [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                key = [key description];
                obj = XZJSONModelDescription(obj, hierarchies);
                [desc appendFormat:@"%@    %@: %@,\n", padding, key, obj];
            }];
            [desc deleteCharactersInRange:NSMakeRange(desc.length - 2, 1)];
            [desc appendFormat:@"%@}", padding];
            
            return desc;
        }
        case XZJSONClassTypeUnknown:
            return @"<unknown>";
    }
}

NSString * _Nonnull XZJSONModelDescription(NSObject *_Nonnull model, NSUInteger hierarchies) {
    if (!model) {
        return @"<nil>";
    }

    if (model == (id)kCFNull) {
        return @"<null>";
    }

    if (![model isKindOfClass:[NSObject class]]) {
        return [NSString stringWithFormat:@"%@", model];
    }

    XZJSONClassDescriptor * const modelClass = [XZJSONClassDescriptor descriptorForClass:model.class];

    if (modelClass->_classType) {
        return XZJSONModelDescriptionOfClassType(model, modelClass->_classType, hierarchies);
    }
    
    if (modelClass->_properties.count == 0) {
        return [NSString stringWithFormat:@"<%@: %p>", model.class, model];
    }
    NSString * const padding = [@"" stringByPaddingToLength:hierarchies * 4 withString:@" " startingAtIndex:0];
    hierarchies += 1;
    
    NSMutableString *desc = [NSMutableString stringWithFormat:@"<%@: %p, properties: {\n", model.class, model];
    [modelClass->_properties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor * _Nonnull property, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = property->_name;
        NSString *value = nil;
        switch (property->_type) {
            case XZObjcTypeBool: {
                BOOL const aValue = ((BOOL (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = aValue ? @"true" : @"false";
            }
            case XZObjcTypeChar: {
                char const aValue = ((char (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%c", aValue];
            }
            case XZObjcTypeUnsignedChar: {
                unsigned char const aValue = ((unsigned char (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%c", aValue];
            }
            case XZObjcTypeShort: {
                short const aValue = ((short (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%d", aValue];
            }
            case XZObjcTypeUnsignedShort: {
                unsigned short const aValue = ((unsigned short (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%u", aValue];
            }
            case XZObjcTypeInt: {
                int const aValue = ((int (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%d", aValue];
            }
            case XZObjcTypeUnsignedInt: {
                unsigned int const aValue = ((unsigned int (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%u", aValue];
            }
            case XZObjcTypeLong: {
                long const aValue = ((long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%ld", aValue];
            }
            case XZObjcTypeUnsignedLong: {
                unsigned long const aValue = ((unsigned long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%lu", aValue];
            }
            case XZObjcTypeFloat: {
                float const aValue = ((float (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%G", aValue];
            }
            case XZObjcTypeDouble: {
                double const aValue = ((double (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%G", aValue];
            }
            case XZObjcTypeLongDouble: {
                long double const aValue = ((long double (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%LG", aValue];
                break;
            }
            case XZObjcTypeLongLong: {
                long long const aValue = ((long long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%lld", aValue];
                break;
            }
            case XZObjcTypeUnsignedLongLong: {
                unsigned long long const aValue = ((unsigned long long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%lld", aValue];
                break;
            }
            case XZObjcTypeObject: {
                value = ((XZJSONGetter)objc_msgSend)((id)model, property->_getter);
                
                if (property->_isUnownedReferenceProperty) {
                    value = [NSString stringWithFormat:@"<%@: %p>", value.class, value];
                } else if (property->_classType) {
                    value = XZJSONModelDescriptionOfClassType(value, property->_classType, hierarchies);
                } else {
                    value = XZJSONModelDescription(value, hierarchies);
                }
                break;
            }
            case XZObjcTypeClass: {
                value = ((XZJSONGetter)objc_msgSend)((id)model, property->_getter);
                value = [NSString stringWithFormat:@"<class: %@>", value ?: @"Nil"];
                break;
            }
            case XZObjcTypeSEL: {
                SEL sel = ((SEL (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                value = [NSString stringWithFormat:@"<selector: %@>", sel ? NSStringFromSelector(sel) : @"nil"];
                break;
            }
            case XZObjcTypeArray: {
                NSString *desc = nil;
                if (modelClass->_usesPropertyJSONEncodingMethod) {
                    desc = [NSString stringWithFormat:@"%@", [(id<XZJSONCoding>)model JSONEncodeValueForKey:key]];
                } else {
                    void *pointer = ((void *(*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                    desc = [NSString stringWithFormat:@"%p", pointer];
                }
                value = [NSString stringWithFormat:@"<array: %@, value: %@>", property->_property.type.name, desc];
                break;
            }
            case XZObjcTypeString: {
                NSString *desc = nil;
                if (modelClass->_usesPropertyJSONEncodingMethod) {
                    desc = [NSString stringWithFormat:@"%@", [(id<XZJSONCoding>)model JSONEncodeValueForKey:key]];
                } else {
                    void *pointer = ((void *(*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                    desc = [NSString stringWithFormat:@"%p", pointer];
                }
                value = [NSString stringWithFormat:@"<string: %@, value: %@>", property->_property.type.name, desc];
                break;
            }
            case XZObjcTypePointer: {
                NSString *desc = nil;
                if (modelClass->_usesPropertyJSONEncodingMethod) {
                    desc = [NSString stringWithFormat:@"%@", [(id<XZJSONCoding>)model JSONEncodeValueForKey:key]];
                } else {
                    void *pointer = ((void *(*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                    desc = [NSString stringWithFormat:@"%p", pointer];
                }
                value = [NSString stringWithFormat:@"<pointer: %@, value: %@>", property->_property.type.name, desc];
                break;
            }
            case XZObjcTypeStruct: {
                value = XZJSONModelEncodeStructProperty(model, property);
                if (value == nil && modelClass->_usesPropertyJSONEncodingMethod) {
                    value = [NSString stringWithFormat:@"%@", [(id<XZJSONCoding>)model JSONEncodeValueForKey:key]];
                }
                if (value) {
                    value = [NSString stringWithFormat:@"<struct: %@, value: %@>", property->_property.type.name, value];
                } else {
                    value = [NSString stringWithFormat:@"<struct: %@>", property->_property.type.name];
                }
                break;
            }
            case XZObjcTypeUnion: {
                if (modelClass->_usesPropertyJSONEncodingMethod) {
                    NSString * const name = property->_property.type.name;
                    value = [NSString stringWithFormat:@"<union: %@, value: %@>", name, [(id<XZJSONCoding>)model JSONEncodeValueForKey:key]];
                } else {
                    value = [NSString stringWithFormat:@"<union: %@>", property->_property.type.name];
                }
                break;
            }
            case XZObjcTypeVoid: {
                if (modelClass->_usesPropertyJSONEncodingMethod) {
                    value = [NSString stringWithFormat:@"<void: %@>", [(id<XZJSONCoding>)model JSONEncodeValueForKey:key]];
                } else {
                    value = @"<void>";
                }
                break;
            }
            case XZObjcTypeBitField: {
                if (modelClass->_usesPropertyJSONEncodingMethod) {
                    value = [NSString stringWithFormat:@"<BitField: %@>", [(id<XZJSONCoding>)model JSONEncodeValueForKey:key]];
                } else {
                    value = [NSString stringWithFormat:@"<BitField: %ld bit>", (long)property->_property.type.sizeInBit];
                }
                break;
            }
            case XZObjcTypeUnknown: {
                if (modelClass->_usesPropertyJSONEncodingMethod) {
                    value = [NSString stringWithFormat:@"<unknown: %@>", [(id<XZJSONCoding>)model JSONEncodeValueForKey:key]];
                } else {
                    value = @"<unknown>";
                }
                break;
            }
        }
        [desc appendFormat:@"%@    %@: %@,\n", padding, key, value];
    }];
    [desc deleteCharactersInRange:NSMakeRange(desc.length - 2, 1)];
    [desc appendFormat:@"%@}>", padding];
    return desc;
}

#pragma mark - NSCoding

static inline BOOL NSCollectionConformsNSCoding(id<NSFastEnumeration> sequence) {
    for (id object in sequence) {
        if (![object conformsToProtocol:@protocol(NSCoding)]) {
            return NO;
        }
    }
    return YES;
}

static inline BOOL NSCollectionTestElementClass(id<NSFastEnumeration> sequence, Class Element) {
    for (id object in sequence) {
        if (![object isKindOfClass:Element]) {
            return NO;
        }
    }
    return YES;
}

static inline BOOL NSDictionaryConformsNSCoding(NSDictionary *dictionary) {
    BOOL __block conforms = YES;
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![key conformsToProtocol:@protocol(NSCoding)] || ![obj conformsToProtocol:@protocol(NSCoding)]) {
            conforms = NO;
            *stop = YES;
        }
    }];
    return conforms;
}

static inline BOOL NSDictionaryTestElementClass(NSDictionary *dictionary, Class Element) {
    BOOL __block isKindOfClass = YES;
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isKindOfClass:NSString.class] || [key isKindOfClass:NSNumber.class]) {
            if ([obj isKindOfClass:Element]) {
                return;
            }
        }
        isKindOfClass = NO;
        *stop = YES;
    }];
    return isKindOfClass;
}

void XZJSONModelEncodeWithCoder(id model, NSCoder *aCoder) {
    if (!model || !aCoder) {
        return;
    }
    
    if (model == (id)kCFNull) {
        [((id<NSCoding>)model) encodeWithCoder:aCoder];
        return;
    }
    
    XZJSONClassDescriptor * const modelClass = [XZJSONClassDescriptor descriptorForClass:[model class]];
    
    switch (modelClass->_classType) {
        case XZJSONClassTypeNSString:
        case XZJSONClassTypeNSMutableString:
        case XZJSONClassTypeNSValue:
        case XZJSONClassTypeNSNumber:
        case XZJSONClassTypeNSDecimalNumber:
        case XZJSONClassTypeNSData:
        case XZJSONClassTypeNSMutableData:
        case XZJSONClassTypeNSDate:
        case XZJSONClassTypeNSURL: {
            [(id<NSCoding>)model encodeWithCoder:aCoder];
            break;
        }
        case XZJSONClassTypeNSArray:
        case XZJSONClassTypeNSMutableArray:
        case XZJSONClassTypeNSSet:
        case XZJSONClassTypeNSMutableSet: {
            if (NSCollectionConformsNSCoding(model)) {
                [(id<NSCoding>)model encodeWithCoder:aCoder];
            }
            break;
        }
        case XZJSONClassTypeNSDictionary:
        case XZJSONClassTypeNSMutableDictionary: {
            if (NSDictionaryConformsNSCoding(model)) {
                [(id<NSCoding>)model encodeWithCoder:aCoder];
            }
            break;
        }
        case XZJSONClassTypeUnknown: {
            [modelClass->_properties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor *property, NSUInteger idx, BOOL *stop) {
                SEL        const getter = property->_getter;
                NSString * const name   = property->_name;
                switch (property->_type) {
                    case XZObjcTypeUnknown:
                    case XZObjcTypeVoid:
                    case XZObjcTypeString:
                    case XZObjcTypeArray:
                    case XZObjcTypeBitField:
                    case XZObjcTypePointer:
                    case XZObjcTypeUnion: {
                        // 无法编码
                        break;
                    }
                    case XZObjcTypeChar: {
                        char const aValue = ((char (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeInt:aValue forKey:name];
                        return;
                    }
                    case XZObjcTypeUnsignedChar: {
                        unsigned char const aValue = ((unsigned char (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeInt:aValue forKey:name];
                        return;
                    }
                    case XZObjcTypeInt: {
                        int const aValue = ((int (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeInt:aValue forKey:name];
                        return;
                    }
                    case XZObjcTypeUnsignedInt: {
                        unsigned int const aValue = ((unsigned int (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeInt:aValue forKey:name];
                        return;
                    }
                    case XZObjcTypeShort: {
                        short const aValue = ((short (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeInt:aValue forKey:name];
                        return;
                    }
                    case XZObjcTypeUnsignedShort: {
                        unsigned short const aValue = ((unsigned short (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeInt:aValue forKey:name];
                        return;
                    }
                    case XZObjcTypeLong: {
                        long const aValue = ((long (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeInt64:aValue forKey:name];
                        return;
                    }
                    case XZObjcTypeUnsignedLong: {
                        unsigned long const aValue = ((unsigned long (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeInt64:aValue forKey:name];
                        return;
                    }
                    case XZObjcTypeLongLong: {
                        long long const aValue = ((long long (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeInt64:aValue forKey:name];
                        return;
                    }
                    case XZObjcTypeUnsignedLongLong: {
                        unsigned long long const aValue = ((unsigned long long (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeInt64:aValue forKey:name];
                        return;
                    }
                    case XZObjcTypeFloat: {
                        float const aValue = ((float (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeFloat:aValue forKey:name];
                        break;
                    }
                    case XZObjcTypeDouble: {
                        double const aValue = ((double (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeDouble:aValue forKey:name];
                        return;
                    }
                    case XZObjcTypeLongDouble: {
                        long double const aValue = ((long double (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeBytes:(const uint8_t *)&aValue length:sizeof(long double) forKey:name];
                        return;
                    }
                    case XZObjcTypeBool: {
                        BOOL const aValue = ((BOOL (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeBool:aValue forKey:name];
                        return;
                    }
                    case XZObjcTypeStruct: {
                        NSString * const aValue = XZJSONModelEncodeStructProperty(model, property);
                        if (aValue) {
                            [aCoder encodeObject:aValue forKey:name];
                            return;
                        }
                        break;
                    }
                    case XZObjcTypeClass: {
                        Class const aValue = ((Class (*)(id, SEL))objc_msgSend)(model, getter);
                        NSString *className = NSStringFromClass(aValue);
                        [aCoder encodeObject:className forKey:name];
                        return;
                    }
                    case XZObjcTypeSEL: {
                        SEL const aValue = ((SEL (*)(id, SEL))objc_msgSend)(model, getter);
                        NSString *selectorName = NSStringFromSelector(aValue);
                        [aCoder encodeObject:selectorName forKey:name];
                        return;
                    }
                    case XZObjcTypeObject: {
                        id const aValue = ((id (*)(id, SEL))objc_msgSend)(model, getter);
                        if (!aValue) {
                            return;
                        }
                        
                        // 安全归档
                        if (aCoder.requiresSecureCoding) {
                            // 无法确定类型，不能安全归档
                            if (!property->_subtype) {
                                break;
                            }
                            // 类型不支持安全归档
                            if (![property->_subtype conformsToProtocol:@protocol(NSSecureCoding)]) {
                                break;
                            }
                            // 如果是集合类型，需要进一步判断元素
                            switch (property->_classType) {
                                case XZJSONClassTypeNSArray:
                                case XZJSONClassTypeNSMutableArray:
                                case XZJSONClassTypeNSSet:
                                case XZJSONClassTypeNSMutableSet: {
                                    // 无法确定元素类型，无法进行安全归档
                                    if (!property->_elementType) {
                                        break;
                                    }
                                    // 元素类型不支持安全归档
                                    if (![property->_elementType conformsToProtocol:@protocol(NSSecureCoding)]) {
                                        break;
                                    }
                                    // 检查元素是否合法：元素必须是已知类型，否则无法解档
                                    if (!NSCollectionTestElementClass(aValue, property->_elementType)) {
                                        break;
                                    }
                                    // 执行归档
                                    [aCoder encodeObject:aValue forKey:name];
                                    return;
                                }
                                case XZJSONClassTypeNSDictionary:
                                case XZJSONClassTypeNSMutableDictionary: {
                                    // 没有元素类型，无法进行编码
                                    if (!property->_elementType) {
                                        break;
                                    }
                                    // 元素类型不支持安全归档
                                    if (![property->_elementType conformsToProtocol:@protocol(NSSecureCoding)]) {
                                        break;
                                    }
                                    // 检查元素是否合法：字典键值，都必须支持已知，且支持安全归档。目前仅支持以 NSString/NSNumber 作为 key 的字典。
                                    if (!NSDictionaryTestElementClass(aValue, property->_elementType)) {
                                        break;
                                    }
                                    // 执行归档
                                    [aCoder encodeObject:aValue forKey:name];
                                    return;
                                }
                                case XZJSONClassTypeNSString:
                                case XZJSONClassTypeNSMutableString:
                                case XZJSONClassTypeNSValue:
                                case XZJSONClassTypeNSNumber:
                                case XZJSONClassTypeNSDecimalNumber:
                                case XZJSONClassTypeNSData:
                                case XZJSONClassTypeNSMutableData:
                                case XZJSONClassTypeNSDate:
                                case XZJSONClassTypeNSURL:
                                case XZJSONClassTypeUnknown: {
                                    // 执行归档：支持安全归档的已知普通类型
                                    [aCoder encodeObject:aValue forKey:name];
                                    return;
                                }
                            }
                            break;
                        }
                        
                        // 普通归档，仅需要支持归档协议即可
                        if (![property->_subtype conformsToProtocol:@protocol(NSCoding)]) {
                            break;
                        }
                        switch (property->_classType) {
                            case XZJSONClassTypeNSArray:
                            case XZJSONClassTypeNSMutableArray:
                            case XZJSONClassTypeNSSet:
                            case XZJSONClassTypeNSMutableSet: {
                                // 检查元素是否合法：元素只要支持归档即可。
                                if (NSCollectionConformsNSCoding(model)) {
                                    [aCoder encodeObject:model forKey:name];
                                    return;
                                }
                                break;
                            }
                            case XZJSONClassTypeNSDictionary:
                            case XZJSONClassTypeNSMutableDictionary: {
                                // 检查元素是否合法：元素只需要支持归档即可
                                if (NSDictionaryConformsNSCoding(model)) {
                                    [aCoder encodeObject:model forKey:name];
                                    return;
                                }
                                break;
                            }
                            case XZJSONClassTypeNSString:
                            case XZJSONClassTypeNSMutableString:
                            case XZJSONClassTypeNSValue:
                            case XZJSONClassTypeNSNumber:
                            case XZJSONClassTypeNSDecimalNumber:
                            case XZJSONClassTypeNSData:
                            case XZJSONClassTypeNSMutableData:
                            case XZJSONClassTypeNSDate:
                            case XZJSONClassTypeNSURL:
                            case XZJSONClassTypeUnknown: {
                                [aCoder encodeObject:model forKey:name];
                                break;
                            }
                        }
                        break;
                    }
                }
                
                // 不能处理的属性
                if (property->_class->_usesPropertyJSONEncodingMethod) {
                    id<NSCoding> aValue = [((id<XZJSONCoding>)model) JSONEncodeValueForKey:name];
                    if (aValue) {
                        [aCoder encodeObject:aValue forKey:name];
                    }
                } else {
                    NSLog(@"[XZJSON] [NSCoding] Can not encode property `%@` of `%@`!", modelClass->_class.name, property->_name);
                }
            }];
            break;
        }
    }
}

id _Nullable XZJSONModelDecodeWithCoder(id model, NSCoder *aCoder) {
    if (!model || !aCoder) {
        return model;
    }
    
    if (model == (id)kCFNull) {
        return model;
    }
    
    XZJSONClassDescriptor * const modelClass = [XZJSONClassDescriptor descriptorForClass:[model class]];
    switch (modelClass->_classType) {
        case XZJSONClassTypeNSString:
        case XZJSONClassTypeNSMutableString:
        case XZJSONClassTypeNSValue:
        case XZJSONClassTypeNSNumber:
        case XZJSONClassTypeNSDecimalNumber:
        case XZJSONClassTypeNSData:
        case XZJSONClassTypeNSMutableData:
        case XZJSONClassTypeNSDate:
        case XZJSONClassTypeNSURL: {
            return [(id<NSCoding>)model initWithCoder:aCoder];
        }
        case XZJSONClassTypeNSArray:
        case XZJSONClassTypeNSMutableArray:
        case XZJSONClassTypeNSSet:
        case XZJSONClassTypeNSMutableSet: {
            if (NSCollectionConformsNSCoding(model)) {
                return [(id<NSCoding>)model initWithCoder:aCoder];
            }
            return nil;
        }
        case XZJSONClassTypeNSDictionary:
        case XZJSONClassTypeNSMutableDictionary: {
            if (NSDictionaryConformsNSCoding(model)) {
                return [(id<NSCoding>)model initWithCoder:aCoder];
            }
            return nil;
        }
        case XZJSONClassTypeUnknown: {
            [modelClass->_properties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor *property, NSUInteger idx, BOOL *stop) {
                NSString * const name   = property->_name;
                SEL        const setter = property->_setter;
                
                // 无归档数据
                if (![aCoder containsValueForKey:name]) {
                    return;
                }
                
                switch (property->_type) {
                    case XZObjcTypeUnknown:
                    case XZObjcTypeVoid:
                    case XZObjcTypeString:
                    case XZObjcTypeArray:
                    case XZObjcTypeBitField:
                    case XZObjcTypePointer:
                    case XZObjcTypeUnion: {
                        // 不支持的数据类型
                        break;
                    }
                    case XZObjcTypeChar: {
                        char const aValue = [aCoder decodeIntForKey:name];
                        ((void (*)(id, SEL, char))objc_msgSend)(model, setter, aValue);
                        return;
                    }
                    case XZObjcTypeUnsignedChar: {
                        unsigned char const aValue = [aCoder decodeIntForKey:name];
                        ((void (*)(id, SEL, unsigned char))objc_msgSend)(model, setter, aValue);
                        return;
                    }
                    case XZObjcTypeInt: {
                        int const aValue = [aCoder decodeIntForKey:name];
                        ((void (*)(id, SEL, int))objc_msgSend)(model, setter, aValue);
                        return;
                    }
                    case XZObjcTypeUnsignedInt: {
                        unsigned int const aValue = [aCoder decodeIntForKey:name];
                        ((void (*)(id, SEL, unsigned int))objc_msgSend)(model, setter, aValue);
                        return;
                    }
                    case XZObjcTypeShort: {
                        short const aValue = [aCoder decodeIntForKey:name];
                        ((void (*)(id, SEL, short))objc_msgSend)(model, setter, aValue);
                        return;
                    }
                    case XZObjcTypeUnsignedShort: {
                        unsigned short const aValue = [aCoder decodeIntForKey:name];
                        ((void (*)(id, SEL, unsigned short))objc_msgSend)(model, setter, aValue);
                        return;
                    }
                    case XZObjcTypeLong: {
                        long const aValue = [aCoder decodeInt64ForKey:name];
                        ((void (*)(id, SEL, long))objc_msgSend)(model, setter, aValue);
                        return;
                    }
                    case XZObjcTypeUnsignedLong: {
                        unsigned long const aValue = [aCoder decodeInt64ForKey:name];
                        ((void (*)(id, SEL, unsigned long))objc_msgSend)(model, setter, aValue);
                        return;
                    }
                    case XZObjcTypeLongLong: {
                        long long const aValue = [aCoder decodeInt64ForKey:name];
                        ((void (*)(id, SEL, long long))objc_msgSend)(model, setter, aValue);
                        return;
                    }
                    case XZObjcTypeUnsignedLongLong: {
                        unsigned long long const aValue = [aCoder decodeInt64ForKey:name];
                        ((void (*)(id, SEL, unsigned long long))objc_msgSend)(model, setter, aValue);
                        return;
                    }
                    case XZObjcTypeFloat: {
                        float const aValue = [aCoder decodeFloatForKey:name];
                        ((void (*)(id, SEL, float))objc_msgSend)(model, setter, aValue);
                        return;
                    }
                    case XZObjcTypeDouble: {
                        double const aValue = [aCoder decodeDoubleForKey:name];
                        ((void (*)(id, SEL, double))objc_msgSend)(model, setter, aValue);
                        [aCoder encodeDouble:aValue forKey:name];
                        return;
                    }
                    case XZObjcTypeLongDouble: {
                        long double *aValue = (long double *)[aCoder decodeBytesForKey:name returnedLength:nil];
                        ((void (*)(id, SEL, long double))objc_msgSend)(model, setter, *aValue);
                        return;
                    }
                    case XZObjcTypeBool: {
                        BOOL const aValue = [aCoder decodeBoolForKey:name];
                        ((void (*)(id, SEL, BOOL))objc_msgSend)(model, setter, aValue);
                        return;
                    }
                    case XZObjcTypeStruct: {
                        id aValue = nil;
                        if (aCoder.requiresSecureCoding) {
                            aValue = [aCoder decodeObjectOfClass:NSString.class forKey:name];
                        } else {
                            aValue = [aCoder decodeObjectForKey:name];
                        }
                        if (!aValue) {
                            break;
                        }
                        if (XZJSONModelDecodeStructProperty(model, property, aValue)) {
                            return;
                        }
                        break;
                    }
                    case XZObjcTypeClass: {
                        id aValue = nil;
                        if (aCoder.requiresSecureCoding) {
                            aValue = [aCoder decodeObjectOfClass:NSString.class forKey:name];
                        } else {
                            aValue = [aCoder decodeObjectForKey:name];
                        }
                        if (!aValue) {
                            break;
                        }
                        if ([aValue isKindOfClass:NSString.class]) {
                            Class const aClass = NSClassFromString((NSString *)aValue);
                            if (aClass) {
                                ((void (*)(id, SEL, Class))objc_msgSend)(model, setter, aClass);
                                return;
                            }
                        }
                        break;
                    }
                    case XZObjcTypeSEL: {
                        id aValue = nil;
                        if (aCoder.requiresSecureCoding) {
                            aValue = [aCoder decodeObjectOfClass:NSString.class forKey:name];
                        } else {
                            aValue = [aCoder decodeObjectForKey:name];
                        }
                        if (!aValue) {
                            break;
                        }
                        if ([aValue isKindOfClass:NSString.class]) {
                            SEL const aSelector = NSSelectorFromString((NSString *)aValue);
                            if (aSelector) {
                                ((void (*)(id, SEL, SEL))objc_msgSend)(model, setter, aSelector);
                                return;
                            }
                        }
                        break;
                    }
                    case XZObjcTypeObject: {
                        // 安全解档
                        if (aCoder.requiresSecureCoding) {
                            // 未知类型，无法安全解档
                            if (!property->_subtype) {
                                break;
                            }
                            // 类型不支持安全解档
                            if (![property->_subtype conformsToProtocol:@protocol(NSSecureCoding)]) {
                                break;
                            }
                            // 集合类型的元素也需要支持安全解档
                            switch (property->_classType) {
                                case XZJSONClassTypeNSArray:
                                case XZJSONClassTypeNSMutableArray:
                                case XZJSONClassTypeNSSet:
                                case XZJSONClassTypeNSMutableSet: {
                                    // 元素类型未知，无法安全解档
                                    if (!property->_elementType) {
                                        break;
                                    }
                                    // 元素类型不支持安全解档
                                    if (![property->_elementType conformsToProtocol:@protocol(NSSecureCoding)]) {
                                        break;
                                    }
                                    NSSet * const classes = [NSSet setWithObjects:property->_subtype, property->_elementType, nil];
                                    id const aValue = [aCoder decodeObjectOfClasses:classes forKey:name];
                                    if (aValue) {
                                        ((void (*)(id, SEL, id))objc_msgSend)(model, setter, aValue);
                                        return;
                                    }
                                    break;
                                }
                                case XZJSONClassTypeNSDictionary:
                                case XZJSONClassTypeNSMutableDictionary: {
                                    // 元素类型未知，无法安全解档
                                    if (!property->_elementType) {
                                        break;
                                    }
                                    // 元素类型不支持安全解档
                                    if (![property->_elementType conformsToProtocol:@protocol(NSSecureCoding)]) {
                                        break;
                                    }
                                    NSSet * const classes = [NSSet setWithObjects:[NSString class], [NSNumber class], property->_subtype, property->_elementType, nil];
                                    id const aValue = [aCoder decodeObjectOfClasses:classes forKey:name];
                                    if (aValue) {
                                        ((void (*)(id, SEL, id))objc_msgSend)(model, setter, aValue);
                                        return;
                                    }
                                    break;
                                }
                                default: {
                                    id aValue = [aCoder decodeObjectOfClass:property->_subtype forKey:name];
                                    if (aValue) {
                                        ((void (*)(id, SEL, id))objc_msgSend)(model, setter, aValue);
                                        return;
                                    }
                                    break;
                                }
                            }
                            break;
                        }
                        
                        // 普通解档
                        id const aValue = [aCoder decodeObjectForKey:name];
                        if (aValue) {
                            ((void (*)(id, SEL, id))objc_msgSend)(model, setter, aValue);
                            return;
                        }
                        break;
                    }
                }
                
                if ([aCoder containsValueForKey:name] && modelClass->_usesPropertyJSONDecodingMethod) {
                    [((id<XZJSONCoding>)model) JSONDecodeValue:aCoder forKey:name];
                } else {
                    NSLog(@"[XZJSON] Can not decode property `%@` of `%@`!", modelClass->_class.name, property->_name);
                }
            }];
            break;
        }
    }
    
    return model;
}
