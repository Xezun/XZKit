//
//  UIColor+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/2/22.
//

#import "UIColor+XZKit.h"

@implementation UIColor (XZKit)

- (XZColor)xzColor {
    CGFloat r = 0, g = 0, b = 0, a = 0;
    if ([self getRed:&r green:&g blue:&b alpha:&a]) {
        return XZColorMake(round(r * 255), round(g * 255), round(b * 255), round(a * 255));
    }
    return XZColorMake(0, 0, 0, 0);
}

@end

BOOL XZColorParser(NSString * _Nullable string, XZColor *color) {
    NSCParameterAssert(string == nil || [string isKindOfClass:NSString.class]);
    NSCParameterAssert(color != NULL);
    
    NSUInteger const length = string.length;
    if (length < 3) {
        return NO;
    }
    
    char numbers[9] = {0};  // 存储数字。
    
    // 满 8 位就不用继续查找了
    NSUInteger count = 0;    // numbers 的长度。
    NSRange range;
    for (NSUInteger i = 0; count < 8 && i < length; i += range.length) {
        range = [string rangeOfComposedCharacterSequenceAtIndex:i];
        
        // 遍历到 ASCII 字符，判断是否为十六进制字符
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
        
        // 遍历到非十六进制字符（非ASCII字符或其它字符）
        
        // 如果当前已识别出3个以上字符，结束识别
        if (count >= 3) {
            break;
        }
        
        // 连续的数字不足 3 位，重新开始查找
        count = 0;
    }
    
    switch (count) {
        case 3: { // #ABC => #AABBCCFF
            color->red   = numbers[0] * 16 + numbers[0];
            color->green = numbers[1] * 16 + numbers[1];
            color->blue  = numbers[2] * 16 + numbers[2];
            color->alpha = 255;
            return YES;
        }
        case 4: { // #ABCD => #AABBCCDD
            color->red   = numbers[0] * 16 + numbers[0];
            color->green = numbers[1] * 16 + numbers[1];
            color->blue  = numbers[2] * 16 + numbers[2];
            color->alpha = numbers[3] * 16 + numbers[3];
            return YES;
        }
        case 5: { // #ABCDE => #AABBCCDE
            color->red   = numbers[0] * 16 + numbers[0];
            color->green = numbers[1] * 16 + numbers[1];
            color->blue  = numbers[2] * 16 + numbers[2];
            color->alpha = numbers[3] * 16 + numbers[4];
            return YES;
        }
        case 6:{ // #123456 => #123456FF
            color->red   = numbers[0] * 16 + numbers[1];
            color->green = numbers[2] * 16 + numbers[3];
            color->blue  = numbers[4] * 16 + numbers[5];
            color->alpha = 255;
            return YES;
        }
        case 7: { // #123456A => #123456AA
            color->red   = numbers[0] * 16 + numbers[1];
            color->green = numbers[2] * 16 + numbers[3];
            color->blue  = numbers[4] * 16 + numbers[5];
            color->alpha = numbers[6] * 16 + numbers[6];
            return YES;
        }
        case 8: { // #123456AA => #123456AA
            color->red   = numbers[0] * 16 + numbers[1];
            color->green = numbers[2] * 16 + numbers[3];
            color->blue  = numbers[4] * 16 + numbers[5];
            color->alpha = numbers[6] * 16 + numbers[7];
            return YES;
        }
        default: {
            return NO;
        }
    }
}
