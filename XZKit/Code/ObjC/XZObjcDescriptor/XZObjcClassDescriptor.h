//
//  XZObjcClassDescriptor.h
//  XZKit
//
//  Created by 徐臻 on 2025/1/26.
//

#import "XZObjcTypeDescriptor.h"

@class XZObjcIvarDescriptor, XZObjcMethodDescriptor, XZObjcPropertyDescriptor;

NS_ASSUME_NONNULL_BEGIN

/// 描述类的对象。
///
/// > 这不是一个线程安全的类。
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
@property (nonatomic, readonly) XZObjcTypeDescriptor *type;

/// 类实例变量。ivars
@property (nonatomic, copy, readonly) NSDictionary<NSString *, XZObjcIvarDescriptor *>     *ivars;

/// 在运行时更新了类的实例变量后，应调用此方法标记更新。
- (void)setNeedsUpdateIvars;

/// 类方法。 methods
@property (nonatomic, copy, readonly) NSDictionary<NSString *, XZObjcMethodDescriptor *>   *methods;

/// 在运行时更新了类的实例方法后，应调用此方法标记更新。
- (void)setNeedsUpdateMethods;

/// 类属性。 properties
@property (nonatomic, copy, readonly) NSDictionary<NSString *, XZObjcPropertyDescriptor *> *properties;

/// 在运行时更新了类的实例属性后，应调用此方法标记更新。
- (void)setNeedsUpdateProperties;

- (instancetype)init NS_UNAVAILABLE;

/// 获取类 aClass 的描述信息。
/// - Parameter aClass: 类
+ (nullable XZObjcClassDescriptor *)descriptorForClass:(nullable Class)aClass;

@end

NS_ASSUME_NONNULL_END
