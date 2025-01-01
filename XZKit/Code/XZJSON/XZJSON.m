//
//  XZJSON.m
//  XZJSON
//
//  Created by 徐臻 on 2024/9/28.
//

#import "XZJSON.h"
#import "XZJSONClassDescriptor.h"
#import "XZJSONPrivate.h"

@implementation XZJSON

#pragma mark - Decoder

+ (id)decode:(id)json options:(NSJSONReadingOptions)options class:(Class)aClass {
    if (json == nil || json == NSNull.null) {
        return nil;
    }
    // 二进制流形式的 json 数据。
    if ([json isKindOfClass:NSData.class]) {
        return [self _decodeData:json options:options class:aClass];
    }
    // 字符串形式的 json 数据。
    if ([json isKindOfClass:NSString.class]) {
        NSData * const data = [((NSString *)json) dataUsingEncoding:NSUTF8StringEncoding];
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
            [models addObject:(model ?: NSNull.null)];
        }
        return models;
    }
    // 其它情况视为已解析好的 json
    return [self _decodeObject:json class:aClass];
}

/// 序列化原始 JOSN 数据。
+ (nullable id)_decodeData:(nonnull NSData *)data options:(NSJSONReadingOptions)options class:(Class)aClass {
    NSError *error = nil;
    id const object = [NSJSONSerialization JSONObjectWithData:data options:options error:&error];
    if ((error == nil || error.code == noErr) && object != nil) {
        return [self _decodeObject:object class:aClass];
    }
    return nil;
}

/// 模型化已序列化的 JSON 数据。
+ (nullable id)_decodeObject:(nonnull id const)object class:(Class)aClass {
    if (object == NSNull.null) {
        return nil;
    }
    // 如果为字典，则认为是模型数据。
    if ([object isKindOfClass:NSDictionary.class]) {
        NSDictionary *dictionary = object;
        XZJSONClassDescriptor *descriptor = [XZJSONClassDescriptor descriptorForClass:aClass];
        
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
        
        if (descriptor->_verifiesValueForDecoding) {
            dictionary = [aClass canDecodeFromJSONDictionary:dictionary];
            if (dictionary == nil) {
                return nil;
            }
        }
        
        if (descriptor->_usesDecodingInitializer) {
            return [[aClass alloc] initWithJSONDictionary:dictionary];
        }
        
        id const model = [aClass new];
        if (model != nil) {
            [self _model:model decodeWithDictionary:dictionary descriptor:descriptor];
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

+ (void)_model:(id)model decodeWithDictionary:(NSDictionary *)dictionary descriptor:(XZJSONClassDescriptor *)descriptor {
    if (descriptor->_numberOfProperties == 0) return;
   
    XZJSONCodingContext context = {0};
    context.descriptor = (__bridge void *)(descriptor);
    context.model      = (__bridge void *)(model);
    context.dictionary = (__bridge void *)(dictionary);
    
    if (descriptor->_numberOfProperties >= CFDictionaryGetCount((CFDictionaryRef)dictionary)) {
        CFDictionaryApplyFunction((CFDictionaryRef)dictionary, XZJSONDecodingDictionaryEnumerator, &context);
        
        if (descriptor->_keyPathProperties) {
            CFRange const range = CFRangeMake(0, CFArrayGetCount((CFArrayRef)descriptor->_keyPathProperties));
            CFArrayApplyFunction((CFArrayRef)descriptor->_keyPathProperties, range, XZJSONDecodingArrayEnumerator, &context);
        }
        
        if (descriptor->_keyArrayProperties) {
            CFRange const range = CFRangeMake(0, CFArrayGetCount((CFArrayRef)descriptor->_keyArrayProperties));
            CFArrayApplyFunction((CFArrayRef)descriptor->_keyArrayProperties, range, XZJSONDecodingArrayEnumerator, &context);
        }
    } else {
        CFRange const range = CFRangeMake(0, descriptor->_numberOfProperties);
        CFArrayApplyFunction((CFArrayRef)descriptor->_properties, range, XZJSONDecodingArrayEnumerator, &context);
    }
}

#pragma mark - Encoder

+ (NSData *)encode:(id)object options:(NSJSONWritingOptions)options error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    if (object == nil) {
        return nil;
    }
    
    id const JSONObject = [self _encodeObject:object dictionary:nil];
    
    if (JSONObject == nil) {
        return nil;
    }
    
    return [NSJSONSerialization dataWithJSONObject:JSONObject options:options error:error];
}

/// 将原生或自定义的数据实例对象 模型化为 JSON基础数据类型。
+ (id)_encodeObject:(nonnull id)model dictionary:(nullable NSMutableDictionary *)dictionary {
    // === 原生数据 ===
    if (model == (id)kCFNull) {
        return model;
    }
    if ([model isKindOfClass:[NSString class]]) {
        return model;
    }
    if ([model isKindOfClass:[NSNumber class]]) {
        return model;
    }
    if ([model isKindOfClass:[NSDictionary class]]) {
        NSDictionary * const dict = model;
        if ([NSJSONSerialization isValidJSONObject:dict]) {
            return dict;
        }
        NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithCapacity:dict.count];
        [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            NSString * const stringKey = [key isKindOfClass:[NSString class]] ? key : key.description;
            if (!stringKey) return;
            id const jsonObj = [self _encodeObject:obj dictionary:nil];
            if (jsonObj != nil) {
                dictM[stringKey] = jsonObj;
            }
        }];
        return dictM;
    }
    if ([model isKindOfClass:[NSSet class]]) {
        NSSet * const set = model;
        model = set.allObjects;
        // fall in next NSArray
    }
    if ([model isKindOfClass:[NSArray class]]) {
        NSArray * const array = model;
        if ([NSJSONSerialization isValidJSONObject:array]) {
            return array;
        }
        NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:array.count];
        for (id obj in (NSArray *)model) {
            id const jsonObj = [self _encodeObject:obj dictionary:nil];
            if (jsonObj != nil) {
                [newArray addObject:jsonObj];
            }
        }
        return newArray;
    }
    if ([model isKindOfClass:[NSURL class]]) {
        return ((NSURL *)model).absoluteString;
    }
    if ([model isKindOfClass:[NSAttributedString class]]) {
        return ((NSAttributedString *)model).string;
    }
    // TODO: DateFormatter
    if ([model isKindOfClass:[NSDate class]]) {
        return [XZJSONDateFormatter() stringFromDate:(id)model];
    }
    if ([model isKindOfClass:[NSData class]]) {
        return nil;
    }
    
    // === 数据模型 ===
    
    XZJSONClassDescriptor *descriptor = [XZJSONClassDescriptor descriptorForClass:[model class]];
    if (dictionary == nil) {
        dictionary = [NSMutableDictionary dictionaryWithCapacity:descriptor->_numberOfProperties];
    }
    
    // 自定义解析
    if (descriptor->_usesJSONEncodingMethod) {
        return [(id<XZJSONEncoding>)model encodeIntoJSONDictionary:dictionary];
    }
    
    // 通用解析
    [self _model:model encodeIntoDictionary:dictionary descriptor:descriptor];
    
    return dictionary;
}

+ (void)_model:(id)model encodeIntoDictionary:(NSMutableDictionary *)dictionary descriptor:(XZJSONClassDescriptor *)descriptor {
    if (!descriptor || descriptor->_numberOfProperties == 0) return;
    
    [descriptor->_keyProperties enumerateKeysAndObjectsUsingBlock:^(NSString *aKey, XZJSONPropertyDescriptor *property, BOOL *stop) {
        if (!property->_getter) return;
        
        NSMutableDictionary *dict = dictionary;
        NSString            *key  = nil;
        if (property->_JSONKeyPath) { // 优先使用 keyPath
            for (NSInteger i = 0, max = property->_JSONKeyPath.count - 1; ; i++) {
                NSString * const subKey = property->_JSONKeyPath[i];
                if (i >= max) {
                    key = subKey;
                    break;
                }
                
                NSMutableDictionary *subDict = dict[subKey];
                if (subDict == nil) {
                    subDict = [NSMutableDictionary dictionary];
                    dict[subKey] = subDict;
                } else if (![subDict isKindOfClass:NSMutableDictionary.class]) {
                    return; // 对应的 key 已经有其它值，不支持设置 keyPath
                }
                dict = subDict;
            }
        } else if (dictionary[property->_JSONKey]) {
            return; // 值已存在，不覆盖。
        } else {
            key = property->_JSONKey;
        }
        
        id value = nil;
        if (property->_isCNumber) {
            // 标量数字
            value = XZJSONEncodeNumberForProperty(model, property);
        } else if (property->_nsType) {
            // 原生类型
            id const nsValue = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
            if (nsValue) {
                value = [self _encodeObject:nsValue dictionary:nil];
            }
        } else {
            // 模型
            switch (property->_type & XZObjcTypeMask) {
                case XZObjcTypeObject: {
                    id const csValue = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                    if (csValue) {
                        // 如果 key 已经有值，则进行合并，不能合并则覆盖
                        NSMutableDictionary *subDict = dict[key];
                        if (![subDict isKindOfClass:NSMutableDictionary.class]) {
                            subDict = [NSMutableDictionary dictionary];
                        }
                        value = [self _encodeObject:csValue dictionary:subDict];
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
                default: {
                    // not supported value
                    break;
                }
            }
        }
       
        dict[key] = value ?: (id)kCFNull;
    }];
}

@end

@implementation XZJSON (XZExtenedJSON)

+ (void)model:(id)object decodeWithDictionary:(NSDictionary *)dictionary {
    XZJSONClassDescriptor * const descriptor = [XZJSONClassDescriptor descriptorForClass:[object class]];
    [self _model:object decodeWithDictionary:dictionary descriptor:descriptor];
}

// yy_modelSetWithDictionary
+ (void)model:(id)object encodeIntoDictionary:(NSMutableDictionary *)dictionary {
    XZJSONClassDescriptor * const descriptor = [XZJSONClassDescriptor descriptorForClass:[object class]];
    [self _model:object encodeIntoDictionary:dictionary descriptor:descriptor];
}

// - (void)yy_modelEncodeWithCoder:(NSCoder *)aCoder
+ (void)object:(id)object encodeWithCoder:(NSCoder *)aCoder {
    if (!aCoder) return;
    if (object == (id)kCFNull) {
        [((id<NSCoding>)object)encodeWithCoder:aCoder];
        return;
    }
    
    XZJSONClassDescriptor *modelMeta = [XZJSONClassDescriptor descriptorForClass:[object class]];
    if (modelMeta->_nsType) {
        [((id<NSCoding>)object)encodeWithCoder:aCoder];
        return;
    }
    
    for (XZJSONPropertyDescriptor *propertyMeta in modelMeta->_properties) {
        if (!propertyMeta->_getter) return;
        
        if (propertyMeta->_isCNumber) {
            NSNumber *value = XZJSONEncodeNumberForProperty(object, propertyMeta);
            if (value) [aCoder encodeObject:value forKey:propertyMeta->_name];
        } else {
            switch (propertyMeta->_type & XZObjcTypeMask) {
                case XZObjcTypeObject: {
                    id value = ((id (*)(id, SEL))(void *)objc_msgSend)((id)object, propertyMeta->_getter);
                    if (value && (propertyMeta->_nsType || [value respondsToSelector:@selector(encodeWithCoder:)])) {
                        if ([value isKindOfClass:[NSValue class]]) {
                            if ([value isKindOfClass:[NSNumber class]]) {
                                [aCoder encodeObject:value forKey:propertyMeta->_name];
                            }
                        } else {
                            [aCoder encodeObject:value forKey:propertyMeta->_name];
                        }
                    }
                } break;
                case XZObjcTypeSEL: {
                    SEL value = ((SEL (*)(id, SEL))(void *)objc_msgSend)((id)object, propertyMeta->_getter);
                    if (value) {
                        NSString *str = NSStringFromSelector(value);
                        [aCoder encodeObject:str forKey:propertyMeta->_name];
                    }
                } break;
                case XZObjcTypeStruct:
                case XZObjcTypeUnion: {
                    if (propertyMeta->_isKVCCompatible && propertyMeta->_isNSCodingStruct) {
                        @try {
                            NSValue *value = [object valueForKey:NSStringFromSelector(propertyMeta->_getter)];
                            [aCoder encodeObject:value forKey:propertyMeta->_name];
                        } @catch (NSException *exception) {}
                    }
                } break;
                    
                default:
                    break;
            }
        }
    }
}

// - (id)yy_modelInitWithCoder:(NSCoder *)aDecoder
+ (id)object:(id)object decodeWithCoder:(NSCoder *)aDecoder {
    if (!aDecoder) return object;
    if (object == (id)kCFNull) return object;
    XZJSONClassDescriptor *modelMeta = [XZJSONClassDescriptor descriptorForClass:[object class]];
    if (modelMeta->_nsType) return object;
    
    for (XZJSONPropertyDescriptor *propertyMeta in modelMeta->_properties) {
        if (!propertyMeta->_setter) continue;
        
        if (propertyMeta->_isCNumber) {
            NSNumber *value = [aDecoder decodeObjectForKey:propertyMeta->_name];
            if ([value isKindOfClass:[NSNumber class]]) {
                XZJSONDecodeNumberForProperty(object, value, propertyMeta);
                [value class];
            }
        } else {
            XZObjcType type = propertyMeta->_type & XZObjcTypeMask;
            switch (type) {
                case XZObjcTypeObject: {
                    id value = [aDecoder decodeObjectForKey:propertyMeta->_name];
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)object, propertyMeta->_setter, value);
                } break;
                case XZObjcTypeSEL: {
                    NSString *str = [aDecoder decodeObjectForKey:propertyMeta->_name];
                    if ([str isKindOfClass:[NSString class]]) {
                        SEL sel = NSSelectorFromString(str);
                        ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)object, propertyMeta->_setter, sel);
                    }
                } break;
                case XZObjcTypeStruct:
                case XZObjcTypeUnion: {
                    if (propertyMeta->_isKVCCompatible) {
                        @try {
                            NSValue *value = [aDecoder decodeObjectForKey:propertyMeta->_name];
                            if (value) [object setValue:value forKey:propertyMeta->_name];
                        } @catch (NSException *exception) {}
                    }
                } break;
                    
                default:
                    break;
            }
        }
    }
    return object;
}

+ (NSUInteger)objectHash:(id)object {
    if (object == (id)kCFNull) return [object hash];
    XZJSONClassDescriptor *modelMeta = [XZJSONClassDescriptor descriptorForClass:[object class]];
    if (modelMeta->_nsType) return [object hash];
    
    NSMutableString *string = [NSMutableString string];
    for (XZJSONPropertyDescriptor *propertyMeta in modelMeta->_properties) {
        if (!propertyMeta->_isKVCCompatible) continue;
        
        NSUInteger const hash = [[object valueForKey:NSStringFromSelector(propertyMeta->_getter)] hash];
        [string appendFormat:@"%lu", hash];
    }
    
    if (string.length == 0) {
        return (long)((__bridge void *)object);
    }
    return string.hash;
}

+ (BOOL)object:(id)object1 isEqualToObject:(id)object2 {
    if (object1 == object2) return YES;
    if (![object2 isMemberOfClass:[object1 class]]) return NO;
    XZJSONClassDescriptor *modelMeta = [XZJSONClassDescriptor descriptorForClass:[object1 class]];
    if (modelMeta->_nsType) return [object1 isEqual:object2];
    if ([object1 hash] != [object2 hash]) return NO;
    
    for (XZJSONPropertyDescriptor *propertyMeta in modelMeta->_properties) {
        if (!propertyMeta->_isKVCCompatible) continue;
        id this = [object1 valueForKey:NSStringFromSelector(propertyMeta->_getter)];
        id that = [object2 valueForKey:NSStringFromSelector(propertyMeta->_getter)];
        if (this == that) continue;
        if (this == nil || that == nil) return NO;
        if (![this isEqual:that]) return NO;
    }
    return YES;
}

+ (BOOL)objectDescription:(id)object {
    return XZJSONDescription(object);
}

+ (id)objectCopy:(id)object {
    if (object == (id)kCFNull) return object;
    XZJSONClassDescriptor *modelMeta = [XZJSONClassDescriptor descriptorForClass:[object class]];
    if (modelMeta->_nsType) return [object copy];
    
    NSObject *one = [[object class] new];
    for (XZJSONPropertyDescriptor *propertyMeta in modelMeta->_properties) {
        if (!propertyMeta->_getter || !propertyMeta->_setter) continue;
        
        if (propertyMeta->_isCNumber) {
            switch (propertyMeta->_type & XZObjcTypeMask) {
                case XZObjcTypeBool: {
                    bool num = ((bool (*)(id, SEL))(void *) objc_msgSend)((id)object, propertyMeta->_getter);
                    ((void (*)(id, SEL, bool))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case XZObjcTypeInt8:
                case XZObjcTypeUInt8: {
                    uint8_t num = ((bool (*)(id, SEL))(void *) objc_msgSend)((id)object, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case XZObjcTypeInt16:
                case XZObjcTypeUInt16: {
                    uint16_t num = ((uint16_t (*)(id, SEL))(void *) objc_msgSend)((id)object, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case XZObjcTypeInt32:
                case XZObjcTypeUInt32: {
                    uint32_t num = ((uint32_t (*)(id, SEL))(void *) objc_msgSend)((id)object, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case XZObjcTypeInt64:
                case XZObjcTypeUInt64: {
                    uint64_t num = ((uint64_t (*)(id, SEL))(void *) objc_msgSend)((id)object, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case XZObjcTypeFloat: {
                    float num = ((float (*)(id, SEL))(void *) objc_msgSend)((id)object, propertyMeta->_getter);
                    ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case XZObjcTypeDouble: {
                    double num = ((double (*)(id, SEL))(void *) objc_msgSend)((id)object, propertyMeta->_getter);
                    ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case XZObjcTypeLongDouble: {
                    long double num = ((long double (*)(id, SEL))(void *) objc_msgSend)((id)object, propertyMeta->_getter);
                    ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } // break; commented for code coverage in next line
                default: break;
            }
        } else {
            switch (propertyMeta->_type & XZObjcTypeMask) {
                case XZObjcTypeObject:
                case XZObjcTypeClass:
                case XZObjcTypeBlock: {
                    id value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)object, propertyMeta->_getter);
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)one, propertyMeta->_setter, value);
                } break;
                case XZObjcTypeSEL:
                case XZObjcTypePointer:
                case XZObjcTypeCString: {
                    size_t value = ((size_t (*)(id, SEL))(void *) objc_msgSend)((id)object, propertyMeta->_getter);
                    ((void (*)(id, SEL, size_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, value);
                } break;
                case XZObjcTypeStruct:
                case XZObjcTypeUnion: {
                    @try {
                        NSValue *value = [object valueForKey:NSStringFromSelector(propertyMeta->_getter)];
                        if (value) {
                            [one setValue:value forKey:propertyMeta->_name];
                        }
                    } @catch (NSException *exception) {}
                } // break; commented for code coverage in next line
                default: break;
            }
        }
    }
    return one;
}

@end
