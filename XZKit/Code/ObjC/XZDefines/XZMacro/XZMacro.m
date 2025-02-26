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
    
    // 总长度小于 1000 直接输出
    NSUInteger const messageLength = message.length;
    if (messageLength + metrics.length <= 1000) {
        NSLog(@"%@ \n%@", metrics, message);
        return;
    }
    
    // 总长度超过 1000 分批输出
    NSLog(@"%@", metrics);
    
    NSRange range = NSMakeRange(0, messageLength);
    while (range.location < messageLength) {
        // 待输出长度不超过 1000 直接输出
        if (range.length <= 1000) {
            NSLog(@"%@", [message substringWithRange:range]);
            break;
        }
        
        // 长度超过 1000 强制换行，且强制换行的位置，前后不能是换行。
        
        // 判断前 1001 个长度的字符中，反向查找换行符。
        NSRange lineRange = [message rangeOfString:@"\n" options:NSBackwardsSearch range:NSMakeRange(range.location, 1001)];
        
        if (lineRange.location == NSNotFound) {
            // 没有换行符，判断第 1000 个位置的完整字符范围，避免截断。
            NSUInteger const maxCharIndex = range.location + 999;
            NSRange    const charRange    = [message rangeOfComposedCharacterSequenceAtIndex:maxCharIndex];
            // 输出长度不超过 1000，如果输出第 1000 位置的字符，长度超标，则不输出它
            if (charRange.length == 1 || charRange.location + charRange.length - 1 <= maxCharIndex) {
                lineRange.location = range.location;
                lineRange.length = charRange.location + charRange.length - range.location;
            } else {
                lineRange.location = range.location;
                lineRange.length = charRange.location - range.location;
            }
            // 下次输出的范围
            range.location = lineRange.location + lineRange.length;
            range.length = range.length - lineRange.length;
        } else {
            // 找到换行符，则换行符之前的行内字符
            lineRange.length = lineRange.location - range.location;
            lineRange.location = range.location;
            // 下次次输出的范围，跳过换行符
            range.location = lineRange.location + lineRange.length + 1;
            range.length = range.length - lineRange.length - 1;
        }
        
        NSLog(@"%@", [message substringWithRange:lineRange]);
    }
}
