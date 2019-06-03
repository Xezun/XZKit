//
//  ObjectiveC.m
//  XZKit
//
//  Created by mlibai on 2018/4/14.
//  Copyright © 2018年 mlibai. All rights reserved.
//

#import "XZKitConstants.h"
#import <sys/time.h>
#import <XZKit/XZKit-Swift.h>

bool XZKitDebugMode = NO;

void __XZKitLoadDebugMode(void) {
    XZKitDebugMode = (bool)[NSProcessInfo.processInfo.arguments containsObject:@"-XZKitDEBUG"];
}

void __xz_defer__(void (^ _Nonnull * _Nonnull operation)(void)) {
    (*operation)();
}

NSTimeInterval xz_timestamp() {
    struct timeval aTime;
    gettimeofday(&aTime, NULL);
    NSTimeInterval sec = aTime.tv_sec;
    NSTimeInterval u_sec = aTime.tv_usec * 1.0e-6L;
    return (sec + u_sec);
}

void xz_print(NSString *format, ...) {
    va_list va_list_pointer;
    va_start(va_list_pointer, format);
    xz_print_v(format, va_list_pointer);
    va_end(va_list_pointer);
}

void xz_print_v(NSString *format, va_list args) {
    // 使用 stderr 错误输出，立即输出内容（printf 使用 stdout 标准输出，遇到 \n 才输出）。
    fprintf(stderr, "%s\n", [[[NSString alloc] initWithFormat:format arguments:args] UTF8String]);
}

void XZLogv(const char * const filePath, int const line, const char * const function, NSString * const _Nonnull format, ...) {
    if (!XZKitDebugMode) {
        return;
    }
    NSString * const dateString     = [[NSString alloc] xz_stringWithDate:[NSDate date] format:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString * const fileName       = [[NSString stringWithUTF8String:filePath] lastPathComponent];
    NSString * const commentMessage = [NSString stringWithFormat:@"§ %@(%d) § %s § %@ §", fileName, line, function, dateString];
    NSString * const dividerLine    = [@"----" stringByPaddingToLength:commentMessage.length withString:@"-" startingAtIndex:0];
    
    va_list va_list_pointer;
    va_start(va_list_pointer, format);
    NSString * const content = [[NSString alloc] initWithFormat:format arguments:va_list_pointer];
    va_end(va_list_pointer);
    
    xz_print(@"%@\n%@\n%@\n%@\n", dividerLine, commentMessage, dividerLine, content);
}
