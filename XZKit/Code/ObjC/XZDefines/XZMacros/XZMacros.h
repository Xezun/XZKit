//
//  XZMacros.h
//  XZKit
//
//  Created by Xezun on 2021/4/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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

/// 获取宏参数列表中的第 N 个参数，最多支持 9 个参数。
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
#define XZ_ATTR_INTERNAL                            __attribute__((visibility("hidden")))
/// 废弃声明
#define XZ_DEPRECATED(message, platforms, ...)      API_DEPRECATED(message, platforms, ##__VA_ARGS__)
/// 废弃声明：重命名
#define XZ_API_RENAMED(newName, platforms, ...)     API_DEPRECATED_WITH_REPLACEMENT(newName, platforms, ##__VA_ARGS__)

/// 仅对外部生效的标记
#ifdef XZ_FRAMEWORK
#define XZ_CONST
#define XZ_READONLY
#define XZ_UNAVAILABLE
#define XZ_PRIVATE
#else
#define XZ_CONST               const
#define XZ_READONLY            readonly
#define XZ_UNAVAILABLE         NS_UNAVAILABLE
#define XZ_PRIVATE             NS_UNAVAILABLE
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

/// 宏函数 `XZLog` 的实际调用的函数。请使用 `XZLog` 宏，而不是直接使用此函数。
///
/// 通过 NSLog 输出到控制台，如果待输出内容过大，则分批次输出，避免输出内容不完整。
///
/// ```objc
/// // 有大概 1017 的长度限制
/// NSLog(@"The message is %@", message);
/// // 似乎没有长度限制
/// NSLog(@"%@", [NSString stringWithFormat:@"The message is %@", message]);
/// ```
///
/// 实际使用 `NSLog` 进行输出，而不是 `printf` 等函数，以避免控制台日志互相嵌套的问题。
///
/// > 自 iOS 10 之后，有迹象表明 NSLog 底层已由 ASL 切换为 OSLog 框架，虽然官方没有明确说明。
///
/// - Parameters:
///   - file: 输入语句所在的文件名
///   - line: 输出语句所在的行数
///   - function: 输出语句所在的函数名
///   - format: 输出内容格式
FOUNDATION_EXPORT void XZLogv(const char *file, const int line, const char *function, NSString *format, ...) NS_FORMAT_FUNCTION(4,5) NS_SWIFT_UNAVAILABLE("Use #LOG instead");

/// 供 Swift 使用 NSLog 的函数。
FOUNDATION_EXPORT void __XZLogv__(NSString *file, NSInteger line, NSString *function, NSString *message) NS_SWIFT_NAME(XZLogv(_:_:_:_:));

/// 宏函数，控制台输出，实际调用 `NSLog` 完成输出，会额外输出语句所在的文件、行数、方法名，且如果待输出内容过大，则分批次输出，避免输出内容不完整。
///
/// - Parameter format: 格式化输出模版
FOUNDATION_EXTERN void XZLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2) NS_SWIFT_UNAVAILABLE("Use #LOG instead");


#if XZ_FRAMEWORK

#if XZ_DEBUG
#define XZLog(format, ...) XZLogv(__FILE_NAME__, __LINE__, __FUNCTION__, format, ##__VA_ARGS__)
#else
#define XZLog(...)
#endif

#else

#ifndef XZ_LOG
#if DEBUG && XZ_DEBUG
#define XZLog(format, ...) XZLogv(__FILE_NAME__, __LINE__, __FUNCTION__, format, ##__VA_ARGS__)
#else
#define XZLog(...)
#endif
#endif // XZ_LOG

#endif


#ifndef XZ_DISPATCH_MACROS
#define XZ_DISPATCH_MACROS 1

/// 请使用 `dispatch_queue/main/global_async/sync` 宏，此函数不可使用。
///
/// 简化在列队 queue 中调用块函数的书写方式。
///
/// 情形一：通常情况下，在 queue 在中执行 block 块函数的代码。
///
/// ```objc
/// dispatch_async(queue, ^{
///      block(NO);
/// });
/// ```
///
/// 情形二：假如 block 可能为 nil 的话，还需要加上 if 语句。
///
/// ```objc
/// if (block) {
///     dispatch_async(queue, ^{
///         block(NO);
///     });
/// }
/// ```
///
/// 通过 `dispatch_queue_macros` 宏函数，代码可以简化为如下格式。
///
/// ```objc
/// dispatch_queue_async(queue, block, NO);
/// ```
///
/// 宏函数 `dispatch_queue_macros` 会在调度列队前检查 `block` 是否为空值，如同上面“情形二”的做法一样。
///
/// 如果不需要对 `block` 判空时，比如在已经确定 `block` 为非空,或使用 `block` 字面量时，可以直接使用带 `_imp` 的宏函数。
///
/// ```objc
/// dispatch_queue_async_imp(queue, ^(BOOL finished) {
///     NSLog(@"do sth.");
/// }, NO);
/// ```
///
/// 主队列 mainQueue 和全局队列 globalQueue 的便利宏函数。
///
/// ```objc
/// dispatch_main_async(block, NO);
/// dispatch_global_async(QOS_CLASS_DEFAULT, block, NO);
/// ```
///
/// 宏函数 `dispatch_queue` 目前支持调度参数不超过 9 的 block 块函数。
///
/// 使用 `dispatch_queue_macros` 宏函数与常规写法是等价的，不存在性能损失。比如，
///
/// ```objc
/// dispatch_main_async_imp(^{
///     NSLog("do sth");
/// })
/// ```
///
/// 在宏展开后，就是如下写法。
///
/// ```objc
/// dispatch_async(dispatch_get_main_queue(), ^{
///     NSLog("do sth");
/// })
/// ```
///
/// 上面用的是 block 字面量，可以直接使用 `_imp` 版本。如果是不带 `_imp` 版本，则仅仅会多进行一步空值判断。
///
/// - Parameters:
///   - queue: 调度列队
///   - block: 块函数
FOUNDATION_EXPORT void dispatch_queue_macros(dispatch_queue_t queue, dispatch_block_t block, ...) NS_UNAVAILABLE;

#define __dispatch_queue_forward__(_00, _01, _02, _03, _04, _05, _06, _07, _08, _09, _10, ...) _10

#define __dispatch_queue_imp_0__(concurrency, queue, block)      xz_macro_paste(dispatch_, concurrency)(queue, block)
#define __dispatch_queue_imp_1__(concurrency, queue, block, ...) xz_macro_paste(dispatch_, concurrency)(queue, ^{ (block)(__VA_ARGS__); })

#define __dispatch_queue_imp__(concurrency, queue, block, ...) __dispatch_queue_forward__(10, ##__VA_ARGS__, \
__dispatch_queue_imp_1__, __dispatch_queue_imp_1__, __dispatch_queue_imp_1__, \
__dispatch_queue_imp_1__, __dispatch_queue_imp_1__, __dispatch_queue_imp_1__, \
__dispatch_queue_imp_1__, __dispatch_queue_imp_1__, __dispatch_queue_imp_1__, \
__dispatch_queue_imp_0__)(concurrency, queue, block, ##__VA_ARGS__)

#define dispatch_queue_async_imp(queue, block, ...)       __dispatch_queue_imp__(async, queue, block, ##__VA_ARGS__)
#define dispatch_queue_sync_imp(queue, block, ...)        __dispatch_queue_imp__(sync, queue, block, ##__VA_ARGS__)
#define dispatch_main_async_imp(block, ...)               __dispatch_queue_imp__(async, dispatch_get_main_queue(), block, ##__VA_ARGS__)
#define dispatch_main_sync_imp(block, ...)                __dispatch_queue_imp__(sync, dispatch_get_main_queue(), block, ##__VA_ARGS__)
#define dispatch_global_async_imp(QOS_CLASS_, block, ...) __dispatch_queue_imp__(async, dispatch_get_global_queue(QOS_CLASS_, 0), block, ##__VA_ARGS__)
#define dispatch_global_sync_imp(QOS_CLASS_, block, ...)  __dispatch_queue_imp__(sync, dispatch_get_global_queue(QOS_CLASS_, 0), block, ##__VA_ARGS__)

#define dispatch_queue_async(queue, block, ...)          { typeof(block) const handler = block; if (handler) { dispatch_queue_async_imp(queue, handler, ##__VA_ARGS__);         } }
#define dispatch_queue_sync(queue, block, ...)           { typeof(block) const handler = block; if (handler) { dispatch_queue_sync_imp(queue, handler, ##__VA_ARGS__);          } }
#define dispatch_main_async(block, ...)                  { typeof(block) const handler = block; if (handler) { dispatch_main_async_imp(handler, ##__VA_ARGS__);                 } }
#define dispatch_main_sync(block, ...)                   { typeof(block) const handler = block; if (handler) { dispatch_main_sync_imp(handler, ##__VA_ARGS__);                  } }
#define dispatch_global_async(QOS_CLASS_, block, ...)    { typeof(block) const handler = block; if (handler) { dispatch_global_async_imp(QOS_CLASS_, handler, ##__VA_ARGS__);   } }
#define dispatch_global_sync(QOS_CLASS_, block, ...)     { typeof(block) const handler = block; if (handler) { dispatch_global_sync_imp(QOS_CLASS_, handler, ##__VA_ARGS__);    } }

#endif

#ifndef XZ_OBJC_MESSAGE_MACROS
#define XZ_OBJC_MESSAGE_MACROS 1

/// 在 x86 架构上，返回值若为超过16字节的结构体，则必须使用 objc_msgSend_stret 函数来发送消息。
FOUNDATION_EXPORT void xz_objc_msgSend_stret(void);
/// 返回值为 float 类型的方法，需要调用此函数发送消息。
FOUNDATION_EXPORT void xz_objc_msgSend_ftret(void);
/// 返回值为 double 类型的方法，需要调用此函数发送消息。
FOUNDATION_EXPORT void xz_objc_msgSend_dbret(void);
/// 返回值为 long double 类型的方法，需要调用此函数发送消息。
FOUNDATION_EXPORT void xz_objc_msgSend_ldret(void);

#undef xz_objc_msgSend_stret
#undef xz_objc_msgSend_ftret
#undef xz_objc_msgSend_dbret
#undef xz_objc_msgSend_ldret

#if defined(__arm64__)
    #define xz_objc_msgSend_stret       objc_msgSend
    #define xz_objc_msgSendSuper_stret  objc_msgSendSuper
    #define xz_objc_msgSend_ftret       objc_msgSend
    #define xz_objc_msgSend_dbret       objc_msgSend
    #define xz_objc_msgSend_ldret       objc_msgSend
#elif defined(__x86_64__)
    #define xz_objc_msgSend_stret       objc_msgSend_stret
    #define xz_objc_msgSendSuper_stret  objc_msgSendSuper_stret
    #define xz_objc_msgSend_ftret       objc_msgSend
    #define xz_objc_msgSend_dbret       objc_msgSend
    #if TYPE_LONGDOUBLE_IS_DOUBLE
        #define xz_objc_msgSend_ldret   objc_msgSend
    #else
        #define xz_objc_msgSend_ldret   objc_msgSend_fpret
    #endif
#elif defined(__i386__)
    #define xz_objc_msgSend_stret       objc_msgSend_stret
    #define xz_objc_msgSendSuper_stret  objc_msgSendSuper_stret
    #define xz_objc_msgSend_ftret       objc_msgSend_fpret
    #define xz_objc_msgSend_dbret       objc_msgSend_fpret
    #define xz_objc_msgSend_ldret       objc_msgSend_fpret
#endif

#endif

NS_ASSUME_NONNULL_END
