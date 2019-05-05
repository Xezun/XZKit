//
//  XZKeyedObject.h
//  XZKeyedObject
//
//  Created by M. X. Z. on 2016/10/26.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XZKeyedObject;

/**
 *  类名：PDKeyedObject
 *  说明：1，为纯属性数据模型设计的基类，优化字典与域名之间的转化效率，可通过协议创建。
 *  *    2，XZKeyedObject 可以像使用字典一样使用。
 *  *    3，子类可通过声明属性，通过属性对键值进行存取。
 *  *    4，对于子类属性，表示如果没有直接或通过 @synthesize 实现，则该属性会在运行时动态生成。
 */
NS_REQUIRES_PROPERTY_DEFINITIONS @interface XZKeyedObject : NSObject <NSSecureCoding, NSCopying>

+ (void)initialize NS_REQUIRES_SUPER;

/** See more in method -[XZKeyedObject initWithDictionary:keyMap:] . */
+ (instancetype)keyedObjectWithDictionary:(nullable NSDictionary<NSString *, id> *)keyedValues;

/** See more in method -[XZKeyedObject initWithDictionary:keyMap:] . */
+ (instancetype)keyedObjectWithDictionary:(nullable NSDictionary<NSString *, id> *)keyedValues keyMap:(nullable NSDictionary<NSString *, NSString *> *)keyMap;

/** See more in method -[XZKeyedObject initWithDictionary:keyMap:] . */
- (instancetype)initWithDictionary:(nullable NSDictionary<NSString *, id> *)keyedValues;

/**
 Create an XZKeyedObject with a key-value dictionary. You can provide a key map if the keys in key-value dictionary not matche the properties. The key of the map is the key-value dictionary's key, and the value of the map is the XZKeyedObject's property name.

 @param keyedValues a dictionary provides values for the new object
 @param keyMap a mapper for `keyedValues` to `properties`
 @return an XZKeyedObject instance
 */
- (instancetype)initWithDictionary:(nullable NSDictionary<NSString *, id> *)keyedValues keyMap:(nullable NSDictionary<NSString *, NSString *> *)keyMap;

// 下面两个方法，不会给非 @dynamic 声明的属性赋值。
- (nullable id)objectForKey:(NSString *)aKey;
- (void)setObject:(nullable id)anObject forKey:(NSString *)aKey;

// 提供了类似于字典的访问方式
- (nullable id)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(nullable id)obj forKeyedSubscript:(NSString *)key;

- (void)addEntriesFromDictionary:(NSDictionary<NSString *, id> *)keyedValues;
- (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues;

/**
 此方法返回的字典键值，数量不一定与属性相等。

 @return 包含所有键值的字典
 */
- (NSDictionary<NSString *, id> *)keyedValues;

@end

@interface XZKeyedObject (XZExtendedKeyedObject)

+ (Class)subclassingByConformingToProtocol:(Protocol *)aProtocol;

+ (__kindof XZKeyedObject *)keyedObjectByConformingToProtocol:(nonnull Protocol *)aProtocol;

+ (__kindof XZKeyedObject *)keyedObjectByConformingToProtocol:(nonnull Protocol *)aProtocol keyedValues:(nullable NSDictionary<NSString *, id> *)keyedVales;

+ (__kindof XZKeyedObject *)keyedObjectByConformingToProtocol:(nonnull Protocol *)aProtocol keyedValues:(nullable NSDictionary<NSString *, id> *)keyedVales keyMap:(nullable NSDictionary<NSString *, NSString *> *)keyMap;

@end

NS_ASSUME_NONNULL_END

// 关于 XCode 警告，通过 @dynamic 声明属性在运行时实现，或通过下面的指令消除警告。
/*
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-property-implementation"

//  code without warnnings.

#pragma clang diagnostic pop
*/
