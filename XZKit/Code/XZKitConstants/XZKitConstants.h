//
//  ObjectiveC.h
//  XZKit
//
//  Created by mlibai on 2018/4/14.
//  Copyright © 2018年 mlibai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 宏定义

/// 声明类不可以被继承。
#define XZ_SUBCLASSING_RESTRICTED __attribute__((objc_subclassing_restricted))
/// 定义类在运行时的名称。
#define XZ_RUNTIME_NAME(runtimeName) __attribute__((objc_runtime_name(runtimeName)))
/// 结构体可以用语法糖包裹成 NSValue 对象。
#define XZ_BOXABLE __attribute__((objc_boxable))
/// 声明函数为构造函数，在 main 函数执行前运行。
#define XZ_CONSTRUCTOR __attribute__((constructor))
/// 声明函数为构造函数，在 main 函数执行前运行，按优先级数字值从小到大依次执行。
#define XZ_CONSTRUCTOR_WITH_PRIORITY(priorityNumber) __attribute__((constructor(priorityNumber)))
/// 声明函数为析构函数，在 main 函数执行后运行。
#define XZ_DESTRUCTOR __attribute__((constructor))
/// 声明函数为析构函数，在 main 函数执行后运行，按优先级数字值从小到大依次执行。
#define XZ_DESTRUCTOR_WITH_PRIORITY(priorityNumber) __attribute__((constructor(priorityNumber)))
/// 编译器函数参数检查。
#define XZ_FUNCTION_PARAMETER_ASSERT(condition, message) __attribute__((enable_if(condition, message)))
/// 函数重载，放在函数末尾。
#define XZ_FUNCTION_OVERLOADABLE __attribute__((overloadable))
/// 变量观察者。当变量结束生命周期时，将自动执行指定的函数，该函数参数为指向被观察变量的指针。
/// @code
/// void observer(Int *anInt) { printf("%d", *anInt); }
/// Int someInt XZ_VARIABLE_OBSERVER(observer) = 0;
/// @endcode
#define XZ_VARIABLE_OBSERVER(anObserver) __attribute__((cleanup(anObserver)))




#pragma mark - 类型定义及常量
/// 当前是否为 DEBUG 模式，程序启动参数添加了 -XZKitDEBUG 参数。
FOUNDATION_EXTERN bool XZKitDebugMode NS_SWIFT_NAME(isDebugMode);
FOUNDATION_EXTERN void __XZKitLoadDebugMode(void) XZ_CONSTRUCTOR NS_UNAVAILABLE;

/// 字符串字符大小写样式。
///
/// - XZCharacterLowercase: 小写字符。
/// - XZCharacterUppercase: 大写字符。
typedef NS_ENUM(BOOL, XZCharacterCase) {
    XZCharacterLowercase = NO,
    XZCharacterUppercase = YES
} NS_SWIFT_NAME(CharacterCase);

#pragma mark - 函数

/// defer 闭包的执行函数，请不要直接调用此函数。
///
/// @param operation 待执行的清理操作。
FOUNDATION_EXPORT void __xz_defer__(void (^ _Nonnull * _Nonnull operation)(void)) NS_SWIFT_UNAVAILABLE("Use Swift.defer instead.");
/// 宏 defer 可以定义一个在当前作用域结束时需执行 block。
FOUNDATION_EXPORT void defer(void (^ _Nonnull operation)(void)) NS_SWIFT_UNAVAILABLE("Use Swift.defer instead.");
#undef defer
/// 连接两个宏参数。
#define __xz_defer_var_v__(X, Y) X##Y
/// 中转，将宏参数替换成宏代表的值。
#define __xz_defer_var_m__(X, Y) __xz_defer_var_v__(X, Y)
/// 定义当前作用域结束时需执行清理操作。
#define defer(statements) void(^__xz_defer_var_m__(__xz_defer_var_, __COUNTER__))(void) __attribute__((cleanup(__xz_defer__), unused)) = statements

/// 获取当前时间戳，精确到微秒。
/// @note 在 Swift 中，请使用 `TimeInterval.since1970` 代替。
///
/// @return 单位为秒，小数点后为微秒。
FOUNDATION_EXTERN NSTimeInterval xz_timestamp(void) NS_REFINED_FOR_SWIFT;
/// 输出信息到控制台，末尾自动换行。不附加任何其它信息。
///
/// @param format 输出格式。
/// @param ...    参数列表。
FOUNDATION_EXTERN void xz_print(NSString * _Nonnull format, ...) NS_FORMAT_FUNCTION(1, 2) NS_NO_TAIL_CALL NS_SWIFT_UNAVAILABLE("Use Swift.print instead.");
/// 输出信息到控制台，末尾自动换行。不附加任何其它信息。
///
/// @param format 输出格式。
/// @param args   参数列表指针。
FOUNDATION_EXTERN void xz_print_v(NSString * _Nonnull format, va_list _Nonnull args) NS_FORMAT_FUNCTION(1, 0) NS_NO_TAIL_CALL NS_SWIFT_UNAVAILABLE("Use Swift.print instead.");
/// 请使用 XZLog 代替本函数。控制台输出，同时附带 XZLogv 的引用文件、所在行数、所处方法名。
/// @note 仅在 XZDebugMode == YES 时输出。
/// @note 仅在程序添加了 -XZKitDEBUG 且在 DEBUG 模式下才执行控制台输出的函数，请自行实现，比如像如下定义 DLog 宏（为避免冲突 XZKit 不直接提供该宏）。
/// @code
/// #if DEBUG
/// FOUNDATION_EXTERN void DLog(NSString * _Nonnull format, ...) NS_SWIFT_UNAVAILABLE("Only for Objective-C.");
/// #undef DLog
/// #define DLog(format, ...) XZLogv(__FILE__, (int)__LINE__, __func__, format, ##__VA_ARGS__)
/// #else
/// #define DLog(...)
/// #endif
/// @endcode
FOUNDATION_EXTERN void XZLogv(const char * const filePath, int const line, const char * const function, NSString * const _Nonnull format, ...) NS_FORMAT_FUNCTION(4, 5) NS_SWIFT_UNAVAILABLE("Use Swift XZKit.XZLog instead.");
/// 控制台输出宏 XZLog 仅在程序添加了启动参数 -XZKitDEBUG 才执行控制台输出的函数。
FOUNDATION_EXTERN void XZLog(NSString * _Nonnull format, ...) NS_SWIFT_UNAVAILABLE("There is a copy implementation of XZLog for Swift.");
/// 没有说明
#undef XZLog
/// 如何说明。
#define XZLog(format, ...) XZLogv(__FILE__, (int)__LINE__, __func__, format, ##__VA_ARGS__)



NS_ASSUME_NONNULL_END



