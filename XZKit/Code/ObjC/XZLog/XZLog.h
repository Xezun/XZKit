//
//  XZLog.h
//  XZKit
//
//  Created by 徐臻 on 2025/7/3.
//

#import <Foundation/Foundation.h>
#import "XZLogSystem.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - XZLog

#define XZ_LOG_ATTR(A, B, msg) __attribute__(( availability(swift, unavailable, message=msg), overloadable, format(__NSString__, A, B) ));

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
FOUNDATION_EXPORT void XZLogv(const char *file, const int line, const char *function, XZLogSystem *system, NSString *format, ...) XZ_LOG_ATTR(5, 6, "Use #XZLog instead");

/// 默认输出。
FOUNDATION_EXPORT void XZLogv(const char *file, const int line, const char *function, NSString *format, ...) XZ_LOG_ATTR(4, 5, "Use #XZLog instead");

/// 供 Swift 使用 NSLog 的函数。
FOUNDATION_EXPORT void XZLogs(XZLogSystem * _Nullable system, NSString *file, NSInteger line, NSString *function, NSString *message);

/// 输出日志指定系统。
///
/// 宏函数，实际调用``NSLog``输出控制台。
///
/// 日志额包含语句所在的文件、行数、方法名，且如果待输出内容过大，则分批次输出，避免输出内容不完整。
///
/// - Parameter system: 日志系统
/// - Parameter format: 格式化输出模版
FOUNDATION_EXTERN void XZLog(XZLogSystem *system, NSString *format, ...) XZ_LOG_ATTR(2, 3, "Use #XZLog instead");
/// 输出日志到 defaultLogSystem 系统。
///
/// 日志额包含语句所在的文件、行数、方法名，且如果待输出内容过大，则分批次输出，避免输出内容不完整。
///
/// 宏函数，实际使用``NSLog``输出到控制台。
FOUNDATION_EXTERN void XZLog(NSString *format, ...) XZ_LOG_ATTR(1, 2, "Use #XZLog instead");

#undef XZLog
#if DEBUG && XZ_FRAMEWORK
#define XZLog(format, ...) XZLogv(__FILE_NAME__, __LINE__, __FUNCTION__, XZLogSystem.XZKitLogSystem, format, ##__VA_ARGS__)
#elif DEBUG
#define XZLog(format, ...) XZLogv(__FILE_NAME__, __LINE__, __FUNCTION__, format, ##__VA_ARGS__)
#else
#define XZLog(...)
#endif

NS_ASSUME_NONNULL_END
