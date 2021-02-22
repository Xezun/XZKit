//
//  UIColor+XZColor.m
//  XZKit
//
//  Created by Xezun on 2021/2/22.
//

#import "UIColor+XZColor.h"

@implementation UIColor (XZColor)

- (XZColor)XZColor {
    CGFloat r = 0, g = 0, b = 0, a = 0;
    if ([self getRed:&r green:&g blue:&b alpha:&a]) {
        return XZColorMake(round(r * 255), round(g * 255), round(b * 255), round(a * 255));
    }
    return XZColorMake(0, 0, 0, 0);
}

+ (UIColor *)xz_colorWithXZColor:(XZColor)color {
    return rgba(color);
}

+ (UIColor *)xz_colorWithRGB:(NSInteger)value {
    return rgb(value);
}

+ (UIColor *)xz_colorWithRGBA:(NSInteger)value {
    return rgba(value);
}

+ (UIColor *)xz_colorWithRed:(NSInteger)red Green:(NSInteger)green Blue:(NSInteger)blue Alpha:(NSInteger)alpha {
    return rgba(red, green, blue, alpha);
}

+ (instancetype)xz_colorWithString:(NSString *)string {
    return rgba(string);
}

+ (UIColor *)xz_colorWithString:(NSString *)string alpha:(CGFloat)alpha {
    return rgba(string, alpha);
}

@end
