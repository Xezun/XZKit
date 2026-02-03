//
//  XZJSONClass.m
//  XZJSON
//
//  Created by Xezun on 2024/9/29.
//

#import "XZJSONClass.h"
#import "XZJSONProperty.h"
#import "XZJSONDefines.h"
#import "XZLog.h"

/// 解析字 JSON 键 key/keyPath 值，返回值nil或字符串或字符串数组。
/// - Parameter aString: 未处理的 JSON Key 字符串
/// - Returns: 键、键路径、键数组
static id XZJSONKeyFromString(NSString *aString);

@implementation XZJSONClass

- (instancetype)initWithClass:(nonnull Class)aClass {
    self = [super init];
    if (self) {
        _raw = [XZObjcClass classWithClass:aClass];
        _cocoaClass = XZJSONCocoaClassFromClass(aClass);
        
        // 原生对象，不需要获取属性
        if (_cocoaClass != XZJSONCocoaClassUnknown) {
            _numberOfProperties = 0;
            _sortedProperties = @[];
            _namedProperties = @{};
            _keyProperties = @{};
            _keyPathProperties = @[];
            _keyArrayProperties = @[];
            _forwardsDecodingClass = NO;
            _verifiesDecodingValue = NO;
            _usesModelDecodingMethod = NO;
            _usesModelEncodingMethod = NO;
            _usesPropertyDecodingMethod = NO;
            _usesPropertyEncodingMethod = NO;
        } else {
            [self update];
        }
    }
    return self;
}

- (void)classNeedsUpdateNotification:(nullable NSNotification *)notification {
    @synchronized (self) {
        [self update];
    }
}

- (void)update {
    Class const rawClass = _raw.raw;
    
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
    
    // 映射：属性名 <=> 属性类型
    NSDictionary *mappingClasses = nil;
    if ([rawClass respondsToSelector:@selector(mappingJSONCodingClasses)]) {
        mappingClasses = [rawClass mappingJSONCodingClasses];
        if (mappingClasses) {
            NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithCapacity:mappingClasses.count];
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
    
    // 所有属性
    NSMutableDictionary * const allProperties = [NSMutableDictionary new];
    {
        XZObjcClass *class = _raw;
        do {
            [class.properties enumerateKeysAndObjectsUsingBlock:^(NSString *name, XZObjcProperty *property, BOOL *stop) {
                if (blockedKeys && [blockedKeys containsObject:name])     {
                    return; // 有黑名单，则不能在黑名单中
                }
                if (allowedKeys && ![allowedKeys containsObject:name])     {
                    return; // 有白名单，则必须在白名单中
                }
                if (allProperties[name]) {
                    return; // 已存在
                }
                XZJSONProperty * const descriptor = [XZJSONProperty descriptorWithProperty:property class:self mappingClass:mappingClasses[property.name]];
                allProperties[name] = descriptor;
            }];
        } while ((class = class.superClass));
    }
    
    _numberOfProperties = allProperties.count;
    _namedProperties    = [NSDictionary dictionaryWithDictionary:allProperties];
    _sortedProperties   = [allProperties.allValues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((XZJSONProperty *)obj1)->_name compare:((XZJSONProperty *)obj2)->_name];
    }];
    
    // 创建 JSONKey - Property 映射关系
    NSMutableDictionary * const keyProperties      = [NSMutableDictionary new];
    NSMutableArray      * const keyPathProperties  = [NSMutableArray new];
    NSMutableArray      * const keyArrayProperties = [NSMutableArray new];
    
    if ([rawClass respondsToSelector:@selector(mappingJSONCodingKeys)]) {
        [[rawClass mappingJSONCodingKeys] enumerateKeysAndObjectsUsingBlock:^(NSString * const propertyName, id const value, BOOL *stop) {
            XZJSONProperty * const property = allProperties[propertyName];
            if (property == nil) {
                XZLog(@"[%@ mappingJSONCodingKeys] 属性 %@ 不存在", rawClass, propertyName);
                return;
            }
            
            NSString * JSONKey      = nil;
            NSArray  * JSONKeyPath  = nil;
            NSArray  * JSONKeyArray = nil;
            
            if ([value isKindOfClass:NSString.class]) {
                id const someKey = XZJSONKeyFromString(value);
                if (someKey == nil) {
                    XZLog(@"[%@ mappingJSONCodingKeys] 属性 %@ 映射 JSON 键 %@ 不合法", rawClass, propertyName, value);
                    return;
                } else if ([someKey isKindOfClass:NSString.class]) {
                    JSONKey = someKey;
                } else {
                    JSONKeyPath = someKey;
                }
            } else if ([value isKindOfClass:NSArray.class]) {
                NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:((NSArray *)value).count];
                for (id object in value) {
                    if (![object isKindOfClass:NSString.class]) {
                        continue;
                    }
                    id const someKey = XZJSONKeyFromString(object);
                    if (someKey == nil) {
                        XZLog(@"[%@ mappingJSONCodingKeys] 属性 %@ 映射 JSON 键 %@ 不合法", rawClass, propertyName, value);
                        continue;
                    }
                    [arrayM addObject:someKey];
                }
                switch (arrayM.count) {
                    case 0:
                        XZLog(@"[%@ mappingJSONCodingKeys] 属性 %@ 映射 JSON 键 %@ 不合法", rawClass, propertyName, value);
                        return;
                    case 1: {
                        id const someKey = arrayM[0];
                        if ([someKey isKindOfClass:NSString.class]) {
                            JSONKey = someKey;
                        } else {
                            JSONKeyPath = someKey;
                        }
                        break;
                    }
                    default: {
                        JSONKeyArray = arrayM;
                        break;
                    }
                }
            } else {
                XZLog(@"[%@ mappingJSONCodingKeys] 属性 %@ 映射 JSON 键 %@ 不合法", rawClass, propertyName, value);
                return;
            }
            
            // 因为映射为 属性 => JSONKey 所以 property 在遍历过程中不会重复。
            if (JSONKey) {
                property->_JSONKey = JSONKey;
                property->_fetchValueFromDictionary = ^id(NSDictionary *dictionary) {
                    return [dictionary valueForKey:JSONKey];
                };
                // 如果 JSONKey 已有映射的属性，那么创建该 JSONKey 的映射链表
                property->_next = keyProperties[JSONKey];
                keyProperties[JSONKey] = property;
            } else if (JSONKeyPath) {
                property->_JSONKeyPath = JSONKeyPath;
                // 不与 key 放同一个集合，因为有可能 key 与 keyPath 相同
                // 如果 JSONKeyPath 已有映射的属性，那么创建该 JSONKeyPath 的映射链表
                NSString * const keyPath = [JSONKeyPath componentsJoinedByString:@"."];
                property->_fetchValueFromDictionary = ^id(NSDictionary *dictionary) {
                    return [dictionary valueForKeyPath:keyPath];
                };
                [keyPathProperties addObject:property];
            } else if (JSONKeyArray) {
                property->_JSONKeyArray = JSONKeyArray;
                NSMutableArray * const valueDecoders = [NSMutableArray arrayWithCapacity:JSONKeyArray.count];
                for (id someKey in JSONKeyArray) {
                    if ([someKey isKindOfClass:[NSString class]]) {
                        NSString * const JSONKey = someKey;
                        [valueDecoders addObject:^id(id object) {
                            return [object valueForKey:JSONKey];
                        }];
                    } else {
                        NSString * const JSONKeyPath = [(NSArray *)someKey componentsJoinedByString:@"."];
                        [valueDecoders addObject:^id(id object) {
                            return [object valueForKeyPath:JSONKeyPath];
                        }];
                    }
                }
                property->_fetchValueFromDictionary = ^id(NSDictionary *dictionary) {
                    for (XZJSONPropertyValueDecoder valueDecoder in valueDecoders) {
                        id const JSONValue = valueDecoder(dictionary);
                        if (JSONValue) {
                            return JSONValue;
                        }
                    }
                    return nil;
                };
                [keyArrayProperties addObject:property];
            }
            
            // 移除已处理的
            [allProperties removeObjectForKey:propertyName];
        }];
    }
    
    // 属性名映射 JSON 键
    [allProperties enumerateKeysAndObjectsUsingBlock:^(NSString *name, XZJSONProperty *property, BOOL *stop) {
        property->_JSONKey = name;
        property->_fetchValueFromDictionary = ^id(NSDictionary *dictionary) {
            return [dictionary valueForKey:name];
        };
        property->_next = keyProperties[name];
        keyProperties[name] = property;
    }];
    
    _keyProperties      = keyProperties;
    _keyPathProperties  = keyPathProperties;
    _keyArrayProperties = keyArrayProperties;
    
    BOOL const conformsToXZJSONCoding = [rawClass conformsToProtocol:@protocol(XZJSONCoding)];
    _forwardsDecodingClass = (conformsToXZJSONCoding && [rawClass respondsToSelector:@selector(forwardingClassForJSONDictionary:)]);
    _verifiesDecodingValue = (conformsToXZJSONCoding && [rawClass respondsToSelector:@selector(canDecodeFromJSONDictionary:)]);
    
    _usesModelDecodingMethod = conformsToXZJSONCoding && [rawClass instancesRespondToSelector:@selector(decodeFromJSONDictionary:)];
    _usesModelEncodingMethod = conformsToXZJSONCoding && [rawClass instancesRespondToSelector:@selector(encodeIntoJSONDictionary:)];
    
    _usesPropertyDecodingMethod = conformsToXZJSONCoding && [rawClass instancesRespondToSelector:@selector(JSONDecodeValue:forKey:)];
    _usesPropertyEncodingMethod = conformsToXZJSONCoding && [rawClass instancesRespondToSelector:@selector(JSONEncodeValueForKey:)];
}


+ (XZJSONClass *)classForClass:(Class)class {
    if (class == Nil || class == NSNull.class || !object_isClass(class) || [class superclass] == Nil || class_isMetaClass(class) ) {
        return nil;
    }
    
    static CFMutableDictionaryRef _storage = nil;
    
    static dispatch_semaphore_t _lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _lock = dispatch_semaphore_create(1);
        _storage = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    });
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    XZJSONClass *cachedClass = CFDictionaryGetValue(_storage, (__bridge const void *)class);
    dispatch_semaphore_signal(_lock);
    
    if (cachedClass) {
        return cachedClass;
    }
    
    XZJSONClass *newClass = [[XZJSONClass alloc] initWithClass:class];
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    XZJSONClass *oldClass = CFDictionaryGetValue(_storage, (__bridge const void *)class);
    if (oldClass == nil) {
        CFDictionarySetValue(_storage, (__bridge const void *)class, (__bridge const void *)newClass);
    } else {
        newClass = oldClass;
    }
    dispatch_semaphore_signal(_lock);
    
    return newClass;
}

@end

id XZJSONKeyFromString(NSString *aString) {
    if (aString.length == 0) {
        return nil;
    }
    
    // 包含非法字符
    if ([aString rangeOfCharacterFromSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].location != NSNotFound) {
        return nil;
    }
    
    // 普通键
    if (![aString containsString:@"."]) {
        return aString;
    }
    
    NSMutableArray  * keyPath = [NSMutableArray array];
    BOOL __block      escaped = NO;
    NSMutableString * current = [NSMutableString string];
    NSRange                    const range   = NSMakeRange(0, aString.length);
    NSStringEnumerationOptions const options = NSStringEnumerationByComposedCharacterSequences;
    
    [aString enumerateSubstringsInRange:range options:options usingBlock:^(NSString *substring, NSRange characterRange, NSRange enclosingRange, BOOL *stop) {
        if (substring == nil) {
            return;
        }
        if (escaped) {
            escaped = NO;
            [current appendString:substring];
        } else if ([substring isEqualToString:@"."]) {
            NSUInteger const length = current.length;
            if (length > 0) {
                [keyPath addObject:current.copy];
                [current deleteCharactersInRange:NSMakeRange(0, length)];
            }
        } else if ([substring isEqualToString:@"\\"]) {
            escaped = YES;
        } else {
            [current appendString:substring];
        }
    }];
    
    if (current.length > 0) {
        [keyPath addObject:current.copy];
        current = nil;
    }
    
    switch (keyPath.count) {
        case 0:
            return nil;
        case 1:
            return keyPath[0];
        default:
            return keyPath;
    }
};
