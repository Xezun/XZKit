//
//  XZLog.h
//  XZKit
//
//  Created by Xezun on 2021/2/7.
//  Copyright © 2021 Xezun Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XZKit/XZDefines.h>
#import <XZKit/XZKitDEBUG.h>

NS_ASSUME_NONNULL_BEGIN

/// 输出信息到控制台，末尾自动换行。不附加任何其它信息。
/// @param format 输出格式
FOUNDATION_EXTERN void XZPrint(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2) NS_NO_TAIL_CALL;

/// 输出信息到控制台，末尾自动换行。不附加任何其它信息。
///
/// @param format 输出格式
/// @param args   参数列表指针
FOUNDATION_EXTERN void XZPrintv(NSString *format, va_list args) NS_FORMAT_FUNCTION(1, 0) NS_NO_TAIL_CALL;

/// 请使用 XZLog 宏。
/// @note 仅在 XZKitDebugMode == YES 时输出。
FOUNDATION_EXTERN void XZLogv(const char *file, int line, const char *func, NSString *format, ...) NS_FORMAT_FUNCTION(4, 5) XZ_OBJC_ONLY;

/// 控制台输出。
/// @note 仅在程序添加了启动参数 -XZKitDEBUG 才执行控制台输出。
/// @note 仅在 DEBUG 模式输出请用 DZLOG 宏。
FOUNDATION_EXTERN void XZLog(NSString *format, ...) XZ_OBJC_ONLY;
#undef XZLog

#if DEBUG
#define XZLog(format, ...) XZLogv(__FILE__, (int)__LINE__, __func__, format, ##__VA_ARGS__)
#else
#define XZLog(...)
#endif

#ifndef XZ_REWRITES_NSLOG
#define XZ_REWRITES_NSLOG
#if DEBUG
#define NSLog(format, ...) XZLogv(__FILE__, (int)__LINE__, __func__, format, ##__VA_ARGS__)
#else
#define NSLog(...)
#endif
#endif

NS_ASSUME_NONNULL_END
