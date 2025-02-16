//
//  XZJSONClassDescriptor.m
//  XZJSON
//
//  Created by Xezun on 2024/9/29.
//

#import "XZJSONClassDescriptor.h"
#import "XZJSONPropertyDescriptor.h"
#import "XZJSONDefines.h"

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
        XZObjcClassDescriptor *currentClass = _class;
        do {
            [currentClass.properties enumerateKeysAndObjectsUsingBlock:^(NSString *name, XZObjcPropertyDescriptor *property, BOOL *stop) {
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
                XZObjcQualifiers const qualifiers = property.type.qualifiers;
                if (qualifiers & XZObjcQualifierWeak) {
                    return; // weak 属性不处理
                }
                if (property.type.type == XZObjcTypeObject && !(qualifiers & XZObjcQualifierCopy) && !(qualifiers & XZObjcQualifierRetain)) {
                    return; // unsafe_unretained 属性不处理
                }
                XZJSONPropertyDescriptor *descriptor = [XZJSONPropertyDescriptor descriptorWithClass:self property:property elementType:mappingClasses[property.name]];
                allProperties[name] = descriptor;
            }];
        } while ((currentClass = currentClass.super));
        // 将属性按名称排序
        _properties = [allProperties.allValues.copy sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
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
                    NSLog(@"[%@ mappingJSONCodingKeys] 属性 %@ 不存在", rawClass, propertyName);
                    return;
                }
                
                NSString * JSONKey      = nil;
                NSArray  * JSONKeyPath  = nil;
                NSArray  * JSONKeyArray = nil;
                
                if ([value isKindOfClass:NSString.class]) {
                    id const someKey = XZJSONKeyFromString(value);
                    if (someKey == nil) {
                        NSLog(@"[%@ mappingJSONCodingKeys] 属性 %@ 映射 JSON 键 %@ 不合法", rawClass, propertyName, value);
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
                        id const someKey = XZJSONKeyFromString(object);
                        if (someKey == nil) {
                            NSLog(@"[%@ mappingJSONCodingKeys] 属性 %@ 映射 JSON 键 %@ 不合法", rawClass, propertyName, value);
                            continue;
                        }
                        [arrayM addObject:someKey];
                    }
                    switch (arrayM.count) {
                        case 0:
                            NSLog(@"[%@ mappingJSONCodingKeys] 属性 %@ 映射 JSON 键 %@ 不合法", rawClass, propertyName, value);
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
                    NSLog(@"[%@ mappingJSONCodingKeys] 属性 %@ 映射 JSON 键 %@ 不合法", rawClass, propertyName, value);
                    return;
                }
                
                property->_JSONKey      = JSONKey;
                property->_JSONKeyPath  = JSONKeyPath;
                property->_JSONKeyArray = JSONKeyArray;
                
                // 建立属性映射链表：JSONKey 映射到多个属性
                property->_next = keyProperties[JSONKey];
                keyProperties[JSONKey]  = property;
                
                if (JSONKeyPath) {
                    [keyPathProperties addObject:property];
                } else if (JSONKeyArray) {
                    [keyArrayProperties addObject:property];
                }
                
                // 移除已处理的
                [allProperties removeObjectForKey:propertyName];
            }];
        }
        
        // 默认属性名直接映射 JSON 键
        [allProperties enumerateKeysAndObjectsUsingBlock:^(NSString *name, XZJSONPropertyDescriptor *property, BOOL *stop) {
            property->_JSONKey = name;
            property->_next = keyProperties[name] ?: nil;
            keyProperties[name] = property;
        }];
        
        _keyProperties      = keyProperties;
        _keyPathProperties  = keyPathProperties;
        _keyArrayProperties = keyArrayProperties;
        _numberOfProperties = _properties.count;
        
        BOOL const conformsToXZJSONCoding = [rawClass conformsToProtocol:@protocol(XZJSONCoding)];
        _forwardsClassForDecoding = (conformsToXZJSONCoding && [rawClass respondsToSelector:@selector(forwardingClassForJSONDictionary:)]);
        _verifiesValueForDecoding = (conformsToXZJSONCoding && [rawClass respondsToSelector:@selector(canDecodeFromJSONDictionary:)]);
        
        BOOL const conformsToXZJSONDecoding = [rawClass conformsToProtocol:@protocol(XZJSONDecoding)];
        BOOL const conformsToXZJSONEncoding = [rawClass conformsToProtocol:@protocol(XZJSONEncoding)];
        
        _usesJSONDecodingMethod = conformsToXZJSONDecoding && [rawClass instancesRespondToSelector:@selector(initWithJSONDictionary:)];
        _usesJSONEncodingMethod = conformsToXZJSONEncoding && [rawClass instancesRespondToSelector:@selector(encodeIntoJSONDictionary:)];
        
        _usesPropertyDecodingMethod = conformsToXZJSONDecoding && [rawClass instancesRespondToSelector:@selector(JSONDecodeValue:forKey:)];
        _usesPropertyEncodingMethod = conformsToXZJSONEncoding && [rawClass instancesRespondToSelector:@selector(JSONEncodeValueForKey:)];
        
        _usesIvarCopyingMethod = [rawClass conformsToProtocol:@protocol(XZJSONCopying)] && [rawClass instancesRespondToSelector:@selector(copyIvar:)];
    }
    return self;
}

+ (XZJSONClassDescriptor *)descriptorForClass:(Class)aClass {
    if (aClass == Nil || !object_isClass(aClass) || [aClass superclass] == Nil || class_isMetaClass(aClass)) {
        return nil;
    }
    
    static const void * const _descriptor = &_descriptor;
    static dispatch_semaphore_t _lock;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _lock = dispatch_semaphore_create(1);
    });
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    XZJSONClassDescriptor *descriptor = objc_getAssociatedObject(aClass, _descriptor);
    if (descriptor == nil) {
        descriptor = [[XZJSONClassDescriptor alloc] initWithClass:aClass];
        objc_setAssociatedObject(aClass, _descriptor, descriptor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        [descriptor->_class properties];
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
