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
#define __XZX_KEYIZE__ autoreleasepool {}
#else
// 空的 @try 在 5.x 的编译器中会被优化掉，但是会产生一条警告，所以只在 release 模式中使用。
#define __XZX_KEYIZE__ try {} @catch (...) {}
#endif

/// 连接两个参数
#define __XZX_PASTE__(A, B) __NSX_PASTE__(A, B)

#pragma mark -  __XZX_ARGS_MAP__

/// 获取参数列表中的第一个参数。参数列表为空，结果也为空。
#define __XZX_ARGS_FIRST__(...)             __XZX_ARGS_FIRST_IMP__(__VA_ARGS__, 0)
#define __XZX_ARGS_FIRST_IMP__(FIRST, ...)  FIRST

/// 获取宏参数列表中的第 N 个参数，最多支持 10 个参数，即 `N ∈ [0, 9]` 。
/// 将 0 到 N - 1 位置上的参数占位，剩下参数的 `__VA_ARGS__` 参数列表的首位，就是获取第 N 位置上的参数。
#define __XZX_ARGS_AT__(N, ...)                                          __XZX_PASTE__(__XZX_ARGS_AT_IMP_, N)(__VA_ARGS__)
#define __XZX_ARGS_AT_IMP_0(...)                                         __XZX_ARGS_FIRST__(__VA_ARGS__)
#define __XZX_ARGS_AT_IMP_1(_0, ...)                                     __XZX_ARGS_FIRST__(__VA_ARGS__)
#define __XZX_ARGS_AT_IMP_2(_0, _1, ...)                                 __XZX_ARGS_FIRST__(__VA_ARGS__)
#define __XZX_ARGS_AT_IMP_3(_0, _1, _2, ...)                             __XZX_ARGS_FIRST__(__VA_ARGS__)
#define __XZX_ARGS_AT_IMP_4(_0, _1, _2, _3, ...)                         __XZX_ARGS_FIRST__(__VA_ARGS__)
#define __XZX_ARGS_AT_IMP_5(_0, _1, _2, _3, _4, ...)                     __XZX_ARGS_FIRST__(__VA_ARGS__)
#define __XZX_ARGS_AT_IMP_6(_0, _1, _2, _3, _4, _5, ...)                 __XZX_ARGS_FIRST__(__VA_ARGS__)
#define __XZX_ARGS_AT_IMP_7(_0, _1, _2, _3, _4, _5, _6, ...)             __XZX_ARGS_FIRST__(__VA_ARGS__)
#define __XZX_ARGS_AT_IMP_8(_0, _1, _2, _3, _4, _5, _6, _7, ...)         __XZX_ARGS_FIRST__(__VA_ARGS__)
#define __XZX_ARGS_AT_IMP_9(_0, _1, _2, _3, _4, _5, _6, _7, _8, ...)     __XZX_ARGS_FIRST__(__VA_ARGS__)
#define __XZX_ARGS_AT_IMP_10(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, ...) __XZX_ARGS_FIRST__(__VA_ARGS__)

/// 获取参数列表中参数的个数（最多 9 个）。
#define __XZX_ARGS_COUNT__(...) __XZX_ARGS_AT__(9, ##__VA_ARGS__, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0)

/// 遍历参数列表：对参数列表中的参数，逐个应用 MACRO(INDEX, ARG) 宏函数。参数列表，最多支持 9 个参数。
#define __XZX_ARGS_MAP__(MACRO, SEP, ...)                                                 __XZX_ARGS_MAP_IMP__(__XZX_ARGS_MAP_CTX__, SEP, MACRO, __VA_ARGS__)
#define __XZX_ARGS_MAP_CTX__(INDEX, MACRO, ARG)                                           MACRO(INDEX, ARG)
#define __XZX_ARGS_MAP_IMP__(CONTEXT, SEP, MACRO, ...)                                    __XZX_PASTE__(__XZX_ARGS_MAP_IMP_, __XZX_ARGS_COUNT__(__VA_ARGS__))(CONTEXT, SEP, MACRO, __VA_ARGS__)
#define __XZX_ARGS_MAP_IMP_0(CONTEXT, SEP, MACRO)
#define __XZX_ARGS_MAP_IMP_1(CONTEXT, SEP, MACRO, _0)                                     CONTEXT(0, MACRO, _0)
#define __XZX_ARGS_MAP_IMP_2(CONTEXT, SEP, MACRO, _0, _1)                                 __XZX_ARGS_MAP_IMP_1(CONTEXT, SEP, MACRO, _0)  SEP  CONTEXT(1, MACRO, _1)
#define __XZX_ARGS_MAP_IMP_3(CONTEXT, SEP, MACRO, _0, _1, _2)                             __XZX_ARGS_MAP_IMP_2(CONTEXT, SEP, MACRO, _0, _1)  SEP  CONTEXT(2, MACRO, _2)
#define __XZX_ARGS_MAP_IMP_4(CONTEXT, SEP, MACRO, _0, _1, _2, _3)                         __XZX_ARGS_MAP_IMP_3(CONTEXT, SEP, MACRO, _0, _1, _2)  SEP  CONTEXT(3, MACRO, _3)
#define __XZX_ARGS_MAP_IMP_5(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4)                     __XZX_ARGS_MAP_IMP_4(CONTEXT, SEP, MACRO, _0, _1, _2, _3)  SEP  CONTEXT(4, MACRO, _4)
#define __XZX_ARGS_MAP_IMP_6(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5)                 __XZX_ARGS_MAP_IMP_5(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4)  SEP  CONTEXT(5, MACRO, _5)
#define __XZX_ARGS_MAP_IMP_7(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5, _6)             __XZX_ARGS_MAP_IMP_6(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5)  SEP  CONTEXT(6, MACRO, _6)
#define __XZX_ARGS_MAP_IMP_8(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5, _6, _7)         __XZX_ARGS_MAP_IMP_7(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5, _6)  SEP  CONTEXT(7, MACRO, _7)
#define __XZX_ARGS_MAP_IMP_9(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5, _6, _7, _8)     __XZX_ARGS_MAP_IMP_8(CONTEXT, SEP, MACRO, _0, _1, _2, _3, _4, _5, _6, _7)  SEP  CONTEXT(8, MACRO, _8)

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

#pragma mark - @enweak & @deweak

#ifndef enweak
#ifndef deweak
/// ### 弱引用的编码与解码
///
/// 在 block 中，通常需要使用 `__weak` 来捕获外部变量，以避免内存泄漏，因此提供了 `@enweak` 和 `@deweak` 宏，以便可以更方便快捷的实现这一操作。
///
/// ```objc
/// @enweak(self);              // 将变量进行 weak 编码
/// dispatch_async(dispatch_get_main_queue(), ^{
///     @deweak(self);          // 将变量进行 weak 解码
///     if (!self) return;      // 从弱引用取出值，使用前需检查是否位空
///     [self description];     // 此处的 self 为强引用，为 block 内局部变量，非捕获外部的变量
/// });
/// ```
///
/// 在 block 外，先使用 `@enweak` 先对变量进行弱引用编码；然后在 block 中，使用外部变量前，再对变量进行 `@deweak` 弱引用解码。
///
/// > 关于命名：由于 -ize 后缀 weakize/strongize 不能表明操作需配对使用，所以使用 en-、de- 表明操作必须配对使用的。
/// 
/// 编码不改变变量自身的引用属性，只是根据变量名，先进行编码，生成弱引用变量，然后在 block 中，再进行解码，生成名称相同的强引用变量。
///
/// 编码不改变对象的引用计数。
///
/// - Attention: 须搭配 `\@deweak` 一起使用。
///
#define enweak(...)                 __XZX_KEYIZE__ __XZX_ARGS_MAP__(__enweak_imp__, , __VA_ARGS__)
#define __enweak_imp__(INDEX, VAR)  __typeof__(VAR) __weak const __XZX_PASTE__(__xz_weak_, VAR) = (VAR);

/// 弱引用解码：将 block 外使用 `@enweak` 弱引用编码的外部变量，解码为 block 内的局部强引用变量使用，变量名不变。
/// @discussion 解码会增加引用计数，但可能为 nil 值，所以使用前应先判断。
/// @seealso 请查看 `@enweak` 获取更多说明。
/// @attention 必须搭配 `@enweak` 一起使用。
FOUNDATION_EXPORT void deweak(id var, ...) NS_SWIFT_UNAVAILABLE("Use swift weak instead");
#undef deweak
// 关于 typeof 的使用。
// typeof 会同时获取变量的 Nullability 标记：如果变量已经被 _Nonnull 标记，解码时再添加 _Nullable 标记会发生语法错误。
// typeof 会同时获取变量的 const 标记：编码后的弱引用变量，已经被 const 标记，解码时就不需要再添加 const 标记。
#define deweak(...)                                 \
_Pragma("clang diagnostic push")                    \
_Pragma("clang diagnostic ignored \"-Wshadow\"")    \
__XZX_KEYIZE__ __XZX_ARGS_MAP__(__deweak_imp__, , __VA_ARGS__)     \
_Pragma("clang diagnostic pop")
#define __deweak_imp__(INDEX, VAR)  __typeof__(__XZX_PASTE__(__xz_weak_, VAR)) __strong _Nullable VAR = __XZX_PASTE__(__xz_weak_, VAR);

#endif
#endif

#ifndef XZ_DISPATCH_MACROS
#define XZ_DISPATCH_MACROS 1

/// # `dispatch_queue_macros` 系列宏函数
///
/// 简化在列队 queue 中调用块函数的书写方式。
///
/// > 宏函数 `dispatch_queue` 目前支持调度参数不超过 9 的 block 块函数。
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
/// 主队列 mainQueue 和全局队列 globalQueue 的便利宏函数。
///
/// ```objc
/// dispatch_main_async(block, NO);
/// dispatch_global_async(QOS_CLASS_DEFAULT, block, NO);
/// ```
///
/// 宏函数 `dispatch_queue_macros` 会在调度列队前检查 `block` 是否为空值，如同上面“情形二”的做法一样。
///
/// 直接使用 `block` 字面量时，或已经确定 `block` 为非空，不需要对 `block` 判空时，使用前缀与原生的相同的 `dispatch_macros` 宏。
///
/// 使用 `dispatch_macros` 宏函数与常规写法是等价的，不存在性能损失。比如，
///
/// ```objc
/// dispatch_async_main(^{
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

// 以下函数是给编译器补全代码用，并不是真正的函数，会被宏替代为真正的代码。

/// 在指定队列 queue 异步调度已确定非空的块函数。
/// - Parameters:
///   - queue: 队列
///   - block: 任意类型的块函数
FOUNDATION_EXPORT void dispatch_async_queue(dispatch_queue_t queue, dispatch_block_t block, ...) NS_SWIFT_UNAVAILABLE("");
/// 在指定队列 queue 同步调度已确定非空的块函数。
/// - Parameters:
///   - queue: 队列
///   - block: 任意类型的块函数
FOUNDATION_EXPORT void dispatch_sync_queue(dispatch_queue_t queue, dispatch_block_t block, ...) NS_SWIFT_UNAVAILABLE("");
/// 在 main 主队列异步调度已确定非空的块函数。
/// - Parameter block: 任意类型的块函数
FOUNDATION_EXPORT void dispatch_async_main(dispatch_block_t block, ...) NS_SWIFT_UNAVAILABLE("");
/// 在 main 主队列同步调度已确定非空的块函数。
/// - Parameter block: 任意类型的块函数
FOUNDATION_EXPORT void dispatch_sync_main(dispatch_block_t block, ...) NS_SWIFT_UNAVAILABLE("");
/// 在 global 全局队列异步调度已确定非空的块函数。
/// - Parameters:
///   - QOS_CLASS: 队列优先级
///   - block: 任意类型的块函数
FOUNDATION_EXPORT void dispatch_async_global(intptr_t QOS_CLASS, dispatch_block_t block, ...) NS_SWIFT_UNAVAILABLE("");
/// 在 global 全局队列同步调度已确定非空的块函数。
/// - Parameters:
///   - QOS_CLASS: 队列优先级
///   - block: 任意类型的块函数
FOUNDATION_EXPORT void dispatch_sync_global(intptr_t QOS_CLASS, dispatch_block_t block, ...) NS_SWIFT_UNAVAILABLE("");

#undef dispatch_async_queue
#undef dispatch_sync_queue
#undef dispatch_async_main
#undef dispatch_sync_main
#undef dispatch_async_global
#undef dispatch_sync_global

/// 仅在 block 块函数非空时，才在队列 queue 中异步调度它。
/// - Parameters:
///   - queue: 队列
///   - block: 任意类型的块函数
FOUNDATION_EXPORT void dispatch_queue_async(dispatch_queue_t queue, id block, ...) NS_SWIFT_UNAVAILABLE("");
/// 仅在 block 块函数非空时，才在队列 queue 中同步调度它。
/// - Parameters:
///   - queue: 队列
///   - block: 任意类型的块函数
FOUNDATION_EXPORT void dispatch_queue_sync(dispatch_queue_t queue, id block, ...) NS_SWIFT_UNAVAILABLE("");
/// 仅在 block 块函数非空时，才在主队列中异步调度它。
/// - Parameter block: 任意类型的块函数
FOUNDATION_EXPORT void dispatch_main_async(id block, ...) NS_SWIFT_UNAVAILABLE("");
/// 仅在 block 块函数非空时，才在主队列中同步调度它。
/// - Parameter block: 任意类型的块函数
FOUNDATION_EXPORT void dispatch_main_sync(id block, ...) NS_SWIFT_UNAVAILABLE("");
/// 仅在 block 块函数非空时，才在全局队列中异步调度它。
/// - Parameters:
///   - QOS_CLASS: 队列优先级
///   - block: 任意类型的块函数
FOUNDATION_EXPORT void dispatch_global_async(intptr_t QOS_CLASS, id block, ...) NS_SWIFT_UNAVAILABLE("");
/// 仅在 block 块函数非空时，才在全局队列中同步调度它。
/// - Parameters:
///   - QOS_CLASS: 队列优先级
///   - block: 任意类型的块函数   
FOUNDATION_EXPORT void dispatch_global_sync(intptr_t QOS_CLASS, id block, ...) NS_SWIFT_UNAVAILABLE("");

#undef dispatch_queue_async
#undef dispatch_queue_sync
#undef dispatch_main_async
#undef dispatch_main_sync
#undef dispatch_global_async
#undef dispatch_global_sync

#define __dispatch_queue_macros_forwarding__(_X, _9, _8, _7, _6, _5, _4, _3, _2, _1, _0, ...) _0

#define __dispatch_queue_macros_imp_0(concurrency, queue, block)      __XZX_PASTE__(dispatch_, concurrency)(queue, block)
#define __dispatch_queue_macros_imp_n(concurrency, queue, block, ...) __XZX_PASTE__(dispatch_, concurrency)(queue, ^{ (block)(__VA_ARGS__); })

#define __dispatch_queue_macros_imp__(concurrency, queue, block, ...)   __dispatch_queue_macros_forwarding__(\
    10, ##__VA_ARGS__, \
    __dispatch_queue_macros_imp_n, __dispatch_queue_macros_imp_n, __dispatch_queue_macros_imp_n, \
    __dispatch_queue_macros_imp_n, __dispatch_queue_macros_imp_n, __dispatch_queue_macros_imp_n, \
    __dispatch_queue_macros_imp_n, __dispatch_queue_macros_imp_n, __dispatch_queue_macros_imp_n, \
    __dispatch_queue_macros_imp_0 \
)(concurrency, queue, block, ##__VA_ARGS__)

#define dispatch_async_queue(queue, block, ...)          __dispatch_queue_macros_imp__(async, queue, block, ##__VA_ARGS__)
#define dispatch_sync_queue(queue, block, ...)           __dispatch_queue_macros_imp__(sync, queue, block, ##__VA_ARGS__)
#define dispatch_async_main(block, ...)                  __dispatch_queue_macros_imp__(async, dispatch_get_main_queue(), block, ##__VA_ARGS__)
#define dispatch_sync_main(block, ...)                   __dispatch_queue_macros_imp__(sync, dispatch_get_main_queue(), block, ##__VA_ARGS__)
#define dispatch_async_global(QOS_CLASS, block, ...)     __dispatch_queue_macros_imp__(async, dispatch_get_global_queue(QOS_CLASS, 0), block, ##__VA_ARGS__)
#define dispatch_sync_global(QOS_CLASS, block, ...)      __dispatch_queue_macros_imp__(sync, dispatch_get_global_queue(QOS_CLASS, 0), block, ##__VA_ARGS__)

#define dispatch_queue_async(queue, block, ...)          { typeof(block) const __xz_block__ = block; if (__xz_block__) { dispatch_async_queue(queue, __xz_block__, ##__VA_ARGS__);        } }
#define dispatch_queue_sync(queue, block, ...)           { typeof(block) const __xz_block__ = block; if (__xz_block__) { dispatch_sync_queue(queue, __xz_block__, ##__VA_ARGS__);         } }
#define dispatch_main_async(block, ...)                  { typeof(block) const __xz_block__ = block; if (__xz_block__) { dispatch_async_main(__xz_block__, ##__VA_ARGS__);                } }
#define dispatch_main_sync(block, ...)                   { typeof(block) const __xz_block__ = block; if (__xz_block__) { dispatch_sync_main(__xz_block__, ##__VA_ARGS__);                 } }
#define dispatch_global_async(QOS_CLASS, block, ...)     { typeof(block) const __xz_block__ = block; if (__xz_block__) { dispatch_async_global(QOS_CLASS, __xz_block__, ##__VA_ARGS__);   } }
#define dispatch_global_sync(QOS_CLASS, block, ...)      { typeof(block) const __xz_block__ = block; if (__xz_block__) { dispatch_sync_global(QOS_CLASS, __xz_block__, ##__VA_ARGS__);    } }

#endif

NS_ASSUME_NONNULL_END
