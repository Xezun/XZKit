//
//  XZObjcPropertyDescriptor.h
//  XZKit
//
//  Created by 徐臻 on 2025/1/26.
//

#import "XZObjcType.h"

@class XZObjcIvarDescriptor, XZObjcType;

NS_ASSUME_NONNULL_BEGIN

/// 描述对象属性的对象。
///
/// Property information.
@interface XZObjcPropertyDescriptor : NSObject <XZObjcDescriptor>
/// 原始值。 property's opaque struct
@property (nonatomic, assign, readonly) objc_property_t raw;
/// 属性名。 property's name
@property (nonatomic, readonly) NSString *name;
/// 属性值的类型。
@property (nonatomic, readonly) XZObjcType *type;
/// 属性的实例变量。
@property (nonatomic, strong, readonly, nullable) XZObjcIvarDescriptor *ivar;
/// 取值方法，非空。
@property (nonatomic, assign, readonly) SEL getter;
/// 存值方法。可能为空。
@property (nonatomic, assign, readonly, nullable) SEL setter;

+ (nullable instancetype)descriptorForProperty:(objc_property_t)property forClass:(Class)aClass;
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
