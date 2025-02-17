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

@interface XZJSONCodableModel : NSObject <NSCoding, NSSecureCoding>
@property (nonatomic, readonly) id model;
+ (instancetype)modelWithModel:(id)model;
@end

@implementation XZJSONCodableModel

+ (instancetype)modelWithModel:(id)model {
    return [[self alloc] initWithModel:model];
}

- (instancetype)initWithModel:(id)model {
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    NSError *error = nil;
    
    Class    const _class = [_model class];
    NSData * const _data  = [XZJSON encode:_model options:kNilOptions error:&error];
    
    [coder encodeObject:NSStringFromClass(_class) forKey:@"_class"];
    if (_data == nil || error.code != noErr) {
        return;
    }
    [coder encodeObject:_data forKey:@"_data"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    Class    const _class = NSClassFromString([coder decodeObjectForKey:@"_class"]);
    NSData * const _data  = [coder decodeObjectForKey:@"_data"];
    return [XZJSON decode:_data options:kNilOptions class:_class];
}

+ (BOOL)supportsSecureCoding {
    return NO;
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
            [((id<NSCoding>)model) encodeWithCoder:aCoder];
            break;
        case XZJSONClassTypeNSArray: {
            NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:((NSArray *)model).count];
            for (id object in (NSArray *)model) {
                if ([object conformsToProtocol:@protocol(NSCoding)]) {
                    [arrayM addObject:object];
                } else {
                    id value = [XZJSONCodableModel modelWithModel:object];
                    [arrayM addObject:value];
                }
            }
            [arrayM.copy encodeWithCoder:aCoder];
            break;
        }
        case XZJSONClassTypeNSMutableArray: {
            NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:((NSMutableArray *)model).count];
            for (id object in (NSArray *)model) {
                if ([object conformsToProtocol:@protocol(NSCoding)]) {
                    [arrayM addObject:object];
                } else {
                    id value = [XZJSONCodableModel modelWithModel:object];
                    [arrayM addObject:value];
                }
            }
            [arrayM encodeWithCoder:aCoder];
            break;
        }
        case XZJSONClassTypeNSDictionary: {
            NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithCapacity:((NSDictionary *)model).count];
            [((NSDictionary *)model) enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull object, BOOL * _Nonnull stop) {
                if ([object conformsToProtocol:@protocol(NSCoding)]) {
                    dictM[key] = object;
                } else {
                    dictM[key] = [XZJSONCodableModel modelWithModel:object];
                }
            }];
            [dictM.copy encodeWithCoder:aCoder];
            break;
        }
        case XZJSONClassTypeNSMutableDictionary: {
            NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithCapacity:((NSDictionary *)model).count];
            [((NSDictionary *)model) enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull object, BOOL * _Nonnull stop) {
                if ([object conformsToProtocol:@protocol(NSCoding)]) {
                    dictM[key] = object;
                } else {
                    dictM[key] = [XZJSONCodableModel modelWithModel:object];
                }
            }];
            [dictM encodeWithCoder:aCoder];
            break;
        }
        case XZJSONClassTypeNSSet: {
            NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:((NSSet *)model).count];
            for (id object in (NSSet *)model) {
                if ([object conformsToProtocol:@protocol(NSCoding)]) {
                    [arrayM addObject:object];
                } else {
                    id value = [XZJSONCodableModel modelWithModel:object];
                    [arrayM addObject:value];
                }
            }
            [[NSSet setWithArray:arrayM] encodeWithCoder:aCoder];
            break;
        }
        case XZJSONClassTypeNSMutableSet: {
            NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:((NSSet *)model).count];
            for (id object in (NSSet *)model) {
                if ([object conformsToProtocol:@protocol(NSCoding)]) {
                    [arrayM addObject:object];
                } else {
                    id value = [XZJSONCodableModel modelWithModel:object];
                    [arrayM addObject:value];
                }
            }
            [[NSMutableSet setWithArray:arrayM] encodeWithCoder:aCoder];
            break;
        }
        case XZJSONClassTypeUnknown: {
            for (XZJSONPropertyDescriptor *property in modelClass->_properties) {
                SEL        const getter = property->_getter;
                NSString * const name   = property->_name;
                switch (property->_type) {
                    case XZObjcTypeUnknown:
                        break;
                    case XZObjcTypeChar: {
                        char const aValue = ((char (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeInt:aValue forKey:name];
                        continue;
                    }
                    case XZObjcTypeUnsignedChar: {
                        unsigned char const aValue = ((unsigned char (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeInt:aValue forKey:name];
                        continue;
                    }
                    case XZObjcTypeInt: {
                        int const aValue = ((int (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeInt:aValue forKey:name];
                        continue;
                    }
                    case XZObjcTypeUnsignedInt: {
                        unsigned int const aValue = ((unsigned int (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeInt:aValue forKey:name];
                        continue;
                    }
                    case XZObjcTypeShort: {
                        short const aValue = ((short (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeInt:aValue forKey:name];
                        continue;
                    }
                    case XZObjcTypeUnsignedShort: {
                        unsigned short const aValue = ((unsigned short (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeInt:aValue forKey:name];
                        continue;
                    }
                    case XZObjcTypeLong: {
                        long const aValue = ((long (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeInt64:aValue forKey:name];
                        continue;
                    }
                    case XZObjcTypeUnsignedLong: {
                        unsigned long const aValue = ((unsigned long (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeInt64:aValue forKey:name];
                        continue;
                    }
                    case XZObjcTypeLongLong: {
                        long long const aValue = ((long long (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeInt64:aValue forKey:name];
                        continue;
                    }
                    case XZObjcTypeUnsignedLongLong: {
                        unsigned long long const aValue = ((unsigned long long (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeInt64:aValue forKey:name];
                        continue;
                    }
                    case XZObjcTypeFloat: {
                        float const aValue = ((float (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeFloat:aValue forKey:name];
                        continue;
                    }
                    case XZObjcTypeDouble: {
                        double const aValue = ((double (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeDouble:aValue forKey:name];
                        continue;
                    }
                    case XZObjcTypeLongDouble: {
                        long double const aValue = ((long double (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeBytes:(const uint8_t *)&aValue length:sizeof(long double) forKey:name];
                        continue;
                    }
                    case XZObjcTypeBool: {
                        BOOL const aValue = ((BOOL (*)(id, SEL))objc_msgSend)(model, getter);
                        [aCoder encodeBool:aValue forKey:name];
                        continue;
                    }
                    case XZObjcTypeVoid:
                    case XZObjcTypeString:
                    case XZObjcTypeArray:
                    case XZObjcTypeBitField:
                    case XZObjcTypePointer:
                    case XZObjcTypeUnion:
                        break;
                    case XZObjcTypeStruct: {
                        NSString * const aValue = XZJSONModelEncodeStructProperty(model, property);
                        if (aValue) {
                            [aCoder encodeObject:aValue forKey:name];
                            continue;
                        }
                        break;
                    }
                    case XZObjcTypeClass: {
                        Class const aValue = ((Class (*)(id, SEL))objc_msgSend)(model, getter);
                        if (aValue) {
                            [aCoder encodeObject:NSStringFromClass(aValue) forKey:name];
                        }
                        continue;
                    }
                    case XZObjcTypeSEL:{
                        SEL const aValue = ((SEL (*)(id, SEL))objc_msgSend)(model, getter);
                        if (aValue) {
                            [aCoder encodeObject:NSStringFromSelector(aValue) forKey:name];
                        }
                        continue;
                    }
                    case XZObjcTypeObject: {
                        id const aValue = ((id (*)(id, SEL))(void *)objc_msgSend)((id)model, property->_getter);
                        if (aValue) {
                            if ([aValue conformsToProtocol:@protocol(NSCoding)]) {
                                [aCoder encodeObject:aValue forKey:name];
                            } else {
                                id model = [XZJSONCodableModel modelWithModel:aValue];
                                [aCoder encodeObject:model forKey:name];
                            }
                            continue;
                        }
                        break;
                    }
                }
                
                NSLog(@"[XZJSON][NSCoding] Can not encode property `%@` for class `%@`.", property->_name, modelClass->_class.name);
            }
            break;
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
            return model;
        }
        case XZJSONClassTypeUnknown: {
            for (XZJSONPropertyDescriptor *property in modelClass->_properties) {
                SEL        const setter = property->_setter;
                NSString * const name   = property->_name;
                switch (property->_type) {
                    case XZObjcTypeUnknown:
                        break;
                    case XZObjcTypeChar:
                        ((void (*)(id, SEL, char))objc_msgSend)(model, setter, [aCoder decodeIntForKey:name]);
                        continue;
                    case XZObjcTypeUnsignedChar:
                        ((void (*)(id, SEL, unsigned char))objc_msgSend)(model, setter, [aCoder decodeIntForKey:name]);
                        continue;
                    case XZObjcTypeInt:
                        ((void (*)(id, SEL, int))objc_msgSend)(model, setter, [aCoder decodeIntForKey:name]);
                        continue;
                    case XZObjcTypeUnsignedInt:
                        ((void (*)(id, SEL, unsigned int))objc_msgSend)(model, setter, [aCoder decodeIntForKey:name]);
                        continue;
                    case XZObjcTypeShort:
                        ((void (*)(id, SEL, short))objc_msgSend)(model, setter, [aCoder decodeIntForKey:name]);
                        continue;
                    case XZObjcTypeUnsignedShort:
                        ((void (*)(id, SEL, unsigned short))objc_msgSend)(model, setter, [aCoder decodeIntForKey:name]);
                        continue;
                    case XZObjcTypeLong:
                        ((void (*)(id, SEL, long))objc_msgSend)(model, setter, [aCoder decodeInt32ForKey:name]);
                        continue;
                    case XZObjcTypeUnsignedLong:
                        ((void (*)(id, SEL, unsigned long))objc_msgSend)(model, setter, [aCoder decodeInt32ForKey:name]);
                        continue;
                    case XZObjcTypeLongLong:
                        ((void (*)(id, SEL, long long))objc_msgSend)(model, setter, [aCoder decodeInt64ForKey:name]);
                        continue;
                    case XZObjcTypeUnsignedLongLong:
                        ((void (*)(id, SEL, unsigned long long))objc_msgSend)(model, setter, [aCoder decodeInt64ForKey:name]);
                        continue;
                    case XZObjcTypeFloat:
                        ((void (*)(id, SEL, float))objc_msgSend)(model, setter, [aCoder decodeFloatForKey:name]);
                        continue;
                    case XZObjcTypeDouble:
                        ((void (*)(id, SEL, double))objc_msgSend)(model, setter, [aCoder decodeDoubleForKey:name]);
                        continue;
                    case XZObjcTypeLongDouble: {
                        NSUInteger length = 0;
                        long double *aValue = (long double *)[aCoder decodeBytesForKey:name returnedLength:&length];
                        if (aValue != NULL && length == sizeof(long double)) {
                            ((void (*)(id, SEL, long double))objc_msgSend)(model, setter, *aValue);
                            continue;
                        }
                        break;
                    }
                    case XZObjcTypeBool:
                        ((void (*)(id, SEL, double))objc_msgSend)(model, setter, [aCoder decodeBoolForKey:name]);
                        break;
                    case XZObjcTypeVoid:
                    case XZObjcTypeString:
                    case XZObjcTypeArray:
                    case XZObjcTypeBitField:
                    case XZObjcTypePointer:
                    case XZObjcTypeUnion:
                        break;
                    case XZObjcTypeStruct: {
                        if (XZJSONModelDecodeStructProperty(model, property, [aCoder decodeObjectForKey:name])) {
                            continue;
                        }
                        break;
                    }
                    case XZObjcTypeClass: {
                        NSString *aString = [aCoder decodeObjectForKey:name];
                        if ([aString isKindOfClass:NSString.class]) {
                            Class const aClass = NSClassFromString(aString);
                            if (aClass) {
                                ((void (*)(id, SEL, Class))objc_msgSend)(model, setter, aClass);
                                continue;
                            }
                        }
                        break;
                    }
                    case XZObjcTypeSEL: {
                        NSString *aString = [aCoder decodeObjectForKey:name];
                        if ([aString isKindOfClass:NSString.class]) {
                            SEL const aSelector = NSSelectorFromString(aString);
                            if (aSelector) {
                                ((void (*)(id, SEL, SEL))objc_msgSend)(model, setter, aSelector);
                                continue;
                            }
                        }
                        break;
                    }
                    case XZObjcTypeObject: {
                        id const object = [aCoder decodeObjectForKey:property->_name];
                        if ([object isKindOfClass:property->_subtype]) {
                            ((void (*)(id, SEL, id))objc_msgSend)(model, setter, object);
                            continue;
                        }
                        break;
                    }
                }
                
                NSLog(@"[XZJSON][NSCoding] Can not decode value for property `%@` for class `%@`.", property->_name, modelClass->_class.name);
            }
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
    XZJSONClassDescriptor * const modelClass = [XZJSONClassDescriptor descriptorForClass:[model class]];
    if (modelClass->_classType) return [model hash];
    
    NSMutableString *string = [NSMutableString stringWithString:@"|"];
    for (XZJSONPropertyDescriptor *property in modelClass->_properties) {
        NSUInteger hash = [XZJSON modelHash:[model valueForKey:NSStringFromSelector(property->_getter)]];
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


