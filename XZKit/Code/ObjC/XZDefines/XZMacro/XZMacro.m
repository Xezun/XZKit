//
//  XZMacro.m
//  XZDefines
//
//  Created by Xezun on 2023/8/6.
//

#import "XZMacro.h"
@import ObjectiveC;
void XZLogv(const char *file, const int line, const char *function, NSString *format, ...) {
    va_list arguments;
    va_start(arguments, format);
    NSString * const message = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);
    
    NSUInteger const messageLength = message.length;
    NSString * const metrics = [NSString stringWithFormat:@"⌘ %s(%d) ⌘ %s ⌘", file, line, function];
    
    if (messageLength == 0) {
        NSLog(@"%@", metrics);
        return;
    }
    
    // 总长度小于 1015 直接输出，超过 1015 则分批输出
    if (messageLength + metrics.length <= 1015) {
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
        if (messageLength - location <= 1017) {
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
    } while (location < messageLength);
}
