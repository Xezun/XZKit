//
//  XZJSONDecoder.m
//  XZJSON
//
//  Created by Xezun on 2025/2/28.
//

#import "XZMacros.h"
#import "NSCharacterSet+XZKit.h"
#import "NSData+XZKit.h"
#import "XZJSONDecoder.h"
#import "XZJSON.h"
#import "XZJSONClass.h"
#import "XZJSONDefines.h"
#import "XZJSONProperty.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (*XZJSONSetter)(id, SEL, id _Nullable);
static void XZJSONModelDecodeProperty(id const _Untain model, XZJSONProperty * const _Untain property, id const _Untain rawValue);
NS_ASSUME_NONNULL_END

/// 字典转模型。
FOUNDATION_STATIC_INLINE id _Nullable XZJSONDecodeDictionary(Class _Untain ModelClass, XZJSONClass * _Nullable _Untain JSONClass, NSDictionary * _Untain dictionary, id _Nullable model) {
    // 获取模型描述
    if (JSONClass == nil) {
        JSONClass = [XZJSONClass classForClass:ModelClass]; // 单例，不需要强持有
        if (JSONClass == nil) {
            return nil;
        }
    }
    
    // 转发解析
    while (JSONClass->_forwardsDecodingClass) {
        Class const _Untain newModelClass = [ModelClass forwardingClassForJSONDictionary:dictionary];
        // 返回 Nil 表示不转发。
        if (newModelClass == Nil || newModelClass == ModelClass) {
            break;
        }
        // 转发的对象不能处理。
        XZJSONClass * const _Untain newJSONClass = [XZJSONClass classForClass:newModelClass];
        if (newJSONClass == nil) {
            return nil;
        }
        ModelClass = newModelClass;
        JSONClass = newJSONClass;
    }
    
    // 数据校验
    if (JSONClass->_verifiesDecodingValue) {
        dictionary = [ModelClass canDecodeFromJSONDictionary:dictionary];
        if (dictionary == nil) {
            return nil;
        }
        // 返回值必须是 NSDictionary 对象
        if (![dictionary isKindOfClass:NSDictionary.class]) {
            return nil;
        }
    }
    
    if (![model isKindOfClass:ModelClass]) {
        model = [[ModelClass alloc] init];
    }
    
    if (JSONClass->_usesModelDecodingMethod) {
        // 使用自定义初始化过程
        if ([model decodeFromJSONDictionary:dictionary]) {
            return model;
        }
        return nil;
    }
    
    // 使用通用初始化过程
    XZJSONModelDecodeFromDictionary(model, JSONClass, dictionary);
    return model;
}

/// 将二进制数据进行 JSON 序列化。参数 data 不能为空。
FOUNDATION_STATIC_INLINE id XZJSONSerialization(NSData *data, NSJSONReadingOptions const options) {
    NSError *error = nil;
    id const object = [NSJSONSerialization JSONObjectWithData:data options:options error:&error];
    if (error == nil || error.code == noErr) {
        return object;
    }
    return nil;
}

/// 在确定 object 为已解析的数据时，使用此方法。
FOUNDATION_STATIC_INLINE id _Nullable XZJSONDecodeObject(id const _Untain object, Class const _Untain ModelClass) {
    // 如果为字典，则认为是模型数据。
    if ([object isKindOfClass:NSDictionary.class]) {
        return XZJSONDecodeDictionary(ModelClass, nil, (NSDictionary *)object, nil);
    }
    // 如果是数组，则数组元素是模型数据（也可能是模型数据数组）。
    if ([object isKindOfClass:NSArray.class]) {
        NSUInteger const count = ((NSArray *)object).count;
        if (count == 0) {
            return object;
        }
        NSMutableArray * const models = [NSMutableArray arrayWithCapacity:count];
        for (id item in (NSArray *)object) {
            id const model = XZJSONDecodeObject(item, ModelClass);
            if (model) {
                [models addObject:model];
            }
        }
        return models;
    }
    // 模型化失败。
    return nil;
}

id _Nullable XZJSONDecodeData(id const _Untain data, NSJSONReadingOptions const options, Class const _Untain ModelClass) {
    if (data == nil || data == (id)kCFNull) {
        return nil;
    }
    
    id object = data;
    
    // JSON原始数据序列化
    if ([object isKindOfClass:NSData.class]) {
        object = XZJSONSerialization(object, options);
    } else if ([object isKindOfClass:NSString.class]) {
        // 字符串形式的 json 数据
        object = [(NSString *)object dataUsingEncoding:NSUTF8StringEncoding];
        if (object == nil) {
            return nil;
        }
        object = XZJSONSerialization(object, options);
    } else if ([object isKindOfClass:NSArray.class]) {
        NSUInteger const count = ((NSArray *)object).count;
        if (count == 0) {
            return object;
        }
        NSMutableArray * const models = [NSMutableArray arrayWithCapacity:count];
        for (id item in ((NSArray *)object)) {
            id const model = XZJSONDecodeData(item, options, ModelClass);
            if (model) {
                [models addObject:model];
            } else if (options & XZJSONReadingKeepCapacity) {
                [models addObject:(id)kCFNull];
            }
        }
        return models;
    }
    
    // 如果已经是目标类型，或没有目标类型，直接使用。
    if (object == nil || ModelClass == Nil || [object isKindOfClass:ModelClass]) {
        return object;
    }
    
    return XZJSONDecodeObject(object, ModelClass);
}

typedef struct XZJSONModelDecodeContext {
    void *model;
    void *JSONClass;
    void *dictionary;
} XZJSONModelDecodeContext;

/// 遍历 JSONDictionary 的函数。
static void XZJSONModelDecodeDictionaryEnumerator(const void *_key, const void *_value, void *_context) {
    XZJSONModelDecodeContext * const context            = _context;
    id                         const _Untain model      = (__bridge id)(context->model);
    XZJSONClass              * const _Untain modelClass = (__bridge XZJSONClass *)(context->JSONClass);
    
    XZJSONProperty * _Untain property = CFDictionaryGetValue((CFDictionaryRef)modelClass->_keyProperties, _key);
    while (property) {
        XZJSONModelDecodeProperty(model, property, (__bridge _Untain id)_value);
        property = property->_next;
    };
}

/// 遍历 模型属性数组 的函数。
static void XZJSONModelDecodePropertiesEnumerator(const void * const propertyRef, void * const contextRef) {
    XZJSONModelDecodeContext * const context            = contextRef;
    NSDictionary             * const _Untain dictionary = (__bridge NSDictionary *)(context->dictionary);
    XZJSONProperty           * const _Untain property   = (__bridge XZJSONProperty *)(propertyRef);
    
    id const value = (property->_fetchValueFromDictionary)(dictionary);
    if (value) {
        id const _Untain model = (__bridge id)(context->model);
        XZJSONModelDecodeProperty(model, property, value);
    }
}

void XZJSONModelDecodeFromDictionary(id const _Untain model, XZJSONClass * const _Untain JSONClass, NSDictionary * const _Untain JSONDictionary) {
    // 没有可用的属性
    if (JSONClass->_numberOfProperties == 0) {
        return;
    }
    
    XZJSONModelDecodeContext context = (XZJSONModelDecodeContext){
        (__bridge void *)model,
        (__bridge void *)JSONClass,
        (__bridge void *)JSONDictionary
    };
   
    // 遍历数量少的集合，可以提高通用模型的解析效率。
    if (JSONClass->_numberOfProperties >= CFDictionaryGetCount((CFDictionaryRef)JSONDictionary)) {
        // 遍历 key 映射的属性
        CFDictionaryApplyFunction((CFDictionaryRef)JSONDictionary, XZJSONModelDecodeDictionaryEnumerator, &context);
        
        // 遍历 keyPath 映射的属性
        if (JSONClass->_keyPathProperties) {
            CFRange const range = CFRangeMake(0, CFArrayGetCount((CFArrayRef)JSONClass->_keyPathProperties));
            CFArrayApplyFunction((CFArrayRef)JSONClass->_keyPathProperties, range, XZJSONModelDecodePropertiesEnumerator, &context);
        }
        
        // 遍历 keyArray 映射的属性
        if (JSONClass->_keyArrayProperties) {
            CFRange const range = CFRangeMake(0, CFArrayGetCount((CFArrayRef)JSONClass->_keyArrayProperties));
            CFArrayApplyFunction((CFArrayRef)JSONClass->_keyArrayProperties, range, XZJSONModelDecodePropertiesEnumerator, &context);
        }
    } else {
        // 遍历所有属性
        CFRange const range = CFRangeMake(0, CFArrayGetCount((CFArrayRef)JSONClass->_sortedProperties));
        CFArrayApplyFunction((CFArrayRef)JSONClass->_sortedProperties, range, XZJSONModelDecodePropertiesEnumerator, &context);
    }
}

FOUNDATION_STATIC_INLINE BOOL NSCharFromJSONValue(id const _Nonnull _Untain JSONValue, char *value) {
    if ([JSONValue isKindOfClass:NSNumber.class]) {
        *value = [(NSNumber *)JSONValue charValue];
        return YES;
    }
    if ([JSONValue isKindOfClass:NSString.class]) {
        if ([(NSString *)JSONValue length] > 0) {
            *value = (char)[(NSString *)JSONValue characterAtIndex:0];
            return YES;
        }
    }
    return NO;
}

FOUNDATION_STATIC_INLINE BOOL NSUnsignedCharFromJSONValue(id const _Nonnull _Untain JSONValue, unsigned char *value) {
    if ([JSONValue isKindOfClass:NSNumber.class]) {
        *value = [(NSNumber *)JSONValue unsignedCharValue];
        return YES;
    }
    if ([JSONValue isKindOfClass:NSString.class]) {
        if ([(NSString *)JSONValue length] > 0) {
            *value = (unsigned char)[(NSString *)JSONValue characterAtIndex:0];
            return YES;
        }
    }
    return NO;
}

FOUNDATION_STATIC_INLINE BOOL NSIntegerFromJSONValue(id const _Nonnull _Untain JSONValue, int *value) {
    if ([JSONValue isKindOfClass:NSNumber.class]) {
        *value = [(NSNumber *)JSONValue intValue];
        return YES;
    }
    if ([JSONValue isKindOfClass:NSString.class]) {
        if ([(NSString *)JSONValue length] > 0) {
            const char *string = [(NSString *)JSONValue UTF8String];
            if (string != NULL) {
                *value = atoi(string);
                return YES;
            }
        }
    }
    return NO;
}

FOUNDATION_STATIC_INLINE BOOL NSUnsignedIntegerFromJSONValue(id const _Nonnull _Untain JSONValue, unsigned int *value) {
    if ([JSONValue isKindOfClass:NSNumber.class]) {
        *value = [(NSNumber *)JSONValue unsignedIntValue];
        return YES;
    }
    if ([JSONValue isKindOfClass:NSString.class]) {
        if ([(NSString *)JSONValue length] > 0) {
            const char *string = [(NSString *)JSONValue cStringUsingEncoding:NSASCIIStringEncoding];
            if (string != NULL) {
                *value = (unsigned int)atol(string);
                return YES;
            }
        }
    }
    return NO;
}

FOUNDATION_STATIC_INLINE BOOL NSLongIntegerFromJSONValue(id const _Nonnull _Untain JSONValue, long *value) {
    if ([JSONValue isKindOfClass:NSNumber.class]) {
        *value = [(NSNumber *)JSONValue longValue];
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

FOUNDATION_STATIC_INLINE BOOL NSUnsignedLongIntegerFromJSONValue(id const _Nonnull _Untain JSONValue, unsigned long *value) {
    if ([JSONValue isKindOfClass:NSNumber.class]) {
        *value = [(NSNumber *)JSONValue unsignedLongValue];
        return YES;
    }
    if ([JSONValue isKindOfClass:NSString.class]) {
        if ([(NSString *)JSONValue length] > 0) {
            const char *string = [(NSString *)JSONValue cStringUsingEncoding:NSASCIIStringEncoding];
            if (string != NULL) {
                *value = strtoul(string, NULL, 0);
                return YES;
            }
        }
    }
    return NO;
}

FOUNDATION_STATIC_INLINE BOOL NSLongLongIntegerFromJSONValue(id const _Nonnull _Untain JSONValue, long long *value) {
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

FOUNDATION_STATIC_INLINE BOOL NSUnsignedLongLongIntegerFromJSONValue(id const _Nonnull _Untain JSONValue, unsigned long long *value) {
    if ([JSONValue isKindOfClass:NSNumber.class]) {
        *value = [(NSNumber *)JSONValue unsignedLongLongValue];
        return YES;
    }
    if ([JSONValue isKindOfClass:NSString.class]) {
        if ([(NSString *)JSONValue length] > 0) {
            const char *string = [(NSString *)JSONValue cStringUsingEncoding:NSASCIIStringEncoding];
            if (string != NULL) {
                *value = strtoull(string, NULL, 0);
                return YES;
            }
        }
    }
    return NO;
}

FOUNDATION_STATIC_INLINE BOOL NSFloatFromJSONValue(id const _Nonnull _Untain JSONValue, float *value) {
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

FOUNDATION_STATIC_INLINE BOOL NSDoubleFromJSONValue(id const  _Nonnull _Untain JSONValue, double *value) {
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

FOUNDATION_STATIC_INLINE BOOL NSLongDoubleFromJSONValue(id const _Nonnull _Untain JSONValue, long double *value) {
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

FOUNDATION_STATIC_INLINE BOOL NSBoolFromJSONValue(id const _Nonnull _Untain JSONValue, BOOL *value) {
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
/// - Parameter value: JSON 值，一定不是 kCFNull
FOUNDATION_STATIC_INLINE NSString * _Nullable NSStringFromJSONValue(id const _Untain JSONValue, BOOL mutable) {
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

FOUNDATION_STATIC_INLINE NSNumber * _Nullable NSNumberFromJSONValue(id const _Nonnull _Untain JSONValue) {
    if ([JSONValue isKindOfClass:[NSNumber class]]) {
        return JSONValue;
    }

    if ([JSONValue isKindOfClass:[NSString class]]) {
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
FOUNDATION_STATIC_INLINE NSDecimalNumber * _Nullable NSDecimalNumberFromJSONValue(id const _Nonnull _Untain JSONValue) {
    if ([JSONValue isKindOfClass:[NSString class]]) {
        // TODO: 确定 local 参数的使用区别
        NSDecimalNumber *const numberValue = [NSDecimalNumber decimalNumberWithString:JSONValue locale:nil];
        NSDecimal decimalValue = numberValue.decimalValue;
        return NSDecimalIsNotANumber(&decimalValue) ? nil : numberValue;
    } else if ([JSONValue isKindOfClass:[NSNumber class]]) {
        NSNumber *number = JSONValue;
        return [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
    } else if ([JSONValue isKindOfClass:[NSDecimalNumber class]]) {
        return JSONValue;
    }
    return nil;
}

FOUNDATION_STATIC_INLINE NSURL * _Nullable NSURLFromJSONValue(id const _Nonnull _Untain JSONValue) {
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

FOUNDATION_STATIC_INLINE NSArray * _Nullable NSArrayFromJSONValue(id const _Nonnull _Untain JSONValue, Class _Nullable const elementClass, BOOL mutable) {
    if ([JSONValue isKindOfClass:NSArray.class]) {
        if (elementClass) {
            NSMutableArray * const arrayM = [NSMutableArray arrayWithCapacity:((NSArray *)JSONValue).count];
            for (id data in (NSArray *)JSONValue) {
                id const model = XZJSONDecodeObject(data, elementClass);
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
        id const model = XZJSONDecodeObject(JSONValue, elementClass);
        if (model) {
            return [NSMutableArray arrayWithObject:model];
        }
        return nil;
    }
    
    return [NSMutableArray arrayWithObject:JSONValue];
}

FOUNDATION_STATIC_INLINE NSSet * _Nullable NSSetFromJSONValue(id const _Nonnull _Untain JSONValue, Class _Nullable const elementClass, Class const MutableSetClass) {
    if ([JSONValue isKindOfClass:NSArray.class]) {
        if (elementClass) {
            NSMutableSet * const setM = [MutableSetClass setWithCapacity:((NSArray *)JSONValue).count];
            for (id data in (NSArray *)JSONValue) {
                id const model = XZJSONDecodeObject(data, elementClass);
                if (model) {
                    [setM addObject:model];
                }
            }
            return setM;
        }
        
        return [MutableSetClass setWithArray:JSONValue];
    }
    
    if (elementClass) {
        id const model = XZJSONDecodeObject(JSONValue, elementClass);
        if (model) {
            if ([model isKindOfClass:NSArray.class]) {
                return [MutableSetClass setWithArray:model];
            }
            return [MutableSetClass setWithObject:model];
        }
        return nil;
    }
    
    return [MutableSetClass setWithObject:JSONValue];
}

FOUNDATION_STATIC_INLINE NSMutableOrderedSet * _Nullable NSOrderedSetFromJSONValue(id const _Nonnull _Untain JSONValue, Class const _Nullable elementClass) {
    if ([JSONValue isKindOfClass:NSArray.class]) {
        if (elementClass) {
            NSMutableOrderedSet * const orderedSetM = [NSMutableOrderedSet orderedSetWithCapacity:((NSArray *)JSONValue).count];
            for (id data in (NSArray *)JSONValue) {
                id const model = XZJSONDecodeObject(data, elementClass);
                if (model) {
                    [orderedSetM addObject:model];
                }
            }
            return orderedSetM;
        }
        
        return [NSMutableOrderedSet orderedSetWithArray:JSONValue];
    }
    
    if (elementClass) {
        id const model = XZJSONDecodeObject(JSONValue, elementClass);
        if (model) {
            if ([model isKindOfClass:NSArray.class]) {
                return [NSMutableOrderedSet orderedSetWithArray:model];
            }
            return [NSMutableOrderedSet orderedSetWithObject:model];
        }
        return nil;
    }
    
    return [NSMutableOrderedSet orderedSetWithObject:JSONValue];
}

FOUNDATION_STATIC_INLINE NSDictionary * _Nullable NSDictionaryFromJSONValue(id const _Nonnull _Untain JSONValue, Class _Nullable const elementClass, BOOL mutable) {
    if (elementClass) {
        if ([JSONValue isKindOfClass:NSDictionary.class]) {
            NSMutableDictionary *dictM = [NSMutableDictionary new];
            [((NSDictionary *)JSONValue) enumerateKeysAndObjectsUsingBlock:^(NSString *oneKey, id oneValue, BOOL *stop) {
                dictM[oneKey] = XZJSONDecodeObject(oneValue, elementClass);
            }];
            return dictM;
        }
        
        if ([JSONValue isKindOfClass:NSArray.class]) {
            NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
            [(NSArray *)JSONValue enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *key = [NSString stringWithFormat:@"%ld", (long)idx];
                dictM[key] = XZJSONDecodeObject(obj, elementClass);
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

FOUNDATION_STATIC_INLINE id NSDataFromJSONValue(id const _Nonnull _Untain JSONValue, BOOL mutable) {
    if ([JSONValue isKindOfClass:NSString.class]) {
        // 符合 RFC2397 URL Data 规范的字符
        // data:[<mediatype>][;base64],<data>
        // https://datatracker.ietf.org/doc/html/rfc2397
        NSString * const JSONString = JSONValue;
        NSUInteger const JSONLength = JSONString.length;
        if ([JSONString hasPrefix:@"data:"] && JSONLength > 5) {
            NSString *type = nil;
            NSString *value = nil;
            
            NSUInteger const max = [JSONString rangeOfString:@"," options:0 range:NSMakeRange(5, MIN(1024, JSONLength - 5))].location;
            if (max == NSNotFound) {
                type = @"base64";
                value = [JSONString substringFromIndex:5];
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
                
                value = [JSONString substringFromIndex:max + 1];
            }
            
            if ([type isEqualToString:@"base64"]) {
                return [[NSMutableData alloc] initWithBase64EncodedString:value options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
            }
            
            if ([type isEqualToString:@"hex"]) {
                return [NSMutableData xz_dataWithHexEncodedString:value];
            }
            
            return nil;
        }
        
        // 默认当作 base64 字符串处理，使用严格模式。
        return [[NSMutableData alloc] initWithBase64EncodedString:JSONValue options:kNilOptions];
    }
    
    if ([JSONValue isKindOfClass:NSDictionary.class]) {
        NSString *encoding = ((NSDictionary *)JSONValue)[@"encoding"];
        NSString *data = ((NSDictionary *)JSONValue)[@"data"];
        if ([encoding isKindOfClass:NSString.class] && [data isKindOfClass:NSString.class]) {
            if ([encoding isEqualToString:@"base64"]) {
                return [[NSMutableData alloc] initWithBase64EncodedString:JSONValue options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
            }
            if ([encoding isEqualToString:@"hex"]) {
                return [NSMutableData xz_dataWithHexEncodedString:data];
            }
        }
    }
    
    return nil;
}

/// 将 JSON 值 value 转换为 NSDate 对象。
/// - Parameter JSONValue: JSON 值
FOUNDATION_STATIC_INLINE NSDate *NSDateFromJSONValue(id const _Nonnull _Untain JSONValue) {
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
FOUNDATION_STATIC_INLINE BOOL XZJSONModelDecodePropertyFallback(id const _Untain model, XZJSONProperty * const _Untain property, id const _Untain JSONValue) {
    switch (property->_cocoaClass) {
        case XZJSONCocoaClassUnknown:
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
            // 这些值类型，不需要默认解析。
            return NO;
        }
        case XZJSONCocoaClassNSValue: {
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
            
            switch (XZStdcStructTypeFromString(type)) {
                case XZStdcStructTypeUnknown: {
                    return NO;
                }
                case XZStdcStructTypeCGRect: {
                    CGRect const aValue = CGRectFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithCGRect:aValue]);
                    return YES;
                }
                case XZStdcStructTypeCGSize: {
                    CGSize const aValue = CGSizeFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithCGSize:aValue]);
                    return YES;
                }
                case XZStdcStructTypeCGPoint: {
                    CGPoint const aValue = CGPointFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithCGPoint:aValue]);
                    return YES;
                }
                case XZStdcStructTypeCGVector: {
                    CGVector const aValue = CGVectorFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithCGVector:aValue]);
                    return YES;
                }
                case XZStdcStructTypeCGAffineTransform: {
                    CGAffineTransform const aValue = CGAffineTransformFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithCGAffineTransform:aValue]);
                    return YES;
                }
                case XZStdcStructTypeNSDirectionalEdgeInsets: {
                    NSDirectionalEdgeInsets const aValue = NSDirectionalEdgeInsetsFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithDirectionalEdgeInsets:aValue]);
                    return YES;
                }
                case XZStdcStructTypeNSRange: {
                    NSRange const aValue = NSRangeFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithRange:aValue]);
                    return YES;
                }
                case XZStdcStructTypeUIEdgeInsets: {
                    UIEdgeInsets const aValue = UIEdgeInsetsFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithUIEdgeInsets:aValue]);
                    return YES;
                }
                case XZStdcStructTypeUIOffset: {
                    UIOffset const aValue = UIOffsetFromString(value);
                    ((XZJSONSetter)objc_msgSend)(model, property->_setter, [NSValue valueWithUIOffset:aValue]);
                    return YES;
                }
            }
            break;
        }
        case XZJSONCocoaClassNSDate: {
            NSDate *date = NSDateFromJSONValue(JSONValue);
            if (date) {
                ((XZJSONSetter)objc_msgSend)(model, property->_setter, date);
                return YES;
            }
            return NO;
        }
        case XZJSONCocoaClassNSData: {
            NSData *data = NSDataFromJSONValue(JSONValue, NO);
            if (data) {
                ((XZJSONSetter)objc_msgSend)(model, property->_setter, data);
                return YES;
            }
            return NO;
        }
        case XZJSONCocoaClassNSMutableData: {
            NSMutableData *data = NSDataFromJSONValue(JSONValue, YES);
            if (data) {
                ((XZJSONSetter)objc_msgSend)(model, property->_setter, data);
                return YES;
            }
            return NO;
        }
    }
}

void XZJSONModelDecodeProperty(id const _Untain model, XZJSONProperty * const _Untain property, id _Nonnull _Untain rawValue) {
    switch (property->_type) {
        case XZStdcTypeUnknown:
        case XZStdcTypeVoid:
        case XZStdcTypeString:
        case XZStdcTypeArray:
        case XZStdcTypeBitField:
        case XZStdcTypePointer:
        case XZStdcTypeUnion: {
            // 无法处理的类型
            break;
        }
        case XZStdcTypeChar: {
            char newValue = 0;
            if (NSCharFromJSONValue(rawValue, &newValue)) {
                ((void (*)(id, SEL, char))objc_msgSend)((id)model, property->_setter, newValue);
                return;
            }
            break;
        }
        case XZStdcTypeUnsignedChar: {
            unsigned char newValue = 0;
            if (NSUnsignedCharFromJSONValue(rawValue, &newValue)) {
                ((void (*)(id, SEL, unsigned char))objc_msgSend)((id)model, property->_setter, newValue);
                return;
            }
            break;
        }
        case XZStdcTypeInt: {
            int newValue = 0;
            if (NSIntegerFromJSONValue(rawValue, &newValue)) {
                ((void (*)(id, SEL, int))objc_msgSend)((id)model, property->_setter, (int)newValue);
                return;
            }
            break;
        }
        case XZStdcTypeUnsignedInt: {
            unsigned int newValue = 0;
            if (NSUnsignedIntegerFromJSONValue(rawValue, &newValue)) {
                ((void (*)(id, SEL, unsigned int))objc_msgSend)((id)model, property->_setter, newValue);
                return;
            }
            return;
        }
        case XZStdcTypeShort: {
            int newValue = 0;
            if (NSIntegerFromJSONValue(rawValue, &newValue)) {
                ((void (*)(id, SEL, short))objc_msgSend)((id)model, property->_setter, (short)newValue);
                return;
            }
            break;
        }
        case XZStdcTypeUnsignedShort: {
            unsigned int newValue = 0;
            if (NSUnsignedIntegerFromJSONValue(rawValue, &newValue)) {
                ((void (*)(id, SEL, unsigned short))objc_msgSend)((id)model, property->_setter, (unsigned short)newValue);
                return;
            }
            break;
        }
        case XZStdcTypeLong: {
            long newValue = 0;
            if (NSLongIntegerFromJSONValue(rawValue, &newValue)) {
                ((void (*)(id, SEL, long))objc_msgSend)((id)model, property->_setter, (long)newValue);
                return;
            }
            break;
        }
        case XZStdcTypeUnsignedLong: {
            unsigned long newValue = 0;
            if (NSUnsignedLongIntegerFromJSONValue(rawValue, &newValue)) {
                ((void (*)(id, SEL, unsigned long))objc_msgSend)((id)model, property->_setter, newValue);
                return;
            }
            break;;
        }
        case XZStdcTypeLongLong: {
            long long newValue = 0;
            if (NSLongLongIntegerFromJSONValue(rawValue, &newValue)) {
                ((void (*)(id, SEL, long long))objc_msgSend)((id)model, property->_setter, (long long)newValue);
                return;
            }
            break;
        }
        case XZStdcTypeUnsignedLongLong: {
            unsigned long long newValue = 0;
            if (NSUnsignedLongLongIntegerFromJSONValue(rawValue, &newValue)) {
                ((void (*)(id, SEL, unsigned long long))objc_msgSend)((id)model, property->_setter, newValue);
                return;
            }
            break;;
        }
        case XZStdcTypeFloat: {
            float newValue = 0;
            if (NSFloatFromJSONValue(rawValue, &newValue)) {
                ((void (*)(id, SEL, float))objc_msgSend)((id)model, property->_setter, newValue);
                return;
            }
            break;
        }
        case XZStdcTypeDouble: {
            double newValue = 0;
            if (NSDoubleFromJSONValue(rawValue, &newValue)) {
                ((void (*)(id, SEL, long long))objc_msgSend)((id)model, property->_setter, newValue);
                return;
            }
            break;
        }
        case XZStdcTypeLongDouble: {
            long double newValue = 0;
            if (NSLongDoubleFromJSONValue(rawValue, &newValue)) {
                ((void (*)(id, SEL, long double))objc_msgSend)((id)model, property->_setter, newValue);
                return;
            }
            break;
        }
        case XZStdcTypeBool: {
            BOOL newValue = NO;
            if (NSBoolFromJSONValue(rawValue, &newValue)) {
                ((void (*)(id, SEL, BOOL))objc_msgSend)((id)model, property->_setter, newValue);
                return;
            }
            break;
        }
        case XZStdcTypeStruct: {
            if (XZJSONModelDecodeStructProperty(model, property, rawValue)) {
                return;
            }
            break;
        }
        case XZStdcTypeClass: {
            if (rawValue == (id)kCFNull) {
                ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, property->_setter, Nil);
                return;
            }
            if (object_isClass(rawValue)) {
                ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, property->_setter, rawValue);
                return;
            }
            if ([rawValue isKindOfClass:[NSString class]]) {
                Class aClass = NSClassFromString(rawValue);
                if (aClass) {
                    ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, property->_setter, aClass);
                    return;
                }
            }
            break;
        }
        case XZStdcTypeSelector: {
            if (rawValue == (id)kCFNull) {
                ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model, property->_setter, (SEL)NULL);
                return;
            }
            if ([rawValue isKindOfClass:[NSString class]]) {
                SEL const newValue = NSSelectorFromString(rawValue);
                if (newValue) {
                    ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model, property->_setter, newValue);
                    return;
                }
            }
            break;
        }
        case XZStdcTypeObject: {
            // 空值
            if (rawValue == (id)kCFNull) {
                ((XZJSONSetter)objc_msgSend)((id)model, property->_setter, (id)nil);
                return;
            }
            
            // 在 M2 芯片模拟器中，XZJSON 与 YYModel 执行数据转模型的结果如下。
            // GHUser:  31.67   30.93
            // Weibo : 115.47  130.36
            // 而在 iPhone SE 2、iPhone 11 中的测试结果，两种模型都是 XZJSON 更快。
            // 经分析，当芯片性能足够强时，代码逻辑处理的执行时间就会非常短，值非常接近，在 M2 模拟器中情况就是如此。
            // 由于 GHUser 的属性大多是 NSString 类型，实际代码流程仅涉及字符串的处理，其中
            // - XZJSON 执行 NSStringFromJSONValue 耗时 11.00 毫秒。
            // - YYModel 由于没有函数调用，仅需要执行 isKindOfClass 只消耗 6 毫秒。
            // 这里 XZJSON 函数调用会额外增加耗时的原因是：
            // 在 ARC 模式下，函数返回对象，会自动添加 autorelease 操作，而
            // 在 NSStringFromJSONValue 函数内，执行 isKindOfClass 耗时 3 毫秒，执行 return 耗时 4 毫秒。
            //
            // 综上，虽然不用函数可以提供性能，但是为了维护的便利性，此处理逻辑保持不变。
            // 另外，XZJSON 支持的按属性自定义解析，以及 fallback 逻辑，此处用函数也更好。
            
            // 由于数据处理，可能产生新的对象，因此需要强持有目标对象。
            id newValue = nil;
            
            switch (property->_cocoaClass) {
                case XZJSONCocoaClassNSString: {
                    newValue = NSStringFromJSONValue(rawValue, NO);
                    break;
                }
                case XZJSONCocoaClassNSMutableString: {
                    newValue = NSStringFromJSONValue(rawValue, YES);
                    break;
                }
                case XZJSONCocoaClassNSValue: {
                    if ([rawValue isKindOfClass:[NSValue class]]) {
                        newValue = rawValue;
                    } else {
                        // 由 fallback 逻辑处理
                    }
                    break;
                }
                case XZJSONCocoaClassNSNumber: {
                    newValue = NSNumberFromJSONValue(rawValue);
                    break;
                }
                case XZJSONCocoaClassNSDecimalNumber: {
                    newValue = NSDecimalNumberFromJSONValue(rawValue);
                    break;
                }
                case XZJSONCocoaClassNSData: {
                    if ([rawValue isKindOfClass:NSData.class]) {
                        newValue = rawValue;
                    } else {
                        // 由 fallback 逻辑处理
                    }
                    break;
                }
                case XZJSONCocoaClassNSMutableData: {
                    if ([rawValue isKindOfClass:NSMutableData.class]) {
                        newValue = rawValue;
                    } else if ([rawValue isKindOfClass:NSData.class]) {
                        newValue = [NSMutableData dataWithData:rawValue];
                    }
                    break;
                }
                case XZJSONCocoaClassNSDate: {
                    if ([rawValue isKindOfClass:NSDate.class]) {
                        newValue = rawValue;
                    }
                    break;
                }
                case XZJSONCocoaClassNSURL: {
                    newValue = NSURLFromJSONValue(rawValue);
                    break;
                }
                case XZJSONCocoaClassNSArray: {
                    newValue = NSArrayFromJSONValue(rawValue, property->_elementClassType, NO);
                    break;
                }
                case XZJSONCocoaClassNSMutableArray: {
                    newValue = NSArrayFromJSONValue(rawValue, property->_elementClassType, YES);
                    break;
                }
                case XZJSONCocoaClassNSSet: {
                    newValue = NSSetFromJSONValue(rawValue, property->_elementClassType, NSMutableSet.class);
                    break;
                }
                case XZJSONCocoaClassNSMutableSet: {
                    newValue = NSSetFromJSONValue(rawValue, property->_elementClassType, NSMutableSet.class);
                    break;
                }
                case XZJSONCocoaClassNSCountedSet: {
                    newValue = NSSetFromJSONValue(rawValue, property->_elementClassType, NSCountedSet.class);
                    break;
                }
                case XZJSONCocoaClassNSOrderedSet: {
                    newValue = NSOrderedSetFromJSONValue(rawValue, property->_elementClassType);
                    break;
                }
                case XZJSONCocoaClassNSMutableOrderedSet: {
                    newValue = NSOrderedSetFromJSONValue(rawValue, property->_elementClassType);
                    break;
                }
                case XZJSONCocoaClassNSDictionary: {
                    newValue = NSDictionaryFromJSONValue(rawValue, property->_elementClassType, NO);
                    break;
                }
                case XZJSONCocoaClassNSMutableDictionary: {
                    newValue = NSDictionaryFromJSONValue(rawValue, property->_elementClassType, YES);
                    break;
                }
                case XZJSONCocoaClassUnknown: {
                    // 自定义类型
                    if (!property->_classType || [rawValue isKindOfClass:property->_classType]) {
                        // 未指定对象类型，或者已经是指定的自定义对象类型，直接赋值
                        newValue = rawValue;
                    } else {
                        XZJSONClass * const JSONClass = [XZJSONClass classForClass:property->_classType];
                        if (!JSONClass) {
                            break;
                        }
                        // JSON 数据模型化为指定的自定义对象类型
                        if (![rawValue isKindOfClass:[NSDictionary class]]) {
                            rawValue = @{ @"rawValue": rawValue }; // 非字典数据，包装为字典
                        }
                        // 如果属性已有值，直接更新它，否则创建新的。
                        newValue = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                        newValue = XZJSONDecodeDictionary(property->_classType, JSONClass, rawValue, newValue);
                    }
                    break;
                }
            }
            
            if (newValue) {
                ((XZJSONSetter)objc_msgSend)(model, property->_setter, newValue);
                return;
            }
            break;
        }
        case XZStdcTypeInt128:
        case XZStdcTypeUnsignedInt128:
        case XZStdcTypeVector: {
            // 无法处理的类型
            break;
        }
    }
    
    // JSONValue 无法解析为目标属性值
    if (property->_owner->_usesPropertyDecodingMethod) {
        if ([(id<XZJSONCoding>)model JSONDecodeValue:rawValue forKey:property->_name]) {
            return;
        }
    }
    
    // 尝试默认解析
    if (XZJSONModelDecodePropertyFallback(model, property, rawValue)) {
        return;
    }
}
