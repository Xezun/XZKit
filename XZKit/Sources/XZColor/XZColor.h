//
//  XZColor.h
//  XZKit
//
//  Created by Xezun on 2021/2/22.
//

#import <UIKit/UIKit.h>
#import <XZKit/XZKitDefines.h>

NS_ASSUME_NONNULL_BEGIN

/// 按 RGBA 顺序排列的 256 位颜色值。
typedef struct XZColor {
    /// 红色 [0, 255]
    NSInteger red;
    /// 绿色 [0, 255]
    NSInteger green;
    /// 蓝色 [0, 255]
    NSInteger blue;
    /// 透明 [0, 255]
    NSInteger alpha;
} XZColor;

/// 颜色通道。
typedef NS_OPTIONS(NSUInteger, XZColorChannel) {
    /// 红色通道。
    XZColorChannelRed   = 1 << 0,
    /// 绿色通道。
    XZColorChannelGreen = 1 << 1,
    /// 蓝色通道。
    XZColorChannelBlue  = 1 << 2,
    /// 透明通道。
    XZColorChannelAlpha = 1 << 3,
    /// RGB三通道。
    XZColorChannelRGB   = XZColorChannelRed | XZColorChannelGreen | XZColorChannelBlue,
    /// 所有通道。
    XZColorChannelAll   = ~0l,
} NS_SWIFT_NAME(XZColor.Channel);


FOUNDATION_STATIC_INLINE XZColor XZColorMake(NSInteger red, NSInteger green, NSInteger blue, NSInteger alpha) XZ_OVERLOAD {
    return (XZColor){red, green, blue, alpha};
}

/// 通过 RGBA 的整数形式构造 RGBA 颜色。
/// @param rgbaValue RGBA 的整数形式
FOUNDATION_STATIC_INLINE XZColor XZColorMake(NSInteger rgbaValue) XZ_OVERLOAD {
    return XZColorMake((rgbaValue>>24)&0xFF, (rgbaValue>>16)&0xFF, (rgbaValue>>8)&0xFF, rgbaValue&0xFF);
}

/// 将 RGBA 转换成整数形式。
/// @param color rgba 颜色
FOUNDATION_STATIC_INLINE NSInteger XZIntegerFromColor(XZColor color) {
    return color.alpha + (color.blue << 8) + (color.green << 16) + (color.red << 24);
}

/// 解析字符串中符合颜色值（连续3位以上的十六进制字符）的部分。
/// @param string 包含颜色值的字符串
UIKIT_EXTERN XZColor XZColorFromString(NSString *string) NS_SWIFT_NAME(XZColor.init(_:));

FOUNDATION_STATIC_INLINE NSString *NSStringFromXZColor(XZColor color) {
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX%02lX", (long)color.red, (long)color.green, (long)color.blue, (long)color.alpha];
}

/// 解决命名冲突的办法：
/// 在引用本头文件前，提前定义宏 XZ_COLOR_RGBA_FUNCS 可屏蔽下面的静态内联函数，即避免命名冲突。
#ifndef XZ_COLOR_RGBA_FUNCS
#define XZ_COLOR_RGBA_FUNCS

/// 通过 XZRGBA 构造 UIColor 对象。
/// @param rgba RGBA 颜色值
FOUNDATION_STATIC_INLINE UIColor *rgba(XZColor rgba) XZ_OVERLOAD XZ_OBJC {
    CGFloat const red   = rgba.red   / 255.0;
    CGFloat const green = rgba.green / 255.0;
    CGFloat const blue  = rgba.blue  / 255.0;
    CGFloat const alpha = rgba.alpha / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark - RGBA

/// 通过整数形式的 RGBA 颜色值构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(NSInteger value) XZ_OVERLOAD XZ_OBJC {
    CGFloat const red   = (value>>24&0xFF) / 255.0;
    CGFloat const green = (value>>16&0xFF) / 255.0;
    CGFloat const blue  = (value>> 8&0xFF) / 255.0;
    CGFloat const alpha = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

FOUNDATION_STATIC_INLINE UIColor *rgba(NSInteger value, CGFloat alpha) XZ_OVERLOAD XZ_OBJC {
    CGFloat const red   = (value>>16&0xFF) / 255.0;
    CGFloat const green = (value>> 8&0xFF) / 255.0;
    CGFloat const blue  = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/// 通过 RGBA 值 [0, 255] 构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(long red, long green, long blue, long alpha) XZ_OVERLOAD XZ_OBJC {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

/// 通过 RGBA 值 [0, 255] 构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(int red, int green, int blue, int alpha) XZ_OVERLOAD XZ_OBJC {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

/// 通过 RGBA 值 [0, 1.0] 构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) XZ_OVERLOAD XZ_OBJC {
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark - RGB

/// 通过整数形式的 RGB 颜色值构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgb(NSInteger value) XZ_OVERLOAD XZ_OBJC {
    CGFloat const red   = (value>>16&0xFF) / 255.0;
    CGFloat const green = (value>> 8&0xFF) / 255.0;
    CGFloat const blue  = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

/// 通过 RGB 值 [0, 255] 构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgb(long red, long green, long blue) XZ_OVERLOAD XZ_OBJC {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

/// 通过 RGB 值 [0, 255] 构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgb(int red, int green, int blue) XZ_OVERLOAD XZ_OBJC {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

/// 通过 RGB 值 [0, 1.0] 构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgb(CGFloat red, CGFloat green, CGFloat blue) XZ_OVERLOAD XZ_OBJC {
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

#pragma mark - String RGB(A)

/// 通过字符串形式的 RGBA 颜色值构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(NSString *string) XZ_OVERLOAD XZ_OBJC {
    XZColor const value = XZColorFromString(string);
    return rgba(value.red, value.green, value.blue, value.alpha);
}

/// 通过字符串形式的 RGBA 颜色值构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(NSString *string, CGFloat alpha) XZ_OVERLOAD XZ_OBJC {
    XZColor const value = XZColorFromString(string);
    CGFloat const red   = value.red / 255.0;
    CGFloat const green = value.green / 255.0;
    CGFloat const blue  = value.blue / 255.0;
    return rgba(red, green, blue, alpha);
}

/// 通过字符串形式的 RGB 颜色值构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgb(NSString *string) XZ_OVERLOAD XZ_OBJC {
    XZColor const value = XZColorFromString(string);
    return rgb(value.red, value.green, value.blue);
}


#endif

NS_ASSUME_NONNULL_END
