//
//  XZJSONClassDescriptor.m
//  XZJSON
//
//  Created by Xezun on 2024/9/29.
//

#import "XZJSONClassDescriptor.h"
#import "XZJSONPropertyDescriptor.h"
#import "XZJSONDefines.h"

static id XZJSONMappingKeyParser(NSString *JSONKey);

@implementation XZJSONClassDescriptor

- (instancetype)initWithClass:(nonnull Class)rawClass {
    XZObjcClassDescriptor * const aClass = [XZObjcClassDescriptor descriptorForClass:rawClass];
    if (aClass == nil) {
        return nil;
    }
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    // 黑名单
    NSSet *blockedKeys = nil;
    if ([rawClass respondsToSelector:@selector(blockedJSONCodingKeys)]) {
        NSArray *properties = [rawClass blockedJSONCodingKeys];
        if (properties) {
            blockedKeys = [NSSet setWithArray:properties];
        }
    }
    
    // 白名单
    NSSet *allowedKeys = nil;
    if ([rawClass respondsToSelector:@selector(allowedJSONCodingKeys)]) {
        NSArray *properties = [rawClass allowedJSONCodingKeys];
        if (properties) {
            allowedKeys = [NSSet setWithArray:properties];
        }
    }
    
    // 类映射
    NSDictionary *mappingClasses = nil;
    if ([rawClass respondsToSelector:@selector(mappingJSONCodingClasses)]) {
        mappingClasses = [rawClass mappingJSONCodingClasses];
        if (mappingClasses) {
            NSMutableDictionary *tmp = [NSMutableDictionary new];
            [mappingClasses enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if (![key isKindOfClass:[NSString class]]) return;
                if (object_isClass(obj)) {
                    tmp[key] = obj;
                } else if ([obj isKindOfClass:[NSString class]]) {
                    tmp[key] = NSClassFromString(obj);
                }
            }];
            mappingClasses = tmp;
        }
    }
    
    // Create all property metas.
    NSMutableDictionary * const namedProperties = [NSMutableDictionary new];
    XZObjcClassDescriptor *currentClass = aClass;
    do {
        [currentClass.properties enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull name, XZObjcPropertyDescriptor * _Nonnull property, BOOL * _Nonnull stop) {
            if (blockedKeys && [blockedKeys containsObject:name])     {
                return; // 有黑名单，则不能在黑名单中
            }
            if (allowedKeys && ![allowedKeys containsObject:name])     {
                return; // 有白名单，则必须在白名单中
            }
            if (namedProperties[name]) {
                return; // 已存在
            }
            XZJSONPropertyDescriptor *descriptor = [XZJSONPropertyDescriptor descriptorWithClass:aClass property:property elementClass:mappingClasses[property.name]];
            if (!descriptor->_getter || !descriptor->_setter) {
                return;
            }
            namedProperties[name] = descriptor;
        }];
    } while ((currentClass = currentClass.superDescriptor));
    if (namedProperties.count) _properties = namedProperties.allValues.copy;
    
    // create mapper
    NSMutableDictionary *keyProperties      = [NSMutableDictionary new];
    NSMutableArray      *keyPathProperties  = [NSMutableArray new];
    NSMutableArray      *keyArrayProperties = [NSMutableArray new];
    
    if ([rawClass respondsToSelector:@selector(mappingJSONCodingKeys)]) {
        [[rawClass mappingJSONCodingKeys] enumerateKeysAndObjectsUsingBlock:^(NSString * const propertyName, id const value, BOOL *stop) {
            XZJSONPropertyDescriptor * const property = namedProperties[propertyName];
            if (property == nil) {
                return; // 没找到对应的属性。
            }
            
            NSString * JSONKey      = nil;
            NSArray  * JSONKeyPath  = nil;
            NSArray  * JSONKeyArray = nil;
            
            if ([value isKindOfClass:NSString.class]) {
                id const someKey = XZJSONMappingKeyParser(value);
                if (someKey == nil) {
                    return;
                } else if ([someKey isKindOfClass:NSString.class]) {
                    JSONKey = someKey;
                } else {
                    JSONKey = [someKey componentsJoinedByString:@"."];
                    JSONKeyPath = someKey;
                }
            } else if ([value isKindOfClass:NSArray.class]) {
                NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:((NSArray *)value).count];
                for (id object in value) {
                    if (![object isKindOfClass:NSString.class]) {
                        continue;
                    }
                    id const someKey = XZJSONMappingKeyParser(object);
                    if (someKey != nil) {
                        [arrayM addObject:someKey];
                    }
                }
                switch (arrayM.count) {
                    case 0:
                        return;
                    case 1: {
                        id const someKey = arrayM[0];
                        if ([someKey isKindOfClass:NSString.class]) {
                            JSONKey = someKey;
                        } else {
                            JSONKey = [someKey componentsJoinedByString:@"."];
                            JSONKeyPath = someKey;
                        }
                        break;
                    }
                    default: {
                        JSONKeyArray = arrayM;
                        id const someKey = arrayM[0];
                        if ([someKey isKindOfClass:NSString.class]) {
                            JSONKey = someKey;
                        } else {
                            JSONKey = [(NSArray *)someKey componentsJoinedByString:@"."];
                        }
                        break;
                    }
                }
            } else {
                return;
            }
            
            // 移除已处理的
            [namedProperties removeObjectForKey:propertyName];
            
            property->_JSONKey      = JSONKey;
            property->_JSONKeyPath  = JSONKeyPath;
            property->_JSONKeyArray = JSONKeyArray;
            property->_next         = keyProperties[JSONKey];
            keyProperties[JSONKey]  = property;
            
            if (JSONKeyPath) {
                [keyPathProperties addObject:property];
            } else if (JSONKeyArray) {
                [keyArrayProperties addObject:property];
            }
        }];
    }
    
    [namedProperties enumerateKeysAndObjectsUsingBlock:^(NSString *name, XZJSONPropertyDescriptor *property, BOOL *stop) {
        property->_JSONKey = name;
        property->_next = keyProperties[name] ?: nil;
        keyProperties[name] = property;
    }];
    
    if (keyProperties.count)    _keyProperties      = keyProperties;
    if (keyPathProperties)      _keyPathProperties  = keyPathProperties;
    if (keyArrayProperties)     _keyArrayProperties = keyArrayProperties;
    
    _class = aClass;
    _numberOfProperties = _properties.count;
    _nsType = XZJSONEncodingNSTypeFromClass(rawClass);
    
    BOOL const _supportsXZJSONCoding = [rawClass conformsToProtocol:@protocol(XZJSONCoding)];
    _forwardsClassForDecoding = (_supportsXZJSONCoding && [rawClass respondsToSelector:@selector(forwardingClassForJSONDictionary:)]);
    _verifiesValueForDecoding = (_supportsXZJSONCoding && [rawClass respondsToSelector:@selector(canDecodeFromJSONDictionary:)]);
    
    BOOL const _supportsXZJSONDecoding = [rawClass conformsToProtocol:@protocol(XZJSONDecoding)];
    _usesDecodingInitializer = (_supportsXZJSONDecoding && [rawClass instancesRespondToSelector:@selector(initWithJSONDictionary:)]);
    
    _usesJSONEncodingMethod = [rawClass conformsToProtocol:@protocol(XZJSONDecoding)] && [rawClass instancesRespondToSelector:@selector(encodeIntoJSONDictionary:)];
    
    return self;
}

+ (XZJSONClassDescriptor *)descriptorForClass:(Class)aClass {
    if (aClass == Nil || !object_isClass(aClass) || [aClass superclass] == Nil || class_isMetaClass(aClass)) {
        return nil;
    }
    
    static CFMutableDictionaryRef _cachedDescriptors;
    static dispatch_semaphore_t   _lock;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cachedDescriptors = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        _lock = dispatch_semaphore_create(1);
    });
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    XZJSONClassDescriptor *descriptor = CFDictionaryGetValue(_cachedDescriptors, (__bridge const void *)(aClass));
    dispatch_semaphore_signal(_lock);
    
    if (descriptor == nil || !descriptor->_class.isValid) {
        descriptor = [[XZJSONClassDescriptor alloc] initWithClass:aClass];
        if (descriptor) {
            dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(_cachedDescriptors, (__bridge const void *)(aClass), (__bridge const void *)(descriptor));
            dispatch_semaphore_signal(_lock);
        }
    }
    
    return descriptor;
}

@end

/// 解析字 JSON 键 key/keyPath 值，返回值nil或字符串或字符串数组。
/// - Parameter JSONKey: JSON 键
id XZJSONMappingKeyParser(NSString *JSONKey) {
    if (JSONKey.length == 0) {
        return nil;
    }
    
    if (![JSONKey containsString:@"."]) {
        return JSONKey;
    }
    
    NSMutableArray *  JSONKeyPath   = [NSMutableArray array];
    BOOL __block      isEescapeMode = NO;
    NSMutableString * key           = [NSMutableString string];
    [JSONKey enumerateSubstringsInRange:NSMakeRange(0, JSONKey.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange characterRange, NSRange enclosingRange, BOOL *stop) {
        if (isEescapeMode) {
            isEescapeMode = NO;
            [key appendString:substring];
        } else if ([substring isEqualToString:@"."]) {
            NSUInteger const length = key.length;
            if (length > 0) {
                [JSONKeyPath addObject:key.copy];
                [key deleteCharactersInRange:NSMakeRange(0, length)];
            }
        } else if ([substring isEqualToString:@"\\"]) {
            isEescapeMode = YES;
        } else {
            [key appendString:substring];
        }
    }];
    
    if (key.length > 0) {
        [JSONKeyPath addObject:key.copy];
        key = nil;
    }
    
    switch (JSONKeyPath.count) {
        case 0:
            return nil;
        case 1:
            return JSONKeyPath[0];
        default:
            return JSONKeyPath;
    }
};
