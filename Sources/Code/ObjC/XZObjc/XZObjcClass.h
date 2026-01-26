//
//  XZObjcClass.h
//  XZKit
//
//  Created by 徐臻 on 2025/1/26.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZObjcType.h>
#else
#import "XZObjcType.h"
#endif

@class XZObjcIvar, XZObjcMethod, XZObjcProperty;

NS_ASSUME_NONNULL_BEGIN

/// 当 Class 发生更新时，会发送此通知。
FOUNDATION_EXPORT NSNotificationName const XZObjcClassDidDidBecomeInvalidNotification;

/// 描述类的对象。
///
/// Class information for a class.
@interface XZObjcClass : NSObject

/// 当前类，当前对象所描述的类。
@property (nonatomic, readonly) Class raw;
 
/// 描述当前类的超类的对象。
@property (readonly, nullable) XZObjcClass *superClass;

/// 类名。class name
@property (nonatomic, readonly) NSString *name;

/// 类的类型描述。
@property (nonatomic, readonly) XZObjcType *type;

/// 类实例变量。ivars
@property (nonatomic, copy, readonly) NSDictionary<NSString *, XZObjcIvar *> *ivars;

/// 类方法。 methods
@property (nonatomic, copy, readonly) NSDictionary<NSString *, XZObjcMethod *> *methods;

/// 类属性。 properties
@property (nonatomic, copy, readonly) NSDictionary<NSString *, XZObjcProperty *> *properties;

- (void)invalidate;

@property (atomic, readonly) BOOL isValid;

- (instancetype)init NS_UNAVAILABLE;

/// 获取描述`rawClass`的对象。
///
/// 如果运行时修改了`Class`的信息，那么`XZObjcClass`对象可能会因失效而被释放，因此调用者需持有该对象。
///
/// - Parameter rawClass: 类
+ (nullable XZObjcClass *)classForClass:(nullable Class)rawClass NS_SWIFT_NAME(init(_:));

/// 使`rawClass`当前的描述对象失效。
/// - Parameter rawClass: 待失效描述对象
+ (void)invalidate:(Class)rawClass;

@end

NS_ASSUME_NONNULL_END
