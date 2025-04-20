//
//  XZObjcClassDescriptor.h
//  XZKit
//
//  Created by 徐臻 on 2025/1/26.
//

#import "XZObjcType.h"

@class XZObjcIvarDescriptor, XZObjcMethodDescriptor, XZObjcPropertyDescriptor;

NS_ASSUME_NONNULL_BEGIN

/// 当 XZObjcClassDescriptor 发生更新时，会发送此通知。
FOUNDATION_EXPORT NSNotificationName const XZObjcClassNeedsUpdateNotification;
/// 在 XZObjcClassDescriptor 的通知中，获取变更枚举 XZObjcClassUpdate 的键。
FOUNDATION_EXPORT NSString * const XZObjcClassUpdateUserInfoKey;

/// 变更类型。
typedef NSString *XZObjcClassUpdate NS_STRING_ENUM;
/// XZObjcClassDescriptor 实例变量更新。
FOUNDATION_EXPORT XZObjcClassUpdate const XZObjcClassUpdateIvars;
/// XZObjcClassDescriptor 方法更新。
FOUNDATION_EXPORT XZObjcClassUpdate const XZObjcClassUpdateMethods;
/// XZObjcClassDescriptor 属性更新。
FOUNDATION_EXPORT XZObjcClassUpdate const XZObjcClassUpdateProperties;

/// 描述类的对象。
///
/// Class information for a class.
@interface XZObjcClassDescriptor : NSObject <XZObjcDescriptor>

/// 当前类，当前对象所描述的类。
@property (nonatomic, readonly) Class raw;
 
/// 描述当前类的超类的对象。
@property (nonatomic, readonly, nullable) XZObjcClassDescriptor *super;

/// 类名。class name
@property (nonatomic, readonly) NSString *name;

/// 类的类型描述。
@property (nonatomic, readonly) XZObjcType *type;

/// 类实例变量。ivars
@property (copy, readonly) NSDictionary<NSString *, XZObjcIvarDescriptor *>     *ivars;

/// 在运行时更新了类的实例变量后，应调用此方法标记更新。
- (void)setNeedsUpdateIvars;

/// 类方法。 methods
@property (copy, readonly) NSDictionary<NSString *, XZObjcMethodDescriptor *>   *methods;

/// 在运行时更新了类的实例方法后，应调用此方法标记更新。
- (void)setNeedsUpdateMethods;

/// 类属性。 properties
@property (copy, readonly) NSDictionary<NSString *, XZObjcPropertyDescriptor *> *properties;

/// 在运行时更新了类的实例属性后，应调用此方法标记更新。
- (void)setNeedsUpdateProperties;

- (instancetype)init NS_UNAVAILABLE;

/// 获取类 aClass 的描述信息。
/// - Parameter aClass: 类
+ (nullable XZObjcClassDescriptor *)descriptorWithClass:(nullable Class)aClass NS_SWIFT_NAME(init(_:));

@end

NS_ASSUME_NONNULL_END
