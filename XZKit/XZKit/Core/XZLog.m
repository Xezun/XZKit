//
//  XZLog.m
//  XZKit
//
//  Created by Xezun on 2021/2/7.
//  Copyright © 2021 Xezun Inc. All rights reserved.
//

#import "XZLog.h"

static void XZDebugPrintf(NSString *format, va_list args) {
    // stderr: 标准错误输出，立即输出到屏幕。
    // stdout: 标准输出，当遇到刷新标志（比如换行）或缓冲满时，才把缓冲的数据输出到设备中。
    // STDERR_FILENO: 与 stderr 相同
    //
    // 在 CF-1153.18 的源文件 CFUtilities.c 中可以找到 CFLog 函数的源码：
    //     NSLog => CFLog => _CFLogvEx => __CFLogCString =>
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
    // 所以在 iOS 平台，NSLog 最终使用的是 writev 函数输出日志到控制台，但是由于
    //     1、函数 writev 不是线程安全的。
    //     2、函数 __CFLogCString 是一个 static 局部函数，且其内部使用 CFLock_t 锁也无法获取。
    // 所以当前函数与`NSLog`不是线程安全的，即有可能会发生与`NSLog`输出内容互相嵌入的情况。
    //
    // 不过对于同已文件来说 fprintf 本身是线程安全的，所以应尽量使用同一种日志输出函数，以避免线程安全问题。
    fprintf(stderr, "%s\n", [[[NSString alloc] initWithFormat:format arguments:args] UTF8String]);
}

void XZDebugPrint(NSString *format, ...) {
    va_list va_list_pointer;
    va_start(va_list_pointer, format);
    XZDebugPrintv(format, va_list_pointer);
    va_end(va_list_pointer);
}

void XZDebugPrintv(NSString *format, va_list args) {
    if (!XZKitDebugMode) {
        return;
    }
    // 与 NSLog 一样，使用 stderr 错误输出，立即输出内容。（printf 使用 stdout 标准输出，遇到 \n 才输出）。
    XZDebugPrintf(format, args);
}

void XZDebugLog(const char *file, int line, const char *func, NSString *format, ...) {
    if (!XZKitDebugMode) {
        return;
    }
    
    NSString * const source = [[NSString stringWithUTF8String:file] lastPathComponent];
    
    // 组成新的输出格式
#if XZ_REWRITES_NSLOG
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    });
    NSString * const datime = [formatter stringFromDate:NSDate.date];
    
    format = [NSString stringWithFormat:@"⌘ %@ ⌘ %@(%d) ⌘ %s ⌘\n%@", datime, source, line, func, format];
#else
    format = [NSString stringWithFormat:@"%@(%d) %s\n%@", source, line, func, format];
#endif
    
    va_list args;
    va_start(args, format);
#if XZ_REWRITES_NSLOG
    XZDebugPrintf(format, args);
#else
    NSLogv(format, args);
#endif
    va_end(args);
}

