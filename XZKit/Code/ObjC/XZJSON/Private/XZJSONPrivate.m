//
//  XZJSONPrivate.m
//  XZJSON
//
//  Created by Xezun on 2024/12/3.
//

#import "XZJSONPrivate.h"

/// 读取 JOSN 字典的 keyPath 对应的值。
/// - Parameters:
///   - dict: JSON 字典
///   - keyPath: 已分隔为数组的键路径
static id _Nullable XZJSONDictionaryValueForKeyPath(__unsafe_unretained NSDictionary *_Nonnull dict, __unsafe_unretained NSArray<NSString *> * _Nonnull keyPath);

/// 读取 JOSN 字典的 keyArray 第一个有效值。
/// - Parameters:
///   - dict: JSON 字典
///   - keyArray: 由“键”、“已分隔为数组的键路径”组成的数组
static id _Nullable XZJSONDictionaryValueForKeyArray(__unsafe_unretained NSDictionary *_Nonnull dict, __unsafe_unretained NSArray *_Nonnull keyArray);

/// 读取 JSON 字典中 keyPath 中最后一个 key 所在的字典，如果中间值不存在，则创建。
/// - Parameters:
///   - dictionary: JSON 字典
///   - keyPath: 键路径
static NSMutableDictionary * _Nullable XZJSONDictionaryForLastKeyInKeyPath(NSMutableDictionary *dictionary, NSArray<NSString *> *keyPath);

/// 将 JSON 值转换为 NSNumber 值。
/// - Parameter JSONValue: JSON 值
static NSNumber        * _Nullable NSNumberFromJSONValue(id _Nonnull JSONValue);

/// 将 JSON 值转换为 NSDecimalNumber 值。
/// - Parameter value: JSON 值
static NSDecimalNumber * _Nullable NSDecimalNumberFromJSONValue(id _Nonnull JSONValue);

/// 将 JSON 值 value 转换为 NSDate 对象。
/// - Parameter JSONValue: JSON 值
static NSDate          * _Nullable NSDateFromJSONValue(id _Nonnull JSONValue);

/// 将 JSON 值转换为 NSString 值。
/// - Parameter value: JSON 值
static NSString        * _Nullable NSStringFromJSONValue(id _Nullable JSONValue);

/// 将 JSON 值转换为 NSData 值。
/// - Parameter JSONValue: JSON 值
static NSData          * _Nullable NSDataFromJSONValue(id _Nullable JSONValue);

static NSArray         * _Nullable NSArrayFromJSONValue(id _Nonnull const JSONValue, Class _Nullable const elementClass);
static NSDictionary    * _Nullable NSDictionaryFromJSONValue(id _Nonnull const JSONValue, Class _Nullable const elementClass);
static NSSet           * _Nullable NSSetFromJSONValue(id _Nonnull const JSONValue, Class _Nullable const elementClass);

/// 将模型结构体属性编码为字符串，仅针对已知的原生结构体。
/// - Parameters:
///   - model: 模型
///   - property: 属性
static NSString        * _Nullable XZJSONModelEncodeStructProperty(id model, XZJSONPropertyDescriptor *property);

@implementation XZJSON (XZJSONDecodingPrivate)

+ (nullable id)_decodeData:(nonnull NSData *)data options:(NSJSONReadingOptions)options class:(Class)aClass {
    NSError *error = nil;
    id const object = [NSJSONSerialization JSONObjectWithData:data options:options error:&error];
    if ((error == nil || error.code == noErr) && object != nil) {
        return [self _decodeObject:object class:aClass];
    }
    return nil;
}

+ (nullable id)_decodeObject:(nonnull id const)object class:(Class)aClass {
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
        if (descriptor->_usesJSONDecodingMethod) {
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
            id const model = [self _decodeObject:item class:aClass];
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
                XZJSONModelDecodePropertyFromValue(model, property, value);
                property = property->_next;
            }
        }];
        
        [descriptor->_keyPathProperties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor *property, NSUInteger idx, BOOL *stop) {
            NSArray<NSString *> *keyPath = property->_JSONKeyPath;
            id JSONValue = XZJSONDictionaryValueForKeyPath(dictionary, keyPath);
            if (JSONValue) {
                XZJSONModelDecodePropertyFromValue(model, property, JSONValue);
            }
        }];
        
        [descriptor->_keyArrayProperties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor *property, NSUInteger idx, BOOL *stop) {
            NSArray *keyArray = property->_JSONKeyArray;
            id JSONValue = XZJSONDictionaryValueForKeyArray(dictionary, keyArray);
            if (JSONValue) {
                XZJSONModelDecodePropertyFromValue(model, property, JSONValue);
            }
        }];
    } else {
        [descriptor->_properties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor *property, NSUInteger idx, BOOL *stop) {
            id JSONValue = nil;
            if (property->_JSONKeyArray) {
                JSONValue = XZJSONDictionaryValueForKeyArray(dictionary, property->_JSONKeyArray);
            } else if (property->_JSONKeyPath) {
                JSONValue = XZJSONDictionaryValueForKeyPath(dictionary, property->_JSONKeyPath);
            } else {
                JSONValue = dictionary[property->_JSONKey];
            }
            if (JSONValue) {
                XZJSONModelDecodePropertyFromValue(model, property, JSONValue);
            }
        }];
    }
}

@end

@implementation XZJSON (XZJSONEncodingPrivate)

+ (NSArray *)_encodeArray:(nonnull NSArray *)array {
    if ([NSJSONSerialization isValidJSONObject:array]) {
        return array;
    }
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:array.count];
    for (id obj in array) {
        XZJSONClassDescriptor *descriptor = [XZJSONClassDescriptor descriptorForClass:[obj class]];
        id const jsonObj = [self _model:obj encodeIntoDictionary:nil descriptor:descriptor];
        if (jsonObj != nil) {
            [newArray addObject:jsonObj];
        }
    }
    return newArray;
}

+ (id)_model:(id)model encodeIntoDictionary:(nullable NSMutableDictionary *)dictionary descriptor:(XZJSONClassDescriptor *)descriptor {
    switch (descriptor->_classType) {
        case XZJSONClassTypeNSString:
        case XZJSONClassTypeNSMutableString: {
            return model;
        }
        case XZJSONClassTypeNSValue: {
            return nil;
        }
        case XZJSONClassTypeNSNumber: {
            return model;
        }
        case XZJSONClassTypeNSDecimalNumber: {
            return [(NSDecimalNumber *)model stringValue];
        }
        case XZJSONClassTypeNSData:
        case XZJSONClassTypeNSMutableData: {
            return [(NSData *)model base64EncodedDataWithOptions:kNilOptions];
        }
        case XZJSONClassTypeNSDate: {
            return @([(NSDate *)model timeIntervalSince1970]);
        }
        case XZJSONClassTypeNSURL: {
            return [(NSURL *)model absoluteString];
        }
        case XZJSONClassTypeNSArray:
        case XZJSONClassTypeNSMutableArray: {
            return [self _encodeArray:model];
        }
        case XZJSONClassTypeNSDictionary:
        case XZJSONClassTypeNSMutableDictionary: {
            if ([NSJSONSerialization isValidJSONObject:model]) {
                return model;
            }
            NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
            [(NSDictionary *)model enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
                NSString * const JSONKey = [key isKindOfClass:[NSString class]] ? key : key.description;
                if (!JSONKey) return;
                id const JSONValue = [self encode:obj options:kNilOptions error:nil];
                if (JSONValue != nil) {
                    dictM[JSONKey] = JSONValue;
                }
            }];
            return dictM;
        }
        case XZJSONClassTypeNSSet:
        case XZJSONClassTypeNSMutableSet: {
            return [self _encodeArray:((NSSet *)model).allObjects];
        }
        case XZJSONClassTypeUnknown: {
            if (model == (id)kCFNull) {
                return model;
            }
            
            if (dictionary == nil) {
                dictionary = [NSMutableDictionary dictionaryWithCapacity:descriptor->_numberOfProperties];
            }
            
            // 自定义序列化
            if (descriptor->_usesJSONEncodingMethod) {
                return [(id<XZJSONEncoding>)model encodeIntoJSONDictionary:dictionary];
            }
            
            // 通用序列化
            [descriptor->_keyProperties enumerateKeysAndObjectsUsingBlock:^(NSString *aKey, XZJSONPropertyDescriptor *property, BOOL *stop) {
                NSString            *key  = nil;
                NSMutableDictionary *dict = dictionary;
                
                // 先判断是否映射到 keyPath 或 keyArray
                if (property->_JSONKeyPath) {
                    dict = XZJSONDictionaryForLastKeyInKeyPath(dict, property->_JSONKeyPath);
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
                        
                        NSMutableDictionary *temp = XZJSONDictionaryForLastKeyInKeyPath(dict, aKey);
                        if (temp) {
                            dict = temp;
                            key = ((NSArray *)aKey).lastObject;
                            break;
                        }
                    }
                    if (key == nil) {
                        return;
                    }
                } else if (dictionary[property->_JSONKey]) {
                    return; // 值已存在，不覆盖。
                } else {
                    key = property->_JSONKey;
                }
                
                id JSONValue = nil;
                
                switch (property->_type) {
                    case XZObjcTypeUnknown:
                        break;
                    case XZObjcTypeChar:
                    case XZObjcTypeUnsignedChar:
                    case XZObjcTypeInt:
                    case XZObjcTypeUnsignedInt:
                    case XZObjcTypeShort:
                    case XZObjcTypeUnsignedShort:
                    case XZObjcTypeLong:
                    case XZObjcTypeUnsignedLong:
                    case XZObjcTypeLongLong:
                    case XZObjcTypeUnsignedLongLong:
                    case XZObjcTypeFloat:
                    case XZObjcTypeDouble:
                    case XZObjcTypeLongDouble:
                    case XZObjcTypeBool:
                        JSONValue = XZJSONModelEncodeScalarNumberProperty(model, property);
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
                        Class aClass = ((Class (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                        JSONValue = aClass ? NSStringFromClass(aClass) : (id)kCFNull;
                        break;
                    }
                    case XZObjcTypeSEL: {
                        SEL aSelector = ((SEL (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                        JSONValue = aSelector ? NSStringFromSelector(aSelector) : (id)kCFNull;
                        break;
                    }
                    case XZObjcTypeObject: {
                        id const value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                                                
                        if (value == nil) {
                            JSONValue = (id)kCFNull;
                        } else {
                            XZJSONClassDescriptor *descriptor = [XZJSONClassDescriptor descriptorForClass:[value class]];
                            // 如果 key 已经有值，则进行合并，不能合并则覆盖
                            NSMutableDictionary *dictionay = dict[key];
                            if (![dictionay isKindOfClass:NSMutableDictionary.class]) {
                                dictionay = [NSMutableDictionary dictionary];
                            }
                            JSONValue = [self _model:value encodeIntoDictionary:dictionary descriptor:descriptor];
                        }
                        break;
                    }
                }
                
                if (JSONValue == nil && property->_class->_usesPropertyEncodingMethod) {
                    JSONValue = [model JSONEncodeValueForKey:property->_name];
                }
                
                if (JSONValue) {
                    dict[key] = JSONValue;
                }
            }];
            
            return dictionary;
        }
    }
}

@end

typedef id _Nullable (*XZJSONGetter)(id _Nonnull, SEL _Nonnull);
typedef void         (*XZJSONSetter)(id _Nonnull, SEL _Nonnull, id _Nullable);

static id _Nullable XZJSONDictionaryValueForKeyPath(__unsafe_unretained NSDictionary *_Nonnull dict, __unsafe_unretained NSArray *_Nonnull keyPaths) {
    NSDictionary *__unsafe_unretained value = nil;

    for (NSUInteger i = 0, max = keyPaths.count - 1; i <= max; i++) {
        NSString *const key = keyPaths[i];
        value = dict[key];

        if (i == max) {
            return value;
        }

        if ([value isKindOfClass:NSDictionary.class]) {
            dict = value;
            continue;
        }

        return nil;
    }

    return value;
}

static id _Nullable XZJSONDictionaryValueForKeyArray(__unsafe_unretained NSDictionary *_Nonnull dict, __unsafe_unretained NSArray *_Nonnull keyArray) {
    id value = nil;

    for (NSString *key in keyArray) {
        if ([key isKindOfClass:[NSString class]]) {
            value = dict[key];
        } else {
            value = XZJSONDictionaryValueForKeyPath(dict, (NSArray *)key);
        }

        if (value) {
            return value;
        }
    }

    return value;
}

NSMutableDictionary *XZJSONDictionaryForLastKeyInKeyPath(NSMutableDictionary *dictionary, NSArray<NSString *> *keyPath) {
    for (NSUInteger i = 0, max = keyPath.count - 1; i < max; i++) {
        NSString * const subKey = keyPath[i];
        NSMutableDictionary *subDict = dictionary[subKey];
        if (subDict == nil) {
            subDict = [NSMutableDictionary dictionary];
            dictionary[subKey] = subDict;
        } else if (![subDict isKindOfClass:NSMutableDictionary.class]) {
            // 对应的 key 已经有其它值，不支持设置 keyPath
            return nil;
        }
        dictionary = subDict;
    }
    return dictionary;
}

static NSNumber * _Nullable NSNumberFromJSONValue(id _Nonnull JSONValue) {
    if (JSONValue == (id)kCFNull) {
        return nil;
    }

    if ([JSONValue isKindOfClass:[NSNumber class]]) {
        return JSONValue;
    }

    static NSDictionary<NSString *, NSNumber *> *_numberStrings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _numberStrings = @{
            @"TRUE": @(YES), @"FALSE": @(NO), @"NIL":  (id)kCFNull, @"(NULL)": (id)kCFNull,
            @"True": @(YES), @"False": @(NO), @"Nil":  (id)kCFNull, @"(Null)": (id)kCFNull,
            @"true": @(YES), @"false": @(NO), @"nil":  (id)kCFNull, @"(null)": (id)kCFNull,
            @"YES":  @(YES), @"NO":    @(NO), @"NULL": (id)kCFNull, @"<NULL>": (id)kCFNull,
            @"Yes":  @(YES), @"No":    @(NO), @"Null": (id)kCFNull, @"<Null>": (id)kCFNull,
            @"yes":  @(YES), @"no":    @(NO), @"null": (id)kCFNull, @"<null>": (id)kCFNull
        };
    });

    if ([JSONValue isKindOfClass:[NSString class]]) {
        NSNumber *const number = _numberStrings[JSONValue];

        if (number == (id)kCFNull) {
            return nil;
        }

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
                id const model = [XZJSON _decodeObject:data class:elementClass];
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
                dictM[oneKey] = [XZJSON _decodeObject:oneValue class:elementClass];
            }];
            return dictM;
        }
        
        if ([JSONValue isKindOfClass:NSArray.class]) {
            NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
            [(NSArray *)JSONValue enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *key = [NSString stringWithFormat:@"%ld", (long)idx];
                dictM[key] = [XZJSON _decodeObject:obj class:elementClass];
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
            id model = [XZJSON _decodeObject:JSONValue class:elementClass];
            if (model) {
                return [NSMutableSet setWithObject:model];
            }
            return nil;
        }
        
        if ([JSONValue isKindOfClass:[NSArray class]] || [JSONValue isKindOfClass:NSSet.class]) {
            NSMutableSet *setM = [NSMutableSet new];
            for (id data in JSONValue) {
                id const model = [XZJSON _decodeObject:data class:elementClass];
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

void XZJSONModelDecodeScalarNumberPropertyFromValue(id model, XZJSONPropertyDescriptor *property, id _Nonnull value) {
    NSNumber * const number = NSNumberFromJSONValue(value);
    switch (property->_type) {
        case XZObjcTypeBool: {
            ((void (*)(id, SEL, BOOL))(void *) objc_msgSend)((id)model, property->_setter, number.boolValue);
            break;
        }
        case XZObjcTypeChar: {
            ((void (*)(id, SEL, char))(void *) objc_msgSend)((id)model, property->_setter, number.charValue);
            break;
        }
        case XZObjcTypeUnsignedChar: {
            ((void (*)(id, SEL, unsigned char))(void *) objc_msgSend)((id)model, property->_setter, number.unsignedCharValue);
            break;
        }
        case XZObjcTypeShort: {
            ((void (*)(id, SEL, short))(void *) objc_msgSend)((id)model, property->_setter, number.shortValue);
            break;
        }
        case XZObjcTypeUnsignedShort: {
            ((void (*)(id, SEL, unsigned short))(void *) objc_msgSend)((id)model, property->_setter, number.unsignedShortValue);
            break;
        }
        case XZObjcTypeInt: {
            ((void (*)(id, SEL, int))(void *) objc_msgSend)((id)model, property->_setter, number.intValue);
        }
        case XZObjcTypeUnsignedInt: {
            ((void (*)(id, SEL, unsigned int))(void *) objc_msgSend)((id)model, property->_setter, number.unsignedIntValue);
            break;
        }
        case XZObjcTypeLong: {
            ((void (*)(id, SEL, long))(void *) objc_msgSend)((id)model, property->_setter, number.longValue);
            break;
        }
        case XZObjcTypeUnsignedLong: {
            ((void (*)(id, SEL, unsigned long))(void *) objc_msgSend)((id)model, property->_setter, number.unsignedLongValue);
            break;
        }
        case XZObjcTypeFloat: {
            float const f = number.floatValue;
            if (isnan(f) || isinf(f)) {
                return;
            }
            ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)model, property->_setter, f);
            break;
        }
        case XZObjcTypeDouble: {
            double const d = number.doubleValue;
            if (isnan(d) || isinf(d)) {
                return;
            }
            ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)model, property->_setter, d);
            break;
        }
        case XZObjcTypeLongDouble: {
            long double const d = number.doubleValue;
            if (isnan(d) || isinf(d)) {
                return;
            }
            ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)model, property->_setter, d);
            break;
        }
        case XZObjcTypeLongLong: {
            long long const d = number.longLongValue;
            if (isnan(d) || isinf(d)) {
                return;
            }
            ((void (*)(id, SEL, long long))(void *) objc_msgSend)((id)model, property->_setter, d);
            break;
        }
        case XZObjcTypeUnsignedLongLong: {
            unsigned long long const d = number.unsignedLongLongValue;
            if (isnan(d) || isinf(d)) {
                return;
            }
            ((void (*)(id, SEL, unsigned long long))(void *) objc_msgSend)((id)model, property->_setter, d);
            break;
        }
        case XZObjcTypeVoid:
        case XZObjcTypeString:
        case XZObjcTypeObject:
        case XZObjcTypeClass:
        case XZObjcTypeSEL:
        case XZObjcTypeArray:
        case XZObjcTypeStruct:
        case XZObjcTypeUnion:
        case XZObjcTypeBitField:
        case XZObjcTypePointer:
        case XZObjcTypeUnknown: {
            break;
        }
    }
}

void XZJSONModelDecodePropertyFromValue(id model, XZJSONPropertyDescriptor *property, id _Nonnull JSONValue) {
    switch (property->_type) {
        case XZObjcTypeUnknown:
            return;
        case XZObjcTypeChar:
        case XZObjcTypeUnsignedChar:
        case XZObjcTypeInt:
        case XZObjcTypeUnsignedInt:
        case XZObjcTypeShort:
        case XZObjcTypeUnsignedShort:
        case XZObjcTypeLong:
        case XZObjcTypeUnsignedLong:
        case XZObjcTypeLongLong:
        case XZObjcTypeUnsignedLongLong:
        case XZObjcTypeFloat:
        case XZObjcTypeDouble:
        case XZObjcTypeLongDouble:
        case XZObjcTypeBool: {
            // 标量数值类型
            XZJSONModelDecodeScalarNumberPropertyFromValue(model, property, JSONValue);
            return;
        }
        case XZObjcTypeVoid:
        case XZObjcTypeString:
        case XZObjcTypeArray:
        case XZObjcTypeBitField:
        case XZObjcTypePointer:
        case XZObjcTypeUnion: {
            // 无法处理的类型
            return;
        }
        case XZObjcTypeStruct: {
            // 结构体只处理原生提供了 -FromString() 的类型。
            if ([JSONValue isKindOfClass:NSString.class]) {
                NSString * const name = property->_property.type.name;
                if ([name isEqualToString:@"CGRect"]) {
                    CGRect aValue = CGRectFromString(JSONValue);
                    ((void (*)(id, SEL, CGRect))(void *) objc_msgSend)((id)model, property->_setter, aValue);
                } else if ([name isEqualToString:@"CGSize"]) {
                    CGSize aValue = CGSizeFromString(JSONValue);
                    ((void (*)(id, SEL, CGSize))(void *) objc_msgSend)((id)model, property->_setter, aValue);
                } else if ([name isEqualToString:@"CGPoint"]) {
                    CGPoint aValue = CGPointFromString(JSONValue);
                    ((void (*)(id, SEL, CGPoint))(void *) objc_msgSend)((id)model, property->_setter, aValue);
                } else if ([name isEqualToString:@"UIEdgeInsets"]) {
                    UIEdgeInsets aValue = UIEdgeInsetsFromString(JSONValue);
                    ((void (*)(id, SEL, UIEdgeInsets))(void *) objc_msgSend)((id)model, property->_setter, aValue);
                } else if ([name isEqualToString:@"CGVector"]) {
                    CGVector aValue = CGVectorFromString(JSONValue);
                    ((void (*)(id, SEL, CGVector))(void *) objc_msgSend)((id)model, property->_setter, aValue);
                } else if ([name isEqualToString:@"CGAffineTransform"]) {
                    CGAffineTransform aValue = CGAffineTransformFromString(JSONValue);
                    ((void (*)(id, SEL, CGAffineTransform))(void *) objc_msgSend)((id)model, property->_setter, aValue);
                } else if ([name isEqualToString:@"NSDirectionalEdgeInsets"]) {
                    NSDirectionalEdgeInsets aValue = NSDirectionalEdgeInsetsFromString(JSONValue);
                    ((void (*)(id, SEL, NSDirectionalEdgeInsets))(void *) objc_msgSend)((id)model, property->_setter, aValue);
                } else if ([name isEqualToString:@"UIOffset"]) {
                    UIOffset aValue = UIOffsetFromString(JSONValue);
                    ((void (*)(id, SEL, UIOffset))(void *) objc_msgSend)((id)model, property->_setter, aValue);
                } else {
                    NSLog(@"[XZJSON] 类 %@ 属性 %@ 值解析失败：未知结构体类型 %@ = %@", property->_class->_class.name, property->_name, name, JSONValue);
                }
            }
            return;
        }
        case XZObjcTypeClass: {
            if (JSONValue == (id)kCFNull) {
                ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, property->_setter, Nil);
            } else if ([JSONValue isKindOfClass:[NSString class]]) {
                Class aClass = NSClassFromString(JSONValue);
                if (aClass) {
                    ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, property->_setter, aClass);
                }
            }
            return;
        }
        case XZObjcTypeSEL: {
            if (JSONValue == (id)kCFNull) {
                ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model, property->_setter, (SEL)NULL);
            } else if ([JSONValue isKindOfClass:[NSString class]]) {
                SEL selector = NSSelectorFromString(JSONValue);
                if (selector) {
                    ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model, property->_setter, selector);
                }
            }
            return;
        }
        case XZObjcTypeObject: {
            // 空值
            if (JSONValue == (id)kCFNull) {
                ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, (id)nil);
                return;
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
                    value = NSNumberFromJSONValue(JSONValue);
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
                            value = [XZJSON _decodeObject:JSONValue class:property->_subtype];
                        }
                    }
                    break;
                }
            }
            
            if (value) {
                ((XZJSONSetter)objc_msgSend)(model, property->_setter, value);
            } else if (value == nil && property->_class->_usesPropertyDecodingMethod) {
                [(id<XZJSONDecoding>)model JSONDecodeValue:JSONValue forKey:property->_name];
            }
            return;
        }
    }
}

NSNumber * _Nullable XZJSONModelEncodeScalarNumberProperty(__unsafe_unretained id _Nonnull model, __unsafe_unretained XZJSONPropertyDescriptor * _Nonnull property) {
    switch (property->_type) { // & XZObjcTypeMask
        case XZObjcTypeBool: {
            return @(((BOOL (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
        }
        case XZObjcTypeChar: {
            return @(((char (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
        }
        case XZObjcTypeUnsignedChar: {
            return @(((unsigned char (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
        }
        case XZObjcTypeShort: {
            return @(((short (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
        }
        case XZObjcTypeUnsignedShort: {
            return @(((unsigned short (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
        }
        case XZObjcTypeInt: {
            return @(((int (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
        }
        case XZObjcTypeUnsignedInt: {
            return @(((unsigned int (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
        }
        case XZObjcTypeLong: {
            return @(((long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
        }
        case XZObjcTypeUnsignedLong: {
            return @(((unsigned long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
        }
        case XZObjcTypeFloat: {
            float num = ((float (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
            if (isnan(num) || isinf(num)) {
                return nil;
            }
            return @(num);
        }
        case XZObjcTypeDouble: {
            double num = ((double (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);

            if (isnan(num) || isinf(num)) {
                return nil;
            }

            return @(num);
        }
        case XZObjcTypeLongDouble: {
            double num = ((long double (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
            if (isnan(num) || isinf(num)) {
                return nil;
            }
            return @(num);
        }
        case XZObjcTypeLongLong: {
            return @(((long long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
            break;
        }
        case XZObjcTypeUnsignedLongLong: {
            return @(((unsigned long long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter));
        }
        case XZObjcTypeVoid:
        case XZObjcTypeString:
        case XZObjcTypeObject:
        case XZObjcTypeClass:
        case XZObjcTypeSEL:
        case XZObjcTypeArray:
        case XZObjcTypeStruct:
        case XZObjcTypeUnion:
        case XZObjcTypeBitField:
        case XZObjcTypePointer:
        case XZObjcTypeUnknown: {
            return nil;
        }
    }
}

NSString * _Nullable XZJSONModelEncodeStructProperty(id model, XZJSONPropertyDescriptor *property) {
    NSString *name = property->_property.type.name;
    if ([name isEqualToString:@"CGRect"]) {
        CGRect structValue = ((CGRect (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
        return NSStringFromCGRect(structValue);
    }
    if ([name isEqualToString:@"CGSize"]) {
        CGSize structValue = ((CGSize (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
        return NSStringFromCGSize(structValue);
    }
    if ([name isEqualToString:@"CGPoint"]) {
        CGPoint structValue = ((CGPoint (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
        return NSStringFromCGPoint(structValue);
    }
    if ([name isEqualToString:@"UIEdgeInsets"]) {
        UIEdgeInsets structValue = ((UIEdgeInsets (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
        return NSStringFromUIEdgeInsets(structValue);
    }
    if ([name isEqualToString:@"CGVector"]) {
        CGVector structValue = ((CGVector (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
        return NSStringFromCGVector(structValue);
    }
    if ([name isEqualToString:@"CGAffineTransform"]) {
        CGAffineTransform structValue = ((CGAffineTransform (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
        return NSStringFromCGAffineTransform(structValue);
    }
    if ([name isEqualToString:@"NSDirectionalEdgeInsets"]) {
        NSDirectionalEdgeInsets structValue = ((NSDirectionalEdgeInsets (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
        return NSStringFromDirectionalEdgeInsets(structValue);
    }
    if ([name isEqualToString:@"UIOffset"]) {
        UIOffset structValue = ((UIOffset (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
        return NSStringFromUIOffset(structValue);
    }
    return nil;
}

NSString * _Nonnull XZJSONModelDescriptionForType(NSObject * _Nonnull model, XZJSONClassType const classType, NSUInteger hierarchies, NSArray *chain) {
    switch (classType) {
        case XZJSONClassTypeNSString:
        case XZJSONClassTypeNSMutableString: {
            NSString *aString = (id)model;
            aString = [aString stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
            return [NSString stringWithFormat:@"\"%@\"", aString];
        }
        case XZJSONClassTypeNSValue:
        case XZJSONClassTypeNSData:
        case XZJSONClassTypeNSMutableData: {
            NSString *tmp = model.description;
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
            NSArray *array = (id)model;
            if (array.count == 0) {
                return @"[]";
            }
            NSString * const padding = [@"" stringByPaddingToLength:hierarchies * 4 withString:@" " startingAtIndex:0];
            hierarchies += 1;
            
            NSMutableString *desc = [NSMutableString stringWithString:@"[\n"];
            for (id obj in array) {
                [desc appendFormat:@"%@    %@,\n", padding, XZJSONModelDescription(obj, hierarchies, chain)];
            }
            [desc appendFormat:@"%@]", padding];
            return desc;
        }
            
        case XZJSONClassTypeNSDictionary:
        case XZJSONClassTypeNSMutableDictionary: {
            NSDictionary *dict = (id)model;
            if (dict.count == 0) {
                return @"{}";
            }
            NSString * const padding = [@"" stringByPaddingToLength:hierarchies * 4 withString:@" " startingAtIndex:0];
            hierarchies += 1;
            
            NSMutableString *desc = [NSMutableString stringWithString:@"{\n"];
            [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                key = [key description];
                obj = XZJSONModelDescription(obj, hierarchies, chain);
                [desc appendFormat:@"%@    %@: %@,\n", padding, key, obj];
            }];
            [desc appendFormat:@"%@}", padding];
            
            return desc;
        }
        case XZJSONClassTypeUnknown:
            return @"<unknown>";
    }
}

/// Generaate a description string
NSString * _Nonnull XZJSONModelDescription(NSObject *_Nonnull model, NSUInteger hierarchies, NSArray *chain) {
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
        return XZJSONModelDescriptionForType(model, modelClass->_classType, hierarchies, chain);
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
            case XZObjcTypeChar:
            case XZObjcTypeInt:
            case XZObjcTypeShort:
            case XZObjcTypeLong:
            case XZObjcTypeLongLong:
            case XZObjcTypeUnsignedChar:
            case XZObjcTypeUnsignedInt:
            case XZObjcTypeUnsignedShort:
            case XZObjcTypeUnsignedLong:
            case XZObjcTypeUnsignedLongLong:
            case XZObjcTypeFloat:
            case XZObjcTypeDouble:
            case XZObjcTypeLongDouble:
            case XZObjcTypeBool: {
                NSNumber *num = XZJSONModelEncodeScalarNumberProperty(model, property);
                value = num.stringValue;
                break;
            }
            case XZObjcTypeObject: {
                value = ((XZJSONGetter)objc_msgSend)((id)model, property->_getter);
                if ([chain containsObject:value]) {
                    value = [NSString stringWithFormat:@"<%@: %p>", value.class, value];
                } else if (property->_classType) {
                    value = XZJSONModelDescriptionForType(value, property->_classType, hierarchies, [chain arrayByAddingObject:model]);
                } else {
                    value = XZJSONModelDescription(value, hierarchies, [chain arrayByAddingObject:model]);
                }
                break;
            }
            case XZObjcTypeClass: {
                value = ((XZJSONGetter)objc_msgSend)((id)model, property->_getter);
                value = [NSString stringWithFormat:@"<class: %@>", value ?: @"<Nil>"];
                break;
            }
            case XZObjcTypeSEL: {
                SEL sel = ((SEL (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                value = [NSString stringWithFormat:@"<selector: %@>", sel ? NSStringFromSelector(sel) : @"<nil>"];
                break;
            }
            case XZObjcTypeArray:
            case XZObjcTypeString:
            case XZObjcTypePointer: {
                void *pointer = ((void *(*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                value = [NSString stringWithFormat:@"<pointer: %p>", pointer];
                break;
            }
            case XZObjcTypeStruct:
            case XZObjcTypeUnion: {
                value = XZJSONModelEncodeStructProperty(model, property);
                value = [NSString stringWithFormat:@"<struct: %@>", value ?: @"unknown"];
                break;
            }
            case XZObjcTypeVoid:
            case XZObjcTypeBitField:
            case XZObjcTypeUnknown:
                value = @"<unknown>";
                break;
        }
        [desc appendFormat:@"%@    %@: %@, \n", padding, key, value];
    }];
    [desc appendFormat:@"%@}>", padding];
    return desc;
}


