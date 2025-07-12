//
//  XZLog.m
//  XZKit
//
//  Created by 徐臻 on 2025/7/3.
//

#import "XZLog.h"
#undef XZLog

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"

static void XZLog(const char *file, const int line, const char *function, XZLogSystem *system, NSString *message) __attribute__((overloadable)) {
    if (!system.isEnabled) {
        return;
    }
    
    NSUInteger const length  = message.length;
    NSString * const metrics = [NSString stringWithFormat:@"⌘ %@ ⌘ %s(%d) ⌘ %s ⌘", system.name, file, line, function];
    
    if (length == 0) {
        NSLog(@"%@", metrics);
        return;
    }
    
    // 总长度小于 1015 直接输出，超过 1015 则分批输出
    if (length + metrics.length <= 1015) {
        NSLog(@"%@ \n%@", metrics, message);
        return;
    }
    
    // 输出杂项
    NSLog(@"%@", metrics);
    
    // 输出日志内容，分批规则：
    // 1、单次最多输出 1000 长度的字符，且避免切割自然字符。
    // 2、尽量以换行符进行切割，除非没有换行符。
    // 3、强制切割的位置后，不是换行符，避免出现连续的空行。
    
    NSUInteger location = 0;
    do {
        // 待输出长度不超过 1017 直接输出
        if (length - location <= 1017) {
            NSLog(@"%@", [message substringFromIndex:location]);
            return;
        }
        
        // 在前 1001 个长度的字符中，反向查找换行符：
        // 1、找到换行符，则输出换行符之前的内容，并跳过换行符输出剩下的部分。
        // 2、没有找到换行符，则输出第 1001 个位置所在的自然字符之前的字符，因为第 1001 字符一定不是换行符，后续输出一定不是换行符。
        NSRange range = [message rangeOfString:@"\n" options:NSBackwardsSearch range:NSMakeRange(location, 1001)];
        if (range.location == NSNotFound) {
            range = [message rangeOfComposedCharacterSequenceAtIndex:location + 1000];
            // 下次输出的起点：因为第 1001 字符不是换行符，不跳过
            range.length = 0;
        }
        
        // 输出日志：
        NSLog(@"%@", [message substringWithRange:NSMakeRange(location, range.location - location)]);
        
        // 下次输出的起点。如果是换行符，则会跳过换行符，因为 NSLog 已经包含一个换行符
        location = range.location + range.length;
    } while (location < length);
}

void XZLog(XZLogSystem *system, NSString *format, ...) __attribute__((overloadable)) {
#if DEBUG
    va_list arguments;
    va_start(arguments, format);
    NSString * const message = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);
    XZLog(__FILE__, __LINE__, __FUNCTION__, (XZLogSystem *)nil, message);
#endif
}

void XZLogv(const char *file, const int line, const char *function, XZLogSystem *system, NSString *format, ...) __attribute__((overloadable)) {
#if DEBUG
    va_list arguments;
    va_start(arguments, format);
    NSString * const message = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);
    XZLog(file, line, function, system, message);
#endif
}

void XZLogv(const char *file, const int line, const char *function, NSString *format, ...) __attribute__((overloadable)) {
#if DEBUG
    va_list arguments;
    va_start(arguments, format);
    NSString * const message = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);
    XZLog(file, line, function, XZLogSystem.defaultLogSystem, message);
#endif
}

void XZLogs(XZLogSystem *system, NSString *file, NSInteger line, NSString *function, NSString *message) {
#if DEBUG
    NSRange const range = [file rangeOfString:system.name];
    if (range.location == 0 && (range.length + 1) < file.length && [file characterAtIndex:range.length] == '/') {
        file = [file substringFromIndex:range.length + 1];
    }
    const char * cfile = [file cStringUsingEncoding:NSUTF8StringEncoding];
    const char * cfunc = [function cStringUsingEncoding:NSUTF8StringEncoding];
    XZLog(cfile, (int)line, cfunc, system, message);
#endif
}

#pragma clang diagnostic pop
