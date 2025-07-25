//
//  XZJSONPrivate.m
//  XZJSON
//
//  Created by Xezun on 2024/12/3.
//

@import ObjectiveC;

#import "XZJSONPrivate.h"
#import "XZJSON.h"
#import "XZMacros.h"
#import "NSCharacterSet+XZKit.h"
#import "NSData+XZKit.h"
#import "XZLog.h"

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

NSString * _Nonnull XZJSONModelDescriptionForFoundationClassOfType(id model, XZJSONFoundationClassType const classType, NSUInteger indent) {
    switch (classType) {
        case XZJSONFoundationClassTypeNSString:
        case XZJSONFoundationClassTypeNSMutableString: {
            NSString *aString = model;
            aString = [aString stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
            return [NSString stringWithFormat:@"\"%@\"", aString];
        }
        case XZJSONFoundationClassTypeNSValue: {
            return ((NSValue *)model).description;
            break;
        }
        case XZJSONFoundationClassTypeNSNumber: {
            return [(NSNumber *)model stringValue];
        }
        case XZJSONFoundationClassTypeNSData:
        case XZJSONFoundationClassTypeNSMutableData: {
            return [(NSData *)model description];
        }
        case XZJSONFoundationClassTypeNSDecimalNumber: {
            return [(NSDecimalNumber *)model stringValue];
        }
        case XZJSONFoundationClassTypeNSDate: {
            return [XZJSON.dateFormatter stringFromDate:model];
        }
        case XZJSONFoundationClassTypeNSURL: {
            return ((NSURL *)model).absoluteString;
        }
        case XZJSONFoundationClassTypeNSSet:
        case XZJSONFoundationClassTypeNSMutableSet:
        case XZJSONFoundationClassTypeNSCountedSet: {
            return XZJSONModelDescriptionForNSCollection(((NSSet *)model).allObjects, ((NSSet *)model).count, indent);
        }
        case XZJSONFoundationClassTypeNSOrderedSet:
        case XZJSONFoundationClassTypeNSMutableOrderedSet: {
            return XZJSONModelDescriptionForNSCollection((NSOrderedSet *)model, ((NSOrderedSet *)model).count, indent);
        }
        case XZJSONFoundationClassTypeNSArray:
        case XZJSONFoundationClassTypeNSMutableArray: {
            return XZJSONModelDescriptionForNSCollection((NSArray *)model, ((NSArray *)model).count, indent);
        }
        case XZJSONFoundationClassTypeNSDictionary:
        case XZJSONFoundationClassTypeNSMutableDictionary: {
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
        case XZJSONFoundationClassTypeUnknown: {
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

    XZJSONClassDescriptor * const modelClass = [XZJSONClassDescriptor descriptorWithClass:model.class];

    if (modelClass->_foundationClassType) {
        return XZJSONModelDescriptionForFoundationClassOfType(model, modelClass->_foundationClassType, indent);
    }
    
    if (modelClass->_sortedProperties.count == 0) {
        return [NSString stringWithFormat:@"<%@: %p>", model.class, model];
    }
    NSString * const padding = [@"" stringByPaddingToLength:indent * 4 withString:@" " startingAtIndex:0];
    indent += 1;
    
    NSMutableString *desc = [NSMutableString stringWithFormat:@"<%@: %p, properties: {\n", model.class, model];
    [modelClass->_sortedProperties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor * _Nonnull property, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = property->_name;
        NSString *value = nil;
        switch (property->_type) {
            case XZObjcTypeBool: {
                BOOL const aValue = ((BOOL (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = aValue ? @"true" : @"false";
                break;
            }
            case XZObjcTypeChar: {
                char const aValue = ((char (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%c", aValue];
                break;
            }
            case XZObjcTypeUnsignedChar: {
                unsigned char const aValue = ((unsigned char (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%c", aValue];
                break;
            }
            case XZObjcTypeShort: {
                short const aValue = ((short (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%d", aValue];
                break;
            }
            case XZObjcTypeUnsignedShort: {
                unsigned short const aValue = ((unsigned short (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%u", aValue];
                break;
            }
            case XZObjcTypeInt: {
                int const aValue = ((int (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%d", aValue];
                break;
            }
            case XZObjcTypeUnsignedInt: {
                unsigned int const aValue = ((unsigned int (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%u", aValue];
                break;
            }
            case XZObjcTypeLong: {
                long const aValue = ((long (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%ld", aValue];
                break;
            }
            case XZObjcTypeUnsignedLong: {
                unsigned long const aValue = ((unsigned long (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%lu", aValue];
                break;
            }
            case XZObjcTypeFloat: {
                float const aValue = ((float (*)(id, SEL))(void *)xz_objc_msgSend_ftret)(model, property->_getter);
                value = [NSString stringWithFormat:@"%f", aValue];
                break;
            }
            case XZObjcTypeDouble: {
                double const aValue = ((double (*)(id, SEL))(void *)xz_objc_msgSend_dbret)(model, property->_getter);
                value = [NSString stringWithFormat:@"%lf", aValue];
                break;
            }
            case XZObjcTypeLongDouble: {
                long double const aValue = ((long double (*)(id, SEL))(void *)xz_objc_msgSend_ldret)(model, property->_getter);
                value = [NSString stringWithFormat:@"%Lf", aValue];
                break;
            }
            case XZObjcTypeLongLong: {
                long long const aValue = ((long long (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%lld", aValue];
                break;
            }
            case XZObjcTypeUnsignedLongLong: {
                unsigned long long const aValue = ((unsigned long long (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%lld", aValue];
                break;
            }
            case XZObjcTypeObject: {
                value = ((id (*)(id _Nonnull, SEL _Nonnull))objc_msgSend)((id)model, property->_getter);
                if (property->_isUnownedReferenceProperty) {
                    value = [NSString stringWithFormat:@"<%@: %p>", value.class, value];
                } else if (property->_foundationClassType) {
                    value = XZJSONModelDescriptionForFoundationClassOfType(value, property->_foundationClassType, indent);
                } else {
                    value = [XZJSON model:value description:indent];
                }
                break;
            }
            case XZObjcTypeClass: {
                value = ((id (*)(id _Nonnull, SEL _Nonnull))objc_msgSend)((id)model, property->_getter);
                value = [NSString stringWithFormat:@"<class: %@>", value ?: @"Nil"];
                break;
            }
            case XZObjcTypeSEL: {
                SEL sel = ((SEL (*)(id, SEL))(void *)objc_msgSend)((id)model, property->_getter);
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
                    void *pointer = ((void *(*)(id, SEL))(void *)objc_msgSend)((id)model, property->_getter);
                    desc = [NSString stringWithFormat:@"%p", pointer];
                }
                switch (property->_type) {
                    case XZObjcTypeArray: {
                        value = [NSString stringWithFormat:@"<array: %@, value: %@>", property->_raw.type.name, desc];
                        break;
                    }
                    case XZObjcTypeString: {
                        value = [NSString stringWithFormat:@"<string: %@, value: %@>", property->_raw.type.name, desc];
                        break;
                    }
                    case XZObjcTypePointer: {
                        value = [NSString stringWithFormat:@"<pointer: %@, value: %@>", property->_raw.type.name, desc];
                        break;
                    }
                    case XZObjcTypeUnknown: {
                        value = [NSString stringWithFormat:@"<unknown: %@, value: %@>", property->_raw.type.name, desc];
                        break;
                    }
                    default:
                        break;
                }
                break;
            }
            case XZObjcTypeStruct: {
                value = XZJSONEncodeStructProperty(model, property);
                if (value == nil) {
                    if (modelClass->_usesPropertyJSONEncodingMethod) {
                        value = [NSString stringWithFormat:@"%@", [(id<XZJSONCoding>)model JSONEncodeValueForKey:key]];
                    }
                }
                if (value) {
                    value = [NSString stringWithFormat:@"<struct: %@, value: %@>", property->_raw.type.name, value];
                } else {
                    value = [NSString stringWithFormat:@"<struct: %@>", property->_raw.type.name];
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
                    value = [NSString stringWithFormat:@"<union: %@>", property->_raw.type.name];
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
                    value = [NSString stringWithFormat:@"<BitField: %ld bit>", (long)property->_raw.type.sizeInBit];
                }
                break;
            }
            case XZObjcTypeInt128:
            case XZObjcTypeUnsignedInt128:
            case XZObjcTypeVector:
                XZLog(@"[XZJSON] 目前平台不支持该数据类型");
                break;
        }
        [desc appendFormat:@"%@    %@: %@,\n", padding, key, value];
    }];
    [desc deleteCharactersInRange:NSMakeRange(desc.length - 2, 1)];
    [desc appendFormat:@"%@}>", padding];
    return desc;
}

#pragma mark - NSCoding

FOUNDATION_STATIC_INLINE BOOL NSCollectionConformsNSCoding(id<NSFastEnumeration> sequence) {
    for (id object in sequence) {
        if (![object conformsToProtocol:@protocol(NSCoding)]) {
            return NO;
        }
    }
    return YES;
}

FOUNDATION_STATIC_INLINE BOOL NSCollectionTestElementClass(id<NSFastEnumeration> sequence, Class Element) {
    for (id object in sequence) {
        if (![object isKindOfClass:Element]) {
            return NO;
        }
    }
    return YES;
}

FOUNDATION_STATIC_INLINE BOOL NSDictionaryConformsNSCoding(NSDictionary *dictionary) {
    BOOL __block conforms = YES;
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![key conformsToProtocol:@protocol(NSCoding)] || ![obj conformsToProtocol:@protocol(NSCoding)]) {
            conforms = NO;
            *stop = YES;
        }
    }];
    return conforms;
}

FOUNDATION_STATIC_INLINE BOOL NSDictionaryTestElementClass(NSDictionary *dictionary, Class Element) {
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
    
    XZJSONClassDescriptor * const modelClass = [XZJSONClassDescriptor descriptorWithClass:[model class]];
    
    switch (modelClass->_foundationClassType) {
        case XZJSONFoundationClassTypeNSString:
        case XZJSONFoundationClassTypeNSMutableString:
        case XZJSONFoundationClassTypeNSValue:
        case XZJSONFoundationClassTypeNSNumber:
        case XZJSONFoundationClassTypeNSDecimalNumber:
        case XZJSONFoundationClassTypeNSData:
        case XZJSONFoundationClassTypeNSMutableData:
        case XZJSONFoundationClassTypeNSDate:
        case XZJSONFoundationClassTypeNSURL: {
            [(id<NSCoding>)model encodeWithCoder:aCoder];
            break;
        }
        case XZJSONFoundationClassTypeNSArray:
        case XZJSONFoundationClassTypeNSMutableArray:
        case XZJSONFoundationClassTypeNSSet:
        case XZJSONFoundationClassTypeNSMutableSet:
        case XZJSONFoundationClassTypeNSCountedSet:
        case XZJSONFoundationClassTypeNSOrderedSet:
        case XZJSONFoundationClassTypeNSMutableOrderedSet: {
            if (NSCollectionConformsNSCoding(model)) {
                [(id<NSCoding>)model encodeWithCoder:aCoder];
            }
            break;
        }
        case XZJSONFoundationClassTypeNSDictionary:
        case XZJSONFoundationClassTypeNSMutableDictionary: {
            if (NSDictionaryConformsNSCoding(model)) {
                [(id<NSCoding>)model encodeWithCoder:aCoder];
            }
            break;
        }
        case XZJSONFoundationClassTypeUnknown: {
            [modelClass->_sortedProperties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor *property, NSUInteger idx, BOOL *stop) {
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
                        float const aValue = ((float (*)(id, SEL))xz_objc_msgSend_ftret)(model, getter);
                        [aCoder encodeFloat:aValue forKey:name];
                        break;
                    }
                    case XZObjcTypeDouble: {
                        double const aValue = ((double (*)(id, SEL))xz_objc_msgSend_dbret)(model, getter);
                        [aCoder encodeDouble:aValue forKey:name];
                        return;
                    }
                    case XZObjcTypeLongDouble: {
                        long double const aValue = ((long double (*)(id, SEL))xz_objc_msgSend_ldret)(model, getter);
                        [aCoder encodeBytes:(const uint8_t *)&aValue length:sizeof(long double) forKey:name];
                        return;
                    }
                    case XZObjcTypeBool: {
                        BOOL const aValue = ((BOOL (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeBool:aValue forKey:name];
                        return;
                    }
                    case XZObjcTypeStruct: {
                        NSString * const aValue = XZJSONEncodeStructProperty(model, property);
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
                            switch (property->_foundationClassType) {
                                case XZJSONFoundationClassTypeNSArray:
                                case XZJSONFoundationClassTypeNSMutableArray:
                                case XZJSONFoundationClassTypeNSSet:
                                case XZJSONFoundationClassTypeNSMutableSet:
                                case XZJSONFoundationClassTypeNSCountedSet:
                                case XZJSONFoundationClassTypeNSOrderedSet:
                                case XZJSONFoundationClassTypeNSMutableOrderedSet: {
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
                                case XZJSONFoundationClassTypeNSDictionary:
                                case XZJSONFoundationClassTypeNSMutableDictionary: {
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
                                case XZJSONFoundationClassTypeNSString:
                                case XZJSONFoundationClassTypeNSMutableString:
                                case XZJSONFoundationClassTypeNSValue:
                                case XZJSONFoundationClassTypeNSNumber:
                                case XZJSONFoundationClassTypeNSDecimalNumber:
                                case XZJSONFoundationClassTypeNSData:
                                case XZJSONFoundationClassTypeNSMutableData:
                                case XZJSONFoundationClassTypeNSDate:
                                case XZJSONFoundationClassTypeNSURL:
                                case XZJSONFoundationClassTypeUnknown: {
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
                        switch (property->_foundationClassType) {
                            case XZJSONFoundationClassTypeNSArray:
                            case XZJSONFoundationClassTypeNSMutableArray:
                            case XZJSONFoundationClassTypeNSSet:
                            case XZJSONFoundationClassTypeNSMutableSet:
                            case XZJSONFoundationClassTypeNSCountedSet:
                            case XZJSONFoundationClassTypeNSOrderedSet:
                            case XZJSONFoundationClassTypeNSMutableOrderedSet: {
                                // 检查元素是否合法：元素只要支持归档即可。
                                if (NSCollectionConformsNSCoding(aValue)) {
                                    [aCoder encodeObject:aValue forKey:name];
                                    return;
                                }
                                break;
                            }
                            case XZJSONFoundationClassTypeNSDictionary:
                            case XZJSONFoundationClassTypeNSMutableDictionary: {
                                // 检查元素是否合法：元素只需要支持归档即可
                                if (NSDictionaryConformsNSCoding(aValue)) {
                                    [aCoder encodeObject:aValue forKey:name];
                                    return;
                                }
                                break;
                            }
                            case XZJSONFoundationClassTypeNSString:
                            case XZJSONFoundationClassTypeNSMutableString:
                            case XZJSONFoundationClassTypeNSValue:
                            case XZJSONFoundationClassTypeNSNumber:
                            case XZJSONFoundationClassTypeNSDecimalNumber:
                            case XZJSONFoundationClassTypeNSData:
                            case XZJSONFoundationClassTypeNSMutableData:
                            case XZJSONFoundationClassTypeNSDate:
                            case XZJSONFoundationClassTypeNSURL:
                            case XZJSONFoundationClassTypeUnknown: {
                                [aCoder encodeObject:aValue forKey:name];
                                return;
                            }
                        }
                        break;
                    }
                    case XZObjcTypeInt128:
                    case XZObjcTypeUnsignedInt128:
                    case XZObjcTypeVector:
                        XZLog(@"[XZJSON] 目前平台不支持该数据类型");
                        break;
                }
                
                // 不能处理的属性
                if (property->_class->_usesPropertyJSONEncodingMethod) {
                    id<NSCoding> aValue = [((id<XZJSONCoding>)model) JSONEncodeValueForKey:name];
                    if (aValue) {
                        [aCoder encodeObject:aValue forKey:name];
                        return;
                    }
                }
                
                XZLog(@"[XZJSON] [NSCoding] Can not encode property `%@` of `%@`!", modelClass->_raw.name, property->_name);
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
    
    XZJSONClassDescriptor * const modelClass = [XZJSONClassDescriptor descriptorWithClass:[model class]];
    switch (modelClass->_foundationClassType) {
        case XZJSONFoundationClassTypeNSString:
        case XZJSONFoundationClassTypeNSMutableString:
        case XZJSONFoundationClassTypeNSValue:
        case XZJSONFoundationClassTypeNSNumber:
        case XZJSONFoundationClassTypeNSDecimalNumber:
        case XZJSONFoundationClassTypeNSData:
        case XZJSONFoundationClassTypeNSMutableData:
        case XZJSONFoundationClassTypeNSDate:
        case XZJSONFoundationClassTypeNSURL: {
            return [(id<NSCoding>)model initWithCoder:aCoder];
        }
        case XZJSONFoundationClassTypeNSArray:
        case XZJSONFoundationClassTypeNSMutableArray:
        case XZJSONFoundationClassTypeNSSet:
        case XZJSONFoundationClassTypeNSMutableSet:
        case XZJSONFoundationClassTypeNSCountedSet:
        case XZJSONFoundationClassTypeNSOrderedSet:
        case XZJSONFoundationClassTypeNSMutableOrderedSet: {
            if (NSCollectionConformsNSCoding(model)) {
                return [(id<NSCoding>)model initWithCoder:aCoder];
            }
            return nil;
        }
        case XZJSONFoundationClassTypeNSDictionary:
        case XZJSONFoundationClassTypeNSMutableDictionary: {
            if (NSDictionaryConformsNSCoding(model)) {
                return [(id<NSCoding>)model initWithCoder:aCoder];
            }
            return nil;
        }
        case XZJSONFoundationClassTypeUnknown: {
            [modelClass->_sortedProperties enumerateObjectsUsingBlock:^(XZJSONPropertyDescriptor *property, NSUInteger idx, BOOL *stop) {
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
                        if (XZJSONDecodeStructProperty(model, property, aValue)) {
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
                            switch (property->_foundationClassType) {
                                case XZJSONFoundationClassTypeNSArray:
                                case XZJSONFoundationClassTypeNSMutableArray:
                                case XZJSONFoundationClassTypeNSSet:
                                case XZJSONFoundationClassTypeNSMutableSet: {
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
                                case XZJSONFoundationClassTypeNSDictionary:
                                case XZJSONFoundationClassTypeNSMutableDictionary: {
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
                    case XZObjcTypeInt128:
                    case XZObjcTypeUnsignedInt128:
                    case XZObjcTypeVector:
                        XZLog(@"[XZJSON] 目前平台不支持该数据类型");
                        break;
                }
                
                if ([aCoder containsValueForKey:name] && modelClass->_usesPropertyJSONDecodingMethod) {
                    if ([((id<XZJSONCoding>)model) JSONDecodeValue:aCoder forKey:name]) {
                        return;
                    }
                }
                
                XZLog(@"[XZJSON] [NSCoding] Can not decode property `%@` of `%@`!", modelClass->_raw.name, property->_name);
            }];
            break;
        }
    }
    
    return model;
}
