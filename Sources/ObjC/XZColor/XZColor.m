//
//  XZColor.m
//  XZKit
//
//  Created by Xezun on 2021/2/22.
//

#import "XZColor.h"

XZColor XZColorFromString(NSString *string) {
    NSUInteger const length = string.length;
    
    // 少于 3 个字符无法满足最低查找条件
    if (length < 3) {
        return XZColorMake(0, 0, 0, 0);
    }
    
    char numbers[8] = {0};  // 存储数字。
    NSInteger count = 0;    // numbers 的长度。
    
    // 满 8 位就不用继续查找了
    NSRange range;
    for (NSUInteger i = 0; i < length && count < 8; i += range.length) {
        // 获取单个字符
        range = [string rangeOfComposedCharacterSequenceAtIndex:i];
        
        // NSString 默认采用的是 UTF-16 编码（两个字节），部分中文也是一个 unichar 字符，
        // 但是十六进制字符都是单字节字符
        if (range.length == 1) {
            unichar const character = [string characterAtIndex:i];
            // A - F
            if (character >= 'A' && character <= 'F') {
                numbers[count++] = character - 'A' + 10;
                continue;
            }
            // a - f
            if (character >= 'a' && character <= 'f') {
                numbers[count++] = character - 'a' + 10;
                continue;
            }
            // 0 - 9
            if (character >= '0' && character <= '9') {
                numbers[count++] = character - '0';
                continue;
            }
        }
        
        // 多字节字符或非十六进制字符
        // 如果当前已经识别出超过3个字符，那么就停止识别，否则重新开始识别
        
        if (count >= 3) {
            break;
        }
        count = 0;
    }
    
    switch (count) {
        case 3: { // #ABC => #AABBCCFF
            CGFloat const r = numbers[0] * 16 + numbers[0];
            CGFloat const g = numbers[1] * 16 + numbers[1];
            CGFloat const b = numbers[2] * 16 + numbers[2];
            return XZColorMake(r, g, b, 255);
        }
        case 4: { // #ABCD => #AABBCCDD
            CGFloat const r = numbers[0] * 16 + numbers[0];
            CGFloat const g = numbers[1] * 16 + numbers[1];
            CGFloat const b = numbers[2] * 16 + numbers[2];
            CGFloat const a = numbers[3] * 16 + numbers[3];
            return XZColorMake(r, g, b, a);
        }
        case 5: { // #ABCDE => #AABBCCDE
            CGFloat const r = numbers[0] * 16 + numbers[0];
            CGFloat const g = numbers[1] * 16 + numbers[1];
            CGFloat const b = numbers[2] * 16 + numbers[2];
            CGFloat const a = numbers[3] * 16 + numbers[4];
            return XZColorMake(r, g, b, a);
        }
        case 6:{ // #123456 => #123456FF
            CGFloat const r = numbers[0] * 16 + numbers[1];
            CGFloat const g = numbers[2] * 16 + numbers[3];
            CGFloat const b = numbers[4] * 16 + numbers[5];
            return XZColorMake(r, g, b, 255);
        }
        case 7: { // #123456A => #123456AA
            CGFloat const r = numbers[0] * 16 + numbers[1];
            CGFloat const g = numbers[2] * 16 + numbers[3];
            CGFloat const b = numbers[4] * 16 + numbers[5];
            CGFloat const a = numbers[6] * 16 + numbers[6];
            return XZColorMake(r, g, b, a);
        }
        case 8: { // #123456AA => #123456AA
            CGFloat const r = numbers[0] * 16 + numbers[1];
            CGFloat const g = numbers[2] * 16 + numbers[3];
            CGFloat const b = numbers[4] * 16 + numbers[5];
            CGFloat const a = numbers[6] * 16 + numbers[7];
            return XZColorMake(r, g, b, a);
        }
        default: {
            return XZColorMake(0, 0, 0, 0);
        }
    }
}
