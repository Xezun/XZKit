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
    return __XZ_RGBA_COLOR__(rgbaValue);
}

+ (instancetype)xz_colorWithString:(NSString *)string {
    XZRGBA const value = XZRGBAFromString(string);
    return __XZ_RGBA_COLOR__(value);
}

+ (UIColor *)xz_colorWithString:(NSString *)string alpha:(CGFloat)alpha {
    XZRGBA value = XZRGBAFromString(string);
    value.alpha = alpha;
    return __XZ_RGBA_COLOR__(value);
}

@end


#pragma mark - RGBA

UIColor *__XZ_RGBA_COLOR__(NSInteger value) XZ_OVERLOAD {
    CGFloat const red   = (value>>24&0xFF) / 255.0;
    CGFloat const green = (value>>16&0xFF) / 255.0;
    CGFloat const blue  = (value>> 8&0xFF) / 255.0;
    CGFloat const alpha = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

UIColor *__XZ_RGBA_COLOR__(long red, long green, long blue, long alpha) XZ_OVERLOAD {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

UIColor *__XZ_RGBA_COLOR__(int red, int green, int blue, int alpha) XZ_OVERLOAD {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

UIColor *__XZ_RGBA_COLOR__(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) XZ_OVERLOAD {
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


#pragma mark - RGB

UIColor *__XZ_RGB_COLOR__(NSInteger value) XZ_OVERLOAD {
    CGFloat const red   = (value>>16&0xFF) / 255.0;
    CGFloat const green = (value>> 8&0xFF) / 255.0;
    CGFloat const blue  = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

UIColor *__XZ_RGB_COLOR__(long red, long green, long blue) XZ_OVERLOAD {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

UIColor *__XZ_RGB_COLOR__(int red, int green, int blue) XZ_OVERLOAD {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

UIColor *__XZ_RGB_COLOR__(CGFloat red, CGFloat green, CGFloat blue) XZ_OVERLOAD {
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}


#pragma mark - String RGB(A)

UIColor *__XZ_RGBA_COLOR__(NSString *string) XZ_OVERLOAD {
    XZRGBA const value = XZRGBAFromString(string);
    return __XZ_RGBA_COLOR__(value.red, value.green, value.blue, value.alpha);
}

UIColor *__XZ_RGB_COLOR__(NSString *string) XZ_OVERLOAD {
    XZRGBA const value = XZRGBAFromString(string);
    return __XZ_RGB_COLOR__(value.red, value.green, value.blue);
}


#pragma mark - XZRGBA

UIColor *__XZ_RGBA_COLOR__(XZRGBA rgba) XZ_OVERLOAD {
    CGFloat const red   = rgba.red   / 255.0;
    CGFloat const green = rgba.green / 255.0;
    CGFloat const blue  = rgba.blue  / 255.0;
    CGFloat const alpha = rgba.alpha / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

XZRGBA XZRGBAFromInteger(NSInteger rgbaValue) {
    return XZRGBAMake(rgbaValue>>24, rgbaValue>>16, rgbaValue>>8, rgbaValue);
}

NSInteger XZIntegerFromRGBA(XZRGBA rgba) {
    return rgba.alpha + (rgba.blue << 8) + (rgba.green << 16) + (rgba.red << 24);
}

XZRGBA XZRGBAFromString(NSString *string) {
    if (string.length < 3) {
        return XZRGBAMake(0, 0, 0, 0);
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
            return XZRGBAMake(r, g, b, 255);
        }
        case 4: { // #ABCD => #AABBCCDD
            CGFloat const r = numbers[0] * 16 + numbers[0];
            CGFloat const g = numbers[1] * 16 + numbers[1];
            CGFloat const b = numbers[2] * 16 + numbers[2];
            CGFloat const a = numbers[3] * 16 + numbers[3];
            return XZRGBAMake(r, g, b, a);
        }
        case 5: { // #ABCDE => #AABBCCDE
            CGFloat const r = numbers[0] * 16 + numbers[0];
            CGFloat const g = numbers[1] * 16 + numbers[1];
            CGFloat const b = numbers[2] * 16 + numbers[2];
            CGFloat const a = numbers[3] * 16 + numbers[4];
            return XZRGBAMake(r, g, b, a);
        }
        case 6:{ // #123456 => #123456FF
            CGFloat const r = numbers[0] * 16 + numbers[1];
            CGFloat const g = numbers[2] * 16 + numbers[3];
            CGFloat const b = numbers[4] * 16 + numbers[5];
            return XZRGBAMake(r, g, b, 255);
        }
        case 7: { // #123456A => #123456AA
            CGFloat const r = numbers[0] * 16 + numbers[1];
            CGFloat const g = numbers[2] * 16 + numbers[3];
            CGFloat const b = numbers[4] * 16 + numbers[5];
            CGFloat const a = numbers[6] * 16 + numbers[6];
            return XZRGBAMake(r, g, b, a);
        }
        case 8: { // #123456AA => #123456AA
            CGFloat const r = numbers[0] * 16 + numbers[1];
            CGFloat const g = numbers[2] * 16 + numbers[3];
            CGFloat const b = numbers[4] * 16 + numbers[5];
            CGFloat const a = numbers[6] * 16 + numbers[7];
            return XZRGBAMake(r, g, b, a);
        }
        default: {
            return XZRGBAMake(0, 0, 0, 0);
        }
    }
}

