//
//  UIColor.m
//  XZKit
//
//  Created by Xezun on 2017/10/24.
//

#import "UIColor+XZKit.h"

@implementation UIColor (XZKit)

- (XZRGBA)xz_rgbaValue {
    CGFloat r = 0, g = 0, b = 0, a = 0;
    if ([self getRed:&r green:&g blue:&b alpha:&a]) {
        return XZRGBAMake(round(r * 255), round(g * 255), round(b * 255), round(a * 255));
    }
    return XZRGBAMake(0, 0, 0, 0);
}

+ (UIColor *)xz_colorWithRGBA:(XZRGBA)rgbaValue {
    return rgba(rgbaValue);
}

+ (instancetype)xz_colorWithString:(NSString *)string {
    return XZUIColorFromNSString(string, -1.0);
}

@end


#define XZParseUIColorAlpha(value) (alpha < 0 ? (value / 255.0) : (alpha > 1 ? alpha / 255.0 : alpha))

UIColor *XZUIColorFromNSString(NSString *string, CGFloat alpha) {
    const char * const characters = [string cStringUsingEncoding:(NSASCIIStringEncoding)];
    char numbers[9] = {0};  // 存储数字。
    NSInteger count = 0;    // numbers 的长度。
    
    for (NSInteger i = 1; count < 9; i++) {
        char const character = characters[i];
        
        // 到了末尾
        if (character == '\0') {
            break;
        }
        
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
        
        // 已解析到颜色值
        if (count >= 3) {
            break;
        }
        
        // 连续的数字不足 3 位，重新开始查找
        count = 0;
    }
    
    switch (count) {
        case 0: break;
        case 1: break;
        case 2: break;
        case 3: { // #ABC => #AABBCCFF
            CGFloat const r = numbers[0] * 16 + numbers[0];
            CGFloat const g = numbers[1] * 16 + numbers[1];
            CGFloat const b = numbers[2] * 16 + numbers[2];
            CGFloat const a = XZParseUIColorAlpha(1.0);
            return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a];
        }
        case 4: { // #ABCD => #AABBCCDD
            CGFloat const r = numbers[0] * 16 + numbers[0];
            CGFloat const g = numbers[1] * 16 + numbers[1];
            CGFloat const b = numbers[2] * 16 + numbers[2];
            CGFloat const a = XZParseUIColorAlpha(numbers[3] * 16 + numbers[3]);
            return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a];
        }
        case 5: { // #ABCDE => #AABBCCDE
            CGFloat const r = numbers[0] * 16 + numbers[0];
            CGFloat const g = numbers[1] * 16 + numbers[1];
            CGFloat const b = numbers[2] * 16 + numbers[2];
            CGFloat const a = XZParseUIColorAlpha(numbers[3] * 16 + numbers[4]);
            return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a];
        }
        case 6:{ // #123456 => #123456FF
            CGFloat const r = numbers[0] * 16 + numbers[1];
            CGFloat const g = numbers[2] * 16 + numbers[3];
            CGFloat const b = numbers[4] * 16 + numbers[5];
            CGFloat const a = XZParseUIColorAlpha(1.0);
            return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a];
        }
        case 7: { // #123456A => #123456AA
            CGFloat const r = numbers[0] * 16 + numbers[1];
            CGFloat const g = numbers[2] * 16 + numbers[3];
            CGFloat const b = numbers[4] * 16 + numbers[5];
            CGFloat const a = XZParseUIColorAlpha(numbers[6] * 16 + numbers[6]);
            return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a];
        }
        case 8:
        default: { // #123456AA => #123456AA
            CGFloat const r = numbers[0] * 16 + numbers[1];
            CGFloat const g = numbers[2] * 16 + numbers[3];
            CGFloat const b = numbers[4] * 16 + numbers[5];
            CGFloat const a = XZParseUIColorAlpha((numbers[6] * 16 + numbers[7]));
            return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a];
        }
            
    }
    return [UIColor clearColor];
}
