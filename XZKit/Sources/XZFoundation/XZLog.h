//
//  XZLog.h
//  XZKit
//
//  Created by Xezun on 2021/2/7.
//  Copyright © 2021 Xezun Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 输出信息到控制台，末尾自动换行。不附加任何其它信息。
/// @param format 输出格式。
/// @param ...    参数列表。
FOUNDATION_EXTERN void XZPrint(NSString * _Nonnull format, ...) NS_FORMAT_FUNCTION(1, 2) NS_NO_TAIL_CALL;

/// 输出信息到控制台，末尾自动换行。不附加任何其它信息。
///
/// @param format 输出格式。
/// @param args   参数列表指针。
FOUNDATION_EXTERN void XZPrintv(NSString * _Nonnull format, va_list _Nonnull args) NS_FORMAT_FUNCTION(1, 0) NS_NO_TAIL_CALL;

/// 请使用 XZLog 宏。
/// @note 仅在 XZKitDebugMode == YES 时输出。
FOUNDATION_EXTERN void __XZLog__(const char * const filePath, int const line, const char * const function, NSString * const _Nonnull format, ...) NS_FORMAT_FUNCTION(4, 5)
NS_SWIFT_UNAVAILABLE("Use Swift XZKit.XZLog instead.");

/// 控制台输出。
/// @note 仅在程序添加了启动参数 -XZKitDEBUG 才执行控制台输出。
/// @note 仅在 DEBUG 模式输出请用 DZLOG 宏。
FOUNDATION_EXTERN void XZLog(NSString * _Nonnull format, ...) NS_SWIFT_UNAVAILABLE("");
#undef  XZLog
#define XZLog(format, ...) __XZLog__(__FILE__, (int)__LINE__, __func__, format, ##__VA_ARGS__)

#ifndef DLOG
#if DEBUG
/// 控制台输出。
/// @note 仅在程序添加了启动参数 -XZKitDEBUG 才执行控制台输出。
/// @note 仅在 DEBUG 模式输出。
FOUNDATION_EXTERN void DLOG(NSString * _Nonnull format, ...) NS_SWIFT_UNAVAILABLE("");
#define DLOG(format, ...) __XZLog__(__FILE__, (int)__LINE__, __func__, format, ##__VA_ARGS__)
#else
#define DLOG(...)
#endif
#endif

NS_ASSUME_NONNULL_END
