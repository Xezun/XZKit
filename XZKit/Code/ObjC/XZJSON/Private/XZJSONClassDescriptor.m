//
//  XZJSONClassDescriptor.m
//  XZJSON
//
//  Created by Xezun on 2024/9/29.
//

#import "XZJSONClassDescriptor.h"
#import "XZJSONPropertyDescriptor.h"
#import "XZJSONDefines.h"
#import "XZMacro.h"

/// 解析字 JSON 键 key/keyPath 值，返回值nil或字符串或字符串数组。
/// - Parameter aString: 未处理的 JSON Key 字符串
/// - Returns: 键、键路径、键数组
static id XZJSONKeyFromString(NSString *aString);

@implementation XZJSONClassDescriptor

- (instancetype)initWithClass:(nonnull Class)rawClass {
    self = [super init];
    if (self) {
        _class = [XZObjcClassDescriptor descriptorForClass:rawClass];
        _classType = XZJSONClassTypeFromClass(rawClass);
        
        // 原生对象，不需要获取属性
        if (_classType) {
            _numberOfProperties = 0;
            _properties = @[];
            _namedProperties = @{};
            _keyProperties = @{};
            _keyPathProperties = @[];
            _keyArrayProperties = @[];
            _forwardsClassForDecoding = NO;
            _verifiesValueForDecoding = NO;
            _usesJSONDecodingInitializer = NO;
            _usesJSONEncodingInitializer = NO;
            _usesPropertyJSONDecodingMethod = NO;
            _usesPropertyJSONEncodingMethod = NO;
        } else {
            XZObjcClassDescriptor *descriptor = _class;
            
            while (descriptor.super) {
                [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(classNeedsUpdateNotification:) name:XZObjcClassNeedsUpdateNotification object:descriptor];
                descriptor = descriptor.super;
            }
            
            [self update];
        }
    }
    return self;
}

- (void)classNeedsUpdateNotification:(nullable NSNotification *)notification {
    if (notification && notification.userInfo[XZObjcClassUpdateTypeUserInfoKey] != XZObjcClassUpdateTypeProperties) {
        return;
    }
    
    @synchronized (self) {
        [self update];
    }
}

- (void)update {
    Class const rawClass = _class.raw;
    
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
        XZObjcClassDescriptor *class = _class;
        do {
            [class.properties enumerateKeysAndObjectsUsingBlock:^(NSString *name, XZObjcPropertyDescriptor *property, BOOL *stop) {
                if (blockedKeys && [blockedKeys containsObject:name])     {
                    return; // 有黑名单，则不能在黑名单中
                }
                if (allowedKeys && ![allowedKeys containsObject:name])     {
                    return; // 有白名单，则必须在白名单中
                }
                if (allProperties[name]) {
                    return; // 已存在
                }
                if (!property.getter || !property.setter) {
                    return; // 必须同时有 getter 和 setter
                }
                XZJSONPropertyDescriptor *descriptor = [XZJSONPropertyDescriptor descriptorWithClass:self property:property elementType:mappingClasses[property.name]];
                allProperties[name] = descriptor;
            }];
        } while ((class = class.super));
    }
    
    // 所有属性字典
    _namedProperties = [NSDictionary dictionaryWithDictionary:allProperties];
    
    // 所有属性集合，将属性按名称排序
    _properties = [allProperties.allValues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((XZJSONPropertyDescriptor *)obj1)->_name compare:((XZJSONPropertyDescriptor *)obj2)->_name];
    }];
    
    // 创建 JSONKey - Property 映射关系
    NSMutableDictionary * const keyProperties      = [NSMutableDictionary new];
    NSMutableArray      * const keyPathProperties  = [NSMutableArray new];
    NSMutableArray      * const keyArrayProperties = [NSMutableArray new];
    
    if ([rawClass respondsToSelector:@selector(mappingJSONCodingKeys)]) {
        [[rawClass mappingJSONCodingKeys] enumerateKeysAndObjectsUsingBlock:^(NSString * const propertyName, id const value, BOOL *stop) {
            XZJSONPropertyDescriptor * const property = allProperties[propertyName];
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
                property->_keyValueCoder = ^id(id object) {
                    return [object valueForKey:JSONKey];
                };
                // 如果 JSONKey 已有映射的属性，那么创建该 JSONKey 的映射链表
                property->_next = keyProperties[JSONKey];
                keyProperties[JSONKey] = property;
            } else if (JSONKeyPath) {
                property->_JSONKeyPath = JSONKeyPath;
                // 不与 key 放同一个集合，因为有可能 key 与 keyPath 相同
                // 如果 JSONKeyPath 已有映射的属性，那么创建该 JSONKeyPath 的映射链表
                NSString * const keyPath = [JSONKeyPath componentsJoinedByString:@"."];
                property->_keyValueCoder = ^id(id object) {
                    return [object valueForKeyPath:keyPath];
                };
                [keyPathProperties addObject:property];
            } else if (JSONKeyArray) {
                property->_JSONKeyArray = JSONKeyArray;
                NSMutableArray * const keyValueCoders = [NSMutableArray arrayWithCapacity:JSONKeyArray.count];
                for (id someKey in JSONKeyArray) {
                    if ([someKey isKindOfClass:[NSString class]]) {
                        NSString * const JSONKey = someKey;
                        [keyValueCoders addObject:^id(id object) {
                            return [object valueForKey:JSONKey];
                        }];
                    } else {
                        NSString * const JSONKeyPath = [(NSArray *)someKey componentsJoinedByString:@"."];
                        [keyValueCoders addObject:^id(id object) {
                            return [object valueForKeyPath:JSONKeyPath];
                        }];
                    }
                }
                property->_keyValueCoder = ^id(id object) {
                    for (XZJSONKeyValueCoder keyValueCoder in keyValueCoders) {
                        id const JSONValue = keyValueCoder(object);
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
    
    // 默认属性名直接映射 JSON 键
    [allProperties enumerateKeysAndObjectsUsingBlock:^(NSString *name, XZJSONPropertyDescriptor *property, BOOL *stop) {
        property->_JSONKey = name;
        property->_keyValueCoder = ^id(id object) {
            return [object valueForKey:name];
        };
        property->_next = keyProperties[name];
        keyProperties[name] = property;
    }];
    
    _keyProperties      = keyProperties;
    _keyPathProperties  = keyPathProperties;
    _keyArrayProperties = keyArrayProperties;
    _numberOfProperties = _properties.count;
    
    BOOL const conformsToXZJSONCoding = [rawClass conformsToProtocol:@protocol(XZJSONCoding)];
    _forwardsClassForDecoding = (conformsToXZJSONCoding && [rawClass respondsToSelector:@selector(forwardingClassForJSONDictionary:)]);
    _verifiesValueForDecoding = (conformsToXZJSONCoding && [rawClass respondsToSelector:@selector(canDecodeFromJSONDictionary:)]);
    
    _usesJSONDecodingInitializer = conformsToXZJSONCoding && [rawClass instancesRespondToSelector:@selector(initWithJSONDictionary:)];
    _usesJSONEncodingInitializer = conformsToXZJSONCoding && [rawClass instancesRespondToSelector:@selector(encodeIntoJSONDictionary:)];
    
    _usesPropertyJSONDecodingMethod = conformsToXZJSONCoding && [rawClass instancesRespondToSelector:@selector(JSONDecodeValue:forKey:)];
    _usesPropertyJSONEncodingMethod = conformsToXZJSONCoding && [rawClass instancesRespondToSelector:@selector(JSONEncodeValueForKey:)];
}


+ (XZJSONClassDescriptor *)descriptorForClass:(Class)aClass {
    if (aClass == Nil || !object_isClass(aClass) || [aClass superclass] == Nil || class_isMetaClass(aClass)) {
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
    XZJSONClassDescriptor *descriptor = CFDictionaryGetValue(_storage, (__bridge const void *)aClass);
    dispatch_semaphore_signal(_lock);
    
    if (descriptor) {
        return descriptor;
    }
    descriptor = [[XZJSONClassDescriptor alloc] initWithClass:aClass];
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    XZJSONClassDescriptor *descriptor2 = CFDictionaryGetValue(_storage, (__bridge const void *)aClass);
    if (descriptor2 == nil) {
        CFDictionarySetValue(_storage, (__bridge const void *)aClass, (__bridge const void *)descriptor);
    } else {
        descriptor = descriptor2;
    }
    dispatch_semaphore_signal(_lock);
    
    return descriptor;
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
