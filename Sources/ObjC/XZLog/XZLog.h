//
//  XZLog.h
//  XZKit
//
//  Created by Xezun on 2025/7/3.
//

#import <Foundation/Foundation.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZLogSystem.h>
#else
#import  "XZLogSystem.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#pragma mark - XZLog

#define XZ_LOG_ATTR(A, B, msg) __attribute__(( availability(swift, unavailable, message=msg), overloadable, format(__NSString__, A, B) ));

/// 使用指定日志系统输出日志，请使用`XZLog`宏，不要直接使用此函数。
///
/// 宏 `XZLog` 的用法与 `NSLog` 函数类似，但是宏 `XZLog` 在编译时会展开为此函数。
/// 
/// 通过 NSLog 输出到控制台，如果待输出内容过大，则分批次输出，避免输出内容不完整。
///
/// - Parameters:
///   - file: 日志语句所在的文件名
///   - line: 日志语句所在的行数
///   - function: 日志语句所在的函数名
///   - system: 如果日志系统 isEnabled 属性为 NO 则不会输出日志到控制台
///   - format: 日志内容
FOUNDATION_EXPORT NSArray<NSString *> * XZLogv(const char *file, const int line, const char *function, XZLogSystem *system, NSString *format, ...) XZ_LOG_ATTR(5, 6, "Use #XZLog instead");

/// 使用默认日志系统输出日志，请使用`XZLog`宏，不要直接使用此函数。
FOUNDATION_EXPORT NSArray<NSString *> * XZLogv(const char *file, const int line, const char *function, NSString *format, ...) XZ_LOG_ATTR(4, 5, "Use #XZLog instead");

/// 供 Swift 使用 NSLog 的函数。
FOUNDATION_EXPORT NSString * XZLogs(XZLogSystem *system, NSString *file, NSInteger line, NSString *function);

/// 宏，使用指定日志系统输出日志。
///
/// - SeeAlso: ``XZLogv``
/// - Parameter system: 日志系统
/// - Parameter format: 日志内容
FOUNDATION_EXTERN void XZLog(XZLogSystem *system, NSString *format, ...) XZ_LOG_ATTR(2, 3, "Use #XZLog instead");

/// 宏，使用 ``NSLog`` 输出日志。
///
/// #### 长度限制
///
/// 由于 `NSLog` 对输出日志内容长度有限制，所以 `XZLog` 会将超过 1017 个字符的日志内容分段输出。
///
/// ```objc
/// // 如下写法长度限制：1017
/// NSLog(@"The message is %@", message);
/// // 如下写法长度限制：32759
/// NSLog(@"%@", [NSString stringWithFormat:@"The message is %@", message]);
/// ```
///
/// #### 日志互嵌
///
/// 同时多个不同的函数输出日志，比如 `printf` 函数，即使文档表明这些函数是原子性的，还是可能会在控制台产生互嵌的日志，所以 `XZLog` 使用 `NSLog` 进行输出。
///
/// 通过溯源原代码，在 CF-1153.18 源文件 CFUtilities.c 中可以找到 `NSLog` 函数的源码：
///
/// ```objc
/// // NSLog() => CFLog() => _CFLogvEx() => __CFLogCString() =>
/// #if DEPLOYMENT_TARGET_MACOSX || DEPLOYMENT_TARGET_EMBEDDED || DEPLOYMENT_TARGET_EMBEDDED_MINI
///     writev(STDERR_FILENO)
/// #elif DEPLOYMENT_TARGET_WINDOWS
///     fprintf_s(stderr)
/// #else
///     fprintf(stderr)
/// #endif
/// ```
///
/// 通过搜索 `DEPLOYMENT_TARGET_EMBEDDED` 宏，在 CFBundle\_Resources.c 的 320-321 行可以找到如下代码。
///
/// ```objc
/// #elif DEPLOYMENT_TARGET_EMBEDDED || DEPLOYMENT_TARGET_EMBEDDED_MINI
///     return CFSTR("iPhoneOS");
/// ```
///
/// 所以可以确定，在 iOS 平台 `NSLog` 最终使用的是 `writev` 函数输出日志，并且使用了 `CFLock_t` 保证线程安全。
/// 由于函数 `\__CFLogCString()` 是 static 私有函数，所以我们无法直接使用这个函数来输出日志。
///
/// > 自 iOS 10 之后，有迹象表明 NSLog 底层已由 ASL 切换为 OSLog 框架，或者使用了与 OSLog 相同的更底层框架，虽然官方没有明确说明。
///
/// #### 日志文件
///
/// 日志输出文件，即函数``fprintf``的第一个参数，可使用如下几个值。
///
/// - stderr: 标准错误输出，立即输出到屏幕。
/// - stdout: 标准输出，当遇到刷新标志（比如换行）或缓冲满时，才把缓冲的数据输出到设备中。
/// - STDERR_FILENO: 与 stderr 相同
///
/// - SeeAlso: ``XZLogv``
/// - Parameter format: 日志内容
FOUNDATION_EXTERN void XZLog(NSString *format, ...) XZ_LOG_ATTR(1, 2, "Use #XZLog instead");

#undef XZLog
#if DEBUG && XZ_FRAMEWORK
#define XZLog(format, ...) __extension__({ for (NSString *message in XZLogv(__FILE_NAME__, __LINE__, __FUNCTION__, XZLogSystem.XZKitSystem, format, ##__VA_ARGS__)) { NSLog(@"%@", message); } })
#elif DEBUG
#define XZLog(format, ...) __extension__({ for (NSString *message in XZLogv(__FILE_NAME__, __LINE__, __FUNCTION__, format, ##__VA_ARGS__)) { NSLog(@"%@", message); } })
#else
#define XZLog(...)
#endif

NS_ASSUME_NONNULL_END
