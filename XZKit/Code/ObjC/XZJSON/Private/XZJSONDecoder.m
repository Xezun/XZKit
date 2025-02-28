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
static void XZJSONModelDecodeProperty(id _Nonnull model, XZJSONPropertyDescriptor * _Nonnull property, id _Nonnull JSONValue);

id _Nullable XZJSONDecodeJSONData(NSData *data, NSJSONReadingOptions options, Class aClass) {
    NSError *error = nil;
    id const object = [NSJSONSerialization JSONObjectWithData:data options:options error:&error];
    if ((error == nil || error.code == noErr) && object != nil) {
        return XZJSONDecodeJSONObject(object, aClass);
    }
    return nil;
}

id _Nullable XZJSONDecodeJSONObject(id object, Class aClass) {
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
            XZJSONModelDecodeFromDictionary(model, descriptor, dictionary);
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

typedef struct XZJSONEnumeratorContext {
    void *modelClass;
    void *model;
    void *dictionary;
} XZJSONEnumeratorContext;

static void XZJSONDictionaryEnumerator(const void *_key, const void *_value, void *_context) {
    XZJSONEnumeratorContext  * const                     context    = _context;
    id                         const __unsafe_unretained model      = (__bridge id)(context->model);
    XZJSONClassDescriptor    * const __unsafe_unretained modelClass = (__bridge XZJSONClassDescriptor *)(context->modelClass);
    
    XZJSONPropertyDescriptor * __unsafe_unretained property = CFDictionaryGetValue((CFDictionaryRef)modelClass->_keyProperties, _key); //[modelClass->_keyProperties objectForKey:(__bridge id)(_key)];
    while (property) {
        if (property->_setter) {
            XZJSONModelDecodeProperty(model, property, (__bridge __unsafe_unretained id)_value);
        }
        property = property->_next;
    };
}

static void XZJSONPropertyArrayEnumerator(const void * const propertyRef, void * const contextRef) {
    XZJSONEnumeratorContext  * const                     context    = contextRef;
    NSDictionary             * const __unsafe_unretained dictionary = (__bridge NSDictionary *)(context->dictionary);
    XZJSONPropertyDescriptor * const __unsafe_unretained property   = (__bridge XZJSONPropertyDescriptor *)(propertyRef);
    
    id const value = (property->_keyValueCoder)(dictionary);
    if (value) {
        __unsafe_unretained id const model = (__bridge id)(context->model);
        XZJSONModelDecodeProperty(model, property, value);
    }
}

void XZJSONModelDecodeFromDictionary(id model, XZJSONClassDescriptor *modelClass, NSDictionary *dictionary) {
    // 没有可用的属性
    if (modelClass->_numberOfProperties == 0) {
        return;
    }
    
    XZJSONEnumeratorContext context = (XZJSONEnumeratorContext){
        (__bridge void *)modelClass,
        (__bridge void *)model,
        (__bridge void *)dictionary
    };
   
    // 遍历数量少的集合，可以提高通用模型的解析效率。
    if (modelClass->_numberOfProperties >= CFDictionaryGetCount((CFDictionaryRef)dictionary)) {
        // 遍历 key 映射的属性
        CFDictionaryApplyFunction((CFDictionaryRef)dictionary, XZJSONDictionaryEnumerator, &context);
        
        // 遍历 keyPath 映射的属性
        if (modelClass->_keyPathProperties) {
            CFRange const range = CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelClass->_keyPathProperties));
            CFArrayApplyFunction((CFArrayRef)modelClass->_keyPathProperties, range, XZJSONPropertyArrayEnumerator, &context);
        }
        
        // 遍历 keyArray 映射的属性
        if (modelClass->_keyArrayProperties) {
            CFRange const range = CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelClass->_keyArrayProperties));
            CFArrayApplyFunction((CFArrayRef)modelClass->_keyArrayProperties, range, XZJSONPropertyArrayEnumerator, &context);
        }
    } else {
        // 遍历所有属性
        CFRange const range = CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelClass->_properties));
        CFArrayApplyFunction((CFArrayRef)modelClass->_properties, range, XZJSONPropertyArrayEnumerator, &context);
    }
}

FOUNDATION_STATIC_INLINE BOOL NSCharFromJSONValue(id _Nonnull JSONValue, char *value) {
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

FOUNDATION_STATIC_INLINE BOOL NSIntegerFromJSONValue(id _Nonnull JSONValue, int *value) {
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

FOUNDATION_STATIC_INLINE BOOL NSLongIntegerFromJSONValue(id _Nonnull JSONValue, long *value) {
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

FOUNDATION_STATIC_INLINE BOOL NSLongLongIntegerFromJSONValue(id _Nonnull JSONValue, long long *value) {
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

FOUNDATION_STATIC_INLINE BOOL NSFloatFromJSONValue(id _Nonnull JSONValue, float *value) {
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

FOUNDATION_STATIC_INLINE BOOL NSDoubleFromJSONValue(id _Nonnull JSONValue, double *value) {
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

FOUNDATION_STATIC_INLINE BOOL NSLongDoubleFromJSONValue(id _Nonnull JSONValue, long double *value) {
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

FOUNDATION_STATIC_INLINE BOOL NSBoolFromJSONValue(id _Nonnull JSONValue, BOOL *value) {
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
FOUNDATION_STATIC_INLINE NSString * _Nullable NSStringFromJSONValue(id JSONValue, BOOL mutable) {
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

FOUNDATION_STATIC_INLINE NSNumber * _Nullable NSObjectNumberFromJSONValue(id _Nonnull JSONValue) {
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
FOUNDATION_STATIC_INLINE NSDecimalNumber * _Nullable NSDecimalNumberFromJSONValue(id _Nonnull JSONValue) {
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

FOUNDATION_STATIC_INLINE NSURL * _Nullable NSURLFromJSONValue(id JSONValue) {
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

FOUNDATION_STATIC_INLINE NSArray * _Nullable NSArrayFromJSONValue(id _Nonnull const JSONValue, Class _Nullable const elementClass, BOOL mutable) {
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

FOUNDATION_STATIC_INLINE NSSet * _Nullable NSSetFromJSONValue(id _Nonnull const JSONValue, Class _Nullable const elementClass, Class MutableSetClass) {
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

FOUNDATION_STATIC_INLINE NSMutableOrderedSet * _Nullable NSOrderedSetFromJSONValue(id _Nonnull const JSONValue, Class _Nullable const elementClass) {
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

FOUNDATION_STATIC_INLINE NSDictionary * _Nullable NSDictionaryFromJSONValue(id _Nonnull const JSONValue, Class _Nullable const elementClass, BOOL mutable) {
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

FOUNDATION_STATIC_INLINE id NSDataFromJSONValue(id JSONValue, BOOL mutable) {
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
FOUNDATION_STATIC_INLINE NSDate *NSDateFromJSONValue(__unsafe_unretained id _Nonnull JSONValue) {
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
FOUNDATION_STATIC_INLINE BOOL XZJSONModelDecodePropertyFallback(id model, XZJSONPropertyDescriptor *property, id JSONValue) {
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
            if (NSStringIntoStructProperty(model, property, JSONValue)) {
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
                            XZJSONClassDescriptor *valueClass = [XZJSONClassDescriptor descriptorForClass:object_getClass(value)];
                            if (valueClass) {
                                XZJSONModelDecodeFromDictionary(value, valueClass, JSONValue);
                            }
                        } else {
                            value = XZJSONDecodeJSONObject(JSONValue, property->_subtype);
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
