//
//  XZJSON.m
//  XZJSON
//
//  Created by Xezun on 2024/9/28.
//

#import "XZJSON.h"
#import "XZJSONPrivate.h"
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

+ (id)decode:(id)json options:(NSJSONReadingOptions)options class:(Class)ModelClass {
    // 判空
    if (json == nil || json == (id)kCFNull) {
        return nil;
    }
    // 二进制流形式的 json 数据
    if ([json isKindOfClass:NSData.class]) {
        return XZJSONDecodeData((NSData *)json, options, ModelClass);
    }
    // 字符串形式的 json 数据
    if ([json isKindOfClass:NSString.class]) {
        NSData * const data = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
        if (data == nil) {
            return nil;
        }
        return XZJSONDecodeData(data, options, ModelClass);
    }
    // 如果为数组，视为解析多个 json 数据
    if ([json isKindOfClass:NSArray.class]) {
        if (((NSArray *)json).count == 0) {
            return json;
        }
        NSMutableArray * const models = [NSMutableArray arrayWithCapacity:((NSArray *)json).count];
        for (id item in ((NSArray *)json)) {
            id const model = [self decode:item options:options class:ModelClass];
            if (model) {
                [models addObject:model];
            } else if (options & XZJSONReadingKeepCapacity) {
                [models addObject:(id)kCFNull];
            }
        }
        return models;
    }
    // 其它情况视为已解析好的 json
    return XZJSONDecodeObject(json, ModelClass);
}

+ (void)model:(id)model decodeFromDictionary:(NSDictionary *)dictionary {
    XZJSONClass * const JSONClass = [XZJSONClass classForClass:object_getClass(model)];
    if (JSONClass) {
        XZJSONModelDecodeFromDictionary(model, JSONClass, dictionary);
    }
}

@end


@implementation XZJSON (XZJSONEncoder)

+ (NSData *)encode:(id)model options:(NSJSONWritingOptions)options error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    if (model == nil) {
        return nil;
    }
    XZJSONClass * const JSONClass = [XZJSONClass classForClass:object_getClass(model)];
    if (JSONClass == nil) {
        return nil;
    }
    id const dictionary = XZJSONObjectEncodeIntoDictionary(model, JSONClass, JSONClass->_cocoaClass, nil);
    if (dictionary == nil) {
        return nil;
    }
    return [NSJSONSerialization dataWithJSONObject:dictionary options:options error:error];
}

+ (void)model:(id)model encodeIntoDictionary:(NSMutableDictionary *)dictionary {
    XZJSONClass * const descriptor = [XZJSONClass classForClass:object_getClass(model)];
    if (descriptor) {
        XZJSONModelEncodeIntoDictionary(model, descriptor, dictionary);
    }
}

@end

static NSString * const XZJSON_NSCoding_KEY = @"XZJSON_NSCoding_KEY";

@implementation XZJSON (NSCoding)

+ (void)model:(id)model initWithCoder:(NSCoder *)coder {
    XZJSONClass * const JSONClass = [XZJSONClass classForClass:object_getClass(model)];
    if (JSONClass == nil) {
        return;
    }
    
    NSAssert(JSONClass->_cocoaClass == XZJSONCocoaClassUnknown, @"此方法仅支持在自定义模型的 -initWithCoder: 方法中使用");
    
    NSDictionary * dictionary = [coder decodeObjectForKey:XZJSON_NSCoding_KEY];
    if ([dictionary isKindOfClass:NSDictionary.class]) {
        [XZJSON model:model decodeFromDictionary:dictionary];
    }
}

+ (void)model:(id)model encodeWithCoder:(NSCoder *)coder {
    XZJSONClass * const JSONClass = [XZJSONClass classForClass:object_getClass(model)];
    if (JSONClass == nil) {
        return;
    }
    
    NSAssert(JSONClass->_cocoaClass == XZJSONCocoaClassUnknown, @"此方法仅支持在自定义模型的 -encodeWithCoder: 方法中使用");
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:JSONClass->_numberOfProperties];
    [XZJSON model:model encodeIntoDictionary:dictionary];
    [coder encodeObject:dictionary forKey:XZJSON_NSCoding_KEY];
}

@end

@implementation XZJSON (NSCopying)

+ (id)model:(id)sourceModel copy:(id)targetModel {
    return XZJSONObjectCopying(sourceModel, targetModel);
}

@end

@implementation XZJSON (NSDescribing)

+ (NSString *)model:(id)model describeWithIndent:(NSUInteger)indent {
    return XZJSONObjectDescription(model, indent);
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
    
    XZJSONClass * const model1Descriptor = [XZJSONClass classForClass:model1Class];
    XZJSONClass * const model2Descriptor = [XZJSONClass classForClass:model2Class];
    
    // 原生类型之间的比较
    if ((model1Descriptor->_cocoaClass != XZJSONCocoaClassUnknown) && (model2Descriptor->_cocoaClass != XZJSONCocoaClassUnknown)) {
        return [model1 isEqual:model2];
    }
    
    // 一个是模型，一个是原生类型
    if ((model1Descriptor->_cocoaClass != XZJSONCocoaClassUnknown) || (model2Descriptor->_cocoaClass != XZJSONCocoaClassUnknown)) {
        return NO;
    }
    
    // 不相等：属性数量不一样
    if (model1Descriptor->_numberOfProperties != model2Descriptor->_numberOfProperties) {
        return NO;
    }
    
    // 都是模型，逐个比较属性。
    for (XZJSONProperty * const property1 in model1Descriptor->_sortedProperties) {
        NSString * const name = property1->_name;
        
        XZJSONProperty * const property2 = model2Descriptor->_namedProperties[name];
        
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
                if (property1->_structType != property2->_structType) {
                    continue;
                }
                switch (property1->_structType) {
                    case XZStdcStructTypeUnknown: {
                        break;
                    }
                    case XZStdcStructTypeCGRect: {
                        CGRect const value1 = ((CGRect(*)(id,SEL))xz_objc_msgSend_stret)(model1, property1->_getter);
                        CGRect const value2 = ((CGRect(*)(id,SEL))xz_objc_msgSend_stret)(model1, property2->_getter);
                        if (!CGRectEqualToRect(value1, value2)) {
                            return NO;
                        }
                        continue;
                    }
                    case XZStdcStructTypeCGSize: {
                        CGSize const value1 = ((CGSize(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                        CGSize const value2 = ((CGSize(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                        if (!CGSizeEqualToSize(value1, value2)) {
                            return NO;
                        }
                        continue;
                    }
                    case XZStdcStructTypeCGPoint: {
                        CGPoint const value1 = ((CGPoint(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                        CGPoint const value2 = ((CGPoint(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                        if (!CGPointEqualToPoint(value1, value2)) {
                            return NO;
                        }
                        continue;
                    }
                    case XZStdcStructTypeCGVector: {
                        CGVector const value1 = ((CGVector(*)(id,SEL))objc_msgSend)(model1, property1->_getter);
                        CGVector const value2 = ((CGVector(*)(id,SEL))objc_msgSend)(model1, property2->_getter);
                        if (value1.dx != value2.dx || value1.dy != value2.dy) {
                            return NO;
                        }
                        continue;
                    }
                    case XZStdcStructTypeCGAffineTransform: {
                        CGAffineTransform const value1 = ((CGAffineTransform(*)(id,SEL))xz_objc_msgSend_stret)(model1, property1->_getter);
                        CGAffineTransform const value2 = ((CGAffineTransform(*)(id,SEL))xz_objc_msgSend_stret)(model1, property2->_getter);
                        if (!CGAffineTransformEqualToTransform(value1, value2)) {
                            return NO;
                        }
                        continue;
                    }
                    case XZStdcStructTypeNSDirectionalEdgeInsets: {
                        NSDirectionalEdgeInsets const value1 = ((NSDirectionalEdgeInsets(*)(id,SEL))xz_objc_msgSend_stret)(model1, property1->_getter);
                        NSDirectionalEdgeInsets const value2 = ((NSDirectionalEdgeInsets(*)(id,SEL))xz_objc_msgSend_stret)(model1, property2->_getter);
                        if (!NSDirectionalEdgeInsetsEqualToDirectionalEdgeInsets(value1, value2)) {
                            return NO;
                        }
                        continue;
                    }
                    case XZStdcStructTypeNSRange: {
                        NSRange const value1 = ((NSRange(*)(id,SEL))xz_objc_msgSend_stret)(model1, property1->_getter);
                        NSRange const value2 = ((NSRange(*)(id,SEL))xz_objc_msgSend_stret)(model1, property2->_getter);
                        if (!NSEqualRanges(value1, value2)) {
                            return NO;
                        }
                        continue;
                    }
                    case XZStdcStructTypeUIEdgeInsets: {
                        UIEdgeInsets const value1 = ((UIEdgeInsets(*)(id,SEL))xz_objc_msgSend_stret)(model1, property1->_getter);
                        UIEdgeInsets const value2 = ((UIEdgeInsets(*)(id,SEL))xz_objc_msgSend_stret)(model1, property2->_getter);
                        if (!UIEdgeInsetsEqualToEdgeInsets(value1, value2)) {
                            return NO;
                        }
                        continue;
                    }
                    case XZStdcStructTypeUIOffset: {
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
            case XZStdcTypeSelector: {
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


