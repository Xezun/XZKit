//
//  XZJSONPrivate.m
//  XZJSON
//
//  Created by Xezun on 2024/12/3.
//

#import "XZJSONPrivate.h"
#import "XZMacro.h"
#import "NSCharacterSet+XZKit.h"
#import "NSData+XZKit.h"
@import ObjectiveC;

static void XZJSONModelDecodeProperty(id model, XZJSONPropertyDescriptor *property, id _Nonnull JSONValue);
static void XZJSONModelEncodeProperty(id model, XZJSONPropertyDescriptor *property, NSMutableDictionary *modelDictionary);

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
            NSCAssert([dictionary isKindOfClass:NSDictionary.class], @"[XZJSON] 方法 +canDecodeFromJSONDictionary: 的返回值必须是 NSDictionary 对象");
        }
        // 自定义初始化过程
        if (descriptor->_usesJSONDecodingInitializer) {
            return [[aClass alloc] initWithJSONDictionary:dictionary];
        }
        // 通用初始化方法
        id const model = [aClass new];
        if (model != nil) {
            [self _model:model decodeFromDictionary:dictionary modelClass:descriptor];
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

+ (void)_model:(id)model decodeFromDictionary:(NSDictionary *)dictionary modelClass:(XZJSONClassDescriptor *)modelClass {
    // 没有可用的属性
    if (modelClass->_numberOfProperties == 0) {
        return;
    }
   
    // 遍历数量少的集合，可以提高通用模型的解析效率。
    if (modelClass->_numberOfProperties >= dictionary.count) {
        // 遍历 JSON 数据，只能找到通过 key 映射的属性，所以需要单独遍历 keyPath 和 keyArray
        [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL * _Nonnull stop) {
            XZJSONPropertyDescriptor *property = modelClass->_keyProperties[key];
            while (property) {
                XZJSONModelDecodeProperty(model, property, value);
                property = property->_next;
            }
        }];
        
        [modelClass->_keyPathProperties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor * _Nonnull property, NSUInteger idx, BOOL * _Nonnull stop) {
            id const JSONValue = (property->_keyValueCoder)(dictionary);
            if (JSONValue) {
                XZJSONModelDecodeProperty(model, property, JSONValue);
            }
        }];
        
        [modelClass->_keyArrayProperties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor *property, NSUInteger idx, BOOL *stop) {
            id const JSONValue = (property->_keyValueCoder)(dictionary);
            if (JSONValue) {
                XZJSONModelDecodeProperty(model, property, JSONValue);
            }
        }];
    } else {
        [modelClass->_properties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor *property, NSUInteger idx, BOOL *stop) {
            id const JSONValue = (property->_keyValueCoder)(dictionary);
            if (JSONValue) {
                XZJSONModelDecodeProperty(model, property, JSONValue);
            }
        }];
    }
}

@end

@implementation XZJSON (XZJSONEncodingPrivate)

+ (id)_encodeObject:(id)object intoDictionary:(nullable NSMutableDictionary *)dictionary descriptor:(XZJSONClassDescriptor *)descriptor {
    switch (descriptor->_classType) {
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
            return [self _encodeCollection:(id<NSFastEnumeration>)object count:[(NSArray *)object count]];
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
                id const JSONValue = [self _encodeObject:obj intoDictionary:nil descriptor:objClass];
                if (JSONValue != nil) {
                    dictM[JSONKey] = JSONValue;
                }
            }];
            return dictM;
        }
        case XZJSONClassTypeNSSet:
        case XZJSONClassTypeNSMutableSet:
        case XZJSONClassTypeNSCountedSet: {
            NSSet *set = object;
            return [self _encodeCollection:set.allObjects count:set.count];
        }
        case XZJSONClassTypeNSOrderedSet:
        case XZJSONClassTypeNSMutableOrderedSet: {
            NSOrderedSet *orderedSet = object;
            return [self _encodeCollection:orderedSet.array.copy count:orderedSet.count];
        }
        case XZJSONClassTypeUnknown: {
            if (object == (id)kCFNull) {
                return object;
            }
            
            if (dictionary == nil) {
                dictionary = [NSMutableDictionary dictionaryWithCapacity:descriptor->_numberOfProperties];
            }
            
            // 自定义序列化
            if (descriptor->_usesJSONEncodingInitializer) {
                return [(id<XZJSONCoding>)object encodeIntoJSONDictionary:dictionary];
            }
            
            // 其它对象，视为模型。
            [self _model:object encodeIntoDictionary:dictionary descriptor:descriptor];
            
            return dictionary;
        }
    }
}

+ (id)_encodeCollection:(id<NSFastEnumeration>)collection count:(NSUInteger)count {
    if ([NSJSONSerialization isValidJSONObject:collection]) {
        return collection;
    }
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:count];
    for (id item in collection) {
        XZJSONClassDescriptor *itemClass = [XZJSONClassDescriptor descriptorForClass:object_getClass(item)];
        if (itemClass == nil) {
            continue;
        }
        id const JSONObject = [self _encodeObject:item intoDictionary:nil descriptor:itemClass];
        if (JSONObject != nil) {
            [newArray addObject:JSONObject];
        }
    }
    return newArray;
}

+ (void)_model:(id)model encodeIntoDictionary:(NSMutableDictionary *)modelDictionary descriptor:(XZJSONClassDescriptor *)descriptor {
    [descriptor->_properties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor * _Nonnull property, NSUInteger idx, BOOL * _Nonnull stop) {
        XZJSONModelEncodeProperty(model, property, modelDictionary);
    }];
}

@end

typedef id _Nullable (*XZJSONGetter)(id _Nonnull, SEL _Nonnull);
typedef void         (*XZJSONSetter)(id _Nonnull, SEL _Nonnull, id _Nullable);

static inline BOOL NSCharFromJSONValue(id _Nonnull JSONValue, char *value) {
    if ([JSONValue isKindOfClass:NSNumber.class]) {
        *value = [(NSNumber *)JSONValue charValue];
        return YES;
    }
    if ([JSONValue isKindOfClass:NSString.class]) {
        if ([(NSString *)JSONValue length] > 0) {
            const char *string = [(NSString *)JSONValue cStringUsingEncoding:NSASCIIStringEncoding];
            if (string != NULL) {
                *value = string[0];
                return YES;
            }
        }
    }
    return NO;
}

static inline BOOL NSIntegerFromJSONValue(id _Nonnull JSONValue, int *value) {
    if ([JSONValue isKindOfClass:NSNumber.class]) {
        *value = [(NSNumber *)JSONValue intValue];
        return YES;
    }
    if ([JSONValue isKindOfClass:NSString.class]) {
        if ([(NSString *)JSONValue length] > 0) {
            const char *string = [(NSString *)JSONValue cStringUsingEncoding:NSASCIIStringEncoding];
            if (string != NULL) {
                *value = atoi(string);
                return YES;
            }
        }
    }
    return NO;
}

static inline BOOL NSLongIntegerFromJSONValue(id _Nonnull JSONValue, long *value) {
    if ([JSONValue isKindOfClass:NSNumber.class]) {
        *value = [(NSNumber *)JSONValue integerValue];
        return YES;
    }
    if ([JSONValue isKindOfClass:NSString.class]) {
        if ([(NSString *)JSONValue length] > 0) {
            const char *string = [(NSString *)JSONValue cStringUsingEncoding:NSASCIIStringEncoding];
            if (string != NULL) {
                *value = atol(string);
                return YES;
            }
        }
    }
    return NO;
}

static inline BOOL NSLongLongIntegerFromJSONValue(id _Nonnull JSONValue, long long *value) {
    if ([JSONValue isKindOfClass:NSNumber.class]) {
        *value = [(NSNumber *)JSONValue longLongValue];
        return YES;
    }
    if ([JSONValue isKindOfClass:NSString.class]) {
        if ([(NSString *)JSONValue length] > 0) {
            const char *string = [(NSString *)JSONValue cStringUsingEncoding:NSASCIIStringEncoding];
            if (string != NULL) {
                *value = atoll(string);
                return YES;
            }
        }
    }
    return NO;
}

static inline BOOL NSFloatFromJSONValue(id _Nonnull JSONValue, float *value) {
    if ([JSONValue isKindOfClass:NSNumber.class]) {
        *value = [(NSNumber *)JSONValue floatValue];
        return YES;
    }
    if ([JSONValue isKindOfClass:NSString.class]) {
        if ([(NSString *)JSONValue length] > 0) {
            const char *string = [(NSString *)JSONValue cStringUsingEncoding:NSASCIIStringEncoding];
            if (string != NULL) {
                char *error = NULL;
                float const aValue = strtof(string, &error);
                if (!error && !isnan(aValue) && !isinf(aValue)) {
                    *value = aValue;
                    return YES;
                }
            }
        }
    }
    return NO;
}

static inline BOOL NSDoubleFromJSONValue(id _Nonnull JSONValue, double *value) {
    if ([JSONValue isKindOfClass:NSNumber.class]) {
        *value = [(NSNumber *)JSONValue doubleValue];
        return YES;
    }
    if ([JSONValue isKindOfClass:NSString.class]) {
        if ([(NSString *)JSONValue length] > 0) {
            const char *string = [(NSString *)JSONValue cStringUsingEncoding:NSASCIIStringEncoding];
            if (string != NULL) {
                char *error = NULL;
                double const aValue = strtod(string, &error);
                if (!error && !isnan(aValue) && !isinf(aValue)) {
                    *value = aValue;
                    return YES;
                }
            }
        }
    }
    return NO;
}

static inline BOOL NSLongDoubleFromJSONValue(id _Nonnull JSONValue, long double *value) {
    if ([JSONValue isKindOfClass:NSNumber.class]) {
        *value = [(NSNumber *)JSONValue doubleValue];
        return YES;
    }
    if ([JSONValue isKindOfClass:NSString.class]) {
        if ([(NSString *)JSONValue length] > 0) {
            const char *string = [(NSString *)JSONValue cStringUsingEncoding:NSASCIIStringEncoding];
            if (string != NULL) {
                char *error = NULL;
                long double const aValue = strtold(string, &error);
                if (!error && !isnan(aValue) && !isinf(aValue)) {
                    *value = aValue;
                    return YES;
                }
            }
        }
    }
    return NO;
}

static inline BOOL NSBoolFromJSONValue(id _Nonnull JSONValue, BOOL *value) {
    if ([JSONValue isKindOfClass:NSNumber.class]) {
        *value = [(NSNumber *)JSONValue boolValue];
        return YES;
    }
    if ([JSONValue isKindOfClass:NSString.class]) {
        *value = [(NSString *)JSONValue boolValue];
        return YES;
    }
    return NO;
}

/// 将 JSON 值转换为 NSString 值。
/// - Parameter value: JSON 值
static inline NSString * _Nullable NSStringFromJSONValue(id JSONValue, BOOL mutable) {
    if ([JSONValue isKindOfClass:NSString.class]) {
        if (mutable) {
            if ([JSONValue isKindOfClass:NSMutableString.class]) {
                return JSONValue;
            }
            return [NSMutableString stringWithString:JSONValue];
        }
        return JSONValue;
    }

    if ([JSONValue isKindOfClass:NSNumber.class]) {
        NSNumber *const number = JSONValue;
        if (mutable) {
            return [NSMutableString stringWithString:number.stringValue];
        }
        return number.stringValue;
    }
    
    return nil;
}

static inline NSNumber * _Nullable NSObjectNumberFromJSONValue(id _Nonnull JSONValue) {
    if ([JSONValue isKindOfClass:[NSNumber class]]) {
        return JSONValue;
    }

    static NSDictionary<NSString *, NSNumber *> *_boolStrings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _boolStrings = @{
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
static inline NSDecimalNumber * _Nullable NSDecimalNumberFromJSONValue(id _Nonnull JSONValue) {
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

static inline NSURL * _Nullable NSURLFromJSONValue(id JSONValue) {
    if ([JSONValue isKindOfClass:[NSURL class]]) {
        return JSONValue;
    }
    if ([JSONValue isKindOfClass:[NSString class]]) {
        NSString *string = JSONValue;
        NSURL *url = [NSURL URLWithString:string];
        if (url) {
            return url;
        }
        string = [string stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        string = [string stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.xz_URIAllowedCharacterSet];
        url = [NSURL URLWithString:string];
        if (url) {
            return url;
        }
    }
    return nil;
}

static inline NSArray * _Nullable NSArrayFromJSONValue(id _Nonnull const JSONValue, Class _Nullable const elementClass, BOOL mutable) {
    if ([JSONValue isKindOfClass:NSArray.class]) {
        if (elementClass) {
            NSMutableArray * const arrayM = [NSMutableArray arrayWithCapacity:((NSArray *)JSONValue).count];
            for (id data in (NSArray *)JSONValue) {
                id const model = [XZJSON _decodeJSONObject:data class:elementClass];
                if (model) {
                    [arrayM addObject:model];
                }
            }
            return arrayM;
        }
        
        if (mutable) {
            if ([JSONValue isKindOfClass:NSMutableArray.class]) {
                return JSONValue;
            }
            return [NSMutableArray arrayWithArray:JSONValue];
        }
        
        return JSONValue;
    }
    
    if (elementClass) {
        if ([JSONValue isKindOfClass:NSDictionary.class]) {
            id const model = [XZJSON _decodeJSONObject:JSONValue class:elementClass];
            if (model) {
                return [NSMutableArray arrayWithObject:model];
            }
            return nil;
        }
        return nil;
    }
    
    return [NSMutableArray arrayWithObject:JSONValue];
}

static inline NSSet * _Nullable NSSetFromJSONValue(id _Nonnull const JSONValue, Class _Nullable const elementClass, Class MutableSetClass) {
    if ([JSONValue isKindOfClass:NSArray.class]) {
        if (elementClass) {
            NSMutableSet * const setM = [MutableSetClass setWithCapacity:((NSArray *)JSONValue).count];
            for (id data in (NSArray *)JSONValue) {
                id const model = [XZJSON _decodeJSONObject:data class:elementClass];
                if (model) {
                    [setM addObject:model];
                }
            }
            return setM;
        }
        
        return [MutableSetClass setWithArray:JSONValue];
    }
    
    if (elementClass) {
        if ([JSONValue isKindOfClass:NSDictionary.class]) {
            id const model = [XZJSON _decodeJSONObject:JSONValue class:elementClass];
            if (model) {
                return [MutableSetClass setWithObject:model];
            }
        }
        return nil;
    }
    
    return [MutableSetClass setWithObject:JSONValue];
}

static inline NSMutableOrderedSet * _Nullable NSOrderedSetFromJSONValue(id _Nonnull const JSONValue, Class _Nullable const elementClass) {
    if ([JSONValue isKindOfClass:NSArray.class]) {
        if (elementClass) {
            NSMutableOrderedSet * const orderedSetM = [NSMutableOrderedSet orderedSetWithCapacity:((NSArray *)JSONValue).count];
            for (id data in (NSArray *)JSONValue) {
                id const model = [XZJSON _decodeJSONObject:data class:elementClass];
                if (model) {
                    [orderedSetM addObject:model];
                }
            }
            return orderedSetM;
        }
        
        return [NSMutableOrderedSet orderedSetWithArray:JSONValue];
    }
    
    if (elementClass) {
        if ([JSONValue isKindOfClass:NSDictionary.class]) {
            id const model = [XZJSON _decodeJSONObject:JSONValue class:elementClass];
            if (model) {
                return [NSMutableOrderedSet orderedSetWithObject:model];
            }
            return nil;
        }
        return nil;
    }
    
    return [NSMutableOrderedSet orderedSetWithObject:JSONValue];
}

static inline NSDictionary * _Nullable NSDictionaryFromJSONValue(id _Nonnull const JSONValue, Class _Nullable const elementClass, BOOL mutable) {
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
    
    if (mutable) {
        if ([JSONValue isKindOfClass:NSMutableDictionary.class]) {
            return JSONValue;
        }
        if ([JSONValue isKindOfClass:NSDictionary.class]) {
            return [NSMutableDictionary dictionaryWithDictionary:JSONValue];
        }
    } else if ([JSONValue isKindOfClass:NSDictionary.class]) {
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

static inline id NSDataFromJSONValue(id JSONValue, BOOL mutable) {
    if ([JSONValue isKindOfClass:NSString.class]) {
        // 符合 RFC2397 URL Data 规范的字符
        // data:[<mediatype>][;base64],<data>
        // https://datatracker.ietf.org/doc/html/rfc2397
        NSString * const JSONString = JSONValue;
        if ([JSONString hasPrefix:@"data:"] && JSONString.length > 5) {
            NSString *type = nil;
            NSString *data = nil;
            
            NSUInteger const max = [JSONString rangeOfString:@"," options:0 range:NSMakeRange(5, MIN(1024, JSONString.length))].location;
            if (max == NSNotFound) {
                type = @"base64";
                data = [JSONString substringFromIndex:5];
            } else {
                NSUInteger const min = [JSONString rangeOfString:@";" options:(NSBackwardsSearch) range:NSMakeRange(5, max - 5)].location;
                
                if (min == NSNotFound) {
                    // data:base64,data
                    type = [JSONString substringWithRange:NSMakeRange(5, max - 5)];
                } else {
                    type = [JSONString substringWithRange:NSMakeRange(min + 1, max - min - 1)];
                }
                
                if ([type containsString:@"="] || [type containsString:@"/"]) {
                    type = @"base64";
                } else {
                    type = [type lowercaseString];
                }
                
                data = [JSONString substringFromIndex:max + 1];
            }
            
            if ([type isEqualToString:@"base64"]) {
                return [[NSMutableData alloc] initWithBase64EncodedString:data options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
            }
            
            if ([type isEqualToString:@"hex"]) {
                return [NSMutableData xz_dataWithHexEncodedString:data];
            }
            
            return nil;
        }
        
        // 默认当作 base64 字符串处理，使用严格模式。
        return [[NSMutableData alloc] initWithBase64EncodedString:JSONValue options:kNilOptions];
    }
    
    if ([JSONValue isKindOfClass:NSDictionary.class]) {
        NSString *type = ((NSDictionary *)JSONValue)[@"type"];
        NSString *data = ((NSDictionary *)JSONValue)[@"data"];
        if ([type isKindOfClass:NSString.class] && [data isKindOfClass:NSString.class]) {
            if ([type isEqualToString:@"base64"]) {
                return [[NSMutableData alloc] initWithBase64EncodedString:JSONValue options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
            }
            if ([type isEqualToString:@"hex"]) {
                return [NSMutableData xz_dataWithHexEncodedString:data];
            }
        }
    }
    
    return nil;
}

/// 将 JSON 值 value 转换为 NSDate 对象。
/// - Parameter JSONValue: JSON 值
static inline NSDate *NSDateFromJSONValue(__unsafe_unretained id _Nonnull JSONValue) {
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

/// 默认解析器，用来解析 NSData、NSDate 等具有多种原生形式的数据。
/// JSONValue 非 nil 且非 NSNull 且非 `property->_classType` 类型。
static inline BOOL XZJSONModelDecodePropertyFallback(id model, XZJSONPropertyDescriptor *property, id JSONValue) {
    switch (property->_classType) {
        case XZJSONClassTypeUnknown:
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
        case XZJSONClassTypeNSMutableDictionary: {
            // 这些值类型，不需要默认解析。
            return NO;
        }
        case XZJSONClassTypeNSValue: {
            if (![JSONValue isKindOfClass:NSDictionary.class]) {
                return NO;
            }
            NSDictionary * const dict = JSONValue;
            
            NSString *type  = dict[@"type"];
            NSString *value = dict[@"value"];
            
            if (![type isKindOfClass:NSString.class] || ![value isKindOfClass:NSString.class]) {
                return NO;
            }
            
            if (type.length == 0 || value.length == 0) {
                return NO;
            }
            
            switch (XZJSONStructTypeFromString(type)) {
                case XZJSONStructTypeUnknown: {
                    return NO;
                }
                case XZJSONStructTypeCGRect: {
                    CGRect const aValue = CGRectFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithCGRect:aValue]);
                    return YES;
                }
                case XZJSONStructTypeCGSize: {
                    CGSize const aValue = CGSizeFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithCGSize:aValue]);
                    return YES;
                }
                case XZJSONStructTypeCGPoint: {
                    CGPoint const aValue = CGPointFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithCGPoint:aValue]);
                    return YES;
                }
                case XZJSONStructTypeUIEdgeInsets: {
                    UIEdgeInsets const aValue = UIEdgeInsetsFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithUIEdgeInsets:aValue]);
                    return YES;
                }
                case XZJSONStructTypeCGVector: {
                    CGVector const aValue = CGVectorFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithCGVector:aValue]);
                    return YES;
                }
                case XZJSONStructTypeCGAffineTransform: {
                    CGAffineTransform const aValue = CGAffineTransformFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithCGAffineTransform:aValue]);
                    return YES;
                }
                case XZJSONStructTypeNSDirectionalEdgeInsets: {
                    NSDirectionalEdgeInsets const aValue = NSDirectionalEdgeInsetsFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithDirectionalEdgeInsets:aValue]);
                    return YES;
                }
                case XZJSONStructTypeUIOffset: {
                    UIOffset const aValue = UIOffsetFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithUIOffset:aValue]);
                    return YES;
                }
            }
            break;
        }
        case XZJSONClassTypeNSDate: {
            NSDate *date = NSDateFromJSONValue(JSONValue);
            if (date) {
                ((XZJSONSetter)objc_msgSend)(model, property->_setter, date);
                return YES;
            }
            return NO;
        }
        case XZJSONClassTypeNSData: {
            NSData *data = NSDataFromJSONValue(JSONValue, NO);
            if (data) {
                ((XZJSONSetter)objc_msgSend)(model, property->_setter, data);
                return YES;
            }
            return NO;
        }
        case XZJSONClassTypeNSMutableData: {
            NSMutableData *data = NSDataFromJSONValue(JSONValue, YES);
            if (data) {
                ((XZJSONSetter)objc_msgSend)(model, property->_setter, data);
                return YES;
            }
            return NO;
        }
    }
}

static inline BOOL XZJSONModelDecodeStructProperty(id model, XZJSONPropertyDescriptor *property, id _Nonnull JSONValue) {
    if ([JSONValue isKindOfClass:NSString.class]) {
        switch (property->_structType) {
            case XZJSONStructTypeUnknown: {
                return NO;
            }
            case XZJSONStructTypeCGRect: {
                CGRect const aValue = CGRectFromString(JSONValue);
                ((void (*)(id, SEL, CGRect))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
            case XZJSONStructTypeCGSize: {
                CGSize const aValue = CGSizeFromString(JSONValue);
                ((void (*)(id, SEL, CGSize))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
            case XZJSONStructTypeCGPoint: {
                CGPoint const aValue = CGPointFromString(JSONValue);
                ((void (*)(id, SEL, CGPoint))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
            case XZJSONStructTypeUIEdgeInsets: {
                UIEdgeInsets const aValue = UIEdgeInsetsFromString(JSONValue);
                ((void (*)(id, SEL, UIEdgeInsets))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
            case XZJSONStructTypeCGVector: {
                CGVector const aValue = CGVectorFromString(JSONValue);
                ((void (*)(id, SEL, CGVector))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
            case XZJSONStructTypeCGAffineTransform: {
                CGAffineTransform const aValue = CGAffineTransformFromString(JSONValue);
                ((void (*)(id, SEL, CGAffineTransform))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
            case XZJSONStructTypeNSDirectionalEdgeInsets: {
                NSDirectionalEdgeInsets const aValue = NSDirectionalEdgeInsetsFromString(JSONValue);
                ((void (*)(id, SEL, NSDirectionalEdgeInsets))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
            case XZJSONStructTypeUIOffset: {
                UIOffset const aValue = UIOffsetFromString(JSONValue);
                ((void (*)(id, SEL, UIOffset))objc_msgSend)(model, property->_setter, aValue);
                return YES;
            }
        }
    }
    return NO;
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
            char value = 0;
            if (NSCharFromJSONValue(JSONValue, &value)) {
                ((void (*)(id, SEL, char))objc_msgSend)((id)model, property->_setter, value);
                return;
            }
            break;
        }
        case XZObjcTypeUnsignedChar: {
            char value = 0;
            if (NSCharFromJSONValue(JSONValue, &value)) {
                ((void (*)(id, SEL, unsigned char))objc_msgSend)((id)model, property->_setter, (unsigned char)value);
                return;
            }
            break;
        }
        case XZObjcTypeInt: {
            int value = 0;
            if (NSIntegerFromJSONValue(JSONValue, &value)) {
                ((void (*)(id, SEL, int))objc_msgSend)((id)model, property->_setter, (int)value);
                return;
            }
            break;
        }
        case XZObjcTypeUnsignedInt: {
            int value = 0;
            if (NSIntegerFromJSONValue(JSONValue, &value)) {
                ((void (*)(id, SEL, unsigned int))objc_msgSend)((id)model, property->_setter, (unsigned int)value);
                return;
            }
            return;
        }
        case XZObjcTypeShort: {
            int value = 0;
            if (NSIntegerFromJSONValue(JSONValue, &value)) {
                ((void (*)(id, SEL, short))objc_msgSend)((id)model, property->_setter, (short)value);
                return;
            }
            break;
        }
        case XZObjcTypeUnsignedShort: {
            int value = 0;
            if (NSIntegerFromJSONValue(JSONValue, &value)) {
                ((void (*)(id, SEL, unsigned short))objc_msgSend)((id)model, property->_setter, (unsigned short)value);
                return;
            }
            break;
        }
        case XZObjcTypeLong: {
            long value = 0;
            if (NSLongIntegerFromJSONValue(JSONValue, &value)) {
                ((void (*)(id, SEL, long))objc_msgSend)((id)model, property->_setter, (long)value);
                return;
            }
            break;
        }
        case XZObjcTypeUnsignedLong: {
            long value = 0;
            if (NSLongIntegerFromJSONValue(JSONValue, &value)) {
                ((void (*)(id, SEL, unsigned long))objc_msgSend)((id)model, property->_setter, (unsigned long)value);
                return;
            }
            break;;
        }
        case XZObjcTypeLongLong: {
            long long value = 0;
            if (NSLongLongIntegerFromJSONValue(JSONValue, &value)) {
                ((void (*)(id, SEL, long long))objc_msgSend)((id)model, property->_setter, (long long)value);
                return;
            }
            break;
        }
        case XZObjcTypeUnsignedLongLong: {
            long long value = 0;
            if (NSLongLongIntegerFromJSONValue(JSONValue, &value)) {
                ((void (*)(id, SEL, unsigned long long))objc_msgSend)((id)model, property->_setter, (unsigned long long)value);
                return;
            }
            break;;
        }
        case XZObjcTypeFloat: {
            float value = 0;
            if (NSFloatFromJSONValue(JSONValue, &value)) {
                ((void (*)(id, SEL, float))objc_msgSend)((id)model, property->_setter, value);
                return;
            }
            break;
        }
        case XZObjcTypeDouble: {
            double value = 0;
            if (NSDoubleFromJSONValue(JSONValue, &value)) {
                ((void (*)(id, SEL, long long))objc_msgSend)((id)model, property->_setter, value);
                return;
            }
            break;
        }
        case XZObjcTypeLongDouble: {
            long double value = 0;
            if (NSLongDoubleFromJSONValue(JSONValue, &value)) {
                ((void (*)(id, SEL, long double))objc_msgSend)((id)model, property->_setter, value);
                return;
            }
            break;
        }
        case XZObjcTypeBool: {
            BOOL value = 0;
            if (NSBoolFromJSONValue(JSONValue, &value)) {
                ((void (*)(id, SEL, BOOL))objc_msgSend)((id)model, property->_setter, value);
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
                return;
            }
            if (object_isClass(JSONValue)) {
                ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, property->_setter, JSONValue);
                return;
            }
            if ([JSONValue isKindOfClass:[NSString class]]) {
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
                return;
            }
            if ([JSONValue isKindOfClass:[NSString class]]) {
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
                    value = NSStringFromJSONValue(JSONValue, NO);
                    break;
                }
                case XZJSONClassTypeNSMutableString: {
                    value = NSStringFromJSONValue(JSONValue, YES);
                    break;
                }
                case XZJSONClassTypeNSValue: {
                    if ([JSONValue isKindOfClass:[NSValue class]]) {
                        value = JSONValue;
                    }
                    break;
                }
                case XZJSONClassTypeNSNumber: {
                    value = NSObjectNumberFromJSONValue(JSONValue);
                    break;
                }
                case XZJSONClassTypeNSDecimalNumber: {
                    value = NSDecimalNumberFromJSONValue(JSONValue);
                    break;
                }
                case XZJSONClassTypeNSData: {
                    if ([JSONValue isKindOfClass:NSData.class]) {
                        value = JSONValue;
                    }
                    break;
                }
                case XZJSONClassTypeNSMutableData: {
                    if ([JSONValue isKindOfClass:NSMutableData.class]) {
                        value = JSONValue;
                    } else if ([JSONValue isKindOfClass:NSData.class]) {
                        value = [NSMutableData dataWithData:JSONValue];
                    }
                    break;
                }
                case XZJSONClassTypeNSDate: {
                    if ([JSONValue isKindOfClass:NSDate.class]) {
                        value = JSONValue;
                    }
                    break;
                }
                case XZJSONClassTypeNSURL: {
                    value = NSURLFromJSONValue(JSONValue);
                    break;
                }
                case XZJSONClassTypeNSArray: {
                    value = NSArrayFromJSONValue(JSONValue, property->_elementType, NO);
                    break;
                }
                case XZJSONClassTypeNSMutableArray: {
                    value = NSArrayFromJSONValue(JSONValue, property->_elementType, YES);
                    break;
                }
                case XZJSONClassTypeNSSet: {
                    value = NSSetFromJSONValue(JSONValue, property->_elementType, NSMutableSet.class);
                    break;
                }
                case XZJSONClassTypeNSMutableSet: {
                    value = NSSetFromJSONValue(JSONValue, property->_elementType, NSMutableSet.class);
                    break;
                }
                case XZJSONClassTypeNSCountedSet: {
                    value = NSSetFromJSONValue(JSONValue, property->_elementType, NSCountedSet.class);
                    break;
                }
                case XZJSONClassTypeNSOrderedSet: {
                    value = NSOrderedSetFromJSONValue(JSONValue, property->_elementType);
                    break;
                }
                case XZJSONClassTypeNSMutableOrderedSet: {
                    value = NSOrderedSetFromJSONValue(JSONValue, property->_elementType);
                    break;
                }
                case XZJSONClassTypeNSDictionary: {
                    value = NSDictionaryFromJSONValue(JSONValue, property->_elementType, NO);
                    break;
                }
                case XZJSONClassTypeNSMutableDictionary: {
                    value = NSDictionaryFromJSONValue(JSONValue, property->_elementType, YES);
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
        if ([(id<XZJSONCoding>)model JSONDecodeValue:JSONValue forKey:property->_name]) {
            return;
        }
    }
    
    // 尝试默认解析
    if (XZJSONModelDecodePropertyFallback(model, property, JSONValue)) {
        return;
    }
    
    XZLog(@"[XZJSON] Can not decode value `%@` for property `%@` of `%@`", JSONValue, property->_name, property->_class->_class.name);
}

/// 读取 JSON 字典中 keyPath 中最后一个 key 所在的字典，如果中间值不存在，则创建。
/// - Parameters:
///   - dictionary: JSON 字典
///   - keyPath: 键路径
static inline NSMutableDictionary *NSDictionaryForLastKeyInKeyPath(NSMutableDictionary *dictionary, NSArray<NSString *> *keyPath) {
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

static inline NSString * _Nullable XZJSONModelEncodeStructProperty(id model, XZJSONPropertyDescriptor *property) {
    switch (property->_structType) {
        case XZJSONStructTypeUnknown: {
            return nil;
        }
        case XZJSONStructTypeCGRect: {
            CGRect aValue = ((CGRect (*)(id, SEL))objc_msgSend)(model, property->_getter);
            return NSStringFromCGRect(aValue);
        }
        case XZJSONStructTypeCGSize: {
            CGSize aValue = ((CGSize (*)(id, SEL))objc_msgSend)(model, property->_getter);
            return NSStringFromCGSize(aValue);
        }
        case XZJSONStructTypeCGPoint: {
            CGPoint aValue = ((CGPoint (*)(id, SEL))objc_msgSend)(model, property->_getter);
            return NSStringFromCGPoint(aValue);
        }
        case XZJSONStructTypeUIEdgeInsets: {
            UIEdgeInsets aValue = ((UIEdgeInsets (*)(id, SEL))objc_msgSend)(model, property->_getter);
            return NSStringFromUIEdgeInsets(aValue);
        }
        case XZJSONStructTypeCGVector: {
            CGVector aValue = ((CGVector (*)(id, SEL))objc_msgSend)(model, property->_getter);
            return NSStringFromCGVector(aValue);
        }
        case XZJSONStructTypeCGAffineTransform: {
            CGAffineTransform aValue = ((CGAffineTransform (*)(id, SEL))objc_msgSend)(model, property->_getter);
            return NSStringFromCGAffineTransform(aValue);
        }
        case XZJSONStructTypeNSDirectionalEdgeInsets: {
            NSDirectionalEdgeInsets aValue = ((NSDirectionalEdgeInsets (*)(id, SEL))objc_msgSend)(model, property->_getter);
            return NSStringFromDirectionalEdgeInsets(aValue);
        }
        case XZJSONStructTypeUIOffset: {
            UIOffset aValue = ((UIOffset (*)(id, SEL))objc_msgSend)(model, property->_getter);
            return NSStringFromUIOffset(aValue);
        }
    }
}

static inline id _Nullable XZJSONModelEncodePropertyFallback(id model, XZJSONPropertyDescriptor *property) {
    switch (property->_classType) {
        case XZJSONClassTypeNSDate:
        case XZJSONClassTypeNSData:
        case XZJSONClassTypeNSMutableData:
        case XZJSONClassTypeNSValue: {
            id const value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
            XZJSONClassDescriptor *valueClass = [XZJSONClassDescriptor descriptorForClass:object_getClass(value)];
            return [XZJSON _encodeObject:value intoDictionary:nil descriptor:valueClass];
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
                        JSONValue = [XZJSON _encodeObject:value intoDictionary:dict descriptor:valueClass];
                    } else {
                        JSONValue = [XZJSON _encodeObject:value intoDictionary:nil descriptor:valueClass];
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

#pragma mark - NSDescription

static NSString * _Nonnull XZJSONModelDescriptionForNSCollection(id<NSFastEnumeration> const model, NSUInteger count, NSUInteger indent) {
    if (count == 0) {
        return @"[]";
    }
    
    NSString * const padding = [@"" stringByPaddingToLength:indent * 4 withString:@" " startingAtIndex:0];
    indent += 1;
    
    NSMutableString *desc = [NSMutableString stringWithString:@"[\n"];
    for (id obj in (id<NSFastEnumeration>)model) {
        NSString *description = XZJSONModelDescription(obj, indent);
        [desc appendFormat:@"%@    %@,\n", padding, description];
    }
    [desc deleteCharactersInRange:NSMakeRange(desc.length - 2, 1)];
    [desc appendFormat:@"%@]", padding];
    
    return desc;
}

NSString * _Nonnull XZJSONModelDescriptionForFoundationClassOfType(id model, XZJSONClassType const classType, NSUInteger indent) {
    switch (classType) {
        case XZJSONClassTypeNSString:
        case XZJSONClassTypeNSMutableString: {
            NSString *aString = model;
            aString = [aString stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
            return [NSString stringWithFormat:@"\"%@\"", aString];
        }
        case XZJSONClassTypeNSValue: {
            return ((NSValue *)model).description;
            break;
        }
        case XZJSONClassTypeNSNumber: {
            return [(NSNumber *)model stringValue];
        }
        case XZJSONClassTypeNSData:
        case XZJSONClassTypeNSMutableData: {
            return [(NSData *)model description];
        }
        case XZJSONClassTypeNSDecimalNumber: {
            return [(NSDecimalNumber *)model stringValue];
        }
        case XZJSONClassTypeNSDate: {
            return [XZJSON.dateFormatter stringFromDate:model];
        }
        case XZJSONClassTypeNSURL: {
            return ((NSURL *)model).absoluteString;
        }
        case XZJSONClassTypeNSSet:
        case XZJSONClassTypeNSMutableSet:
        case XZJSONClassTypeNSCountedSet: {
            return XZJSONModelDescriptionForNSCollection(((NSSet *)model).allObjects, ((NSSet *)model).count, indent);
        }
        case XZJSONClassTypeNSOrderedSet:
        case XZJSONClassTypeNSMutableOrderedSet: {
            return XZJSONModelDescriptionForNSCollection((NSOrderedSet *)model, ((NSOrderedSet *)model).count, indent);
        }
        case XZJSONClassTypeNSArray:
        case XZJSONClassTypeNSMutableArray: {
            return XZJSONModelDescriptionForNSCollection((NSArray *)model, ((NSArray *)model).count, indent);
        }
        case XZJSONClassTypeNSDictionary:
        case XZJSONClassTypeNSMutableDictionary: {
            NSDictionary * const dict  = (id)model;
            NSUInteger     const count = dict.count;
            if (count == 0) {
                return @"{}";
            }
            
            NSString * const padding = [@"" stringByPaddingToLength:indent * 4 withString:@" " startingAtIndex:0];
            indent += 1;
            
            NSMutableString *desc = [NSMutableString stringWithString:@"{\n"];
            [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                key = [key description];
                obj = XZJSONModelDescription(obj, indent);
                [desc appendFormat:@"%@    %@: %@,\n", padding, key, obj];
            }];
            [desc deleteCharactersInRange:NSMakeRange(desc.length - 2, 1)];
            [desc appendFormat:@"%@}", padding];
            
            return desc;
        }
        case XZJSONClassTypeUnknown: {
            @throw [NSException exceptionWithName:NSGenericException reason:@"" userInfo:nil];
        }
    }
}

NSString * _Nonnull XZJSONModelDescription(NSObject *_Nonnull model, NSUInteger indent) {
    if (!model) {
        return @"<nil>";
    }

    if (model == (id)kCFNull) {
        return @"<null>";
    }

    if (![model isKindOfClass:[NSObject class]]) {
        return [NSString stringWithFormat:@"<%@: %p>", object_getClass(model), model];
    }

    XZJSONClassDescriptor * const modelClass = [XZJSONClassDescriptor descriptorForClass:model.class];

    if (modelClass->_classType) {
        return XZJSONModelDescriptionForFoundationClassOfType(model, modelClass->_classType, indent);
    }
    
    if (modelClass->_properties.count == 0) {
        return [NSString stringWithFormat:@"<%@: %p>", model.class, model];
    }
    NSString * const padding = [@"" stringByPaddingToLength:indent * 4 withString:@" " startingAtIndex:0];
    indent += 1;
    
    NSMutableString *desc = [NSMutableString stringWithFormat:@"<%@: %p, properties: {\n", model.class, model];
    [modelClass->_properties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor * _Nonnull property, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = property->_name;
        NSString *value = nil;
        switch (property->_type) {
            case XZObjcTypeBool: {
                BOOL const aValue = ((BOOL (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = aValue ? @"true" : @"false";
                break;
            }
            case XZObjcTypeChar: {
                char const aValue = ((char (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%c", aValue];
                break;
            }
            case XZObjcTypeUnsignedChar: {
                unsigned char const aValue = ((unsigned char (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%c", aValue];
                break;
            }
            case XZObjcTypeShort: {
                short const aValue = ((short (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%d", aValue];
                break;
            }
            case XZObjcTypeUnsignedShort: {
                unsigned short const aValue = ((unsigned short (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%u", aValue];
                break;
            }
            case XZObjcTypeInt: {
                int const aValue = ((int (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%d", aValue];
                break;
            }
            case XZObjcTypeUnsignedInt: {
                unsigned int const aValue = ((unsigned int (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%u", aValue];
                break;
            }
            case XZObjcTypeLong: {
                long const aValue = ((long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%ld", aValue];
                break;
            }
            case XZObjcTypeUnsignedLong: {
                unsigned long const aValue = ((unsigned long (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%lu", aValue];
                break;
            }
            case XZObjcTypeFloat: {
                float const aValue = ((float (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%f", aValue];
                break;
            }
            case XZObjcTypeDouble: {
                double const aValue = ((double (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%lf", aValue];
                break;
            }
            case XZObjcTypeLongDouble: {
                long double const aValue = ((long double (*)(id, SEL))(void *) objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%Lf", aValue];
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
                    value = XZJSONModelDescriptionForFoundationClassOfType(value, property->_classType, indent);
                } else {
                    value = [XZJSON model:value description:indent];
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
            case XZObjcTypeArray:
            case XZObjcTypeString:
            case XZObjcTypePointer:
            case XZObjcTypeUnknown: {
                NSString *desc = nil;
                if (modelClass->_usesPropertyJSONEncodingMethod) {
                    desc = [NSString stringWithFormat:@"%@", [(id<XZJSONCoding>)model JSONEncodeValueForKey:key]];
                } else {
                    void *pointer = ((void *(*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                    desc = [NSString stringWithFormat:@"%p", pointer];
                }
                switch (property->_type) {
                    case XZObjcTypeArray: {
                        value = [NSString stringWithFormat:@"<array: %@, value: %@>", property->_property.type.name, desc];
                        break;
                    }
                    case XZObjcTypeString: {
                        value = [NSString stringWithFormat:@"<string: %@, value: %@>", property->_property.type.name, desc];
                        break;
                    }
                    case XZObjcTypePointer: {
                        value = [NSString stringWithFormat:@"<pointer: %@, value: %@>", property->_property.type.name, desc];
                        break;
                    }
                    case XZObjcTypeUnknown: {
                        value = [NSString stringWithFormat:@"<unknown: %@, value: %@>", property->_property.type.name, desc];
                        break;
                    }
                    default:
                        break;
                }
                break;
            }
            case XZObjcTypeStruct: {
                value = XZJSONModelEncodeStructProperty(model, property);
                if (value == nil) {
                    if (modelClass->_usesPropertyJSONEncodingMethod) {
                        value = [NSString stringWithFormat:@"%@", [(id<XZJSONCoding>)model JSONEncodeValueForKey:key]];
                    }
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
                    value = [NSString stringWithFormat:@"%@", [(id<XZJSONCoding>)model JSONEncodeValueForKey:key]];
                }
                if (value) {
                    value = [NSString stringWithFormat:@"<union: %@, value: %@>", key, value];
                } else {
                    value = [NSString stringWithFormat:@"<union: %@>", property->_property.type.name];
                }
                break;
            }
            case XZObjcTypeVoid: {
                value = @"<void>";
                break;
            }
            case XZObjcTypeBitField: {
                if (modelClass->_usesPropertyJSONEncodingMethod) {
                    value = [NSString stringWithFormat:@"%@", [(id<XZJSONCoding>)model JSONEncodeValueForKey:key]];
                }
                if (value) {
                    value = [NSString stringWithFormat:@"<BitField: %@>", value];
                } else {
                    value = [NSString stringWithFormat:@"<BitField: %ld bit>", (long)property->_property.type.sizeInBit];
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
        case XZJSONClassTypeNSMutableSet:
        case XZJSONClassTypeNSCountedSet:
        case XZJSONClassTypeNSOrderedSet:
        case XZJSONClassTypeNSMutableOrderedSet: {
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
                        
                        // 没有值
                        if (!aValue) {
                            return;
                        }
                        
                        // 值 实际类型 与 声明类型 不一致
                        if (property->_subtype && ![aValue isKindOfClass:property->_subtype]) {
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
                                case XZJSONClassTypeNSMutableSet:
                                case XZJSONClassTypeNSCountedSet:
                                case XZJSONClassTypeNSOrderedSet:
                                case XZJSONClassTypeNSMutableOrderedSet: {
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
                            case XZJSONClassTypeNSMutableSet:
                            case XZJSONClassTypeNSCountedSet:
                            case XZJSONClassTypeNSOrderedSet:
                            case XZJSONClassTypeNSMutableOrderedSet: {
                                // 检查元素是否合法：元素只要支持归档即可。
                                if (NSCollectionConformsNSCoding(aValue)) {
                                    [aCoder encodeObject:aValue forKey:name];
                                    return;
                                }
                                break;
                            }
                            case XZJSONClassTypeNSDictionary:
                            case XZJSONClassTypeNSMutableDictionary: {
                                // 检查元素是否合法：元素只需要支持归档即可
                                if (NSDictionaryConformsNSCoding(aValue)) {
                                    [aCoder encodeObject:aValue forKey:name];
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
                                [aCoder encodeObject:aValue forKey:name];
                                return;
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
                        return;
                    }
                }
                
                XZLog(@"[XZJSON] [NSCoding] Can not encode property `%@` of `%@`!", modelClass->_class.name, property->_name);
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
        case XZJSONClassTypeNSMutableSet:
        case XZJSONClassTypeNSCountedSet:
        case XZJSONClassTypeNSOrderedSet:
        case XZJSONClassTypeNSMutableOrderedSet: {
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
                    if ([((id<XZJSONCoding>)model) JSONDecodeValue:aCoder forKey:name]) {
                        return;
                    }
                }
                
                XZLog(@"[XZJSON] [NSCoding] Can not decode property `%@` of `%@`!", modelClass->_class.name, property->_name);
            }];
            break;
        }
    }
    
    return model;
}
