//
//  XZJSONPrivate.m
//  XZJSON
//
//  Created by Xezun on 2024/12/3.
//

#import "XZJSONPrivate.h"

/// 读取 JOSN 字典中 keyPath
/// Get the value with key paths from dictionary
/// The dic should be NSDictionary, and the keyPath should not be nil.
/// @param dict JSON 字典
/// @param keyPath 值路径
static id _Nullable XZJSONDictionaryValueForKeyPath(__unsafe_unretained NSDictionary *_Nonnull dict, __unsafe_unretained NSArray<NSString *> * _Nonnull keyPath);
/// 按照 键或键路径 数组的先后顺序从 JSON 字典中取值。
/// Get the value with multi key (or key path) from dictionary
/// The dic should be NSDictionary
/// @param dict JSON 字典
/// @param keyArray 键或键路径的数组
static id _Nullable XZJSONDictionaryValueForKeyArray(__unsafe_unretained NSDictionary *_Nonnull dict, __unsafe_unretained NSArray *_Nonnull keyArray);
/// 读取 dictionary 的 keyPath 中最后一个路径值，如果中间值不存在，则创建。
static NSMutableDictionary * _Nullable XZJSONDictionaryForLastKeyInKeyPath(NSMutableDictionary *dictionary, NSArray<NSString *> *keyPath);

static NSNumber        * _Nullable XZJSONDecodeNSNumberFromValue(id _Nonnull value);
static NSDecimalNumber * _Nullable XZJSONDecodeNSDecimalNumberFromValue(id _Nonnull value);
/// 将非 NSDate 非 nil 非 kCFNull 的值 value 转换为 NSDate 对象。
static NSDate          * _Nullable XZJSONDecodeNSDateFromValue(__unsafe_unretained id _Nonnull value);
static NSString        * _Nullable XZJSONDecodeNSStringFromValue(id _Nullable value);
static NSData          * _Nullable XZJSONDecodeNSDataFromValue(id _Nullable value);
static NSString        * _Nullable XZJSONModelEncodeStructForProperty(id model, XZJSONPropertyDescriptor *property);

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
    if (descriptor->_numberOfProperties == 0) return;
   
    // 遍历数量少的集合，可以提高通用模型的解析效率。
    if (descriptor->_numberOfProperties >= dictionary.count) {
        // 遍历 JSON 数据，只能找到通过 key 映射的属性，所以需要单独遍历 keyPath 和 keyArray
        [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL * _Nonnull stop) {
            XZJSONPropertyDescriptor *property = descriptor->_keyProperties[key];
            while (property) {
                XZJSONModelDecodeValueForProperty(model, property, value);
                property = property->_next;
            }
        }];
        
        [descriptor->_keyPathProperties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor *property, NSUInteger idx, BOOL *stop) {
            NSArray<NSString *> *keyPath = property->_JSONKeyPath;
            id JSONValue = XZJSONDictionaryValueForKeyPath(dictionary, keyPath);
            if (JSONValue) {
                XZJSONModelDecodeValueForProperty(model, property, JSONValue);
            }
        }];
        
        [descriptor->_keyArrayProperties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor *property, NSUInteger idx, BOOL *stop) {
            NSArray *keyArray = property->_JSONKeyArray;
            id JSONValue = XZJSONDictionaryValueForKeyArray(dictionary, keyArray);
            if (JSONValue) {
                XZJSONModelDecodeValueForProperty(model, property, JSONValue);
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
                XZJSONModelDecodeValueForProperty(model, property, JSONValue);
            }
        }];
    }
}

@end

@implementation XZJSON (XZJSONEncodingPrivate)

+ (id)_encodeObject:(nonnull id)object forProperty:(XZJSONPropertyDescriptor *)property dictionary:(nullable NSMutableDictionary *)dictionary {
    // === 基础数据 ===
    if (object == (id)kCFNull) {
        return object;
    }
    if ([object isKindOfClass:[NSString class]]) {
        return object;
    }
    if ([object isKindOfClass:[NSNumber class]]) {
        return object;
    }
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary * const dict = object;
        if ([NSJSONSerialization isValidJSONObject:dict]) {
            return dict;
        }
        NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithCapacity:dict.count];
        [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            NSString * const JSONKey = [key isKindOfClass:[NSString class]] ? key : key.description;
            if (!JSONKey) return;
            id const JSONValue = [self _encodeObject:obj forProperty:nil dictionary:nil];
            if (JSONValue != nil) {
                dictM[JSONKey] = JSONValue;
            }
        }];
        return dictM;
    }
    if ([object isKindOfClass:[NSSet class]]) {
        NSSet * const set = object;
        return [self _encodeArray:set.allObjects];
    }
    if ([object isKindOfClass:[NSArray class]]) {
        return [self _encodeArray:object];
    }
    if ([object isKindOfClass:[NSURL class]]) {
        return ((NSURL *)object).absoluteString;
    }
    if ([object isKindOfClass:[NSAttributedString class]]) {
        return ((NSAttributedString *)object).string;
    }
    if ([object isKindOfClass:[NSDate class]]) {
        if (property && property->_class->_usesDateEncodingMethod) {
            return [(id<XZJSONEncoding>)object encodeDateIntoJSONValue:object forKey:property->_name];
        }
        return @([(NSDate *)object timeIntervalSince1970]);
    }
    if ([object isKindOfClass:[NSData class]]) {
        return nil;
    }
    
    // === 数据模型 ===
    
    XZJSONClassDescriptor * const descriptor = [XZJSONClassDescriptor descriptorForClass:[object class]];
    if (dictionary == nil) {
        dictionary = [NSMutableDictionary dictionaryWithCapacity:descriptor->_numberOfProperties];
    }
    
    // 自定义解析
    if (descriptor->_usesJSONEncodingMethod) {
        return [(id<XZJSONEncoding>)object encodeIntoJSONDictionary:dictionary];
    }
    
    // 通用解析
    [self _model:object encodeIntoDictionary:dictionary descriptor:descriptor];
    
    return dictionary;
}

+ (NSArray *)_encodeArray:(nonnull NSArray *)array {
    if ([NSJSONSerialization isValidJSONObject:array]) {
        return array;
    }
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:array.count];
    for (id obj in array) {
        id const jsonObj = [self _encodeObject:obj forProperty:nil dictionary:nil];
        if (jsonObj != nil) {
            [newArray addObject:jsonObj];
        }
    }
    return newArray;
}

+ (void)_model:(id)model encodeIntoDictionary:(NSMutableDictionary *)dictionary descriptor:(XZJSONClassDescriptor *)descriptor {
    if (!descriptor || descriptor->_numberOfProperties == 0) return;
    
    [descriptor->_keyProperties enumerateKeysAndObjectsUsingBlock:^(NSString *aKey, XZJSONPropertyDescriptor *property, BOOL *stop) {
        NSMutableDictionary *dict = dictionary;
        NSString            *key  = nil;
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
        
        id value = nil;
        if (property->_isScalarNumber) {
            // 标量数字
            value = XZJSONModelEncodeScalarNumberForProperty(model, property);
        } else if (property->_classType) {
            // 原生类型
            id const nsValue = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
            if (nsValue) {
                value = [self _encodeObject:nsValue forProperty:property dictionary:nil];
            }
        } else {
            // 其它类型
            switch (property->_type) {
                case XZObjcTypeObject: {
                    id const csValue = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                    if (csValue) {
                        // 如果 key 已经有值，则进行合并，不能合并则覆盖
                        NSMutableDictionary *subDict = dict[key];
                        if (![subDict isKindOfClass:NSMutableDictionary.class]) {
                            subDict = [NSMutableDictionary dictionary];
                        }
                        value = [self _encodeObject:csValue forProperty:property dictionary:subDict];
                    }
                    break;
                }
                case XZObjcTypeClass: {
                    Class v = ((Class (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                    value = v ? NSStringFromClass(v) : nil;
                    break;
                }
                case XZObjcTypeSEL: {
                    SEL v = ((SEL (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                    value = v ? NSStringFromSelector(v) : nil;
                    break;
                }
                case XZObjcTypeStruct: {
                    value = XZJSONModelEncodeStructForProperty(model, property);
                    if (value == nil) {
                        NSString *name = property->_property.type.name;
                        NSLog(@"[XZJSON] 类 %@ 属性 %@ 值序列化失败：无法将结构体类型 %@ 序列化为 JSON 数据", property->_class->_class.name, property->_name, name);
                    }
                    break;
                }
                case XZObjcTypeUnion: {
                    break;
                }
                case XZObjcTypeString: {
                    break;
                }
                default: {
                    break;
                }
            }
        }
       
        if (value) {
            dict[key] = value;
        }
    }];
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

static NSNumber * _Nullable XZJSONDecodeNSNumberFromValue(id _Nonnull value) {
    if (value == (id)kCFNull) {
        return nil;
    }

    if ([value isKindOfClass:[NSNumber class]]) {
        return value;
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

    if ([value isKindOfClass:[NSString class]]) {
        NSNumber *const number = _numberStrings[value];

        if (number == (id)kCFNull) {
            return nil;
        }

        if (number) {
            return number;
        }

        const char *const string = [((NSString *)value) cStringUsingEncoding:NSASCIIStringEncoding];

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

static NSDecimalNumber * _Nullable XZJSONDecodeNSDecimalNumberFromValue(id _Nonnull value) {
    if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *number = value;
        return [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
    } else if ([value isKindOfClass:[NSString class]]) {
        NSDecimalNumber *const number = [NSDecimalNumber decimalNumberWithString:value];
        NSDecimal const numberValue = number.decimalValue;
        if (numberValue._length == 0 && numberValue._isNegative) {
            return nil;
        }
        return number;
    } else if ([value isKindOfClass:[NSDecimalNumber class]]) {
        return value;
    }
    return nil;
}

static NSDate *XZJSONDecodeNSDateFromValue(__unsafe_unretained id _Nonnull value) {
    // 时间戳，默认秒
    if ([value isKindOfClass:NSNumber.class]) {
        NSTimeInterval const timeInterval = [(NSNumber *)value doubleValue];
        return [NSDate dateWithTimeIntervalSince1970:timeInterval];
    }
    
    // 非字符串无法处理为时间
    if ([value isKindOfClass:NSString.class]) {
        return [XZJSON.dateFormatter dateFromString:value];
    }
    
    return nil;
}

static NSString * _Nullable XZJSONDecodeNSStringFromValue(id _Nullable value) {
    if (!value || value == (id)kCFNull) {
        return nil;
    }

    if ([value isKindOfClass:NSString.class]) {
        return value;
    }

    if ([value isKindOfClass:NSNumber.class]) {
        NSNumber *const number = value;
        return [NSString stringWithString:number.stringValue];
    }

    if ([value isKindOfClass:NSData.class]) { // may not necessary, json has no bytes data
        return [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
    }

    return nil;
}

static NSData * _Nullable XZJSONDecodeNSDataFromValue(id _Nullable value) {
    if ([value isKindOfClass:NSString.class]) {
        NSString *const string = value;

        // data:[<mediatype>][;base64],<data>
        // 支持 RFC2397 URL Data
        // https://datatracker.ietf.org/doc/html/rfc2397
        if ([string hasPrefix:@"data:"] && string.length > 5) {
            NSUInteger const max = [string rangeOfString:@"," options:0 range:NSMakeRange(0, MIN(64, string.length))].location;
            
            if (max == NSNotFound) {
                // 没有编码字段，默认base64
                NSString *base64String = [string substringFromIndex:5];
                return [[NSData alloc] initWithBase64EncodedString:base64String options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
            }
            
            NSUInteger const min = [string rangeOfString:@";" options:(NSBackwardsSearch) range:NSMakeRange(5, max - 5)].location;
            NSString *encodingString = nil;
            if (min == NSNotFound) {
                encodingString = [string substringWithRange:NSMakeRange(5, max - 5)];
            } else {
                encodingString = [string substringWithRange:NSMakeRange(min + 1, max - min - 1)];
            }
            if ([encodingString caseInsensitiveCompare:@"base64"] == NSOrderedSame) {
                NSString *base64String = [string substringFromIndex:max + 1];
                return [[NSData alloc] initWithBase64EncodedString:base64String options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
            }
            
            // 非 base64 编码，透传出去
            return [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        }
        
        static NSCharacterSet * _sharedSet = nil;
        NSCharacterSet * searchSet = _sharedSet;
        if (searchSet == nil) {
            NSString *base64 = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/=\n";
            searchSet = [[NSCharacterSet characterSetWithCharactersInString:base64] invertedSet];
            _sharedSet = searchSet;
        }
        
        // 字符串符合 base64 规则
        if ([string rangeOfCharacterFromSet:searchSet].location == NSNotFound) {
            return [[NSData alloc] initWithBase64EncodedString:string options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
        }
        
        // 透传
        return [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    }
    
    if ([value isKindOfClass:NSValue.class]) {
        NSValue *aValue = value;
        XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorForTypeEncoding:aValue.objCType];
        if (descriptor) {
            // TODO: 验证
            void *bytes = calloc(descriptor.size, sizeof(char));
            [aValue getValue:bytes size:descriptor.size];
            return [[NSData alloc] initWithBytesNoCopy:bytes length:descriptor.size freeWhenDone:YES];
        }
        return nil;
    }

    if ([value isKindOfClass:NSData.class]) {
        return value;
    }

    return nil;
}


/// 将 JSON 值，转换并赋值给数值属性。
/// @param model 模型对象
/// @param value JSON 值
/// @param descriptor 属性
void XZJSONModelDecodeScalarNumberForProperty(__unsafe_unretained id _Nonnull model, __unsafe_unretained XZJSONPropertyDescriptor *_Nonnull descriptor, __unsafe_unretained id _Nonnull value) {
    NSNumber *const number = XZJSONDecodeNSNumberFromValue(value);
    switch (descriptor->_type) { // & XZObjcTypeMask
        case XZObjcTypeBool: {
            ((void (*)(id, SEL, BOOL))(void *) objc_msgSend)((id)model, descriptor->_setter, number.boolValue);
            break;
        }
        case XZObjcTypeChar: {
            ((void (*)(id, SEL, char))(void *) objc_msgSend)((id)model, descriptor->_setter, number.charValue);
            break;
        }
        case XZObjcTypeUnsignedChar: {
            ((void (*)(id, SEL, unsigned char))(void *) objc_msgSend)((id)model, descriptor->_setter, number.unsignedCharValue);
            break;
        }
        case XZObjcTypeShort: {
            ((void (*)(id, SEL, short))(void *) objc_msgSend)((id)model, descriptor->_setter, number.shortValue);
            break;
        }
        case XZObjcTypeUnsignedShort: {
            ((void (*)(id, SEL, unsigned short))(void *) objc_msgSend)((id)model, descriptor->_setter, number.unsignedShortValue);
            break;
        }
        case XZObjcTypeInt: {
            ((void (*)(id, SEL, int))(void *) objc_msgSend)((id)model, descriptor->_setter, number.intValue);
        }
        case XZObjcTypeUnsignedInt: {
            ((void (*)(id, SEL, unsigned int))(void *) objc_msgSend)((id)model, descriptor->_setter, number.unsignedIntValue);
            break;
        }
        case XZObjcTypeLong: {
            ((void (*)(id, SEL, long))(void *) objc_msgSend)((id)model, descriptor->_setter, number.longValue);
            break;
        }
        case XZObjcTypeUnsignedLong: {
            ((void (*)(id, SEL, unsigned long))(void *) objc_msgSend)((id)model, descriptor->_setter, number.unsignedLongValue);
            break;
        }
        case XZObjcTypeFloat: {
            float const f = number.floatValue;
            if (isnan(f) || isinf(f)) {
                return;
            }
            ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)model, descriptor->_setter, f);
            break;
        }
        case XZObjcTypeDouble: {
            double const d = number.doubleValue;
            if (isnan(d) || isinf(d)) {
                return;
            }
            ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)model, descriptor->_setter, d);
            break;
        }
        case XZObjcTypeLongDouble: {
            long double const d = number.doubleValue;
            if (isnan(d) || isinf(d)) {
                return;
            }
            ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)model, descriptor->_setter, d);
            break;
        }
        case XZObjcTypeLongLong: {
            long long const d = number.longLongValue;
            if (isnan(d) || isinf(d)) {
                return;
            }
            ((void (*)(id, SEL, long long))(void *) objc_msgSend)((id)model, descriptor->_setter, d);
            break;
        }
        case XZObjcTypeUnsignedLongLong: {
            unsigned long long const d = number.unsignedLongLongValue;
            if (isnan(d) || isinf(d)) {
                return;
            }
            ((void (*)(id, SEL, unsigned long long))(void *) objc_msgSend)((id)model, descriptor->_setter, d);
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

void XZJSONModelDecodeValueForProperty(__unsafe_unretained id _Nonnull model, __unsafe_unretained XZJSONPropertyDescriptor *_Nonnull property, __unsafe_unretained id _Nonnull value) {
    // 标量数值类型
    if (property->_isScalarNumber) {
        XZJSONModelDecodeScalarNumberForProperty(model, property, value);
        return;
    }

    // 原生对象类型
    if (property->_classType != XZJSONClassTypeUnknown) {
        if (value == (id)kCFNull) {
            ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, (id)nil);
            return;
        }

        switch (property->_classType) {
            case XZJSONClassTypeNSString: {
                NSString *const string = XZJSONDecodeNSStringFromValue(value);
                if (string) {
                    ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, string);
                }
                return;
            }
            case XZJSONClassTypeNSMutableString: {
                NSMutableString * const string = (id)XZJSONDecodeNSStringFromValue(value);
                if ([string isKindOfClass:NSMutableString.class]) {
                    ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, string);
                } else if (string) {
                    ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, [string mutableCopy]);
                }
                return;
            }
            case XZJSONClassTypeNSValue: {
                if ([value isKindOfClass:[NSValue class]]) {
                    ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, value);
                }
                return;
            }
            case XZJSONClassTypeNSNumber: {
                NSNumber *number = XZJSONDecodeNSNumberFromValue(value);
                if (number) {
                    ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, number);
                }
                return;
            }
            case XZJSONClassTypeNSDecimalNumber: {
                NSDecimalNumber *number = XZJSONDecodeNSDecimalNumberFromValue(value);
                if (number) {
                    ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, number);
                }
                return;
            }
            case XZJSONClassTypeNSData: {
                NSData *const data = XZJSONDecodeNSDataFromValue(value);
                if (data) {
                    ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, data);
                }
                return;
            }
            case XZJSONClassTypeNSMutableData: {
                NSMutableData * data = (id)XZJSONDecodeNSDataFromValue(value);
                if ([data isKindOfClass:[NSMutableData class]]) {
                    ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, data);
                } else if (data) {
                    ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, [data mutableCopy]);
                }
                return;
            }
            case XZJSONClassTypeNSDate: {
                if ([value isKindOfClass:[NSDate class]]) {
                    ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, value);
                } else if (property->_class->_usesDateDecodingMethod) {
                    [(id<XZJSONDecoding>)model decodeDateFromJSONValue:value forKey:property->_name];
                } else {
                    NSDate *date = XZJSONDecodeNSDateFromValue(value);
                    if (date) {
                        ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, date);
                    }
                }
                return;
            }
            case XZJSONClassTypeNSURL: {
                NSURL *url = nil;
                if ([value isKindOfClass:[NSURL class]]) {
                    url = value;
                } else if ([value isKindOfClass:[NSString class]]) {
                    NSString *string = value;
                    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                    string = [string stringByTrimmingCharactersInSet:set];
                    url = [NSURL URLWithString:string];
                }
                if (url) {
                    ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, url);
                }
                return;
            }
            case XZJSONClassTypeNSArray:
            case XZJSONClassTypeNSMutableArray: {
                if (property->_elementType) {
                    NSArray *array = nil;

                    if ([value isKindOfClass:[NSArray class]]) {
                        array = value;
                    } else if ([value isKindOfClass:[NSSet class]]) {
                        array = ((NSSet *)value).allObjects;
                    } else if ([value isKindOfClass:[NSDictionary class]]) {
                        array = @[value];
                    }

                    if (array) {
                        NSMutableArray * const arrayM = [NSMutableArray arrayWithCapacity:array.count];
                        for (id data in array) {
                            id const model = [XZJSON _decodeObject:data class:property->_elementType];
                            if (model) {
                                [arrayM addObject:model];
                            }
                        }
                        ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, arrayM);
                    }
                } else {
                    if ([value isKindOfClass:[NSArray class]]) {
                        if (property->_classType == XZJSONClassTypeNSArray) {
                            ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, value);
                        } else {
                            ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, ((NSArray *)value).mutableCopy);
                        }
                    } else if ([value isKindOfClass:[NSSet class]]) {
                        if (property->_classType == XZJSONClassTypeNSArray) {
                            ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, ((NSSet *)value).allObjects);
                        } else {
                            ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, ((NSSet *)value).allObjects.mutableCopy);
                        }
                    }
                }
                return;
            }
            case XZJSONClassTypeNSDictionary:
            case XZJSONClassTypeNSMutableDictionary: {
                if ([value isKindOfClass:[NSDictionary class]]) {
                    if (property->_elementType) {
                        NSMutableDictionary *dictM = [NSMutableDictionary new];
                        [((NSDictionary *)value) enumerateKeysAndObjectsUsingBlock:^(NSString *oneKey, id oneValue, BOOL *stop) {
                            id const model = [XZJSON _decodeObject:oneValue class:property->_elementType];
                            if (model) {
                                dictM[oneKey] = model;
                            }
                        }];
                        ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, dictM);
                    } else {
                        if (property->_classType == XZJSONClassTypeNSDictionary) {
                            ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, value);
                        } else {
                            ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, ((NSDictionary *)value).mutableCopy);
                        }
                    }
                }
                return;
            }
            case XZJSONClassTypeNSSet:
            case XZJSONClassTypeNSMutableSet: {
                if (property->_elementType) {
                    if ([value isKindOfClass:NSDictionary.class]) {
                        value = @[value];
                    } else if (![value isKindOfClass:[NSArray class]] && ![value isKindOfClass:NSSet.class]) {
                        return;
                    }
                    NSMutableSet *setM = [NSMutableSet new];
                    for (id data in value) {
                        id const model = [XZJSON _decodeObject:data class:property->_elementType];
                        if (model) {
                            [setM addObject:model];
                        }
                    }
                    ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, setM);
                } else {
                    NSMutableSet *set = value;
                    if ([value isKindOfClass:NSArray.class]) {
                        set = [NSMutableSet setWithArray:value];
                    } else if ([value isKindOfClass:NSDictionary.class]) {
                        set = [NSMutableSet setWithObject:value];
                    } else if ([value isKindOfClass:NSMutableSet.class]) {
                        set = value;
                    } else if ([value isKindOfClass:NSSet.class]) {
                        if (property->_classType == XZJSONClassTypeNSMutableSet) {
                            set = [value mutableCopy];
                        }
                    }
                    ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, set);
                }
                return;
            }

            default: {
                return;
            }
        }
        return;
    }

    // 其它类型
    switch (property->_type) {
        case XZObjcTypeObject: { // 对象类型
            if (value == (id)kCFNull) {
                // 下发 Null 值，才会执行 setter
                ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, (id)nil);
            } else if (!property->_subtype || [value isKindOfClass:property->_subtype]) {
                // 未指定对象类型，或者已经是指定的自定义对象类型，直接赋值
                ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, (id)value);
            } else {
                // JSON 数据模型化为指定的自定义对象类型
                if (![value isKindOfClass:[NSDictionary class]]) {
                    value = @{ @"rawValue": value }; // 非字典数据，包装为字典
                }
                // 如果属性已有值，直接更新它。
                NSObject *object = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);;
                if (object) {
                    [XZJSON model:object decodeFromDictionary:value];
                } else {
                    object = [XZJSON _decodeObject:value class:property->_subtype];
                    if (object) {
                        ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, (id)object);
                    }
                }
            }
            return;
        }
        case XZObjcTypeClass: {
            if (value == (id)kCFNull) {
                ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, property->_setter, Nil);
            } else if ([value isKindOfClass:[NSString class]]) {
                Class aClass = NSClassFromString(value);
                if (aClass) {
                    ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, property->_setter, aClass);
                }
            }
            return;
        }
        case  XZObjcTypeSEL: {
            if (value == (id)kCFNull) {
                ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model, property->_setter, (SEL)NULL);
            } else if ([value isKindOfClass:[NSString class]]) {
                SEL selector = NSSelectorFromString(value);
                if (selector) {
                    ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model, property->_setter, selector);
                }
            }
            return;
        }

        case XZObjcTypeStruct: {
            if ([value isKindOfClass:NSString.class]) {
                NSString * const name = property->_property.type.name;
                if ([name isEqualToString:@"CGRect"]) {
                    CGRect aValue = CGRectFromString(value);
                    ((void (*)(id, SEL, CGRect))(void *) objc_msgSend)((id)model, property->_setter, aValue);
                } else if ([name isEqualToString:@"CGSize"]) {
                    CGSize aValue = CGSizeFromString(value);
                    ((void (*)(id, SEL, CGSize))(void *) objc_msgSend)((id)model, property->_setter, aValue);
                } else if ([name isEqualToString:@"CGPoint"]) {
                    CGPoint aValue = CGPointFromString(value);
                    ((void (*)(id, SEL, CGPoint))(void *) objc_msgSend)((id)model, property->_setter, aValue);
                } else if ([name isEqualToString:@"UIEdgeInsets"]) {
                    UIEdgeInsets aValue = UIEdgeInsetsFromString(value);
                    ((void (*)(id, SEL, UIEdgeInsets))(void *) objc_msgSend)((id)model, property->_setter, aValue);
                } else if ([name isEqualToString:@"CGVector"]) {
                    CGVector aValue = CGVectorFromString(value);
                    ((void (*)(id, SEL, CGVector))(void *) objc_msgSend)((id)model, property->_setter, aValue);
                } else if ([name isEqualToString:@"CGAffineTransform"]) {
                    CGAffineTransform aValue = CGAffineTransformFromString(value);
                    ((void (*)(id, SEL, CGAffineTransform))(void *) objc_msgSend)((id)model, property->_setter, aValue);
                } else if ([name isEqualToString:@"NSDirectionalEdgeInsets"]) {
                    NSDirectionalEdgeInsets aValue = NSDirectionalEdgeInsetsFromString(value);
                    ((void (*)(id, SEL, NSDirectionalEdgeInsets))(void *) objc_msgSend)((id)model, property->_setter, aValue);
                } else if ([name isEqualToString:@"UIOffset"]) {
                    UIOffset aValue = UIOffsetFromString(value);
                    ((void (*)(id, SEL, UIOffset))(void *) objc_msgSend)((id)model, property->_setter, aValue);
                } else {
                    NSLog(@"[XZJSON] 类 %@ 属性 %@ 值解析失败：未知结构体类型 %@ = %@", property->_class->_class.name, property->_name, name, value);
                }
                return;
            }
            // fallthrough to check NSValue
        }
        case XZObjcTypeUnion:
        case XZObjcTypeArray:
        case XZObjcTypePointer:
        case XZObjcTypeString: {
            // JSON 解析，不支持此类值
            break;
        }

        default: break;
    }
}

NSNumber * _Nullable XZJSONModelEncodeScalarNumberForProperty(__unsafe_unretained id _Nonnull model, __unsafe_unretained XZJSONPropertyDescriptor * _Nonnull property) {
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
            return @(NAN);
            break;
        }
    }
}

NSString * _Nullable XZJSONModelEncodeStructForProperty(id model, XZJSONPropertyDescriptor *property) {
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
                NSNumber *num = XZJSONModelEncodeScalarNumberForProperty(model, property);
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
                value = XZJSONModelEncodeStructForProperty(model, property);
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


