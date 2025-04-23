//
//  XZJSONDecoder.m
//  XZJSON
//
//  Created by 徐臻 on 2025/2/28.
//

#import "XZMacro.h"
#import "NSCharacterSet+XZKit.h"
#import "NSData+XZKit.h"
#import "XZJSONDecoder.h"
#import "XZJSON.h"
#import "XZJSONClassDescriptor.h"
#import "XZJSONDefines.h"
#import "XZJSONPropertyDescriptor.h"

typedef void (*XZJSONSetter)(id _Nonnull, SEL _Nonnull, id _Nullable);
static void XZJSONModelDecodeProperty(id _Nonnull __unsafe_unretained model, XZJSONPropertyDescriptor * _Nonnull __unsafe_unretained property, id _Nonnull __unsafe_unretained JSONValue);

id _Nullable XZJSONDecodeJSONData(NSData * const __unsafe_unretained data, NSJSONReadingOptions const options, Class const __unsafe_unretained aClass) {
    NSError *error = nil;
    id const object = [NSJSONSerialization JSONObjectWithData:data options:options error:&error];
    if ((error == nil || error.code == noErr) && object != nil) {
        return XZJSONDecodeJSONObject(object, aClass);
    }
    return nil;
}

FOUNDATION_STATIC_INLINE id _Nullable XZJSONDecodeJSONDictionary(Class __unsafe_unretained modelRawClass, XZJSONClassDescriptor * _Nullable __unsafe_unretained modelClass, NSDictionary * __strong JSONDictionary) {
    // 获取模型描述
    if (modelClass == nil) {
        modelClass = [XZJSONClassDescriptor descriptorWithClass:modelRawClass]; // 单例，不需要强持有
    }
    // 转发解析
    if (modelClass->_forwardsClassForDecoding) {
        Class const newRawClass = [modelRawClass forwardingClassForJSONDictionary:JSONDictionary];
        if (newRawClass == Nil) {
            return nil;
        }
        if (newRawClass != modelRawClass) {
            modelRawClass = newRawClass;
            modelClass = [XZJSONClassDescriptor descriptorWithClass:modelRawClass];
        }
    }
    // 数据校验
    if (modelClass->_verifiesValueForDecoding) {
        JSONDictionary = [modelRawClass canDecodeFromJSONDictionary:JSONDictionary];
        if (JSONDictionary == nil) {
            return nil;
        }
        NSCAssert([JSONDictionary isKindOfClass:NSDictionary.class], @"[XZJSON] 方法 +canDecodeFromJSONDictionary: 的返回值必须是 NSDictionary 对象");
    }
    // 自定义初始化过程
    if (modelClass->_usesJSONDecodingInitializer) {
        return [[modelRawClass alloc] initWithJSONDictionary:JSONDictionary];
    }
    // 通用初始化方法
    id const model = [modelRawClass new];
    if (model != nil) {
        XZJSONModelDecodeFromDictionary(model, modelClass, JSONDictionary);
    }
    return model;
}

id _Nullable XZJSONDecodeJSONObject(id const __unsafe_unretained object, Class const __unsafe_unretained aClass) {
    if (object == NSNull.null) {
        return nil;
    }
    // 如果为字典，则认为是模型数据。
    if ([object isKindOfClass:NSDictionary.class]) {
        return XZJSONDecodeJSONDictionary(aClass, nil, object);
    }
    // 如果是数组，则对数组元素是模型数据（也可能是模型数据数组）。
    if ([object isKindOfClass:NSArray.class]) {
        NSArray * const array = object;
        if (array.count == 0) {
            return array;
        }
        
        NSMutableArray * const models = [NSMutableArray arrayWithCapacity:array.count];
        for (id item in array) {
            id const model = XZJSONDecodeJSONObject(item, aClass);
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

typedef struct XZJSONDecodeEnumeratorContext {
    void *modelClass;
    void *model;
    void *dictionary;
} XZJSONDecodeEnumeratorContext;

/// 用于遍历 NSDictionary 的函数。
static void XZJSONDecodePropertyDictionaryEnumerator(const void *_key, const void *_value, void *_context) {
    XZJSONDecodeEnumeratorContext * const                     context    = _context;
    id                              const __unsafe_unretained model      = (__bridge id)(context->model);
    XZJSONClassDescriptor         * const __unsafe_unretained modelClass = (__bridge XZJSONClassDescriptor *)(context->modelClass);
    
    XZJSONPropertyDescriptor * __unsafe_unretained property = CFDictionaryGetValue((CFDictionaryRef)modelClass->_keyProperties, _key);
    while (property) {
        if (property->_setter) {
            XZJSONModelDecodeProperty(model, property, (__bridge __unsafe_unretained id)_value);
        }
        property = property->_next;
    };
}

/// 用于遍历模型属性数组的函数。
static void XZJSONDecodePropertyArrayEnumerator(const void * const propertyRef, void * const contextRef) {
    XZJSONDecodeEnumeratorContext * const                     context    = contextRef;
    NSDictionary                  * const __unsafe_unretained dictionary = (__bridge NSDictionary *)(context->dictionary);
    XZJSONPropertyDescriptor      * const __unsafe_unretained property   = (__bridge XZJSONPropertyDescriptor *)(propertyRef);
    
    id const value = (property->_valueDecoder)(dictionary);
    if (value) {
        __unsafe_unretained id const model = (__bridge id)(context->model);
        XZJSONModelDecodeProperty(model, property, value);
    }
}

void XZJSONModelDecodeFromDictionary(id const __unsafe_unretained model, XZJSONClassDescriptor * const __unsafe_unretained modelClass, NSDictionary * const __unsafe_unretained dictionary) {
    // 没有可用的属性
    if (modelClass->_numberOfProperties == 0) {
        return;
    }
    
    XZJSONDecodeEnumeratorContext context = (XZJSONDecodeEnumeratorContext){
        (__bridge void *)modelClass,
        (__bridge void *)model,
        (__bridge void *)dictionary
    };
   
    // 遍历数量少的集合，可以提高通用模型的解析效率。
    if (modelClass->_numberOfProperties >= CFDictionaryGetCount((CFDictionaryRef)dictionary)) {
        // 遍历 key 映射的属性
        CFDictionaryApplyFunction((CFDictionaryRef)dictionary, XZJSONDecodePropertyDictionaryEnumerator, &context);
        
        // 遍历 keyPath 映射的属性
        if (modelClass->_keyPathProperties) {
            CFRange const range = CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelClass->_keyPathProperties));
            CFArrayApplyFunction((CFArrayRef)modelClass->_keyPathProperties, range, XZJSONDecodePropertyArrayEnumerator, &context);
        }
        
        // 遍历 keyArray 映射的属性
        if (modelClass->_keyArrayProperties) {
            CFRange const range = CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelClass->_keyArrayProperties));
            CFArrayApplyFunction((CFArrayRef)modelClass->_keyArrayProperties, range, XZJSONDecodePropertyArrayEnumerator, &context);
        }
    } else {
        // 遍历所有属性
        CFRange const range = CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelClass->_properties));
        CFArrayApplyFunction((CFArrayRef)modelClass->_properties, range, XZJSONDecodePropertyArrayEnumerator, &context);
    }
}

FOUNDATION_STATIC_INLINE BOOL NSCharFromJSONValue(id const _Nonnull __unsafe_unretained JSONValue, char *value) {
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

FOUNDATION_STATIC_INLINE BOOL NSIntegerFromJSONValue(id const _Nonnull __unsafe_unretained JSONValue, int *value) {
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

#if !XZ_LONG_IS_LLONG
FOUNDATION_STATIC_INLINE BOOL NSLongIntegerFromJSONValue(id const _Nonnull __unsafe_unretained JSONValue, long *value) {
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
#endif

FOUNDATION_STATIC_INLINE BOOL NSLongLongIntegerFromJSONValue(id const _Nonnull __unsafe_unretained JSONValue, long long *value) {
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

FOUNDATION_STATIC_INLINE BOOL NSFloatFromJSONValue(id const _Nonnull __unsafe_unretained JSONValue, float *value) {
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

FOUNDATION_STATIC_INLINE BOOL NSDoubleFromJSONValue(id const  _Nonnull __unsafe_unretained JSONValue, double *value) {
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

FOUNDATION_STATIC_INLINE BOOL NSLongDoubleFromJSONValue(id const _Nonnull __unsafe_unretained JSONValue, long double *value) {
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

FOUNDATION_STATIC_INLINE BOOL NSBoolFromJSONValue(id const _Nonnull __unsafe_unretained JSONValue, BOOL *value) {
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
FOUNDATION_STATIC_INLINE NSString * _Nullable NSStringFromJSONValue(id const __unsafe_unretained JSONValue, BOOL mutable) {
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

FOUNDATION_STATIC_INLINE NSNumber * _Nullable NSObjectNumberFromJSONValue(id const _Nonnull __unsafe_unretained JSONValue) {
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
FOUNDATION_STATIC_INLINE NSDecimalNumber * _Nullable NSDecimalNumberFromJSONValue(id const _Nonnull __unsafe_unretained JSONValue) {
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

FOUNDATION_STATIC_INLINE NSURL * _Nullable NSURLFromJSONValue(id const _Nonnull __unsafe_unretained JSONValue) {
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

FOUNDATION_STATIC_INLINE NSArray * _Nullable NSArrayFromJSONValue(id const _Nonnull __unsafe_unretained JSONValue, Class _Nullable const elementClass, BOOL mutable) {
    if ([JSONValue isKindOfClass:NSArray.class]) {
        if (elementClass) {
            NSMutableArray * const arrayM = [NSMutableArray arrayWithCapacity:((NSArray *)JSONValue).count];
            for (id data in (NSArray *)JSONValue) {
                id const model = XZJSONDecodeJSONObject(data, elementClass);
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
            id const model = XZJSONDecodeJSONObject(JSONValue, elementClass);
            if (model) {
                return [NSMutableArray arrayWithObject:model];
            }
            return nil;
        }
        return nil;
    }
    
    return [NSMutableArray arrayWithObject:JSONValue];
}

FOUNDATION_STATIC_INLINE NSSet * _Nullable NSSetFromJSONValue(id const _Nonnull __unsafe_unretained JSONValue, Class _Nullable const elementClass, Class const MutableSetClass) {
    if ([JSONValue isKindOfClass:NSArray.class]) {
        if (elementClass) {
            NSMutableSet * const setM = [MutableSetClass setWithCapacity:((NSArray *)JSONValue).count];
            for (id data in (NSArray *)JSONValue) {
                id const model = XZJSONDecodeJSONObject(data, elementClass);
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
            id const model = XZJSONDecodeJSONObject(JSONValue, elementClass);
            if (model) {
                return [MutableSetClass setWithObject:model];
            }
        }
        return nil;
    }
    
    return [MutableSetClass setWithObject:JSONValue];
}

FOUNDATION_STATIC_INLINE NSMutableOrderedSet * _Nullable NSOrderedSetFromJSONValue(id const _Nonnull __unsafe_unretained JSONValue, Class const _Nullable elementClass) {
    if ([JSONValue isKindOfClass:NSArray.class]) {
        if (elementClass) {
            NSMutableOrderedSet * const orderedSetM = [NSMutableOrderedSet orderedSetWithCapacity:((NSArray *)JSONValue).count];
            for (id data in (NSArray *)JSONValue) {
                id const model = XZJSONDecodeJSONObject(data, elementClass);
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
            id const model = XZJSONDecodeJSONObject(JSONValue, elementClass);
            if (model) {
                return [NSMutableOrderedSet orderedSetWithObject:model];
            }
            return nil;
        }
        return nil;
    }
    
    return [NSMutableOrderedSet orderedSetWithObject:JSONValue];
}

FOUNDATION_STATIC_INLINE NSDictionary * _Nullable NSDictionaryFromJSONValue(id const _Nonnull __unsafe_unretained JSONValue, Class _Nullable const elementClass, BOOL mutable) {
    if (elementClass) {
        if ([JSONValue isKindOfClass:NSDictionary.class]) {
            NSMutableDictionary *dictM = [NSMutableDictionary new];
            [((NSDictionary *)JSONValue) enumerateKeysAndObjectsUsingBlock:^(NSString *oneKey, id oneValue, BOOL *stop) {
                dictM[oneKey] = XZJSONDecodeJSONObject(oneValue, elementClass);
            }];
            return dictM;
        }
        
        if ([JSONValue isKindOfClass:NSArray.class]) {
            NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
            [(NSArray *)JSONValue enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *key = [NSString stringWithFormat:@"%ld", (long)idx];
                dictM[key] = XZJSONDecodeJSONObject(obj, elementClass);
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

FOUNDATION_STATIC_INLINE id NSDataFromJSONValue(id const _Nonnull __unsafe_unretained JSONValue, BOOL mutable) {
    if ([JSONValue isKindOfClass:NSString.class]) {
        // 符合 RFC2397 URL Data 规范的字符
        // data:[<mediatype>][;base64],<data>
        // https://datatracker.ietf.org/doc/html/rfc2397
        NSString * const JSONString = JSONValue;
        NSUInteger const JSONLength = JSONString.length;
        if ([JSONString hasPrefix:@"data:"] && JSONLength > 5) {
            NSString *type = nil;
            NSString *data = nil;
            
            NSUInteger const max = [JSONString rangeOfString:@"," options:0 range:NSMakeRange(5, MIN(1024, JSONLength - 5))].location;
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
FOUNDATION_STATIC_INLINE NSDate *NSDateFromJSONValue(id const _Nonnull __unsafe_unretained JSONValue) {
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
FOUNDATION_STATIC_INLINE BOOL XZJSONModelDecodePropertyFallback(id const __unsafe_unretained model, XZJSONPropertyDescriptor * const __unsafe_unretained property, id const __unsafe_unretained JSONValue) {
    switch (property->_foundationClass) {
        case XZJSONFoundationClassUnknown:
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
            // 这些值类型，不需要默认解析。
            return NO;
        }
        case XZJSONFoundationClassNSValue: {
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
            
            switch (XZJSONFoundationStructFromString(type)) {
                case XZJSONFoundationStructUnknown: {
                    return NO;
                }
                case XZJSONFoundationStructCGRect: {
                    CGRect const aValue = CGRectFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithCGRect:aValue]);
                    return YES;
                }
                case XZJSONFoundationStructCGSize: {
                    CGSize const aValue = CGSizeFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithCGSize:aValue]);
                    return YES;
                }
                case XZJSONFoundationStructCGPoint: {
                    CGPoint const aValue = CGPointFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithCGPoint:aValue]);
                    return YES;
                }
                case XZJSONFoundationStructUIEdgeInsets: {
                    UIEdgeInsets const aValue = UIEdgeInsetsFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithUIEdgeInsets:aValue]);
                    return YES;
                }
                case XZJSONFoundationStructCGVector: {
                    CGVector const aValue = CGVectorFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithCGVector:aValue]);
                    return YES;
                }
                case XZJSONFoundationStructCGAffineTransform: {
                    CGAffineTransform const aValue = CGAffineTransformFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithCGAffineTransform:aValue]);
                    return YES;
                }
                case XZJSONFoundationStructNSDirectionalEdgeInsets: {
                    NSDirectionalEdgeInsets const aValue = NSDirectionalEdgeInsetsFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithDirectionalEdgeInsets:aValue]);
                    return YES;
                }
                case XZJSONFoundationStructUIOffset: {
                    UIOffset const aValue = UIOffsetFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithUIOffset:aValue]);
                    return YES;
                }
            }
            break;
        }
        case XZJSONFoundationClassNSDate: {
            NSDate *date = NSDateFromJSONValue(JSONValue);
            if (date) {
                ((XZJSONSetter)objc_msgSend)(model, property->_setter, date);
                return YES;
            }
            return NO;
        }
        case XZJSONFoundationClassNSData: {
            NSData *data = NSDataFromJSONValue(JSONValue, NO);
            if (data) {
                ((XZJSONSetter)objc_msgSend)(model, property->_setter, data);
                return YES;
            }
            return NO;
        }
        case XZJSONFoundationClassNSMutableData: {
            NSMutableData *data = NSDataFromJSONValue(JSONValue, YES);
            if (data) {
                ((XZJSONSetter)objc_msgSend)(model, property->_setter, data);
                return YES;
            }
            return NO;
        }
    }
}

void XZJSONModelDecodeProperty(id const __unsafe_unretained model, XZJSONPropertyDescriptor * const __unsafe_unretained property, id _Nonnull __strong JSONValue) {
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
#if !XZ_LONG_IS_LLONG
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
#endif
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
            if (XZJSONDecodeStructProperty(model, property, JSONValue)) {
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
            
            switch (property->_foundationClass) {
                case XZJSONFoundationClassNSString: {
                    value = NSStringFromJSONValue(JSONValue, NO);
                    break;
                }
                case XZJSONFoundationClassNSMutableString: {
                    value = NSStringFromJSONValue(JSONValue, YES);
                    break;
                }
                case XZJSONFoundationClassNSValue: {
                    if ([JSONValue isKindOfClass:[NSValue class]]) {
                        value = JSONValue;
                    }
                    break;
                }
                case XZJSONFoundationClassNSNumber: {
                    value = NSObjectNumberFromJSONValue(JSONValue);
                    break;
                }
                case XZJSONFoundationClassNSDecimalNumber: {
                    value = NSDecimalNumberFromJSONValue(JSONValue);
                    break;
                }
                case XZJSONFoundationClassNSData: {
                    if ([JSONValue isKindOfClass:NSData.class]) {
                        value = JSONValue;
                    }
                    break;
                }
                case XZJSONFoundationClassNSMutableData: {
                    if ([JSONValue isKindOfClass:NSMutableData.class]) {
                        value = JSONValue;
                    } else if ([JSONValue isKindOfClass:NSData.class]) {
                        value = [NSMutableData dataWithData:JSONValue];
                    }
                    break;
                }
                case XZJSONFoundationClassNSDate: {
                    if ([JSONValue isKindOfClass:NSDate.class]) {
                        value = JSONValue;
                    }
                    break;
                }
                case XZJSONFoundationClassNSURL: {
                    value = NSURLFromJSONValue(JSONValue);
                    break;
                }
                case XZJSONFoundationClassNSArray: {
                    value = NSArrayFromJSONValue(JSONValue, property->_elementType, NO);
                    break;
                }
                case XZJSONFoundationClassNSMutableArray: {
                    value = NSArrayFromJSONValue(JSONValue, property->_elementType, YES);
                    break;
                }
                case XZJSONFoundationClassNSSet: {
                    value = NSSetFromJSONValue(JSONValue, property->_elementType, NSMutableSet.class);
                    break;
                }
                case XZJSONFoundationClassNSMutableSet: {
                    value = NSSetFromJSONValue(JSONValue, property->_elementType, NSMutableSet.class);
                    break;
                }
                case XZJSONFoundationClassNSCountedSet: {
                    value = NSSetFromJSONValue(JSONValue, property->_elementType, NSCountedSet.class);
                    break;
                }
                case XZJSONFoundationClassNSOrderedSet: {
                    value = NSOrderedSetFromJSONValue(JSONValue, property->_elementType);
                    break;
                }
                case XZJSONFoundationClassNSMutableOrderedSet: {
                    value = NSOrderedSetFromJSONValue(JSONValue, property->_elementType);
                    break;
                }
                case XZJSONFoundationClassNSDictionary: {
                    value = NSDictionaryFromJSONValue(JSONValue, property->_elementType, NO);
                    break;
                }
                case XZJSONFoundationClassNSMutableDictionary: {
                    value = NSDictionaryFromJSONValue(JSONValue, property->_elementType, YES);
                    break;
                }
                case XZJSONFoundationClassUnknown: {
                    // 自定义类型
                    if (!property->_subtype || [JSONValue isKindOfClass:property->_subtype]) {
                        // 未指定对象类型，或者已经是指定的自定义对象类型，直接赋值
                        value = JSONValue;
                    } else {
                        XZJSONClassDescriptor * const valueClass = [XZJSONClassDescriptor descriptorWithClass:property->_subtype];
                        if (!valueClass) {
                            break;
                        }
                        // JSON 数据模型化为指定的自定义对象类型
                        if (![JSONValue isKindOfClass:[NSDictionary class]]) {
                            JSONValue = @{ @"rawValue": JSONValue }; // 非字典数据，包装为字典
                        }
                        // 如果属性已有值，直接更新它，否则创建新的。
                        value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);;
                        if ([value isKindOfClass:property->_subtype]) {
                            XZJSONModelDecodeFromDictionary(value, valueClass, JSONValue);
                        } else {
                            value = XZJSONDecodeJSONDictionary(property->_subtype, valueClass, JSONValue);
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
