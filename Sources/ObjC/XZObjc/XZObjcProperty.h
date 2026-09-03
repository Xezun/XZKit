//
//  XZObjcProperty.h
//  XZKit
//
//  Created by Xezun on 2025/1/26.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "XZObjcType.h"

@class XZObjcIvar, XZObjcType;

NS_ASSUME_NONNULL_BEGIN

/// 对运行时结构体 `objc_property_t` 的封装。
@interface XZObjcProperty : NSObject

/// 原始的 `objc_property_t` 结构体。
@property (nonatomic, readonly) objc_property_t raw;
/// 属性名。 
@property (nonatomic, readonly) NSString *name;
/// 属性值的类型。
@property (nonatomic, readonly) XZObjcType *type;
/// 属性修饰类型。
@property (nonatomic, readonly) XZStdcModifiers modifiers;
/// 属性的实例变量。
@property (nonatomic, strong, readonly, nullable) XZObjcIvar *ivar;
/// 取值方法，一定非空，且已验证可用。
@property (nonatomic, readonly) SEL getter;
/// 存值方法。如果属性不是只读的，那么值一定为空，且已验证可用。
@property (nonatomic, readonly, nullable) SEL setter;

- (instancetype)init NS_UNAVAILABLE;

+ (nullable instancetype)propertyWithProperty:(objc_property_t)property forClass:(Class)aClass NS_SWIFT_NAME(init(_:for:));

@end

NS_ASSUME_NONNULL_END
