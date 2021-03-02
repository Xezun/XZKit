//
//  XZLog.m
//  XZKit
//
//  Created by Xezun on 2021/2/7.
//  Copyright © 2021 Xezun Inc. All rights reserved.
//

#import "XZLog.h"

void XZPrint(NSString *format, ...) {
    va_list va_list_pointer;
    va_start(va_list_pointer, format);
    XZPrintv(format, va_list_pointer);
    va_end(va_list_pointer);
}

void XZPrintv(NSString *format, va_list args) {
    // 与 NSLog 一样，使用 stderr 错误输出，立即输出内容。（printf 使用 stdout 标准输出，遇到 \n 才输出）。
    fprintf(stderr, "%s\n", [[[NSString alloc] initWithFormat:format arguments:args] UTF8String]);
}

void __XZLog__(const char * const filePath, int const line, const char * const function, NSString * const _Nonnull format, ...) {
    if (!XZKitDebugMode) {
        return;
    }
    
    static NSDateFormatter  *_formater = nil;
    static dispatch_queue_t  _logQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _formater = [[NSDateFormatter alloc] init];
        _formater.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        _logQueue = dispatch_queue_create("com.xezun.XZLog", DISPATCH_QUEUE_SERIAL);
    });
    
    va_list va_list_pointer;
    va_start(va_list_pointer, format);
    NSString * const content = [[NSString alloc] initWithFormat:format arguments:va_list_pointer];
    va_end(va_list_pointer);
    
    NSString * const dateString     = [_formater stringFromDate:NSDate.date];
    NSString * const fileName       = [[NSString stringWithUTF8String:filePath] lastPathComponent];
    NSString * const commentMessage = [NSString stringWithFormat:@"§ %@(%d) § %s § %@ §", fileName, line, function, dateString];
    NSString * const dividerLine    = [@"----" stringByPaddingToLength:commentMessage.length withString:@"-" startingAtIndex:0];
    
    dispatch_sync(_logQueue, ^{
        XZPrint(@"%@\n%@\n%@\n%@\n", dividerLine, commentMessage, dividerLine, content);
    });
}

