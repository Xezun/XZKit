//
//  XZMacro.m
//  XZDefines
//
//  Created by Xezun on 2023/8/6.
//

#import "XZMacro.h"

void __xz_log_imp__(const char *file, const int line, const char *function, NSString *format, ...) {
    va_list arguments;
    va_start(arguments, format);
    NSString * const message = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);
    NSString * const metrics = [NSString stringWithFormat:@"⌘ %s(%d) ⌘ %s ⌘", file, line, function];
    
    NSUInteger const length = message.length;
    if (length + metrics.length <= 1021) {
        NSLog(@"%@ \n%@", metrics, message);
        return;
    }
    
    NSLog(@"%@", metrics);
    
    NSRange range = NSMakeRange(0, length);
    while (range.location < length) {
        NSRange lineRange = [message rangeOfString:@"\n" options:kNilOptions range:range];
        
        // 确定行的范围
        if (lineRange.location == NSNotFound) {
            // 只有一行
            lineRange = range;
            range.location = lineRange.location + lineRange.length;
            range.length = 0;
        } else {
            // 行字符不包括 换行符
            lineRange.length = lineRange.location - range.location;
            lineRange.location = range.location;
            // +1 跳过换行符
            range.location = (lineRange.location + lineRange.length + 1);
            range.length -= (lineRange.length + 1);
        }
        
        if (lineRange.length <= 1000) {
            // 行字符数量少于 1000 直接输出
            NSLog(@"%@", [message substringWithRange:lineRange]);
            continue;
        }
        
        // 单行超出 1000 字符，每次输出 1000 字符
        NSUInteger const lineMaxIndex = lineRange.location + lineRange.length;
        
        NSRange subRange = NSMakeRange(lineRange.location, 0);
        while (subRange.location < lineMaxIndex) {
            // 第 1000 个字符的位置
            const NSUInteger charIndex = subRange.location + 999;
            if (charIndex < lineMaxIndex) {
                NSRange const charRange = [message rangeOfComposedCharacterSequenceAtIndex:charIndex];
                subRange.length = (charRange.location + charRange.length) - subRange.location;
            } else {
                subRange.length = (lineMaxIndex - 1) - subRange.location;
            }
            
            if (subRange.location == lineRange.location) {
                NSLog(@"%@", [message substringWithRange:subRange]);
            } else {
                // 缩进
                NSLog(@"\t%@", [message substringWithRange:subRange]);
            }
            subRange.location = subRange.location + subRange.length;
        }
    }
}
