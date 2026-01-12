//
//  XZObjcProperty.h
//  XZKit
//
//  Created by 徐臻 on 2025/1/26.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZObjcType.h>
#else
#import "XZObjcType.h"
#endif

@class XZObjcIvar, XZObjcType;

NS_ASSUME_NONNULL_BEGIN

/// 描述对象属性的对象。
///
/// Property information.
@interface XZObjcProperty : NSObject <XZObjcType>

/// 原始值。 property's opaque struct
@property (nonatomic, readonly) objc_property_t raw;
/// 属性名。 property's name
@property (nonatomic, readonly) NSString *name;
/// 属性值的类型。
@property (nonatomic, readonly) XZObjcType *type;
/// 属性的实例变量。
@property (nonatomic, strong, readonly, nullable) XZObjcIvar *ivar;
/// 取值方法，非空。
@property (nonatomic, readonly) SEL getter;
/// 存值方法。可能为空。
@property (nonatomic, readonly, nullable) SEL setter;

- (instancetype)init NS_UNAVAILABLE;

+ (nullable instancetype)propertyForProperty:(objc_property_t)rawProperty forClass:(Class)aClass NS_SWIFT_NAME(init(for:for:));

@end

NS_ASSUME_NONNULL_END
