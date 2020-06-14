//
//  XZKitRuntime.h
//  XZKit
//
//  Created by Xezun on 2019/3/27.
//  Copyright © 2019 XEZUN INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XZKit/XZKitDefines.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

/// 构造一个与指定类名称相似的新类名。如 XZKit.NSObject.1、XZKit.NSObject.2 等。
/// @note 该函数在 XZKit 动态拓展系统类时使用。
///
/// @param existedClass 以此类名作为前缀。
/// @return 新的类名。
FOUNDATION_EXTERN NSString *xz_objc_class_name_create(Class existedClass) NS_SWIFT_NAME(objc_class_name_create(_:)) XZ_OBJC_FUNCTION_OVERLOADABLE;

/// 以指定名字为基础，构造一个唯一的类名称。
/// @note 用于动态构造已有类的子类来替换现有的类。
///
/// @param classNameBase 原始类名称。
/// @return 新的类名称。
FOUNDATION_EXTERN NSString *xz_objc_class_name_create(NSString * classNameBase) NS_SWIFT_NAME(objc_class_name_create(_:)) XZ_OBJC_FUNCTION_OVERLOADABLE;

/// 将指定类的 方法1 与 方法2 的方法体互换。
/// @note 如果 方法1 不存在（包括继承自父类但是没有重写的方法），则给类增加一个与方法2相同方法体的方法。
///
/// @param aClass 需要替换方法体的类。
/// @param selector1 待交换方法体的方法。
/// @param selector2 被交换方法体的方法。
FOUNDATION_EXTERN void xz_objc_class_exchangeMethodImplementations(Class aClass, SEL selector1, SEL selector2) NS_SWIFT_NAME(objc_class_exchangeMethodImplementations(_:_:_:));

/// 遍历类实例对象的变量。
///
/// @param aClass 类。
/// @param block 遍历所用的 block 。
FOUNDATION_EXTERN void xz_objc_class_enumerateInstanceVariables(Class aClass, void (^block)(Ivar ivar)) NS_SWIFT_NAME(objc_class_enumerateInstanceVariables(_:_:));

/// 获取类实例对象的变量名。
///
/// @param aClass 类。
FOUNDATION_EXTERN NSArray<NSString *> * _Nullable xz_objc_class_getInstanceVariableNames(Class aClass) NS_SWIFT_NAME(objc_class_getInstanceVariableNames(_:));

/// 遍历类实例对象的方法，不包括父类的方法。
///
/// @param aClass 类。
/// @param block 遍历所用的 block 。
FOUNDATION_EXTERN void xz_objc_class_enumerateInstanceMethods(Class aClass, void (^block)(Method method)) NS_SWIFT_NAME(objc_class_enumerateInstanceMethods(_:_:));

/// 获取类实例对象的方法名。
///
/// @param aClass 类。
FOUNDATION_EXTERN NSArray<NSString *> * _Nullable xz_objc_class_getInstanceMethodSelectors(Class aClass) NS_SWIFT_NAME(objc_class_getInstanceMethodSelectors(_:));

NS_ASSUME_NONNULL_END
