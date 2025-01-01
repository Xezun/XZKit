//
//  XZMacro.h
//  XZKit
//
//  Created by Xezun on 2021/4/21.
//

#import <Foundation/Foundation.h>

#ifndef XZ_MACRO
#define XZ_MACRO

#pragma mark - meta宏

/// @define 将两个符号粘贴在一起，成为一个符号。
#define XZ_META_PASTE(A, B) __NSX_PASTE__(A, B)

/// @define 获取参数列表中的第一个参数。
#define XZ_META_ARGS_FIRST(...) XZ_META_ARGS_FIRST_IMP(__VA_ARGS__, 0)
#define XZ_META_ARGS_FIRST_IMP(FIRST, ...) FIRST

/// @define 获取宏参数列表中的第 INDEX 位置的参数，从 0 开始计数。
#define XZ_META_ARGS_AT(INDEX, ...) XZ_META_PASTE(XZ_META_ARGS_AT, INDEX)(__VA_ARGS__)
#define XZ_META_ARGS_AT0(...)                                           XZ_META_ARGS_FIRST(__VA_ARGS__)
#define XZ_META_ARGS_AT1(_0, ...)                                       XZ_META_ARGS_FIRST(__VA_ARGS__)
#define XZ_META_ARGS_AT2(_0, _1, ...)                                   XZ_META_ARGS_FIRST(__VA_ARGS__)
#define XZ_META_ARGS_AT3(_0, _1, _2, ...)                               XZ_META_ARGS_FIRST(__VA_ARGS__)
#define XZ_META_ARGS_AT4(_0, _1, _2, _3, ...)                           XZ_META_ARGS_FIRST(__VA_ARGS__)
#define XZ_META_ARGS_AT5(_0, _1, _2, _3, _4, ...)                       XZ_META_ARGS_FIRST(__VA_ARGS__)
#define XZ_META_ARGS_AT6(_0, _1, _2, _3, _4, _5, ...)                   XZ_META_ARGS_FIRST(__VA_ARGS__)
#define XZ_META_ARGS_AT7(_0, _1, _2, _3, _4, _5, _6, ...)               XZ_META_ARGS_FIRST(__VA_ARGS__)
#define XZ_META_ARGS_AT8(_0, _1, _2, _3, _4, _5, _6, _7, ...)           XZ_META_ARGS_FIRST(__VA_ARGS__)
#define XZ_META_ARGS_AT9(_0, _1, _2, _3, _4, _5, _6, _7, _8, ...)       XZ_META_ARGS_FIRST(__VA_ARGS__)
#define XZ_META_ARGS_AT10(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, ...)  XZ_META_ARGS_FIRST(__VA_ARGS__)

/// @define 获取参数的个数（最多10个）。
#define XZ_META_ARGS_COUNT(...) XZ_META_ARGS_AT(10, ##__VA_ARGS__, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0)

/// @define 使用宏 MACRO(ARG, INDEX) 遍历参数列表，即对参数列表中的每一个参数，逐个应用 MACRO 宏函数。
#define XZ_META_ARGS_FORIN(MACRO, SEP, ...) XZ_META_ARGS_FORIN_IMP(XZ_META_ARGS_FORIN_CTX, MACRO, SEP, ##__VA_ARGS__)

#define XZ_META_ARGS_FORIN_CTX(MACRO, ARG, INDEX) MACRO(ARG, INDEX)

#define XZ_META_ARGS_FORIN_IMP(CONTEXT, MACRO, SEP, ...) \
XZ_META_PASTE(XZ_META_ARGS_FORIN_IMP, XZ_META_ARGS_COUNT(__VA_ARGS__))(CONTEXT, MACRO, SEP, ##__VA_ARGS__)

#define XZ_META_ARGS_FORIN_IMP0(CONTEXT, MACRO, SEP)

#define XZ_META_ARGS_FORIN_IMP1(CONTEXT, MACRO, SEP, _0) CONTEXT(MACRO, _0, 0)

#define XZ_META_ARGS_FORIN_IMP2(CONTEXT, MACRO, SEP, _0, _1) \
XZ_META_ARGS_FORIN_IMP1(CONTEXT, MACRO, SEP, _0) \
SEP \
CONTEXT(MACRO, _1, 1)

#define XZ_META_ARGS_FORIN_IMP3(CONTEXT, MACRO, SEP, _0, _1, _2) \
XZ_META_ARGS_FORIN_IMP2(CONTEXT, MACRO, SEP, _0, _1) \
SEP \
CONTEXT(MACRO, _2, 2)

#define XZ_META_ARGS_FORIN_IMP4(CONTEXT, MACRO, SEP, _0, _1, _2, _3) \
XZ_META_ARGS_FORIN_IMP3(CONTEXT, MACRO, SEP, _0, _1, _2) \
SEP \
CONTEXT(MACRO, _3, 3)

#define XZ_META_ARGS_FORIN_IMP5(CONTEXT, MACRO, SEP, _0, _1, _2, _3, _4) \
XZ_META_ARGS_FORIN_IMP4(CONTEXT, MACRO, SEP, _0, _1, _2, _3) \
SEP \
CONTEXT(MACRO, _4, 4)

#define XZ_META_ARGS_FORIN_IMP6(CONTEXT, MACRO, SEP, _0, _1, _2, _3, _4, _5) \
XZ_META_ARGS_FORIN_IMP5(CONTEXT, MACRO, SEP, _0, _1, _2, _3, _4) \
SEP \
CONTEXT(MACRO, _5, 5)

#define XZ_META_ARGS_FORIN_IMP7(CONTEXT, MACRO, SEP, _0, _1, _2, _3, _4, _5, _6) \
XZ_META_ARGS_FORIN_IMP6(CONTEXT, MACRO, SEP, _0, _1, _2, _3, _4, _5) \
SEP \
CONTEXT(MACRO, _6, 6)

#define XZ_META_ARGS_FORIN_IMP8(CONTEXT, MACRO, SEP, _0, _1, _2, _3, _4, _5, _6, _7) \
XZ_META_ARGS_FORIN_IMP7(CONTEXT, MACRO, SEP, _0, _1, _2, _3, _4, _5, _6) \
SEP \
CONTEXT(MACRO, _7, 7)

#define XZ_META_ARGS_FORIN_IMP9(CONTEXT, MACRO, SEP, _0, _1, _2, _3, _4, _5, _6, _7, _8) \
XZ_META_ARGS_FORIN_IMP8(CONTEXT, MACRO, SEP, _0, _1, _2, _3, _4, _5, _6, _7) \
SEP \
CONTEXT(MACRO, _8, 8)

#define XZ_META_ARGS_FORIN_IMP10(CONTEXT, MACRO, SEP, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9) \
XZ_META_ARGS_FORIN_IMP9(CONTEXT, MACRO, SEP, _0, _1, _2, _3, _4, _5, _6, _7, _8) \
SEP \
CONTEXT(MACRO, _9, 9)


#pragma mark - 关键字

/// @define
/// 宏 XZ_OBJC_KEYWORD 的作用是，使宏定义在使用时可以 @ 符号开头。
/// @discussion 1、空的 @autoreleasepool {} 不会被优化，只在 DEBUG 中使用。
/// @discussion 2、空的 @try {} 在 Xcode 5.x 以上版本中，会被编译器优化，但是会产生一条警告，所以只在 release 模式中使用。
#if DEBUG
#define XZ_OBJC_KEYWORD autoreleasepool {}
#else
#define XZ_OBJC_KEYWORD try {} @catch (...) {}
#endif

/// 标记属性或方法仅在 Objective-C 中可用（Swift中不可用）。
#define XZ_OBJC_ONLY NS_SWIFT_UNAVAILABLE("")


#pragma mark - 编译器属性

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
/// XZ_ATTR 属性枚举，用法见 XZ_OVERLOADABLE宏。
#define XZ_ATTR_OVERLOADABLE                overloadable
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
#define XZ_OVERLOADABLE XZ_ATTR(XZ_ATTR_OVERLOADABLE)

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

#ifndef enweak
/// @define enweak
/// 将变量进行 weak 编码，并且在之后的 block 中，可以通过 deweak(VAR) 解码出 VAR 变量以供使用，以避免循环引用。
/// @code
/// @enweak(self);           // 将变量进行 weak 编码
/// dispatch_async(dispatch_get_main_queue(), ^{
///     @deweak(self);       // 将变量进行 weak 解码
///     [self description];  // 此处的 self 为 strong，为 block 内局部变量，非捕获外部的变量
/// });
/// @endcode
/// @note 该方法不改变 VAR 自身的强、弱引用属性。
/// @note 该方法不改变 VAR 的引用计数。
/// @param VAR 变量
#define enweak(...) XZ_OBJC_KEYWORD XZ_META_ARGS_FORIN(__ENWEAK_IMP__, , __VA_ARGS__)
#define __ENWEAK_IMP__(VAR, INDEX) __typeof__(VAR) __weak const XZ_META_PASTE(__xm_weak_, VAR) = (VAR);
#endif /* enweak */

#ifndef deweak
/// @define deweak
/// 将变量进行 weak 解码，以便之后可以将变量将作为强引用变量使用。
/// @note 该方法必须搭配 @enweak 使用。
/// @note 在 block 中，该方法捕获的是 enweak 编码后的弱引用变量，即不捕获外部的 VAR 变量，不会造成循环引用。
/// @note 该方法必须在使用 VAR 变量之前使用。
/// @seealso @enweak()
/// @param VAR 变量
#define deweak(...) XZ_OBJC_KEYWORD \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
XZ_META_ARGS_FORIN(__DEWEAK_IMP__, , __VA_ARGS__) \
_Pragma("clang diagnostic pop")
#define __DEWEAK_IMP__(VAR, INDEX) __typeof__(VAR) __strong const VAR = XZ_META_PASTE(__xm_weak_, VAR);
#endif /* deweak */

#define XZ_XCODE_9_0     90000
#define XZ_XCODE_10_0   100000
#define XZ_XCODE_11_0   110000
#define XZ_XCODE_12_0   120000
#define XZ_XCODE_12_1   120100
#define XZ_XCODE_12_2   120200
#define XZ_XCODE_12_3   120300
#define XZ_XCODE_12_4   120400
#define XZ_XCODE_12_5   120500

// Xcode 版本
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_14_5
#define XZ_XCODE_VERSION  XZ_XCODE_12_5
#elif __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_14_4
#define XZ_XCODE_VERSION  XZ_XCODE_12_4
#elif __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_14_3
#define XZ_XCODE_VERSION  XZ_XCODE_12_3
#elif __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_14_2
#define XZ_XCODE_VERSION  XZ_XCODE_12_2
#elif __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_14_1
#define XZ_XCODE_VERSION  XZ_XCODE_12_1
#elif __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_14_0
#define XZ_XCODE_VERSION  XZ_XCODE_12_0
#elif __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0
#define XZ_XCODE_VERSION  XZ_XCODE_11_0
#elif __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_12_0
#define XZ_XCODE_VERSION  XZ_XCODE_10_0
#elif __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
#define XZ_XCODE_VERSION  XZ_XCODE_9_0
#else
// XZ_XCODE_VERSION is not defined.
#endif
#if __IPHONE_OS_VERSION_MIN_REQUIRED
#endif

#endif /* XZ_MACRO */
