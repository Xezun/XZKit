//
//  UIColor.m
//  XZKit
//
//  Created by Xezun on 2017/10/24.
//

#import "UIColor+XZKit.h"


@implementation UIColor (XZKit)

+ (instancetype)xz_colorWithString:(NSString *)string {
    if (![string hasPrefix:@"#"]) {
        return [UIColor clearColor];
    }
    
    NSInteger length = MIN([string lengthOfBytesUsingEncoding:NSASCIIStringEncoding], 9); // 只需找九位。
    const char *characters = [string cStringUsingEncoding:(NSASCIIStringEncoding)];
    char numbers[8] = {0};  // 存储数字。
    int numberOfBits = 0;   // numbers 的实际长度。
    for (NSInteger i = 1; i < length; i++) {
        char c = characters[i];
        if (c >= 'A' && c <= 'F') {
            numbers[numberOfBits] = c - 'A' + 10;
        } else if (c >= 'a' && c <= 'f') {
            numbers[numberOfBits] = c - 'a' + 10;
        } else if (c >= '0' && c <= '9') {
            numbers[numberOfBits] = c - '0';
        } else {
            break;
        }
        numberOfBits += 1;
    }
    
    switch (numberOfBits) {
        case 0: break;
        case 1: break;
        case 2: break;
        case 3:
        case 4:
        case 5: {
            XZColorValue red   = numbers[0] * 16 + numbers[0];
            XZColorValue green = numbers[1] * 16 + numbers[1];
            XZColorValue blue  = numbers[2] * 16 + numbers[2];
            return [UIColor colorWithRed:(CGFloat)red / 255.0 green:(CGFloat)green / 255.0 blue:(CGFloat)blue / 255.0 alpha:1.0];
        }
        case 6:
        case 7: {
            XZColorValue red   = numbers[0] * 16 + numbers[1];
            XZColorValue green = numbers[2] * 16 + numbers[3];
            XZColorValue blue  = numbers[4] * 16 + numbers[5];
            return [UIColor colorWithRed:(CGFloat)red / 255.0 green:(CGFloat)green / 255.0 blue:(CGFloat)blue / 255.0 alpha:1.0];
        }
        case 8:
        default: {
            XZColorValue red   = numbers[0] * 16 + numbers[1];
            XZColorValue green = numbers[2] * 16 + numbers[3];
            XZColorValue blue  = numbers[4] * 16 + numbers[5];
            XZColorValue alpha = numbers[6] * 16 + numbers[7];
            return [UIColor colorWithRed:(CGFloat)red / 255.0 green:(CGFloat)green / 255.0 blue:(CGFloat)blue / 255.0 alpha:(CGFloat)alpha / 255.0];
        }
            
    }
    return [UIColor clearColor];
}

+ (UIColor *)xz_colorWithColorValue:(XZColorValue)colorValue {
    XZColorValue const alpha = (colorValue & 0x000000FF) >> 0;
    XZColorValue const blue  = (colorValue & 0x0000FF00) >> 8;
    XZColorValue const green = (colorValue & 0x00FF0000) >> 16;
    XZColorValue const red   = (colorValue & 0xFF000000) >> 24;
    return [UIColor colorWithRed:(CGFloat)red / 255.0 green:(CGFloat)green / 255.0 blue:(CGFloat)blue / 255.0 alpha:(CGFloat)alpha / 255.0];
}

+ (UIColor *)xz_colorWithRedValue:(XZColorValue)redValue greenValue:(XZColorValue)greenValue blueValue:(XZColorValue)blueValue alphaValue:(XZColorValue)alphaValue {
    return [UIColor colorWithRed:(CGFloat)redValue / 255.0
                           green:(CGFloat)greenValue / 255.0
                            blue:(CGFloat)blueValue / 255.0
                           alpha:(CGFloat)alphaValue / 255.0];
}

- (XZColorValue)xz_rgbaValue {
    CGFloat r = 0, g = 0, b = 0, a = 0;
    if ([self getRed:&r green:&g blue:&b alpha:&a]) {
        XZColorValue red   = (XZColorValue)(r * 255);
        XZColorValue green = (XZColorValue)(g * 255);
        XZColorValue blue  = (XZColorValue)(b * 255);
        XZColorValue alpha = (XZColorValue)(a * 255);
        return alpha + (blue << 8) + (green << 16) + (red << 24);
    }
    return 0;
}


@end
