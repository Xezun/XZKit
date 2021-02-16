//
//  UIColor.m
//  XZKit
//
//  Created by Xezun on 2017/10/24.
//

#define XZ_RGBA_COLOR
#import "UIColor+XZKit.h"

@implementation UIColor (XZKit)

- (XZColor)XZColor {
    CGFloat r = 0, g = 0, b = 0, a = 0;
    if ([self getRed:&r green:&g blue:&b alpha:&a]) {
        return XZColorMake(round(r * 255), round(g * 255), round(b * 255), round(a * 255));
    }
    return XZColorMake(0, 0, 0, 0);
}

+ (UIColor *)xz_colorWithXZColor:(XZColor)color {
    CGFloat const r = color.red   / 255.0;
    CGFloat const g = color.green / 255.0;
    CGFloat const b = color.blue  / 255.0;
    CGFloat const a = color.alpha / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

+ (UIColor *)xz_colorWithRGB:(NSInteger)rgb {
    CGFloat const red   = (rgb>>16&0xFF) / 255.0;
    CGFloat const green = (rgb>> 8&0xFF) / 255.0;
    CGFloat const blue  = (rgb>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

+ (UIColor *)xz_colorWithRGBA:(NSInteger)rgba {
    CGFloat const red   = (rgba>>24&0xFF) / 255.0;
    CGFloat const green = (rgba>>16&0xFF) / 255.0;
    CGFloat const blue  = (rgba>> 8&0xFF) / 255.0;
    CGFloat const alpha = (rgba>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)xz_colorWithRed:(NSInteger)red Green:(NSInteger)green Blue:(NSInteger)blue Alpha:(NSInteger)alpha {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

+ (instancetype)xz_colorWithString:(NSString *)string {
    XZColor const v = XZColorFromString(string);
    CGFloat const r = v.red   / 255.0;
    CGFloat const g = v.green / 255.0;
    CGFloat const b = v.blue  / 255.0;
    CGFloat const a = v.alpha / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

+ (UIColor *)xz_colorWithString:(NSString *)string alpha:(CGFloat)alpha {
    XZColor const v = XZColorFromString(string);
    CGFloat const r = v.red   / 255.0;
    CGFloat const g = v.green / 255.0;
    CGFloat const b = v.blue  / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}

@end


XZColor XZColorFromString(NSString *string) {
    if (string.length < 3) {
        return XZColorMake(0, 0, 0, 0);
    }
    
    const char * const characters = [string cStringUsingEncoding:(NSASCIIStringEncoding)];
    char numbers[9] = {0};  // 存储数字。
    NSInteger count = 0;    // numbers 的长度。
    
    // 满 8 位就不用继续查找了
    for (NSInteger i = 0; count < 8; i++) {
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

