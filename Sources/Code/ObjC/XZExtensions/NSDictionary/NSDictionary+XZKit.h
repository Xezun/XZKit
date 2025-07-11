//
//  NSDictionary+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/6/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary<KeyType, ObjectType> (XZKit)

- (BOOL)xz_boolValueForKey:(KeyType)aKey OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");

- (NSInteger)xz_integerValueForKey:(KeyType)aKey defaultValue:(NSInteger)defaultValue OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");
- (NSInteger)xz_integerValueForKey:(KeyType)aKey OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");

- (CGFloat)xz_floatValueForKey:(KeyType)aKey defaultValue:(NSInteger)defaultValue OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");
- (CGFloat)xz_floatValueForKey:(KeyType)aKey OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");

/// 将 JSON 数据，`NSData`或`NSString`对象，解析为`NSDictionary`对象。
/// @note JSON 数据顶层必须为字典。
/// @note 使用可变容器始构造，则 JSON 数据内的值，也为可变容器。
/// @param json 待解析的 JSON 数据
/// @param options 序列化选项
+ (nullable instancetype)xz_dictionaryWithJSON:(nullable id)json options:(NSJSONReadingOptions)options NS_SWIFT_NAME(init(JSON:options:));
/// 将 JSON 数据，`NSData`或`NSString`对象，解析为`NSDictionary`对象。
/// @param json 待解析的 JSON 数据
+ (nullable instancetype)xz_dictionaryWithJSON:(nullable id)json NS_SWIFT_NAME(init(JSON:));

@end

@interface NSMutableDictionary<KeyType, ObjectType> (XZKit)

- (nullable ObjectType)xz_removeObjectForKey:(KeyType)aKey OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");
- (NSArray<ObjectType> *)xz_removeObjectsForKeys:(NSArray<KeyType> *)keyArray OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");

@end

NS_ASSUME_NONNULL_END
