//
//  XZJSON.m
//  XZJSON
//
//  Created by Xezun on 2024/9/28.
//

#import "XZMacro.h"
#import "XZJSON.h"
#import "XZJSONFoundation.h"
#import "XZJSONClassDescriptor.h"
#import "XZJSONDecoder.h"
#import "XZJSONEncoder.h"

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

@implementation XZJSON (XZJSONDecoder)

+ (id)decode:(id)json options:(NSJSONReadingOptions)options class:(Class)aClass {
    // 判空
    if (json == nil || json == NSNull.null) {
        return nil;
    }
    // 二进制流形式的 json 数据
    if ([json isKindOfClass:NSData.class]) {
        return XZJSONDecodeJSONData(json, options, aClass);
    }
    // 字符串形式的 json 数据
    if ([json isKindOfClass:NSString.class]) {
        NSString * const JSONString = json;
        NSData   * const JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
        if (JSONData == nil) {
            return nil;
        }
        return XZJSONDecodeJSONData(JSONData, options, aClass);
    }
    // 如果为数组，视为解析多个 json 数据
    if ([json isKindOfClass:NSArray.class]) {
        NSArray * const JSONArray = json;
        if (JSONArray.count == 0) {
            return JSONArray;
        }
        NSMutableArray * const models = [NSMutableArray arrayWithCapacity:JSONArray.count];
        for (id json in JSONArray) {
            id const model = [self decode:json options:options class:aClass];
            if (model) {
                [models addObject:model];
            }
        }
        return models;
    }
    // 其它情况视为已解析好的 json
    return XZJSONDecodeJSONObject(json, aClass);
}

+ (void)model:(id)model decodeFromDictionary:(NSDictionary *)dictionary {
    XZJSONClassDescriptor * const modelClass = [XZJSONClassDescriptor descriptorForClass:[model class]];
    if (modelClass) {
        XZJSONModelDecodeFromDictionary(model, modelClass, dictionary);
    }
}

@end


@implementation XZJSON (XZJSONEncoder)

+ (NSData *)encode:(id)object options:(NSJSONWritingOptions)options error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    if (object == nil) {
        return nil;
    }
    XZJSONClassDescriptor * const objectClass = [XZJSONClassDescriptor descriptorForClass:object_getClass(object)];
    if (objectClass == nil) {
        return nil;
    }
    id const JSONObject = XZJSONEncodeObjectIntoDictionary(object, objectClass, nil);
    return [NSJSONSerialization dataWithJSONObject:JSONObject options:options error:error];
}

+ (void)model:(id)model encodeIntoDictionary:(NSMutableDictionary *)dictionary {
    XZJSONClassDescriptor * const modelClass = [XZJSONClassDescriptor descriptorForClass:[model class]];
    if (modelClass) {
        XZJSONModelEncodeIntoDictionary(model, modelClass, dictionary);
    }
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


@implementation XZJSON (NSDescription)

+ (NSString *)model:(id)model description:(NSUInteger)indent {
    return XZJSONModelDescription(model, indent);
}

@end


@implementation XZJSON (NSCopying)

+ (id)model:(id)model copy:(BOOL (^)(id _Nonnull, NSString * _Nonnull))block {
    if (model == nil || model == (id)kCFNull) {
        return model;
    }
    
    XZJSONClassDescriptor * const modelClass  = [XZJSONClassDescriptor descriptorForClass:[model class]];
    
    // 原生对象不支持复制
    if (modelClass->_classType) {
        return [model copy];
    }
    
    id const newModel = [modelClass->_class.raw new];
    
    // 模型复制，只复制同名属性
    [modelClass->_properties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor * const property, NSUInteger idx, BOOL * _Nonnull stop) {
        SEL const getter = property->_getter;
        SEL const setter = property->_setter;
        switch (property->_type) {
            case XZObjcTypeChar: {
                char const value = ((char (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, char))objc_msgSend)(newModel, setter, value);
                return;
            }
            case XZObjcTypeInt: {
                int const value = ((int (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, int))objc_msgSend)(newModel, setter, value);
                return;
            }
            case XZObjcTypeShort: {
                short const value = ((short (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, short))objc_msgSend)(newModel, setter, value);
                return;
            }
            case XZObjcTypeLong: {
                long const value = ((long (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, long))objc_msgSend)(newModel, setter, value);
                return;
            }
            case XZObjcTypeLongLong: {
                long long const value = ((long long (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, long long))objc_msgSend)(newModel, setter, value);
                return;
            }
            case XZObjcTypeUnsignedChar: {
                unsigned char const value = ((unsigned char (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, unsigned char))objc_msgSend)(newModel, setter, value);
                return;
            }
            case XZObjcTypeUnsignedInt: {
                unsigned int const value = ((unsigned int (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, unsigned int))objc_msgSend)(newModel, setter, value);
                return;
            }
            case XZObjcTypeUnsignedShort: {
                unsigned short const value = ((unsigned short (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, unsigned short))objc_msgSend)(newModel, setter, value);
                return;
            }
            case XZObjcTypeUnsignedLong: {
                unsigned long const value = ((unsigned long (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, unsigned long))objc_msgSend)(newModel, setter, value);
                return;
            }
            case XZObjcTypeUnsignedLongLong: {
                unsigned long long const value = ((unsigned long long (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, unsigned long long))objc_msgSend)(newModel, setter, value);
                return;
            }
            case XZObjcTypeFloat: {
                float const value = ((float (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, float))objc_msgSend)(newModel, setter, value);
                return;
            }
            case XZObjcTypeDouble: {
                double const value = ((double (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, double))objc_msgSend)(newModel, setter, value);
                return;
            }
            case XZObjcTypeLongDouble: {
                long double const value = ((long double (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, long double))objc_msgSend)(newModel, setter, value);
                return;
            }
            case XZObjcTypeBool: {
                BOOL const value = ((BOOL (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, BOOL))objc_msgSend)(newModel, setter, value);
                return;
            }
            case XZObjcTypeClass: {
                Class const value = ((Class (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, Class))objc_msgSend)(newModel, setter, value);
                return;
            }
            case XZObjcTypeSEL:  {
                SEL const value = ((SEL (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, SEL))objc_msgSend)(newModel, setter, value);
                return;
            }
            case XZObjcTypeObject:  {
                id const value = ((id (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, id))objc_msgSend)(newModel, setter, value);
                return;
            }
            case XZObjcTypeStruct: {
                switch (property->_structType) {
                    case XZJSONStructTypeUnknown: {
                        break;
                    }
                    case XZJSONStructTypeCGRect: {
                        CGRect const value = ((CGRect (*)(id, SEL))objc_msgSend)(self, getter);
                        ((void (*)(id, SEL, CGRect))objc_msgSend)(newModel, setter, value);
                        return;
                    }
                    case XZJSONStructTypeCGSize: {
                        CGSize const value = ((CGSize (*)(id, SEL))objc_msgSend)(self, getter);
                        ((void (*)(id, SEL, CGSize))objc_msgSend)(newModel, setter, value);
                        return;
                    }
                    case XZJSONStructTypeCGPoint: {
                        CGPoint const value = ((CGPoint (*)(id, SEL))objc_msgSend)(self, getter);
                        ((void (*)(id, SEL, CGPoint))objc_msgSend)(newModel, setter, value);
                        return;
                    }
                    case XZJSONStructTypeUIEdgeInsets: {
                        UIEdgeInsets const value = ((UIEdgeInsets (*)(id, SEL))objc_msgSend)(self, getter);
                        ((void (*)(id, SEL, UIEdgeInsets))objc_msgSend)(newModel, setter, value);
                        return;
                    }
                    case XZJSONStructTypeCGVector: {
                        CGVector const value = ((CGVector (*)(id, SEL))objc_msgSend)(self, getter);
                        ((void (*)(id, SEL, CGVector))objc_msgSend)(newModel, setter, value);
                        return;
                    }
                    case XZJSONStructTypeCGAffineTransform: {
                        CGAffineTransform const value = ((CGAffineTransform (*)(id, SEL))objc_msgSend)(self, getter);
                        ((void (*)(id, SEL, CGAffineTransform))objc_msgSend)(newModel, setter, value);
                        return;
                    }
                    case XZJSONStructTypeNSDirectionalEdgeInsets: {
                        NSDirectionalEdgeInsets const value = ((NSDirectionalEdgeInsets (*)(id, SEL))objc_msgSend)(self, getter);
                        ((void (*)(id, SEL, NSDirectionalEdgeInsets))objc_msgSend)(newModel, setter, value);
                        return;
                    }
                    case XZJSONStructTypeUIOffset: {
                        UIOffset const value = ((UIOffset (*)(id, SEL))objc_msgSend)(self, getter);
                        ((void (*)(id, SEL, UIOffset))objc_msgSend)(newModel, setter, value);
                        return;
                    }
                }
                break;
            }
            case XZObjcTypeUnion:
            case XZObjcTypeBitField:
            case XZObjcTypeVoid:
            case XZObjcTypeString:
            case XZObjcTypeArray:
            case XZObjcTypePointer:
            case XZObjcTypeUnknown: {
                break;
            }
        }
        // 无法复制的属性
        if (block && block(newModel, property->_name)) {
            return;
        }
        XZLog(@"[XZJSON] 无法复制 %@ 对象的属性 %@ 的值", modelClass->_class.raw, property->_name);
    }];
    
    return newModel;
}

@end


@implementation XZJSON (NSEquatable)

+ (BOOL)model:(id)model1 isEqualToModel:(id)model2 comparator:(XZJSONEquation (^)(id _Nonnull, id _Nonnull, NSString * _Nonnull))block {
    // 相等：同一对象
    if (model1 == model2) {
        return YES;
    }
    
    // 不相等：其中一个为 nil
    if (model1 == nil || model2 == nil) {
        return NO;
    }
    
    XZJSONClassDescriptor * const model1Class = [XZJSONClassDescriptor descriptorForClass:[model1 class]];
    XZJSONClassDescriptor * const model2Class = [XZJSONClassDescriptor descriptorForClass:[model2 class]];
    
    // 不相等：属性数量不一样
    if (model1Class->_numberOfProperties != model2Class->_numberOfProperties) {
        return NO;
    }
    
    // 原生类型之间的比较
    if (model1Class->_classType && model2Class->_classType) {
        return [model1 isEqual:model2];
    }
    
    // 一个是模型，一个是原生类型
    if (model1Class->_classType || model2Class->_classType) {
        return NO;
    }
    
    // 都是模型，逐个比较属性。
    for (XZJSONPropertyDescriptor * const property1 in model1Class->_properties) {
        NSString                 * const name      = property1->_name;
        XZJSONPropertyDescriptor * const property2 = model2Class->_namedProperties[name];
        
        // 不相等：模型没有同名属性
        if (property2 == nil) {
            return NO;
        }
        
        // 不相等：同名属性的值类型不相同
        if (property1->_type != property2->_type) {
            return NO;
        }
        
        // 比较属性值
        switch (property1->_type) {
            case XZObjcTypeUnknown:
                break;
            case XZObjcTypeChar: {
                char value1 = ((char(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                char value2 = ((char(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZObjcTypeUnsignedChar: {
                unsigned char value1 = ((unsigned char(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                unsigned char value2 = ((unsigned char(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZObjcTypeInt: {
                int value1 = ((int(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                int value2 = ((int(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZObjcTypeUnsignedInt: {
                unsigned int value1 = ((unsigned int(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                unsigned int value2 = ((unsigned int(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZObjcTypeShort: {
                short value1 = ((short(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                short value2 = ((short(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZObjcTypeUnsignedShort: {
                unsigned short value1 = ((unsigned short(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                unsigned short value2 = ((unsigned short(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZObjcTypeLong: {
                long value1 = ((long(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                long value2 = ((long(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZObjcTypeUnsignedLong: {
                unsigned long value1 = ((unsigned long(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                unsigned long value2 = ((unsigned long(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZObjcTypeLongLong: {
                long long value1 = ((long long(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                long long value2 = ((long long(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZObjcTypeUnsignedLongLong: {
                unsigned long long value1 = ((unsigned long long(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                unsigned long long value2 = ((unsigned long long(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZObjcTypeFloat: {
                float value1 = ((float(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                float value2 = ((float(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZObjcTypeDouble: {
                double value1 = ((double(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                double value2 = ((double(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZObjcTypeLongDouble: {
                long double value1 = ((long double(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                long double value2 = ((long double(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZObjcTypeBool: {
                BOOL value1 = ((BOOL(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                BOOL value2 = ((BOOL(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZObjcTypeVoid:
            case XZObjcTypeString:
            case XZObjcTypeArray:
            case XZObjcTypeBitField:
            case XZObjcTypePointer:
            case XZObjcTypeUnion: {
                break;
            }
            case XZObjcTypeStruct:
                if (property1->_structType != property2->_structType) {
                    return NO;
                }
                switch (property1->_structType) {
                    case XZJSONStructTypeUnknown: {
                        break;
                    }
                    case XZJSONStructTypeCGRect: {
                        CGRect value1 = ((CGRect(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                        CGRect value2 = ((CGRect(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                        if (!CGRectEqualToRect(value1, value2)) {
                            return NO;
                        }
                        continue;
                    }
                    case XZJSONStructTypeCGSize: {
                        CGSize value1 = ((CGSize(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                        CGSize value2 = ((CGSize(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                        if (!CGSizeEqualToSize(value1, value2)) {
                            return NO;
                        }
                        continue;
                    }
                    case XZJSONStructTypeCGPoint: {
                        CGPoint value1 = ((CGPoint(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                        CGPoint value2 = ((CGPoint(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                        if (!CGPointEqualToPoint(value1, value2)) {
                            return NO;
                        }
                        continue;
                    }
                    case XZJSONStructTypeUIEdgeInsets: {
                        UIEdgeInsets value1 = ((UIEdgeInsets(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                        UIEdgeInsets value2 = ((UIEdgeInsets(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                        if (!UIEdgeInsetsEqualToEdgeInsets(value1, value2)) {
                            return NO;
                        }
                        continue;
                    }
                    case XZJSONStructTypeCGVector: {
                        CGVector value1 = ((CGVector(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                        CGVector value2 = ((CGVector(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                        if (value1.dx != value2.dx || value1.dy != value2.dy) {
                            return NO;
                        }
                        continue;
                    }
                    case XZJSONStructTypeCGAffineTransform: {
                        CGAffineTransform value1 = ((CGAffineTransform(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                        CGAffineTransform value2 = ((CGAffineTransform(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                        if (!CGAffineTransformEqualToTransform(value1, value2)) {
                            return NO;
                        }
                        continue;
                    }
                    case XZJSONStructTypeNSDirectionalEdgeInsets: {
                        NSDirectionalEdgeInsets value1 = ((NSDirectionalEdgeInsets(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                        NSDirectionalEdgeInsets value2 = ((NSDirectionalEdgeInsets(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                        if (!NSDirectionalEdgeInsetsEqualToDirectionalEdgeInsets(value1, value2)) {
                            return NO;
                        }
                        continue;
                    }
                    case XZJSONStructTypeUIOffset: {
                        UIOffset value1 = ((UIOffset(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                        UIOffset value2 = ((UIOffset(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                        if (!UIOffsetEqualToOffset(value1, value2)) {
                            return NO;
                        }
                        continue;
                    }
                }
                break;
            case XZObjcTypeClass: {
                Class value1 = ((Class(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                Class value2 = ((Class(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZObjcTypeSEL: {
                SEL value1 = ((SEL(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                SEL value2 = ((SEL(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZObjcTypeObject: {
                id value1 = ((id(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                id value2 = ((id(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                
                if (value1 == nil) {
                    if (value2 == nil) {
                        continue;
                    }
                    return NO;
                }
                
                if (value2 == nil) {
                    return NO;
                }
                
                if ([value1 isKindOfClass:NSObject.class]) {
                    if (![value1 isEqual:value2]) {
                        return NO;
                    }
                    continue;
                }
                if ([value2 isKindOfClass:NSObject.class]) {
                    if (![value2 isEqual:value1]) {
                        return NO;
                    }
                    continue;
                }
                break;
            }
        }
        
        // 无法比较的属性值
        if (block) {
            switch (block(model1, model2, name)) {
                case XZJSONEquationNo:
                    return NO;
                case XZJSONEquationUnknown:
                    break;
                case XZJSONEquationYes:
                    continue;
            }
        }
        
        // 默认不相等。
        XZLog(@"[XZJSON] 无法比较数据模型 %@ 与 %@ 的 属性 %@ 的值", model1Class->_class.raw, model2Class->_class.raw, name);
        return NO;
    }
    
    return YES;
}

@end


