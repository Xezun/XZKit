//
//  XZJSON.m
//  XZJSON
//
//  Created by Xezun on 2024/9/28.
//

#import "XZJSON.h"
#import "XZJSONPrivate.h"
#import "XZMacros.h"
#import "XZLog.h"

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

+ (id)decode:(id)json options:(NSJSONReadingOptions)options class:(Class)modelClass {
    // 判空
    if (json == nil || json == (id)kCFNull) {
        return nil;
    }
    // 二进制流形式的 json 数据
    if ([json isKindOfClass:NSData.class]) {
        return XZJSONDecodeJSONData((NSData *)json, options, modelClass);
    }
    // 字符串形式的 json 数据
    if ([json isKindOfClass:NSString.class]) {
        NSData * const data = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
        if (data == nil) {
            return nil;
        }
        return XZJSONDecodeJSONData(data, options, modelClass);
    }
    // 如果为数组，视为解析多个 json 数据
    if ([json isKindOfClass:NSArray.class]) {
        if (((NSArray *)json).count == 0) {
            return json;
        }
        NSMutableArray * const models = [NSMutableArray arrayWithCapacity:((NSArray *)json).count];
        for (id item in ((NSArray *)json)) {
            id const model = [self decode:item options:options class:modelClass];
            if (model) {
                [models addObject:model];
            } else if (options & XZJSONReadingKeepCapacity) {
                [models addObject:(id)kCFNull];
            }
        }
        return models;
    }
    // 其它情况视为已解析好的 json
    return XZJSONDecodeJSONObject(json, modelClass);
}

+ (void)model:(id)model decodeFromDictionary:(NSDictionary *)dictionary {
    Class const modelClass = object_getClass(model);
    XZJSONClassDescriptor * const descriptor = [XZJSONClassDescriptor descriptorForClass:modelClass];
    if (modelClass) {
        XZJSONModelDecodeFromDictionary(model, descriptor, dictionary);
    }
}

@end


@implementation XZJSON (XZJSONEncoder)

+ (NSData *)encode:(id)model options:(NSJSONWritingOptions)options error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    if (model == nil) {
        return nil;
    }
    Class const modelClass = object_getClass(model);
    if (modelClass == Nil) {
        return nil;
    }
    XZJSONClassDescriptor * const descriptor = [XZJSONClassDescriptor descriptorForClass:modelClass];
    if (descriptor == nil) {
        return nil;
    }
    id const dictionary = XZJSONEncodeModelIntoDictionary(model, descriptor, descriptor->_foundationClass, nil);
    return [NSJSONSerialization dataWithJSONObject:dictionary options:options error:error];
}

+ (void)model:(id)model encodeIntoDictionary:(NSMutableDictionary *)dictionary {
    Class const modelClass = object_getClass(model);
    XZJSONClassDescriptor * const descriptor = [XZJSONClassDescriptor descriptorForClass:modelClass];
    if (descriptor) {
        XZJSONModelEncodeIntoDictionary(model, descriptor, dictionary);
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

+ (NSString *)model:(id)model descriptionWithIndent:(NSUInteger)indent {
    return XZJSONModelDescription(model, indent);
}

@end


@implementation XZJSON (NSCopying)

+ (id)model:(id)sourceModel copy:(nullable id)targetModel {
    // 判空
    if (sourceModel == nil || sourceModel == (id)kCFNull) {
        return sourceModel;
    }
    
    Class const sourceClass = object_getClass(sourceModel);
    XZJSONClassDescriptor * const sourceDescriptor  = [XZJSONClassDescriptor descriptorForClass:sourceClass];
    
    // 不支持复制原生对象
    if (sourceDescriptor->_foundationClass) {
        return targetModel ?: [sourceModel copy];
    }
    
    // 没有属性可以复制
    if (sourceDescriptor->_numberOfProperties == 0) {
        return targetModel;
    }
    
    NSArray<XZJSONPropertyDescriptor *> *properties = nil;
    
    if (targetModel == nil) {
        // 创建新对象
        targetModel = [sourceClass new];
        properties = sourceDescriptor->_sortedProperties;
    } else if ([targetModel isKindOfClass:sourceClass]) {
        // 目标对象是同类或子类
        properties = sourceDescriptor->_sortedProperties;
    } else {
        // 模型复制，只复制同名属性
        Class const targetClass = object_getClass(targetModel);
        XZJSONClassDescriptor * const targetDescriptor = [XZJSONClassDescriptor descriptorForClass:targetClass];
        properties = [NSMutableArray arrayWithCapacity:sourceDescriptor->_sortedProperties.count];
        for (XZJSONPropertyDescriptor *sourceProperty in sourceDescriptor->_sortedProperties) {
            XZJSONPropertyDescriptor *targetProperty = targetDescriptor->_namedProperties[sourceProperty->_name];
            if (targetProperty->_raw.type == sourceProperty->_raw.type) {
                [(NSMutableArray *)properties addObject:sourceProperty];
            }
        }
    }
    
    [properties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor * const property, NSUInteger idx, BOOL * _Nonnull stop) {
        SEL const getter = property->_getter;
        SEL const setter = property->_setter;
        switch (property->_type) {
            case XZStdcTypeChar: {
                char const value = ((char (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, char))objc_msgSend)(targetModel, setter, value);
                return;
            }
            case XZStdcTypeUnsignedChar: {
                unsigned char const value = ((unsigned char (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, unsigned char))objc_msgSend)(targetModel, setter, value);
                return;
            }
            case XZStdcTypeInt: {
                int const value = ((int (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, int))objc_msgSend)(targetModel, setter, value);
                return;
            }
            case XZStdcTypeUnsignedInt: {
                unsigned int const value = ((unsigned int (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, unsigned int))objc_msgSend)(targetModel, setter, value);
                return;
            }
            case XZStdcTypeShort: {
                short const value = ((short (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, short))objc_msgSend)(targetModel, setter, value);
                return;
            }
            case XZStdcTypeUnsignedShort: {
                unsigned short const value = ((unsigned short (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, unsigned short))objc_msgSend)(targetModel, setter, value);
                return;
            }
            case XZStdcTypeLong: {
                long const value = ((long (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, long))objc_msgSend)(targetModel, setter, value);
                return;
            }
            case XZStdcTypeUnsignedLong: {
                unsigned long const value = ((unsigned long (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, unsigned long))objc_msgSend)(targetModel, setter, value);
                return;
            }
            case XZStdcTypeLongLong: {
                long long const value = ((long long (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, long long))objc_msgSend)(targetModel, setter, value);
                return;
            }
            case XZStdcTypeUnsignedLongLong: {
                unsigned long long const value = ((unsigned long long (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, unsigned long long))objc_msgSend)(targetModel, setter, value);
                return;
            }
            case XZStdcTypeFloat: {
                float const value = ((float (*)(id, SEL))xz_objc_msgSend_ftret)(self, getter);
                ((void (*)(id, SEL, float))objc_msgSend)(targetModel, setter, value);
                return;
            }
            case XZStdcTypeDouble: {
                double const value = ((double (*)(id, SEL))xz_objc_msgSend_dbret)(self, getter);
                ((void (*)(id, SEL, double))objc_msgSend)(targetModel, setter, value);
                return;
            }
            case XZStdcTypeLongDouble: {
                long double const value = ((long double (*)(id, SEL))xz_objc_msgSend_ldret)(self, getter);
                ((void (*)(id, SEL, long double))objc_msgSend)(targetModel, setter, value);
                return;
            }
            case XZStdcTypeBool: {
                BOOL const value = ((BOOL (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, BOOL))objc_msgSend)(targetModel, setter, value);
                return;
            }
            case XZStdcTypeClass: {
                Class const value = ((Class (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, Class))objc_msgSend)(targetModel, setter, value);
                return;
            }
            case XZStdcTypeSEL:  {
                SEL const value = ((SEL (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, SEL))objc_msgSend)(targetModel, setter, value);
                return;
            }
            case XZStdcTypeObject:  {
                id const value = ((id (*)(id, SEL))objc_msgSend)(self, getter);
                ((void (*)(id, SEL, id))objc_msgSend)(targetModel, setter, value);
                return;
            }
            case XZStdcTypeStruct: {
                switch (property->_foundationStruct) {
                    case XZJSONFoundationStructUnknown: {
                        break;
                    }
                    case XZJSONFoundationStructCGRect: {
                        CGRect const value = ((CGRect (*)(id, SEL))xz_objc_msgSend_stret)(self, getter);
                        ((void (*)(id, SEL, CGRect))objc_msgSend)(targetModel, setter, value);
                        return;
                    }
                    case XZJSONFoundationStructCGSize: {
                        CGSize const value = ((CGSize (*)(id, SEL))objc_msgSend)(self, getter);
                        ((void (*)(id, SEL, CGSize))objc_msgSend)(targetModel, setter, value);
                        return;
                    }
                    case XZJSONFoundationStructCGPoint: {
                        CGPoint const value = ((CGPoint (*)(id, SEL))objc_msgSend)(self, getter);
                        ((void (*)(id, SEL, CGPoint))objc_msgSend)(targetModel, setter, value);
                        return;
                    }
                    case XZJSONFoundationStructUIEdgeInsets: {
                        UIEdgeInsets const value = ((UIEdgeInsets (*)(id, SEL))xz_objc_msgSend_stret)(self, getter);
                        ((void (*)(id, SEL, UIEdgeInsets))objc_msgSend)(targetModel, setter, value);
                        return;
                    }
                    case XZJSONFoundationStructCGVector: {
                        CGVector const value = ((CGVector (*)(id, SEL))objc_msgSend)(self, getter);
                        ((void (*)(id, SEL, CGVector))objc_msgSend)(targetModel, setter, value);
                        return;
                    }
                    case XZJSONFoundationStructCGAffineTransform: {
                        CGAffineTransform const value = ((CGAffineTransform (*)(id, SEL))xz_objc_msgSend_stret)(self, getter);
                        ((void (*)(id, SEL, CGAffineTransform))objc_msgSend)(targetModel, setter, value);
                        return;
                    }
                    case XZJSONFoundationStructNSDirectionalEdgeInsets: {
                        NSDirectionalEdgeInsets const value = ((NSDirectionalEdgeInsets (*)(id, SEL))xz_objc_msgSend_stret)(self, getter);
                        ((void (*)(id, SEL, NSDirectionalEdgeInsets))objc_msgSend)(targetModel, setter, value);
                        return;
                    }
                    case XZJSONFoundationStructUIOffset: {
                        UIOffset const value = ((UIOffset (*)(id, SEL))objc_msgSend)(self, getter);
                        ((void (*)(id, SEL, UIOffset))objc_msgSend)(targetModel, setter, value);
                        return;
                    }
                }
                break;
            }
            case XZStdcTypeUnion:
            case XZStdcTypeBitField:
            case XZStdcTypeVoid:
            case XZStdcTypeString:
            case XZStdcTypeArray:
            case XZStdcTypePointer:
            case XZStdcTypeUnknown: {
                break;
            }
            case XZStdcTypeInt128:
            case XZStdcTypeUnsignedInt128:
            case XZStdcTypeVector:
                XZLog(@"[XZJSON] 目前平台不支持该数据类型");
                break;
        }
        // 无法复制的属性
        XZLog(@"[XZJSON] 无法复制 <%p: %@> 对象的属性 %@ 的值", sourceModel, sourceDescriptor->_raw.raw, property->_name);
    }];
    
    return targetModel;
}

@end


@implementation XZJSON (NSEquatable)

+ (BOOL)model:(id)model1 isEqual:(id)model2 {
    // 相等：同一对象
    if (model1 == model2) {
        return YES;
    }
    
    // 不相等：其中一个为 nil
    if (model1 == nil || model2 == nil) {
        return NO;
    }
    
    Class const model1Class = object_getClass(model1);
    Class const model2Class = object_getClass(model2);
    
    XZJSONClassDescriptor * const model1Descriptor = [XZJSONClassDescriptor descriptorForClass:model1Class];
    XZJSONClassDescriptor * const model2Descriptor = [XZJSONClassDescriptor descriptorForClass:model2Class];
    
    // 原生类型之间的比较
    if ((model1Descriptor->_foundationClass != XZJSONFoundationClassUnknown) && (model2Descriptor->_foundationClass != XZJSONFoundationClassUnknown)) {
        return [model1 isEqual:model2];
    }
    
    // 一个是模型，一个是原生类型
    if ((model1Descriptor->_foundationClass != XZJSONFoundationClassUnknown) || (model2Descriptor->_foundationClass != XZJSONFoundationClassUnknown)) {
        return NO;
    }
    
    // 不相等：属性数量不一样
    if (model1Descriptor->_numberOfProperties != model2Descriptor->_numberOfProperties) {
        return NO;
    }
    
    // 都是模型，逐个比较属性。
    for (XZJSONPropertyDescriptor * const property1 in model1Descriptor->_sortedProperties) {
        NSString * const name = property1->_name;
        
        XZJSONPropertyDescriptor * const property2 = model2Descriptor->_namedProperties[name];
        
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
            case XZStdcTypeUnknown:
                continue;
            case XZStdcTypeChar: {
                char const value1 = ((char(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                char const value2 = ((char(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZStdcTypeUnsignedChar: {
                unsigned char const value1 = ((unsigned char(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                unsigned char const value2 = ((unsigned char(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZStdcTypeInt: {
                int const value1 = ((int(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                int const value2 = ((int(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZStdcTypeUnsignedInt: {
                unsigned int const value1 = ((unsigned int(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                unsigned int const value2 = ((unsigned int(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZStdcTypeShort: {
                short const value1 = ((short(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                short const value2 = ((short(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZStdcTypeUnsignedShort: {
                unsigned short const value1 = ((unsigned short(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                unsigned short const value2 = ((unsigned short(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZStdcTypeLong: {
                long const value1 = ((long(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                long const value2 = ((long(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZStdcTypeUnsignedLong: {
                unsigned long const value1 = ((unsigned long(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                unsigned long const value2 = ((unsigned long(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZStdcTypeLongLong: {
                long long const value1 = ((long long(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                long long const value2 = ((long long(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZStdcTypeUnsignedLongLong: {
                unsigned long long const value1 = ((unsigned long long(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                unsigned long long const value2 = ((unsigned long long(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZStdcTypeFloat: {
                float const value1 = ((float(*)(id,SEL))xz_objc_msgSend_ftret)(model1, property1->_getter);
                float const value2 = ((float(*)(id,SEL))xz_objc_msgSend_ftret)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZStdcTypeDouble: {
                double const value1 = ((double(*)(id,SEL))xz_objc_msgSend_dbret)(model1, property1->_getter);
                double const value2 = ((double(*)(id,SEL))xz_objc_msgSend_dbret)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZStdcTypeLongDouble: {
                long double const value1 = ((long double(*)(id,SEL))xz_objc_msgSend_ldret)(model1, property1->_getter);
                long double const value2 = ((long double(*)(id,SEL))xz_objc_msgSend_ldret)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZStdcTypeBool: {
                BOOL const value1 = ((BOOL(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                BOOL const value2 = ((BOOL(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZStdcTypeVoid:
            case XZStdcTypeString:
            case XZStdcTypeArray:
            case XZStdcTypeBitField:
            case XZStdcTypePointer:
            case XZStdcTypeUnion: {
                continue;
            }
            case XZStdcTypeStruct:
                if (property1->_foundationStruct != property2->_foundationStruct) {
                    continue;
                }
                switch (property1->_foundationStruct) {
                    case XZJSONFoundationStructUnknown: {
                        break;
                    }
                    case XZJSONFoundationStructCGRect: {
                        CGRect const value1 = ((CGRect(*)(id,SEL))xz_objc_msgSend_stret)(model1, property1->_getter);
                        CGRect const value2 = ((CGRect(*)(id,SEL))xz_objc_msgSend_stret)(model1, property2->_getter);
                        if (!CGRectEqualToRect(value1, value2)) {
                            return NO;
                        }
                        continue;
                    }
                    case XZJSONFoundationStructCGSize: {
                        CGSize const value1 = ((CGSize(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                        CGSize const value2 = ((CGSize(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                        if (!CGSizeEqualToSize(value1, value2)) {
                            return NO;
                        }
                        continue;
                    }
                    case XZJSONFoundationStructCGPoint: {
                        CGPoint const value1 = ((CGPoint(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                        CGPoint const value2 = ((CGPoint(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                        if (!CGPointEqualToPoint(value1, value2)) {
                            return NO;
                        }
                        continue;
                    }
                    case XZJSONFoundationStructUIEdgeInsets: {
                        UIEdgeInsets const value1 = ((UIEdgeInsets(*)(id,SEL))xz_objc_msgSend_stret)(model1, property1->_getter);
                        UIEdgeInsets const value2 = ((UIEdgeInsets(*)(id,SEL))xz_objc_msgSend_stret)(model1, property2->_getter);
                        if (!UIEdgeInsetsEqualToEdgeInsets(value1, value2)) {
                            return NO;
                        }
                        continue;
                    }
                    case XZJSONFoundationStructCGVector: {
                        CGVector const value1 = ((CGVector(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                        CGVector const value2 = ((CGVector(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                        if (value1.dx != value2.dx || value1.dy != value2.dy) {
                            return NO;
                        }
                        continue;
                    }
                    case XZJSONFoundationStructCGAffineTransform: {
                        CGAffineTransform const value1 = ((CGAffineTransform(*)(id,SEL))xz_objc_msgSend_stret)(model1, property1->_getter);
                        CGAffineTransform const value2 = ((CGAffineTransform(*)(id,SEL))xz_objc_msgSend_stret)(model1, property2->_getter);
                        if (!CGAffineTransformEqualToTransform(value1, value2)) {
                            return NO;
                        }
                        continue;
                    }
                    case XZJSONFoundationStructNSDirectionalEdgeInsets: {
                        NSDirectionalEdgeInsets const value1 = ((NSDirectionalEdgeInsets(*)(id,SEL))xz_objc_msgSend_stret)(model1, property1->_getter);
                        NSDirectionalEdgeInsets const value2 = ((NSDirectionalEdgeInsets(*)(id,SEL))xz_objc_msgSend_stret)(model1, property2->_getter);
                        if (!NSDirectionalEdgeInsetsEqualToDirectionalEdgeInsets(value1, value2)) {
                            return NO;
                        }
                        continue;
                    }
                    case XZJSONFoundationStructUIOffset: {
                        UIOffset const value1 = ((UIOffset(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                        UIOffset const value2 = ((UIOffset(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                        if (!UIOffsetEqualToOffset(value1, value2)) {
                            return NO;
                        }
                        continue;
                    }
                }
                break;
            case XZStdcTypeClass: {
                Class const value1 = ((Class(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                Class const value2 = ((Class(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZStdcTypeSEL: {
                SEL const value1 = ((SEL(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                SEL const value2 = ((SEL(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if (value1 != value2) {
                    return NO;
                }
                continue;
            }
            case XZStdcTypeObject: {
                id const value1 = ((id(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                id const value2 = ((id(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                if ([value1 isEqual:value2]) {
                    continue;
                }
                return NO;
            }
            case XZStdcTypeInt128:
            case XZStdcTypeUnsignedInt128:
            case XZStdcTypeVector:
                XZLog(@"[XZJSON] 目前平台不支持该数据类型");
                continue;
        }
    }
    
    return YES;
}

@end


