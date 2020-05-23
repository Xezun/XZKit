//
//  XZKitDefines.h
//  XZKit
//
//  Created by Xezun on 2018/4/14.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#ifndef XZKIT_DEFINES
#define XZKIT_DEFINES

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 宏定义

/// 用于类声明，限制类不可以被继承。
/// @code
/// XZ_OBJC_SUBCLASSING_RESTRICTED @interface FooBar : NSObject
/// @end
/// @endcode
#define XZ_OBJC_SUBCLASSING_RESTRICTED __attribute__((objc_subclassing_restricted))

/// 用于类或协议声明，指定其在运行时的名称。
/// @code
/// XZ_OBJC_RUNTIME_NAME("Bar") @interface Foo : NSObject
/// @end
/// @endcode
#define XZ_OBJC_RUNTIME_NAME(runtimeName) __attribute__((objc_runtime_name(runtimeName)))

/// 用于结构体声明，使其可以用语法糖 @(value) 包裹成 NSValue 对象。
/// @code
/// typedef struct XZ_OBJC_BOXABLE {
///     CGFloat bar;
/// } Foo;
/// @endcode
#define XZ_OBJC_BOXABLE __attribute__((objc_boxable))

/// 声明函数为构造函数，在 main 函数执行前运行。
/// @code
/// void foo(NSInteger bar) XZ_OBJC_CONSTRUCTOR;
/// @endcode
#define XZ_OBJC_CONSTRUCTOR __attribute__((constructor))

/// 声明函数为构造函数，在 main 函数执行前运行，按优先级数字值从小到大依次执行。
/// @code
/// void foo1(NSInteger bar) XZ_OBJC_CONSTRUCTOR_WITH_PRIORITY(1);
/// void foo2(NSInteger bar) XZ_OBJC_CONSTRUCTOR_WITH_PRIORITY(2);
/// @endcode
#define XZ_OBJC_CONSTRUCTOR_WITH_PRIORITY(priorityNumber) __attribute__((constructor(priorityNumber)))

/// 声明函数为析构函数，在 main 函数执行后运行。
/// @code
/// void foo(NSInteger bar) XZ_OBJC_DESTRUCTOR;
/// @endcode
#define XZ_OBJC_DESTRUCTOR __attribute__((constructor))

/// 声明函数为析构函数，在 main 函数执行后运行，按优先级数字值从小到大依次执行。
/// @code
/// void foo1(NSInteger bar) XZ_OBJC_DESTRUCTOR_WITH_PRIORITY(1);
/// void foo2(NSInteger bar) XZ_OBJC_DESTRUCTOR_WITH_PRIORITY(2);
/// @endcode
#define XZ_OBJC_DESTRUCTOR_WITH_PRIORITY(priorityNumber) __attribute__((constructor(priorityNumber)))

/// 编译器函数参数检查。
/// @code
/// void fooBar(NSInteger foo, NSInteger bar)
/// XZ_OBJC_FUNCTION_PARAMETER_ASSERT(foo > 2, "参数 foo 必须大于 2 ！")
/// XZ_OBJC_FUNCTION_PARAMETER_ASSERT(bar > 1, "参数 bar 必须大于 1 ！");
/// @endcode
#define XZ_OBJC_FUNCTION_PARAMETER_ASSERT(condition, message) __attribute__((enable_if(condition, message)))

/// 函数重载，放在函数末尾。
#define XZ_OBJC_FUNCTION_OVERLOADABLE __attribute__((overloadable))

/// 变量观察者。当变量结束生命周期时，将自动执行指定的函数，该函数参数为指向被观察变量的指针。
/// @code
/// void observer(Int *anInt) {
///     printf("%d", *anInt);
/// }
/// void main() {
///     Int someInt XZ_OBJC_VARIABLE_OBSERVER(observer) = 0;
/// }
/// @endcode
#define XZ_OBJC_VARIABLE_OBSERVER(anObserver) __attribute__((cleanup(anObserver)))


#pragma mark - 类型定义及常量

/// 当前是否为 DEBUG 模式，程序启动参数添加了 -XZKitDEBUG 参数。
#ifndef XZKIT_CONSTANTS_DEBUG_SUPPORTING
#define XZKIT_CONSTANTS_DEBUG_SUPPORTING
FOUNDATION_EXTERN bool const XZKitDebugMode NS_SWIFT_NAME(isDebugMode);
#endif

/// 字符串字符大小写样式。
/// - XZCharacterLowercase: 小写字符。
/// - XZCharacterUppercase: 大写字符。
typedef NS_ENUM(NSInteger, XZCharacterCase) {
    XZCharacterLowercase = 0,
    XZCharacterUppercase = 1
} NS_SWIFT_NAME(CharacterCase);


#pragma mark - defer

/// defer 闭包的执行函数，请不要直接调用此函数。
///
/// @param operation 待执行的清理操作。
FOUNDATION_EXPORT void __xz_defer_obsv__(void (^ _Nonnull * _Nonnull operation)(void)) NS_SWIFT_UNAVAILABLE("Use Swift.defer instead.");
/// 连接两个宏参数。
/// 中转，将宏参数替换成宏代表的值。
#define __xz_defer_impl__(L, S) void (^__NSX_PASTE__(__xz_defer_stmt_, L))(void) __attribute__((cleanup(__xz_defer_obsv__), unused)) = S
/// 定义当前作用域结束时需执行清理操作。
#define xz_defer(statements) __xz_defer_impl__(__COUNTER__, statements)

#ifndef defer
/// 使用 defer 封装的代码，不会立即执行，而是在运行至当前作用域结束时才执行。
/// 这在函数返回时，需要执行清理操作的逻辑中，特别是有多个返回分支的逻辑中非常有用，可以提前处理清理逻辑。
/// @param operation 需执行的代码。
/// @code
/// - (void)fooBar {
///     DataBase *db = [DataBase dataBase];
///     [db open:@"SELECT * FROM table"];
///     defer({
///         [db close]; // 本方法结束时，这句会被执行。
///     });
///     // more operations with the db.
/// }
/// @endcode
FOUNDATION_EXPORT void defer(void (^ _Nonnull operation)(void)) NS_SWIFT_UNAVAILABLE("Use Swift.defer instead.");
#undef defer
#define defer(statements) xz_defer(statements)
#endif


#pragma mark - timestamp

/// 获取当前时间戳，精确到微秒。
/// @note 在 Swift 中，请使用 `TimeInterval.since1970` 代替。
/// @return 单位为秒，小数点后为微秒。
FOUNDATION_EXTERN NSTimeInterval xz_timestamp(void) NS_REFINED_FOR_SWIFT;


#pragma mark - print

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

#undef XZLog
#define XZLog(format, ...) XZLogv(__FILE__, (int)__LINE__, __func__, format, ##__VA_ARGS__)


@interface NSObject (XZKitDefines)
+ (void)load;
@end

NS_ASSUME_NONNULL_END

#endif
