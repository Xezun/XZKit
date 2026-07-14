//
//  XZObjcClass.h
//  XZKit
//
//  Created by Xezun on 2025/1/26.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class XZObjcType, XZObjcIvar, XZObjcMethod, XZObjcProperty;

NS_ASSUME_NONNULL_BEGIN

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

- (instancetype)init NS_UNAVAILABLE;

/// 对原生 `Class` 类对象的封装。
///
/// - Parameter aClass: 原生 Class 类对象
+ (nullable XZObjcClass *)classWithClass:(nullable Class)aClass NS_SWIFT_NAME(init(_:));

@end

NS_ASSUME_NONNULL_END
