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
/// > 懒加载，可通过设置 nil 然后获取重新生成。
@property (nonatomic, copy, readonly) NSDictionary<NSString *, XZObjcIvarDescriptor *>     *ivars;
- (void)setNeedsUpdateIvars;
/// 类方法。 methods
/// > 懒加载，可通过设置 nil 然后获取重新生成。
@property (nonatomic, copy, readonly) NSDictionary<NSString *, XZObjcMethodDescriptor *>   *methods;
- (void)setNeedsUpdateMethods;
/// 类属性。 properties
/// > 懒加载，可通过设置 nil 然后获取重新生成。
@property (nonatomic, copy, readonly) NSDictionary<NSString *, XZObjcPropertyDescriptor *> *properties;
- (void)setNeedsUpdateProperties;

- (instancetype)init NS_UNAVAILABLE;

/// 获取类 aClass 的描述信息。
/// - Parameter aClass: 类
+ (nullable XZObjcClassDescriptor *)descriptorForClass:(nullable Class)aClass;

@end

NS_ASSUME_NONNULL_END
