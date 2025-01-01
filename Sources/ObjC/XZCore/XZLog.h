//
//  XZLog.h
//  XZKit
//
//  Created by Xezun on 2021/2/7.
//  Copyright © 2021 Xezun Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XZKit/XZDefines.h>
#import <XZKit/XZDebugMode.h>

NS_ASSUME_NONNULL_BEGIN

/// 输出信息到控制台，末尾自动换行。不附加任何其它信息。
/// @param format 输出格式
FOUNDATION_EXTERN void XZDebugPrint(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2) NS_NO_TAIL_CALL;

/// 输出信息到控制台，末尾自动换行。不附加任何其它信息。
///
/// @param format 输出格式
/// @param args   参数列表指针
FOUNDATION_EXTERN void XZDebugPrintv(NSString *format, va_list args) NS_FORMAT_FUNCTION(1, 0) NS_NO_TAIL_CALL;

/// 请使用 XZLog 宏。
/// @note 仅在 XZKitDebugMode == YES 时输出。
FOUNDATION_EXTERN void XZDebugLog(const char *file, int line, const char *func, NSString *format, ...) NS_FORMAT_FUNCTION(4, 5) XZ_OBJC_ONLY;

#if DEBUG
#define XZPrint(format, ...) XZDebugPrint(format, ##__VA_ARGS__)
#define XZLog(format, ...) XZDebugLog(__FILE__, (int)__LINE__, __func__, format, ##__VA_ARGS__)
#else
#define XZPrint(...)
#define XZLog(...)
#endif

// 通过宏将 NSLog 替换为 XZDebugLog 函数。
// 可通过预定义此宏，关闭对 NSLog 的替换。
#ifndef XZ_REWRITES_NSLOG
#define XZ_REWRITES_NSLOG 1

#if DEBUG
#define NSLog(format, ...) XZDebugLog(__FILE__, (int)__LINE__, __func__, format, ##__VA_ARGS__)
#else
#define NSLog(...)
#endif

#endif

NS_ASSUME_NONNULL_END
