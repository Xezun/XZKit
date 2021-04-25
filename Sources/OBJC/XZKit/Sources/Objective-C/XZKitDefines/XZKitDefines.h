//
//  XZKitDefines.h
//  XZKit
//
//  Created by Xezun on 2018/4/14.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XZKit/macro.h>

#ifndef XZKIT_DEFINES
#define XZKIT_DEFINES


#pragma mark - 宏定义

#ifndef XZ_CONST
#define XZ_CONST const
#endif

/// 标记属性或方法只提供给 ObjC
#define XZ_OBJC_ONLY NS_SWIFT_UNAVAILABLE("this API is designed for Objective-C only")


#pragma mark 编译器属性

/// XZ_ATTR 重命名了部分常用编译器 __attribute__ 属性定义（见下面的枚举）以方便使用。
/// @code
/// // 单个属性使用。
/// XZ_ATTR(XZ_ATTR_FINAL_CLASS)
/// // 多属性使用。
/// XZ_ATTR(XZ_ATTR_OBSERVER(func_obsv), XZ_ATTR_UNUSED)
/// @endcode
/// @see [Attributes in Clang](https://clang.llvm.org/docs/AttributeReference.html)
#define XZ_ATTR(attr, ...) __attribute__((attr, ##__VA_ARGS__))

/// XZ_ATTR 属性枚举，用法见 XZ_FINAL_CLASS 宏。
#define XZ_ATTR_FINAL_CLASS                 objc_subclassing_restricted
/// XZ_ATTR 属性枚举，用法见 XZ_RUNTIME 宏。
#define XZ_ATTR_RUNTIME(name)               objc_runtime_name(name)
/// XZ_ATTR 属性枚举，用法见 XZ_BOXABLE 宏。
#define XZ_ATTR_BOXABLE                     objc_boxable
/// XZ_ATTR 属性枚举，用法见 XZ_INIT 宏。
#define XZ_ATTR_INIT                        constructor
/// XZ_ATTR 属性枚举，用法见 XZ_INIT_AT 宏。
#define XZ_ATTR_INIT_AT(order)              constructor(order)
/// XZ_ATTR 属性枚举，用法见 XZ_DEINIT 宏。
#define XZ_ATTR_DEINIT                      destructor
/// XZ_ATTR 属性枚举，用法见 XZ_DEINIT_AT 宏。
#define XZ_ATTR_DEINIT_AT(order)            destructor(order)
/// XZ_ATTR 属性枚举，用法见 XZ_GUARD 宏。
#define XZ_ATTR_GUARD(condition, message)   enable_if(condition, message)
/// XZ_ATTR 属性枚举，用法见 XZ_OVERLOAD 宏。
#define XZ_ATTR_OVERLOAD                    overloadable
/// XZ_ATTR 属性枚举，用法见 XZ_OBSERVER 宏。
#define XZ_ATTR_OBSERVER(observer)          cleanup(observer)
/// XZ_ATTR 属性枚举，用法见 XZ_UNUSED 宏。
#define XZ_ATTR_UNUSED                      unused
/// XZ_ATTR 属性枚举，用法见 XZ_PACKED 宏。
#define XZ_ATTR_PACKED                      packed

/// 用于类声明，限制类不可以被继承。
/// @code
/// XZ_FINAL_CLASS
/// @interface FooBar : NSObject
/// @end
/// @endcode
#define XZ_FINAL_CLASS XZ_ATTR(XZ_ATTR_FINAL_CLASS)

/// 用于类或协议声明，指定其在运行时的名称。
/// @code
/// XZ_RUNTIME("Bar")
/// @interface Foo : NSObject
/// @end
/// @endcode
#define XZ_RUNTIME(name) XZ_ATTR(XZ_ATTR_RUNTIME(name))

/// 用于结构体声明，使其可以用语法糖 @(value) 包裹成 NSValue 对象。
/// @code
/// typedef struct XZ_BOXABLE Foo {
///     CGFloat bar;
/// } Foo;
/// @endcode
#define XZ_BOXABLE XZ_ATTR(XZ_ATTR_BOXABLE)

/// 声明函数为构造函数，在 main 函数执行前运行。
/// @code
/// void foo(NSInteger bar) XZ_INIT;
/// @endcode
#define XZ_INIT XZ_ATTR(XZ_ATTR_INIT)

/// 声明函数为构造函数，在 main 函数执行前运行，按优先级数字值从小到大依次执行。
/// @code
/// void foo1(NSInteger bar) XZ_INIT_AT(1);
/// void foo2(NSInteger bar) XZ_INIT_AT(2);
/// @endcode
#define XZ_INIT_AT(order) XZ_ATTR(XZ_ATTR_INIT_AT(order))

/// 声明函数为析构函数，在 main 函数执行后运行。
/// @code
/// void foo(NSInteger bar) XZ_DEINIT;
/// @endcode
#define XZ_DEINIT XZ_ATTR(XZ_ATTR_DEINIT)

/// 声明函数为析构函数，在 main 函数执行后运行，按优先级数字值从小到大依次执行。
/// @code
/// void foo1(NSInteger bar) XZ_DEINIT_AT(1);
/// void foo2(NSInteger bar) XZ_DEINIT_AT(2);
/// @endcode
#define XZ_DEINIT_AT(order) XZ_ATTR(XZ_ATTR_DEINIT_AT(order))

/// 编译器函数参数检查。
/// @code
/// void fooBar(NSInteger foo, NSInteger bar)
/// XZ_GUARD(foo > 2, "参数 foo 必须大于 2 ！")
/// XZ_GUARD(bar > 1, "参数 bar 必须大于 1 ！");
/// @endcode
#define XZ_GUARD(condition, message) XZ_ATTR(XZ_ATTR_GUARD(condition, message))

/// 函数重载，放在函数末尾。
#define XZ_OVERLOAD  XZ_ATTR(XZ_ATTR_OVERLOAD)

/// 变量观察者。当变量结束生命周期时，将自动执行指定的函数，该函数参数为指向被观察变量的指针。
/// @code
/// void observer(Int *anInt) {
///     printf("%d", *anInt);
/// }
/// void main() {
///     Int someInt XZ_OBSERVER(observer) = 0;
/// }
/// @endcode
#define XZ_OBSERVER(anObserver) XZ_ATTR(XZ_ATTR_OBSERVER(anObserver))

/// 未使用变量去警告
#define XZ_UNUSED XZ_ATTR(XZ_ATTR_UNUSED)

/// 设置结构体不字节对齐。
/// @code
/// struct Example {
/// int a;
/// id __unsafe_unretained b;
///} XZ_PACKED;
/// @endcode
#define XZ_PACKED XZ_ATTR(XZ_ATTR_PACKED)


// 编译版本
// __IPHONE_OS_VERSION_MIN_REQUIRED
// __IPHONE_OS_VERSION_MAX_ALLOWED
// __IPHONE_11_0

#endif


#ifndef enweak

/// @code
/// enweak(self);           // 将变量进行 weak 编码
/// dispatch_async(dispatch_get_main_queue(), ^{
///     deweak(self);       // 将变量进行 weak 解码
///     [self description]; // 此处的 self 为 strong，为 block 内局部变量，非捕获外部的变量
/// });
/// @endcode
/// 将变量进行 weak 编码，并且在之后的 block 中，可以通过 deweak(VAR) 解码出 VAR 变量以供使用，以避免循环引用。
/// @note 该方法不改变 VAR 自身的强、弱引用属性。
/// @note 该方法不改变 VAR 的引用计数。
/// @define enweak
/// @param VAR 变量
#define enweak(...) \
autoreleasepool { } \
macro_args_map(__enweak_imp__,, __VA_ARGS__)

/// 将变量进行 weak 解码，以便之后可以将变量 VAR 将作为强引用变量使用。
/// @note 该方法必须搭配 enweak 使用。
/// @note 在 block 中，该方法捕获的是 enweak 编码后的弱引用变量，即不捕获外部的 VAR 变量，不会造成循环引用。
/// @note 该方法必须在使用 VAR 变量之前使用。
/// @seealso enweak()
/// @define deweak
/// @param VAR 变量
#define deweak(...) \
autoreleasepool { } \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
macro_args_map(__deweak_imp__,, __VA_ARGS__) \
_Pragma("clang diagnostic pop")


#define __enweak_imp__(INDEX, VAR) __typeof__(VAR) __weak const macro_concat(__xz_weak_, VAR) = (VAR);
#define __deweak_imp__(INDEX, VAR) __typeof__(VAR) __strong const VAR = macro_concat(__xz_weak_, VAR);

#endif
