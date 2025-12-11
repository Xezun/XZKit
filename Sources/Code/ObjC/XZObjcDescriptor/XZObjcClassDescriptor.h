//
//  XZObjcClassDescriptor.h
//  XZKit
//
//  Created by 徐臻 on 2025/1/26.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZObjcTypeDescriptor.h>
#else
#import "XZObjcTypeDescriptor.h"
#endif

@class XZObjcIvarDescriptor, XZObjcMethodDescriptor, XZObjcPropertyDescriptor;

NS_ASSUME_NONNULL_BEGIN

/// 当 Class 发生更新时，会发送此通知。
FOUNDATION_EXPORT NSNotificationName const XZObjcClassDidDidBecomeInvalidNotification;

/// 描述类的对象。
///
/// Class information for a class.
@interface XZObjcClassDescriptor : NSObject <XZObjcDescriptor>

/// 当前类，当前对象所描述的类。
@property (nonatomic, readonly) Class raw;
 
/// 描述当前类的超类的对象。
@property (readonly, nullable) XZObjcClassDescriptor *superDescriptor;

/// 类名。class name
@property (nonatomic, readonly) NSString *name;

/// 类的类型描述。
@property (nonatomic, readonly) XZObjcTypeDescriptor *type;

/// 类实例变量。ivars
@property (nonatomic, copy, readonly) NSDictionary<NSString *, XZObjcIvarDescriptor *> *ivars;

/// 类方法。 methods
@property (nonatomic, copy, readonly) NSDictionary<NSString *, XZObjcMethodDescriptor *> *methods;

/// 类属性。 properties
@property (nonatomic, copy, readonly) NSDictionary<NSString *, XZObjcPropertyDescriptor *> *properties;

- (void)invalidate;

@property (atomic, readonly) BOOL isValid;

- (instancetype)init NS_UNAVAILABLE;

/// 获取类 aClass 的描述信息。
///
/// 由于运行时类的信息可能会被修改，因此 XZObjcClassDescriptor 可能会失效，因此
///
/// > 返回值并非单例，已过期的 XZObjcClassDescriptor 会被释放，因此调用者需持有该对象。
///
/// - Parameter rawClass: 类
+ (nullable XZObjcClassDescriptor *)descriptorForClass:(nullable Class)rawClass NS_SWIFT_NAME(init(_:));

+ (void)invalidate:(Class)rawClass;

@end

NS_ASSUME_NONNULL_END
