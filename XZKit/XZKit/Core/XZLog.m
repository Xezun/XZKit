//
//  XZLog.m
//  XZKit
//
//  Created by Xezun on 2021/2/7.
//  Copyright © 2021 Xezun Inc. All rights reserved.
//

#import "XZLog.h"

static void XZPrintf(NSString *format, va_list args) {
    // 函数 fprintf 在输出到同一个文件时是线程安全的，所以这里与 NSLog 保持一致，
    // 用 fprintf 函数及 stderr 标准错误文件，以避免与 NSLog 的输出的内容出现互相穿插的情况。
    //
    // printf 使用 stdout 标准输出，当遇到刷新标志（比如换行）或缓冲满时，才把缓冲的数据输出到设备中。
    //
    // 在 CoreFoundation 的 CFUtilities.c 文件中可以找到 CFLog 函数的源码：
    // 1、NSLog => CFLog => _CFLogvEx => __CFLogCString => fprintf
    // 2、在 __CFLogCString 中，日志在输出到控制台前，还通过 writev 函数写入到了 STDERR_FILENO 文件中。
    fprintf(stderr, "%s\n", [[[NSString alloc] initWithFormat:format arguments:args] UTF8String]);
}

void XZPrint(NSString *format, ...) {
    va_list va_list_pointer;
    va_start(va_list_pointer, format);
    XZPrintv(format, va_list_pointer);
    va_end(va_list_pointer);
}

void XZPrintv(NSString *format, va_list args) {
    if (!XZKitDebugMode) {
        return;
    }
    // 与 NSLog 一样，使用 stderr 错误输出，立即输出内容。（printf 使用 stdout 标准输出，遇到 \n 才输出）。
    XZPrintf(format, args);
}

void XZLogv(const char *file, int line, const char *func, NSString *format, ...) {
    if (!XZKitDebugMode) {
        return;
    }
    
    static NSDateFormatter *formatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    });
    
    // 标题格式，备用分隔符：┇、•、❚、§、⌘、◼︎
    NSString * const datime = [formatter stringFromDate:NSDate.date];
    NSString * const source = [[NSString stringWithUTF8String:file] lastPathComponent];
    NSString * const header = [NSString stringWithFormat:@"⌘ %@ ⌘ %@(%d) ⌘ %s ⌘", datime, source, line, func];
    
    // 组成新的输出格式
    format = [NSString stringWithFormat:@"%@\n%@", header, format];
    
    va_list args;
    va_start(args, format);
    XZPrintf(format, args);
    va_end(args);
}

