//
//  UIColor+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/2/22.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZDefines/XZMacros.h>)
#import <XZDefines/XZMacros.h>
#else
#import "XZMacros.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// 按 RGBA 顺序排列的 256 位颜色值。
typedef struct XZColor {
    /// 红色 [0, 255]
    UInt32 red : 8;
    /// 绿色 [0, 255]
    UInt32 green : 8;
    /// 蓝色 [0, 255]
    UInt32 blue : 8;
    /// 透明 [0, 255]
    UInt32 alpha : 8;
} XZColor;

@interface UIColor (XZKit)

/// 颜色的 RGBA 值。
@property (nonatomic, readonly) XZColor xzColor;

@end

// MARK: - XZColor

/// 从字符串中解析颜色 RGBA 值。
/// @param string 任意字符串
/// @param color 颜色值通过此参数输出，**必须不能为空指针**
/// @return 返回 NO 表示字符串不包含颜色值
UIKIT_EXTERN BOOL XZColorParser(NSString * _Nullable string, XZColor *color);

/// 通过 [0, 255] 颜色通道值，构造 XZColor 结构体。
FOUNDATION_STATIC_INLINE XZColor XZColorMake(UInt32 red, UInt32 green, UInt32 blue, UInt32 alpha) {
    return (XZColor){red, green, blue, alpha};
}

/// 将 RGBA 转换成整数形式。
/// @param rgba rgba 颜色
FOUNDATION_STATIC_INLINE NSInteger NSIntegerFromXZColor(XZColor rgba) {
    // 因为 UInt32 位数可能比 NSInteger 少。当 UInt32 首位为 1 时，会被当作负数转换为 NSInteger 导致结果与预期不一致，因此需要先提升位数再位移求和。
    return (((NSInteger)rgba.red << 24) + ((NSInteger)rgba.green << 16) + ((NSInteger)rgba.blue << 8) + rgba.alpha);
}

/// 将 XZColor 转化成如 #AABBCCFF 的字符串形式。
/// @param color XZColor
FOUNDATION_STATIC_INLINE NSString *NSStringFromXZColor(XZColor color) {
    return [NSString stringWithFormat:@"#%02X%02X%02X%02X", color.red, color.green, color.blue, color.alpha];
}

/// 将 UIColor 转化成字符串形式。
/// @param color UIColor
FOUNDATION_STATIC_INLINE NSString *NSStringFromUIColor(UIColor *color) {
    return NSStringFromXZColor(color.xzColor);
}



// MARK: - 便利函数

/// 如何避免命名冲突？
/// 在引用本头文件前，提前定义宏 XZ_RGBA_COLOR 可屏蔽下面的静态内联函数，避免命名冲突。
#ifndef XZ_RGBA_COLOR
#define XZ_RGBA_COLOR

// MARK: - RGBA

/// 通过十六进制整数形式的 0xRRGGBBAA 颜色值构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(int value) XZ_ATTR_OVERLOAD {
    CGFloat const red   = (value>>24&0xFF) / 255.0;
    CGFloat const green = (value>>16&0xFF) / 255.0;
    CGFloat const blue  = (value>> 8&0xFF) / 255.0;
    CGFloat const alpha = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/// 通过十六进制整数形式的 0xRRGGBBAA 颜色值构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(unsigned int value) XZ_ATTR_OVERLOAD {
    CGFloat const red   = (value>>24&0xFF) / 255.0;
    CGFloat const green = (value>>16&0xFF) / 255.0;
    CGFloat const blue  = (value>> 8&0xFF) / 255.0;
    CGFloat const alpha = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/// 通过十六进制整数形式的 0xRRGGBBAA 颜色值构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(long value) XZ_ATTR_OVERLOAD {
    CGFloat const red   = (value>>24&0xFF) / 255.0;
    CGFloat const green = (value>>16&0xFF) / 255.0;
    CGFloat const blue  = (value>> 8&0xFF) / 255.0;
    CGFloat const alpha = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/// 通过十六进制整数形式的 0xRRGGBBAA 颜色值构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(unsigned long value) XZ_ATTR_OVERLOAD {
    CGFloat const red   = (value>>24&0xFF) / 255.0;
    CGFloat const green = (value>>16&0xFF) / 255.0;
    CGFloat const blue  = (value>> 8&0xFF) / 255.0;
    CGFloat const alpha = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


// MARK: - RGB_A

/// 通过十六进制整数形式的 0xRRGGBB 颜色值和 [0, 1.0] alpha通道值，构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(int value, float alpha) XZ_ATTR_OVERLOAD {
    CGFloat const red   = (value>>16&0xFF) / 255.0;
    CGFloat const green = (value>> 8&0xFF) / 255.0;
    CGFloat const blue  = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/// 通过十六进制整数形式的 0xRRGGBB 颜色值和 [0, 1.0] alpha通道值，构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(unsigned int value, float alpha) XZ_ATTR_OVERLOAD {
    CGFloat const red   = (value>>16&0xFF) / 255.0;
    CGFloat const green = (value>> 8&0xFF) / 255.0;
    CGFloat const blue  = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/// 通过十六进制整数形式的 0xRRGGBB 颜色值和 [0, 1.0] alpha通道值，构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(long value, float alpha) XZ_ATTR_OVERLOAD {
    CGFloat const red   = (value>>16&0xFF) / 255.0;
    CGFloat const green = (value>> 8&0xFF) / 255.0;
    CGFloat const blue  = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/// 通过十六进制整数形式的 0xRRGGBB 颜色值和 alpha[0, 1.0] 通道值，构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(unsigned long value, float alpha) XZ_ATTR_OVERLOAD {
    CGFloat const red   = (value>>16&0xFF) / 255.0;
    CGFloat const green = (value>> 8&0xFF) / 255.0;
    CGFloat const blue  = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/// 通过十六进制整数形式的 0xRRGGBB 颜色值和 [0, 1.0] alpha通道值，构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(int value, double alpha) XZ_ATTR_OVERLOAD {
    CGFloat const red   = (value>>16&0xFF) / 255.0;
    CGFloat const green = (value>> 8&0xFF) / 255.0;
    CGFloat const blue  = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/// 通过十六进制整数形式的 0xRRGGBB 颜色值和 [0, 1.0] alpha通道值，构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(unsigned int value, double alpha) XZ_ATTR_OVERLOAD {
    CGFloat const red   = (value>>16&0xFF) / 255.0;
    CGFloat const green = (value>> 8&0xFF) / 255.0;
    CGFloat const blue  = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/// 通过十六进制整数形式的 0xRRGGBB 颜色值和 [0, 1.0] alpha通道值，构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(long value, double alpha) XZ_ATTR_OVERLOAD {
    CGFloat const red   = (value>>16&0xFF) / 255.0;
    CGFloat const green = (value>> 8&0xFF) / 255.0;
    CGFloat const blue  = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/// 通过十六进制整数形式的 0xRRGGBB 颜色值和 alpha[0, 1.0] 通道值，构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(unsigned long value, double alpha) XZ_ATTR_OVERLOAD {
    CGFloat const red   = (value>>16&0xFF) / 255.0;
    CGFloat const green = (value>> 8&0xFF) / 255.0;
    CGFloat const blue  = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


// MARK: - integer R_G_B_A
/// 通过 R、G、B、A 各个通道值 [0, 255] 构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(long red, long green, long blue, long alpha) XZ_ATTR_OVERLOAD {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

/// 通过 R、G、B、A 各个通道值 [0, 255] 构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(int red, int green, int blue, int alpha) XZ_ATTR_OVERLOAD {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

/// 通过 R、G、B、A 各个通道值 [0, 255] 构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(unsigned int red, unsigned int green, unsigned int blue, unsigned int alpha) XZ_ATTR_OVERLOAD {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

/// 通过 R、G、B、A 各个通道值 [0, 255] 构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(unsigned long red, unsigned long green, unsigned long blue, unsigned long alpha) XZ_ATTR_OVERLOAD {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

/// 由 [0, 255] 的  R、G、B 通道值和 [0, 1.0] 的 alpha 通道值构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(int red, int green, int blue, double alpha) XZ_ATTR_OVERLOAD {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

/// 由 [0, 255] 的  R、G、B 通道值和 [0, 1.0] 的 alpha 通道值构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(int red, int green, int blue, float alpha) XZ_ATTR_OVERLOAD {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

/// 由 [0, 255] 的  R、G、B 通道值和 [0, 1.0] 的 alpha 通道值构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(long red, long green, long blue, double alpha) XZ_ATTR_OVERLOAD {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

/// 由 [0, 255] 的  R、G、B 通道值和 [0, 1.0] 的 alpha 通道值构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(long red, long green, long blue, float alpha) XZ_ATTR_OVERLOAD {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

// MARK: - float R_G_B_A
/// 通过 R、G、B、A 各个通道值 [0, 1.0] 构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(float red, float green, float blue, float alpha) XZ_ATTR_OVERLOAD {
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/// 通过 R、G、B、A 各个通道值 [0, 1.0] 构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(double red, double green, double blue, double alpha) XZ_ATTR_OVERLOAD {
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


// MARK: - RGB
/// 通过十六进制整数形式的 0xRRGGBB 颜色值构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgb(int value) XZ_ATTR_OVERLOAD {
    CGFloat const red   = (value>>16&0xFF) / 255.0;
    CGFloat const green = (value>> 8&0xFF) / 255.0;
    CGFloat const blue  = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

/// 通过十六进制整数形式的 0xRRGGBB 颜色值构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgb(long value) XZ_ATTR_OVERLOAD {
    CGFloat const red   = (value>>16&0xFF) / 255.0;
    CGFloat const green = (value>> 8&0xFF) / 255.0;
    CGFloat const blue  = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

/// 通过十六进制整数形式的 0xRRGGBB 颜色值构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgb(unsigned int value) XZ_ATTR_OVERLOAD {
    CGFloat const red   = (value>>16&0xFF) / 255.0;
    CGFloat const green = (value>> 8&0xFF) / 255.0;
    CGFloat const blue  = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

/// 通过十六进制整数形式的 0xRRGGBB 颜色值构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgb(unsigned long value) XZ_ATTR_OVERLOAD {
    CGFloat const red   = (value>>16&0xFF) / 255.0;
    CGFloat const green = (value>> 8&0xFF) / 255.0;
    CGFloat const blue  = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}


// MARK: - integer R_G_B
/// 通过 R、G、B 各通道值 [0, 255] 构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgb(long red, long green, long blue) XZ_ATTR_OVERLOAD {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

/// 通过 R、G、B 各通道值 [0, 255] 构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgb(int red, int green, int blue) XZ_ATTR_OVERLOAD {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

/// 通过 R、G、B 各通道值 [0, 255] 构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgb(unsigned long red, unsigned long green, unsigned long blue) XZ_ATTR_OVERLOAD {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

/// 通过 R、G、B 各通道值 [0, 255] 构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgb(unsigned int red, unsigned int green, unsigned int blue) XZ_ATTR_OVERLOAD {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}


// MARK: - integer R_G_B
/// 通过 R、G、B 各通道值 [0, 1.0] 构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgb(float red, float green, float blue) XZ_ATTR_OVERLOAD {
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}
/// 通过 R、G、B 各通道值 [0, 1.0] 构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgb(double red, double green, double blue) XZ_ATTR_OVERLOAD {
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}


// MARK: - String RGBA

/// 通过 rgba 字符串构造 UIColor 对象，并指定字符串解析失败时的默认颜色。
FOUNDATION_STATIC_INLINE UIColor * _Nullable rgba(NSString * _Nullable string, UIColor * _Nullable defaultColor) XZ_ATTR_OVERLOAD {
    XZColor color;
    if (XZColorParser(string, &color)) {
        CGFloat const red   = color.red   / 255.0;
        CGFloat const green = color.green / 255.0;
        CGFloat const blue  = color.blue  / 255.0;
        CGFloat const alpha = color.alpha / 255.0;
        return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
    }
    return defaultColor;
}

/// 通过 rgba 字符串构造 UIColor 对象，如果字符串解析失败则使用默认颜色颜值创建。
FOUNDATION_STATIC_INLINE UIColor *rgba(NSString * _Nullable string, long defaultColorRGBA) XZ_ATTR_OVERLOAD {
    XZColor color;
    if (XZColorParser(string, &color)) {
        CGFloat const red   = color.red   / 255.0;
        CGFloat const green = color.green / 255.0;
        CGFloat const blue  = color.blue  / 255.0;
        CGFloat const alpha = color.alpha / 255.0;
        return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
    }
    return rgba(defaultColorRGBA);
}

/// 通过 rgba 字符串构造 UIColor 对象，如果字符串解析失败则使用默认颜色颜值创建。
FOUNDATION_STATIC_INLINE UIColor *rgba(NSString * _Nullable string, int defaultColorRGBA) XZ_ATTR_OVERLOAD {
    XZColor color;
    if (XZColorParser(string, &color)) {
        CGFloat const red   = color.red   / 255.0;
        CGFloat const green = color.green / 255.0;
        CGFloat const blue  = color.blue  / 255.0;
        CGFloat const alpha = color.alpha / 255.0;
        return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
    }
    return rgba(defaultColorRGBA);
}

/// 通过 rgba 字符串构造 UIColor 对象，默认返回透明色。
FOUNDATION_STATIC_INLINE UIColor *rgba(NSString * _Nullable string) XZ_ATTR_OVERLOAD {
    XZColor color;
    if (XZColorParser(string, &color)) {
        CGFloat const red   = color.red   / 255.0;
        CGFloat const green = color.green / 255.0;
        CGFloat const blue  = color.blue  / 255.0;
        CGFloat const alpha = color.alpha / 255.0;
        return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
    }
    return UIColor.clearColor;
}


// MARK: - String RGB,A

/// 通过 rgb 字符串构造 UIColor 对象，并指定 alpha 通道值，如果字符串解析失败则使用默认颜色。
FOUNDATION_STATIC_INLINE UIColor * _Nullable rgba(NSString *string, float alpha, UIColor * _Nullable defaultColor) XZ_ATTR_OVERLOAD {
    XZColor color;
    if (XZColorParser(string, &color)) {
        CGFloat const red   = color.red   / 255.0;
        CGFloat const green = color.green / 255.0;
        CGFloat const blue  = color.blue  / 255.0;
        return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
    }
    return defaultColor;
}

/// 通过 rgb 字符串构造 UIColor 对象，并指定 alpha 通道值，如果字符串解析失败则使用默认颜色。
FOUNDATION_STATIC_INLINE UIColor * _Nullable rgba(NSString *string, double alpha, UIColor * _Nullable defaultColor) XZ_ATTR_OVERLOAD {
    XZColor color;
    if (XZColorParser(string, &color)) {
        CGFloat const red   = color.red   / 255.0;
        CGFloat const green = color.green / 255.0;
        CGFloat const blue  = color.blue  / 255.0;
        return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
    }
    return defaultColor;
}

/// 通过 rgb 字符串构造 UIColor 对象，并指定 alpha 通道值，如果字符串解析失败则使用默认颜色值创建。
FOUNDATION_STATIC_INLINE UIColor *rgba(NSString *string, float alpha, int defaultColorRGB) XZ_ATTR_OVERLOAD {
    XZColor color;
    if (XZColorParser(string, &color)) {
        CGFloat const red   = color.red   / 255.0;
        CGFloat const green = color.green / 255.0;
        CGFloat const blue  = color.blue  / 255.0;
        return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
    }
    return rgba(defaultColorRGB, alpha);
}

/// 通过 rgb 字符串构造 UIColor 对象，并指定 alpha 通道值，如果字符串解析失败则使用默认颜色值创建。
FOUNDATION_STATIC_INLINE UIColor *rgba(NSString *string, float alpha, long defaultColorRGB) XZ_ATTR_OVERLOAD {
    XZColor color;
    if (XZColorParser(string, &color)) {
        CGFloat const red   = color.red   / 255.0;
        CGFloat const green = color.green / 255.0;
        CGFloat const blue  = color.blue  / 255.0;
        return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
    }
    return rgba(defaultColorRGB, alpha);
}

/// 通过 rgb 字符串构造 UIColor 对象，并指定 alpha 通道值，如果字符串解析失败则使用默认颜色值创建。
FOUNDATION_STATIC_INLINE UIColor *rgba(NSString *string, double alpha, int defaultColorRGB) XZ_ATTR_OVERLOAD {
    XZColor color;
    if (XZColorParser(string, &color)) {
        CGFloat const red   = color.red   / 255.0;
        CGFloat const green = color.green / 255.0;
        CGFloat const blue  = color.blue  / 255.0;
        return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
    }
    return rgba(defaultColorRGB, alpha);
}

/// 通过 rgb 字符串构造 UIColor 对象，并指定 alpha 通道值，如果字符串解析失败则使用默认颜色值创建。
FOUNDATION_STATIC_INLINE UIColor *rgba(NSString *string, double alpha, long defaultColorRGB) XZ_ATTR_OVERLOAD {
    XZColor color;
    if (XZColorParser(string, &color)) {
        CGFloat const red   = color.red   / 255.0;
        CGFloat const green = color.green / 255.0;
        CGFloat const blue  = color.blue  / 255.0;
        return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
    }
    return rgba(defaultColorRGB, alpha);
}

/// 通过 rgb 字符串构造 UIColor 对象，并指定 alpha 通道值，如果字符串解析失败则返回透明色。
FOUNDATION_STATIC_INLINE UIColor *rgba(NSString *string, double alpha) XZ_ATTR_OVERLOAD {
    XZColor color;
    if (XZColorParser(string, &color)) {
        CGFloat const red   = color.red   / 255.0;
        CGFloat const green = color.green / 255.0;
        CGFloat const blue  = color.blue  / 255.0;
        return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
    }
    return UIColor.clearColor;
}

/// 通过字符串构造颜色，默认返回透明色。
FOUNDATION_STATIC_INLINE UIColor *rgba(NSString *string, float alpha) XZ_ATTR_OVERLOAD {
    XZColor color;
    if (XZColorParser(string, &color)) {
        CGFloat const red   = color.red   / 255.0;
        CGFloat const green = color.green / 255.0;
        CGFloat const blue  = color.blue  / 255.0;
        return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
    }
    return UIColor.clearColor;
}

#pragma mark - String RGB

/// 通过 rgb 字符串构造 UIColor 对象，如果字符串解析失败则使用默认颜色。
FOUNDATION_STATIC_INLINE UIColor * _Nullable rgb(NSString *string, UIColor * _Nullable defaultColor) XZ_ATTR_OVERLOAD {
    XZColor color;
    if (XZColorParser(string, &color)) {
        CGFloat const red   = color.red   / 255.0;
        CGFloat const green = color.green / 255.0;
        CGFloat const blue  = color.blue  / 255.0;
        return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:1.0];
    }
    return defaultColor;
}

/// 通过 rgb 字符串构造 UIColor 对象，如果字符串解析失败则使用默认颜色值创建。
FOUNDATION_STATIC_INLINE UIColor *rgb(NSString *string, int defaultColorRGB) XZ_ATTR_OVERLOAD {
    XZColor color;
    if (XZColorParser(string, &color)) {
        CGFloat const red   = color.red   / 255.0;
        CGFloat const green = color.green / 255.0;
        CGFloat const blue  = color.blue  / 255.0;
        return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:1.0];
    }
    return rgb(defaultColorRGB);
}

/// 通过 rgb 字符串构造 UIColor 对象，如果字符串解析失败则使用默认颜色值创建。
FOUNDATION_STATIC_INLINE UIColor *rgb(NSString *string, long defaultColorRGB) XZ_ATTR_OVERLOAD {
    XZColor color;
    if (XZColorParser(string, &color)) {
        CGFloat const red   = color.red   / 255.0;
        CGFloat const green = color.green / 255.0;
        CGFloat const blue  = color.blue  / 255.0;
        return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:1.0];
    }
    return rgb(defaultColorRGB);
}

/// 通过 rgb 字符串构造 UIColor 对象，如果字符串解析失败则使用默认颜色值创建。
FOUNDATION_STATIC_INLINE UIColor *rgb(NSString *string) XZ_ATTR_OVERLOAD {
    XZColor color;
    if (XZColorParser(string, &color)) {
        CGFloat const red   = color.red   / 255.0;
        CGFloat const green = color.green / 255.0;
        CGFloat const blue  = color.blue  / 255.0;
        return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:1.0];
    }
    return UIColor.clearColor;
}

#endif

NS_ASSUME_NONNULL_END
