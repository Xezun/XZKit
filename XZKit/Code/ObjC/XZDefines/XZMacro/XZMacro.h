//
//  XZMacro.h
//  XZKit
//
//  Created by Xezun on 2021/4/20.
//

#import <Foundation/Foundation.h>

#if DEBUG
// 空的 @autoreleasepool 不会被优化，只在 DEBUG 中使用。
#define xz_macro_keyize autoreleasepool {}
#else
// 空的 @try 在 5.x 的编译器中会被优化掉，但是会产生一条警告，所以只在 release 模式中使用。
#define xz_macro_keyize try {} @catch (...) {}
#endif

/// 连接两个参数
#define xz_macro_paste(A, B) __NSX_PASTE__(A, B)

#pragma mark - xz_macro_args_first

/// 获取参数列表中的第一个个参数。
#define xz_macro_args_first(...) xz_macro_args_first_imp(__VA_ARGS__, 0)
/// 宏 xz_macro_args_first 的实现。
#define xz_macro_args_first_imp(FIRST, ...) FIRST

#pragma mark - xz_macro_args_at

/// 获取宏参数列表中的第 N 个参数。
/// 宏 xz_macro_args_at 的实现：
/// 通过 xz_macro_paste 拼接 N 后，就变成下面对应的宏，
/// 由于 0 到 N - 1 之间的参数已占位，这样参数列表 ... 就是 N 及之后的参数，
/// 然后获取这个参数列表的第一个参数，即是原始参数列表的第 N 个参数。
#define xz_macro_args_at(N, ...)                                        xz_macro_paste(xz_macro_args_at_imp_, N)(__VA_ARGS__)
#define xz_macro_args_at_imp_0(...)                                     xz_macro_args_first(__VA_ARGS__)
#define xz_macro_args_at_imp_1(_1, ...)                                 xz_macro_args_first(__VA_ARGS__)
#define xz_macro_args_at_imp_2(_1, _2, ...)                             xz_macro_args_first(__VA_ARGS__)
#define xz_macro_args_at_imp_3(_1, _2, _3, ...)                         xz_macro_args_first(__VA_ARGS__)
#define xz_macro_args_at_imp_4(_1, _2, _3, _4, ...)                     xz_macro_args_first(__VA_ARGS__)
#define xz_macro_args_at_imp_5(_1, _2, _3, _4, _5, ...)                 xz_macro_args_first(__VA_ARGS__)
#define xz_macro_args_at_imp_6(_1, _2, _3, _4, _5, _6, ...)             xz_macro_args_first(__VA_ARGS__)
#define xz_macro_args_at_imp_7(_1, _2, _3, _4, _5, _6, _7, ...)         xz_macro_args_first(__VA_ARGS__)
#define xz_macro_args_at_imp_8(_1, _2, _3, _4, _5, _6, _7, _8, ...)     xz_macro_args_first(__VA_ARGS__)
#define xz_macro_args_at_imp_9(_1, _2, _3, _4, _5, _6, _7, _8, _9, ...) xz_macro_args_first(__VA_ARGS__)

#pragma mark - xz_macro_args_count

/// 获取参数列表中参数的个数（最多10个）。
/// 在参数列表后添加从 10 到 1 的数字，取得第 11 个元素，就是原始参数列表的个数。
#define xz_macro_args_count(...) xz_macro_args_at(9, __VA_ARGS__, 9, 8, 7, 6, 5, 4, 3, 2, 1)

#pragma mark - xz_macro_args_map

/// 遍历参数列表：对参数列表中的参数，逐个应用 MACRO(INDEX, ARG) 宏函数。
#define xz_macro_args_map(MACRO, SEP, ...)                  xz_macro_args_map_imp(xz_macro_args_map_ctx, SEP, MACRO, __VA_ARGS__)
#define xz_macro_args_map_imp(CONTEXT, SEP, MACRO, ...)     xz_macro_paste(xz_macro_args_map_imp_, xz_macro_args_count(__VA_ARGS__))(CONTEXT, SEP, MACRO, __VA_ARGS__)
#define xz_macro_args_map_ctx(INDEX, MACRO, ARG)            MACRO(INDEX, ARG)
#define xz_macro_args_map_imp_0(CONTEXT, SEP, MACRO)
#define xz_macro_args_map_imp_1(CONTEXT, SEP, MACRO, _0)                                                                                                                    CONTEXT(0, MACRO, _0)
#define xz_macro_args_map_imp_2(CONTEXT, SEP, MACRO, _0, _1)                                                         xz_macro_args_map_imp_1(CONTEXT, SEP, MACRO, _0)  SEP  CONTEXT(1, MACRO, _1)
#define xz_macro_args_map_imp_3(CONTEXT, SEP, MACRO, _0, _1, _2)                                                 xz_macro_args_map_imp_2(CONTEXT, SEP, MACRO, _0, _1)  SEP  CONTEXT(2, MACRO, _2)
#define xz_macro_args_map_imp_4(CONTEXT, SEP, MACRO, _0, _1, _2, _3)                                         xz_macro_args_map_imp_3(CONTEXT, SEP, MACRO, _0, _1, _2)  SEP  CONTEXT(3, MACRO, _3)
#define xz_macro_args_map_imp_5(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4)                                 xz_macro_args_map_imp_4(CONTEXT, SEP, MACRO, _0, _1, _2, _3)  SEP  CONTEXT(4, MACRO, _4)
#define xz_macro_args_map_imp_6(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5)                         xz_macro_args_map_imp_5(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4)  SEP  CONTEXT(5, MACRO, _5)
#define xz_macro_args_map_imp_7(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5, _6)                 xz_macro_args_map_imp_6(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5)  SEP  CONTEXT(6, MACRO, _6)
#define xz_macro_args_map_imp_8(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5, _6, _7)         xz_macro_args_map_imp_7(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5, _6)  SEP  CONTEXT(7, MACRO, _7)
#define xz_macro_args_map_imp_9(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5, _6, _7, _8) xz_macro_args_map_imp_8(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5, _6, _7)  SEP  CONTEXT(8, MACRO, _8)

#pragma mark - XZ_ATTR

/// 函数重载
#define XZ_ATTR_OVERLOAD                            __attribute__((overloadable))
/// 函数外部不可见
#define XZ_ATTR_INTERNAL                            __attribute__ ((visibility("hidden")))
/// 废弃声明
#define XZ_DEPRECATED(message, platforms, ...)      API_DEPRECATED(message, platforms, ##__VA_ARGS__)
/// 废弃声明：重命名
#define XZ_API_RENAMED(newName, platforms, ...)     API_DEPRECATED_WITH_REPLACEMENT(newName, platforms, ##__VA_ARGS__)

/// 仅对外部生效的标记
#ifdef XZ_FRAMEWORK
#define XZ_CONST
#define XZ_READONLY
#define XZ_UNAVAILABLE
#define XZ_PRIVATE_UNAVAILABLE
#else
#define XZ_CONST               const
#define XZ_READONLY            readonly
#define XZ_UNAVAILABLE         NS_UNAVAILABLE
#define XZ_PRIVATE_UNAVAILABLE NS_UNAVAILABLE
#endif

#pragma mark - enweak & deweak

#ifndef enweak
/// 弱引用编码：将变量进行弱引用编码，以准备在 block 中使用 `deweak` 解码后使用，避免循环引用。
/// @discussion
/// 由于 -ize 后缀 weakize/strongize 不能表明操作需配对使用，所以使用 en-、de- 表明操作必须配对使用的。
/// @discussion
/// 在 block 外，先对变量进行 enweak 编码；然后在 block 中，使用外部变量前，再对变量进行 deweak 解码。
/// @discussion
/// 编码不改变变量自身的引用属性，只是根据变量名，先进行编码，生成弱引用变量，然后在 block 中，再进行解码，生成名称相同的强引用变量。
/// @discussion
/// 编码不改变对象的引用计数。
/// @code
/// enweak(self);              // 将变量进行 weak 编码
/// dispatch_async(dispatch_get_main_queue(), ^{
///     deweak(self);          // 将变量进行 weak 解码
///     if (!self) return;
///     [self description];    // 此处的 self 为强引用，为 block 内局部变量，非捕获外部的变量
/// });
/// @endcode
/// @attention 必须搭配 `deweak` 一起使用。
FOUNDATION_EXPORT void enweak(id var, ...) NS_SWIFT_UNAVAILABLE("Use swift weak instead");
#undef enweak
#define enweak(...)                 xz_macro_args_map(__enweak_imp__, , __VA_ARGS__)
#define __enweak_imp__(INDEX, VAR)  __typeof__(VAR) __weak const xz_macro_paste(__xz_weak_, VAR) = (VAR);
#endif

#ifndef deweak
/// 弱引用解码：将 block 外使用 `enweak` 弱引用编码的外部变量，解码为 block 内的局部强引用变量使用，变量名不变。
/// @discussion 解码会增加引用计数，但可能为 nil 值，所以使用前应先判断。
/// @seealso 请查看 `enweak` 获取更多说明。
/// @attention 必须搭配 `enweak` 一起使用。
FOUNDATION_EXPORT void deweak(id var, ...) NS_SWIFT_UNAVAILABLE("Use swift weak instead");
#undef deweak
// 关于 typeof 的使用。
// typeof 会同时获取变量的 Nullability 标记：如果变量已经被 _Nonnull 标记，解码时再添加 _Nullable 标记会发生语法错误。
// typeof 会同时获取变量的 const 标记：编码后的弱引用变量，已经被 const 标记，解码时就不需要再添加 const 标记。
#define deweak(...)                                 \
_Pragma("clang diagnostic push")                    \
_Pragma("clang diagnostic ignored \"-Wshadow\"")    \
xz_macro_args_map(__deweak_imp__,, __VA_ARGS__)     \
_Pragma("clang diagnostic pop")
#define __deweak_imp__(INDEX, VAR)  __typeof__(xz_macro_paste(__xz_weak_, VAR)) __strong _Nullable VAR = xz_macro_paste(__xz_weak_, VAR);
#endif

#pragma mark - XZLog

#if XZ_FRAMEWORK

#if DEBUG
#define XZLog(format, ...) __xz_log_imp__(__FILE_NAME__, __LINE__, __FUNCTION__, format, ##__VA_ARGS__)
#else
#define XZLog(...)
#endif

#else // XZ_FRAMEWORK

#ifndef XZLog
#ifdef XZ_DEBUG
#define XZLog(format, ...) __xz_log_imp__(__FILE_NAME__, __LINE__, __FUNCTION__, format, ##__VA_ARGS__)
#else
#define XZLog(...)
#endif
#endif // => XZLog

#endif // XZ_FRAMEWORK

FOUNDATION_EXPORT void __xz_log_imp__(const char *file, const int line, const char *function, NSString *format, ...) NS_FORMAT_FUNCTION(4,5) NS_SWIFT_UNAVAILABLE("Use Swift.print instead");


// 关于重写 NSLog 的一点笔记
// stderr: 标准错误输出，立即输出到屏幕。
// stdout: 标准输出，当遇到刷新标志（比如换行）或缓冲满时，才把缓冲的数据输出到设备中。
// STDERR_FILENO: 与 stderr 相同
//
// 经过溯源原代码，在 CF-1153.18 源文件 CFUtilities.c 中可以找到 NSLog 函数的源码：
//     NSLog() => CFLog() => _CFLogvEx() => __CFLogCString() =>
//     #if DEPLOYMENT_TARGET_MACOSX || DEPLOYMENT_TARGET_EMBEDDED || DEPLOYMENT_TARGET_EMBEDDED_MINI
//         => writev(STDERR_FILENO)
//     #elif DEPLOYMENT_TARGET_WINDOWS
//         => fprintf_s(stderr)
//     #else
//         => fprintf(stderr)
//     #endif
// 而在 CFBundle_Resources.c 文件的 320-321 行
//     #elif DEPLOYMENT_TARGET_EMBEDDED || DEPLOYMENT_TARGET_EMBEDDED_MINI
//         return CFSTR("iPhoneOS");
// 所以在 iOS 平台，NSLog 最终使用的是 writev 函数输出日志，并且使用了 CFLock_t 保证线程安全。
// 而且函数 __CFLogCString() 是 static 局部函数，保证 writev 线程安全的 CFLock_t 锁也是局部的，
// 并不能被访问，而如果使用其它函数在控制台输出，就会不可避免出现与 NSLog 的输出内容互相嵌入的情况。
//
// 关于 NSLog 长度限制
// NSLog(@"The message is %@", message); // 有大概 1017 的长度限制 
// NSLog(@"%@", [NSString stringWithFormat:@"The message is：%@", message]); // 没有长度限制
//
