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
/// Class information for a class.
@interface XZObjcClassDescriptor : NSObject <XZObjcDescriptor>

/// 当前类，当前对象所描述的类。
@property (nonatomic, readonly) Class raw;
/// 描述当前类的超类的对象。
@property (nonatomic, readonly, nullable) XZObjcClassDescriptor *super;

/// 类名。class name
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) XZObjcTypeDescriptor *type;

/// 类实例变量。 ivars
@property (nonatomic, strong, readonly) NSDictionary<NSString *, XZObjcIvarDescriptor *>     *ivars;
/// 类方法。 methods
@property (nonatomic, strong, readonly) NSDictionary<NSString *, XZObjcMethodDescriptor *>   *methods;
/// 类属性。 properties
@property (nonatomic, strong, readonly) NSDictionary<NSString *, XZObjcPropertyDescriptor *> *properties;

- (instancetype)init NS_UNAVAILABLE;

/// 当前描述是否有效。
///
/// > 为了提高效率，不会为基类和元类创建描述对象。
///
/// If this method returns `YES`, you should stop using this instance and call
/// `classInfoWithClass` or `classInfoWithClassName` to get the updated class info.
@property (nonatomic, readonly) BOOL needsUpdate;

/// 如果在运行时修改了类的信息，应该调用此方法，标记描述对象已失效。
///
/// If the class is changed (for example: you add a method to this class with
/// `class_addMethod()`), you should call this method to refresh the class info cache.
///
/// After called this method, `needsUpdate` will returns `YES`, and you should call
/// `classInfoWithClass` or `classInfoWithClassName` to get the updated class info.
- (void)setNeedsUpdate;

/// 更新类信息，重新生成 `ivars`、`methods`、`properties` 信息。
- (void)updateIfNeeded;

/// 获取类 aClass 的描述信息。
/// - Parameter aClass: 类
+ (nullable XZObjcClassDescriptor *)descriptorForClass:(nullable Class)aClass;

@end

NS_ASSUME_NONNULL_END
