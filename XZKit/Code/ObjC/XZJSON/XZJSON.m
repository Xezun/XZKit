//
//  XZJSON.m
//  XZJSON
//
//  Created by Xezun on 2024/9/28.
//

#import "XZJSON.h"
#import "XZJSONPrivate.h"
#import "XZJSONClassDescriptor.h"

@implementation XZJSON

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *_dateFormatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    });
    
    return _dateFormatter;
}

@end

@implementation XZJSON (XZJSONDecoding)

+ (id)decode:(id)json options:(NSJSONReadingOptions)options class:(Class)aClass {
    // 判空
    if (json == nil || json == NSNull.null) {
        return nil;
    }
    // 二进制流形式的 json 数据
    if ([json isKindOfClass:NSData.class]) {
        return [self _decodeJSONData:json options:options class:aClass];
    }
    // 字符串形式的 json 数据
    if ([json isKindOfClass:NSString.class]) {
        NSString * const aString = json;
        NSData   * const data = [aString dataUsingEncoding:NSUTF8StringEncoding];
        if (data == nil) {
            return nil;
        }
        return [self _decodeJSONData:data options:options class:aClass];
    }
    // 如果为数组，视为解析多个 json 数据
    if ([json isKindOfClass:NSArray.class]) {
        NSArray * const jsonArray = json;
        if (jsonArray.count == 0) {
            return jsonArray;
        }
        NSMutableArray * const models = [NSMutableArray arrayWithCapacity:jsonArray.count];
        for (id json in jsonArray) {
            id const model = [self decode:json options:options class:aClass];
            if (model) {
                [models addObject:model];
            }
        }
        return models;
    }
    // 其它情况视为已解析好的 json
    return [self _decodeJSONObject:json class:aClass];
}

+ (void)model:(id)object decodeFromDictionary:(NSDictionary *)dictionary {
    XZJSONClassDescriptor * const descriptor = [XZJSONClassDescriptor descriptorForClass:[object class]];
    [self _model:object decodeFromDictionary:dictionary descriptor:descriptor];
}

@end


@implementation XZJSON (XZJSONEncoding)

+ (NSData *)encode:(id)object options:(NSJSONWritingOptions)options error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    if (object == nil) {
        return nil;
    }
    
    id const JSONObject = [self _encodeObject:object intoDictionary:nil];
    
    if (JSONObject == nil) {
        return nil;
    }
    
    return [NSJSONSerialization dataWithJSONObject:JSONObject options:options error:error];
}

+ (void)model:(id)model encodeIntoDictionary:(NSMutableDictionary *)dictionary {
    XZJSONClassDescriptor * const descriptor = [XZJSONClassDescriptor descriptorForClass:[model class]];
    [self _model:model encodeIntoDictionary:dictionary descriptor:descriptor];
}

@end


@implementation XZJSON (NSCoding)

+ (void)model:(id)model encodeWithCoder:(NSCoder *)aCoder {
    XZJSONModelEncodeWithCoder(model, aCoder);
}

+ (id)model:(id)model decodeWithCoder:(NSCoder *)aCoder {
    return XZJSONModelDecodeWithCoder(model, aCoder);
}

@end

@implementation XZJSON (NSCopying)

+ (id)modelCopy:(id)model {
    if (model == (id)kCFNull) {
        return model;
    }
    
    XZJSONClassDescriptor * const modelClass = [XZJSONClassDescriptor descriptorForClass:[model class]];
    
    if (modelClass->_classType) {
        return [model copy];
    }
    
    id const newModel = [[model class] alloc];
    
    [modelClass->_properties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor *property, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (property->_type) {
            case XZObjcTypeChar: {
                char const value = ((char (*)(id, SEL))objc_msgSend)(self, property->_getter);
                ((void (*)(id, SEL, char))objc_msgSend)(newModel, property->_setter, value);
                break;
            }
            case XZObjcTypeInt: {
                int const value = ((int (*)(id, SEL))objc_msgSend)(self, property->_getter);
                ((void (*)(id, SEL, int))objc_msgSend)(newModel, property->_setter, value);
                break;
            }
            case XZObjcTypeShort: {
                short const value = ((short (*)(id, SEL))objc_msgSend)(self, property->_getter);
                ((void (*)(id, SEL, short))objc_msgSend)(newModel, property->_setter, value);
                break;
            }
            case XZObjcTypeLong: {
                long const value = ((long (*)(id, SEL))objc_msgSend)(self, property->_getter);
                ((void (*)(id, SEL, long))objc_msgSend)(newModel, property->_setter, value);
                break;
            }
            case XZObjcTypeLongLong: {
                long long const value = ((long long (*)(id, SEL))objc_msgSend)(self, property->_getter);
                ((void (*)(id, SEL, long long))objc_msgSend)(newModel, property->_setter, value);
                break;
            }
            case XZObjcTypeUnsignedChar: {
                unsigned char const value = ((unsigned char (*)(id, SEL))objc_msgSend)(self, property->_getter);
                ((void (*)(id, SEL, unsigned char))objc_msgSend)(newModel, property->_setter, value);
                break;
            }
            case XZObjcTypeUnsignedInt: {
                unsigned int const value = ((unsigned int (*)(id, SEL))objc_msgSend)(self, property->_getter);
                ((void (*)(id, SEL, unsigned int))objc_msgSend)(newModel, property->_setter, value);
                break;
            }
            case XZObjcTypeUnsignedShort: {
                unsigned short const value = ((unsigned short (*)(id, SEL))objc_msgSend)(self, property->_getter);
                ((void (*)(id, SEL, unsigned short))objc_msgSend)(newModel, property->_setter, value);
                break;
            }
            case XZObjcTypeUnsignedLong: {
                unsigned long const value = ((unsigned long (*)(id, SEL))objc_msgSend)(self, property->_getter);
                ((void (*)(id, SEL, unsigned long))objc_msgSend)(newModel, property->_setter, value);
                break;
            }
            case XZObjcTypeUnsignedLongLong: {
                unsigned long long const value = ((unsigned long long (*)(id, SEL))objc_msgSend)(self, property->_getter);
                ((void (*)(id, SEL, unsigned long long))objc_msgSend)(newModel, property->_setter, value);
                break;
            }
            case XZObjcTypeFloat: {
                float const value = ((float (*)(id, SEL))objc_msgSend)(self, property->_getter);
                ((void (*)(id, SEL, float))objc_msgSend)(newModel, property->_setter, value);
                break;
            }
            case XZObjcTypeDouble: {
                double const value = ((double (*)(id, SEL))objc_msgSend)(self, property->_getter);
                ((void (*)(id, SEL, double))objc_msgSend)(newModel, property->_setter, value);
                break;
            }
            case XZObjcTypeLongDouble: {
                long double const value = ((long double (*)(id, SEL))objc_msgSend)(self, property->_getter);
                ((void (*)(id, SEL, long double))objc_msgSend)(newModel, property->_setter, value);
                break;
            }
            case XZObjcTypeBool: {
                BOOL const value = ((BOOL (*)(id, SEL))objc_msgSend)(self, property->_getter);
                ((void (*)(id, SEL, BOOL))objc_msgSend)(newModel, property->_setter, value);
                break;
            }
            case XZObjcTypeClass: {
                Class const value = ((Class (*)(id, SEL))objc_msgSend)(self, property->_getter);
                ((void (*)(id, SEL, Class))objc_msgSend)(newModel, property->_setter, value);
                break;
            }
            case XZObjcTypeSEL:  {
                SEL const value = ((SEL (*)(id, SEL))objc_msgSend)(self, property->_getter);
                ((void (*)(id, SEL, SEL))objc_msgSend)(newModel, property->_setter, value);
                break;
            }
            case XZObjcTypeObject:  {
                id const value = ((id (*)(id, SEL))objc_msgSend)(self, property->_getter);
                ((void (*)(id, SEL, id))objc_msgSend)(newModel, property->_setter, value);
                break;
            }
            case XZObjcTypeStruct:
            case XZObjcTypeUnion:
            case XZObjcTypeBitField:
            case XZObjcTypeVoid:
            case XZObjcTypeString:
            case XZObjcTypeArray:
            case XZObjcTypePointer:
            case XZObjcTypeUnknown: {
                NSValue * const value = [self valueForKey:property->_name];
                if (property->_isKeyValueCodable) {
                    [newModel setValue:value forKey:property->_isKeyValueCodable];
                } else {
                    XZObjcClassDescriptor *class = modelClass->_class;
                    XZObjcMethodDescriptor *method = class.methods[NSStringFromSelector(property->_setter)];
                    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:[method.encoding cStringUsingEncoding:NSASCIIStringEncoding]];
                    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                    
                    void *bytes = calloc(property->_property.type.size, sizeof(char));
                    @try {
                        [value getValue:&bytes];
                        [invocation setArgument:bytes atIndex:2];
                        [invocation invokeWithTarget:newModel];
                    } @catch (NSException *exception) {
                        NSLog(@"[XZJSON] `%@` copy value for property `%@` failed", class.name, property->_name);
                    } @finally {
                        free(bytes);
                    }
                }
                break;
            }
        }
        
    }];
    
    return newModel;
}

@end

@implementation XZJSON (NSDescription)

+ (NSString *)modelDescription:(id)model {
    return XZJSONModelDescription(model, 0);
}

@end


@implementation XZJSON (NSHashable)

+ (NSUInteger)modelHash:(id)model {
    if (model == (id)kCFNull) {
        return [model hash];
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
        case XZJSONClassTypeNSURL:
        case XZJSONClassTypeNSArray:
        case XZJSONClassTypeNSMutableArray:
        case XZJSONClassTypeNSDictionary:
        case XZJSONClassTypeNSMutableDictionary:
        case XZJSONClassTypeNSSet:
        case XZJSONClassTypeNSMutableSet: {
            return [model hash];
        }
        case XZJSONClassTypeUnknown: {
            NSMutableString *string = [NSMutableString stringWithString:@"|"];
            for (XZJSONPropertyDescriptor *property in modelClass->_properties) {
                SEL const getter = property->_getter;
                switch (property->_type) {
                    case XZObjcTypeUnknown:
                        break;
                    case XZObjcTypeChar: // 使用值，而不是字符，以避免产生 | 字符
                        [string appendFormat:@"%d|", ((char (*)(id,SEL))objc_msgSend)(model, getter)];
                        break;
                    case XZObjcTypeUnsignedChar:
                        [string appendFormat:@"%u|", ((char (*)(id,SEL))objc_msgSend)(model, getter)];
                        break;
                    case XZObjcTypeInt:
                        [string appendFormat:@"%d|", ((int (*)(id,SEL))objc_msgSend)(model, getter)];
                        break;
                    case XZObjcTypeUnsignedInt:
                        [string appendFormat:@"%u|", ((unsigned int (*)(id,SEL))objc_msgSend)(model, getter)];
                        break;
                    case XZObjcTypeShort:
                        [string appendFormat:@"%d|", ((short (*)(id,SEL))objc_msgSend)(model, getter)];
                        break;
                    case XZObjcTypeUnsignedShort:
                        [string appendFormat:@"%u|", ((unsigned short (*)(id,SEL))objc_msgSend)(model, getter)];
                        break;
                    case XZObjcTypeLong:
                        [string appendFormat:@"%ld|", ((long (*)(id,SEL))objc_msgSend)(model, getter)];
                        break;
                    case XZObjcTypeUnsignedLong:
                        [string appendFormat:@"%lu|", ((unsigned long (*)(id,SEL))objc_msgSend)(model, getter)];
                        break;
                    case XZObjcTypeLongLong:
                        [string appendFormat:@"%lld|", ((long long (*)(id,SEL))objc_msgSend)(model, getter)];
                        break;
                    case XZObjcTypeUnsignedLongLong:
                        [string appendFormat:@"%llu|", ((unsigned long long (*)(id,SEL))objc_msgSend)(model, getter)];
                        break;
                    case XZObjcTypeFloat:
                        [string appendFormat:@"%G|", ((float (*)(id,SEL))objc_msgSend)(model, getter)];
                        break;
                    case XZObjcTypeDouble:
                        [string appendFormat:@"%G|", ((double (*)(id,SEL))objc_msgSend)(model, getter)];
                        break;
                    case XZObjcTypeLongDouble:
                        [string appendFormat:@"%LG|", ((long double (*)(id,SEL))objc_msgSend)(model, getter)];
                        break;
                    case XZObjcTypeBool:
                        [string appendFormat:@"%@|", ((BOOL (*)(id,SEL))objc_msgSend)(model, getter) ? @"true" : @"false"];
                        break;
                    case XZObjcTypeVoid:
                    case XZObjcTypeString:
                    case XZObjcTypeArray:
                    case XZObjcTypeBitField:
                    case XZObjcTypePointer:
                    case XZObjcTypeUnion:
                        break;
                    case XZObjcTypeStruct:
                        [string appendFormat:@"%@|", XZJSONModelEncodeStructProperty(model, property)];
                        break;
                    case XZObjcTypeClass: {
                        Class const aClass = ((Class (*)(id,SEL))objc_msgSend)(model, getter);
                        [string appendFormat:@"%@|", aClass ? NSStringFromClass(aClass) : nil];
                        break;
                    }
                    case XZObjcTypeSEL: {
                        SEL const aSelector = ((SEL (*)(id,SEL))objc_msgSend)(model, getter);
                        [string appendFormat:@"%@|", aSelector ? NSStringFromSelector(aSelector) : nil];
                        break;
                    }
                    case XZObjcTypeObject: {
                        id const value = ((id (*)(id,SEL))objc_msgSend)(model, getter);
                        NSInteger hash = [XZJSON modelHash:value];
                        [string appendFormat:@"%ld|", (long)hash];
                        break;
                    }
                }
            }
            if (string.length == 1) {
                return (long)((__bridge void *)model);
            }
            return string.hash;
        }
    }
}

@end

@implementation XZJSON (NSEquatable)

+ (BOOL)model:(id)model1 isEqualToModel:(id)model2 {
    if (model1 == model2) {
        return YES;
    }
    if ([model1 class] != [model2 class]) {
        return NO;
    }
    XZJSONClassDescriptor * const modelClass = [XZJSONClassDescriptor descriptorForClass:[model1 class]];
    if (modelClass->_classType) {
        return [model1 isEqual:model2];
    }
    if ([model1 hash] != [model2 hash]) {
        return NO;
    }
    
    for (XZJSONPropertyDescriptor *property in modelClass->_properties) {
        id value1 = [model1 valueForKey:NSStringFromSelector(property->_getter)];
        id value2 = [model2 valueForKey:NSStringFromSelector(property->_getter)];
        if ([XZJSON model:value1 isEqualToModel:value2]) {
            continue;
        }
        return NO;
    }
    return YES;
}

@end


