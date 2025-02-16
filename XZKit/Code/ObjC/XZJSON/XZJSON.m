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
        return [self _decodeData:json options:options class:aClass];
    }
    // 字符串形式的 json 数据
    if ([json isKindOfClass:NSString.class]) {
        NSString * const aString = json;
        NSData   * const data = [aString dataUsingEncoding:NSUTF8StringEncoding];
        if (data == nil) {
            return nil;
        }
        return [self _decodeData:data options:options class:aClass];
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
    return [self _decodeObject:json class:aClass];
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
    
    XZJSONClassDescriptor *descriptor = [XZJSONClassDescriptor descriptorForClass:[object class]];
    id const JSONObject = [self _model:object encodeIntoDictionary:nil descriptor:descriptor];
    
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
    if (!model || !aCoder) {
        return;
    }
    
    if (model == (id)kCFNull) {
        [((id<NSCoding>)model) encodeWithCoder:aCoder];
        return;
    }
    
    XZJSONClassDescriptor *modelClass = [XZJSONClassDescriptor descriptorForClass:[model class]];
    
    // 原生类型
    if (modelClass->_classType) {
        [((id<NSCoding>)model) encodeWithCoder:aCoder];
        return;
    }
    
    for (XZJSONPropertyDescriptor *property in modelClass->_properties) {    
        // 标量数字
        if (property->_isScalarNumber) {
            NSNumber *value = XZJSONModelEncodeScalarNumberProperty(model, property);
            if (value) {
                [aCoder encodeObject:value forKey:property->_name];
            }
            continue;
        }
        
        // 其它类型
        switch (property->_type) {
            case XZObjcTypeObject: { // 对象类型
                id const value = ((id (*)(id, SEL))(void *)objc_msgSend)((id)model, property->_getter);
                if (value) {
                    BOOL const secure = [value conformsToProtocol:@protocol(NSSecureCoding)];
                    NSError *error = nil;
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value requiringSecureCoding:secure error:&error];
                    if (data && (error == nil || error.code == noErr)) {
                        [aCoder encodeObject:data forKey:property->_name];
                    }
                }
                break;
            }
            case XZObjcTypeSEL: {
                SEL value = ((SEL (*)(id, SEL))(void *)objc_msgSend)((id)model, property->_getter);
                if (value) {
                    NSString *str = NSStringFromSelector(value);
                    [aCoder encodeObject:str forKey:property->_name];
                }
            } break;
            case XZObjcTypeStruct:
            case XZObjcTypeUnion: {
                NSValue *value = [model valueForKey:NSStringFromSelector(property->_getter)];
                if (value) {
                    size_t const size = property->_property.type.size;
                    if (size <= 64) {
                        char bytes[64] = { 0 };
                        [value getValue:bytes size:size];
                        NSData *data = [NSData dataWithBytes:bytes length:size];
                        [aCoder encodeObject:data forKey:property->_name];
                    } else if (property->_isKeyValueCodable) {
                        char *bytes = calloc(size, sizeof(char));
                        [value getValue:bytes size:size];
                        NSData *data = [NSData dataWithBytesNoCopy:bytes length:size freeWhenDone:YES];
                        [aCoder encodeObject:data forKey:property->_name];
                    } else {
                        // 其它值，不支持 kvc 的话，就没法赋值
                    }
                }
                break;
            }
            default: {
                NSLog(@"[XZJSON] %@ 的属性 %@ 值类型 %@ 无法编码", modelClass->_class.name, property->_property.name, property->_property.type.name);
                break;
            }
        }
    }
}

+ (id)model:(id)model decodeWithCoder:(NSCoder *)aCoder {
    if (!model || !aCoder) {
        return model;
    }
    
    if (model == (id)kCFNull) {
        return model;
    }
    
    XZJSONClassDescriptor * const modelClass = [XZJSONClassDescriptor descriptorForClass:[model class]];
    
    // 原生类型
    if (modelClass->_classType) {
        return model;
    }
    
    for (XZJSONPropertyDescriptor *property in modelClass->_properties) {
        if (!property->_setter) {
            continue;
        }
        
        if (property->_isScalarNumber) {
            NSNumber *value = [aCoder decodeObjectForKey:property->_name];
            XZJSONModelDecodeScalarNumberPropertyFromValue(model, property, value);
            continue;
        }
        
        switch (property->_type) {
            case XZObjcTypeObject: {
                NSData * const data = [aCoder decodeObjectForKey:property->_name];
                Class const ValueClass = property->_property.type.subtype;
                if (ValueClass != Nil && [data isKindOfClass:NSData.class]) {
                    NSError *error = nil;
                    id const value = [NSKeyedUnarchiver unarchivedObjectOfClass:ValueClass fromData:data error:&error];
                    if (value && error.code == noErr) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, property->_setter, value);
                    }
                }
                break;
            }
            case XZObjcTypeSEL: {
                NSString *string = [aCoder decodeObjectForKey:property->_name];
                if ([string isKindOfClass:[NSString class]]) {
                    SEL sel = NSSelectorFromString(string);
                    ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model, property->_setter, sel);
                }
                break;
            }
            case XZObjcTypeStruct:
            case XZObjcTypeUnion: {
                NSData * const data = [aCoder decodeObjectForKey:property->_name];
                if ([data isKindOfClass:NSData.class]) {
                    XZObjcTypeDescriptor *raw = property->_property.type;
                    const char * const bytes = (const char *)data.bytes;
                    if (raw.size <= 64) {
                        ((void (*)(id, SEL, const char[64]))(void *) objc_msgSend)((id)model, property->_setter, bytes);
                    } else if (property->_isKeyValueCodable) {
                        const char * const encoding = [raw.encoding cStringUsingEncoding:NSASCIIStringEncoding];
                        NSValue    * const value    = [NSValue valueWithBytes:bytes objCType:encoding];
                        [model setValue:value forKey:property->_isKeyValueCodable];
                    }
                }
            } break;
                
            default:
                break;
        }
    }
    return model;
}

@end

@implementation XZJSON (NSCopying)

+ (id)modelCopy:(id)model {
    if (model == (id)kCFNull) {
        return model;
    }
    
    XZJSONClassDescriptor *descriptor = [XZJSONClassDescriptor descriptorForClass:[model class]];
    
    if (descriptor->_classType) {
        return [model copy];
    }
    
    id const newModel = [[model class] alloc];
    
    [descriptor->_properties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor *property, NSUInteger idx, BOOL * _Nonnull stop) {
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
                    XZObjcClassDescriptor *class = descriptor->_class;
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
    return XZJSONModelDescription(model, 0, @[]);
}

@end


@implementation XZJSON (NSHashable)

+ (NSUInteger)modelHash:(id)model {
    if (model == (id)kCFNull) return [model hash];
    XZJSONClassDescriptor *modelMeta = [XZJSONClassDescriptor descriptorForClass:[model class]];
    if (modelMeta->_classType) return [model hash];
    
    NSMutableString *string = [NSMutableString stringWithString:@"|"];
    for (XZJSONPropertyDescriptor *propertyMeta in modelMeta->_properties) {
        NSUInteger hash = [XZJSON modelHash:[model valueForKey:NSStringFromSelector(propertyMeta->_getter)]];
        [string appendFormat:@"%lu|", (unsigned long)hash];
    }
    
    if (string.length == 1) {
        return (long)((__bridge void *)model);
    }
    return string.hash;
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
    XZJSONClassDescriptor *modelMeta = [XZJSONClassDescriptor descriptorForClass:[model1 class]];
    if (modelMeta->_classType) {
        return [model1 isEqual:model2];
    }
    if ([model1 hash] != [model2 hash]) {
        return NO;
    }
    
    for (XZJSONPropertyDescriptor *propertyMeta in modelMeta->_properties) {
        id value1 = [model1 valueForKey:NSStringFromSelector(propertyMeta->_getter)];
        id value2 = [model2 valueForKey:NSStringFromSelector(propertyMeta->_getter)];
        if ([XZJSON model:value1 isEqualToModel:value2]) {
            continue;;
        }
        return NO;
    }
    return YES;
}

@end


