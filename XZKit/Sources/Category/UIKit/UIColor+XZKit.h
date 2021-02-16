//
//  UIColor.h
//  XZKit
//
//  Created by Xezun on 2017/10/24.
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

@interface UIColor (XZKit)

/// 颜色的 RGBA 值。
@property (nonatomic, readonly) XZColor XZColor NS_SWIFT_NAME(xzColor);

/// 通过一个用十六进制数表示的 RGBA 颜色值创建 UIColor 对象。
/// @note 数字必须是 RGBA 值。
/// @param color An XZColor value
/// @return UIColor
+ (UIColor *)xz_colorWithXZColor:(XZColor)color NS_SWIFT_NAME(init(_:));

/// 通过一个用十六进制数表示的 RGBA 颜色值创建 UIColor 对象。
/// @note 数字必须是 RGBA 值。
/// @param rgb An RGBA value like 0xAABBCC
/// @return UIColor
+ (UIColor *)xz_colorWithRGB:(NSInteger)rgb NS_SWIFT_NAME(init(rgb:));

/// 通过一个用十六进制数表示的 RGBA 颜色值创建 UIColor 对象。
/// @note 数字必须是 RGBA 值。
/// @param rgba An RGBA value like 0xAABBCCFF
/// @return UIColor
+ (UIColor *)xz_colorWithRGBA:(NSInteger)rgba NS_SWIFT_NAME(init(rgba:));

/// 使用 [0, 255] 颜色通道值创建 UIColor 对象。
/// @param red [0, 255]
/// @param green [0, 255]
/// @param blue [0, 255]
/// @param alpha [0, 255]
+ (UIColor *)xz_colorWithRed:(NSInteger)red Green:(NSInteger)green Blue:(NSInteger)blue Alpha:(NSInteger)alpha NS_SWIFT_NAME(init(Red:Green:Blue:Alpha:));

/// 通过十六进制数表示的颜色值字符串，创建 UIColor 。
/// @param string A string like #F00 or #1A2B3C or #1A2B3CFF.
/// @return UIColor
+ (UIColor *)xz_colorWithString:(NSString *)string NS_SWIFT_NAME(init(_:));

/// 通过十六进制数表示的颜色值字符串，创建 UIColor 。
/// @note 从字符串中读取的 alpha 值将被忽略。
/// @param string A string like #F00 or #1A2B3C or #1A2B3CFF
/// @param alpha The alpha
+ (UIColor *)xz_colorWithString:(NSString *)string alpha:(CGFloat)alpha NS_SWIFT_NAME(init(_:alpha:));

@end


#pragma mark - XZColor

FOUNDATION_STATIC_INLINE XZColor XZColorMake(NSInteger red, NSInteger green, NSInteger blue, NSInteger alpha) XZ_OVERLOAD XZ_OBJC {
    return (XZColor){red, green, blue, alpha};
}

/// 通过 RGBA 的整数形式构造 RGBA 颜色。
/// @param rgbaValue RGBA 的整数形式
FOUNDATION_STATIC_INLINE XZColor XZColorMake(NSInteger rgbaValue) XZ_OVERLOAD XZ_OBJC {
    return XZColorMake((rgbaValue>>24)&0xFF, (rgbaValue>>16)&0xFF, (rgbaValue>>8)&0xFF, rgbaValue&0xFF);
}

/// 将 RGBA 转换成整数形式。
/// @param rgba rgba 颜色
FOUNDATION_STATIC_INLINE NSInteger XZIntegerFromColor(XZColor rgba) XZ_OBJC {
    return rgba.alpha + (rgba.blue << 8) + (rgba.green << 16) + (rgba.red << 24);
}

/// 解析字符串中符合颜色值（连续3位以上的十六进制字符）的部分。
/// @param string 包含颜色值的字符串
UIKIT_EXTERN XZColor XZColorFromString(NSString *string) NS_SWIFT_NAME(XZColor.init(_:));



#pragma mark - 便利函数

/// 解决命名冲突：
/// 在引用本头文件前，提前定义宏 XZ_RGBA_COLOR 可屏蔽下面的静态内联函数，避免命名冲突。
#ifndef XZ_RGBA_COLOR
#define XZ_RGBA_COLOR

#pragma mark - RGBA

/// 通过 XZRGBA 构造 UIColor 对象。
/// @param rgba RGBA 颜色值
FOUNDATION_STATIC_INLINE UIColor *rgba(XZColor rgba) XZ_OVERLOAD XZ_OBJC {
    CGFloat const red   = rgba.red   / 255.0;
    CGFloat const green = rgba.green / 255.0;
    CGFloat const blue  = rgba.blue  / 255.0;
    CGFloat const alpha = rgba.alpha / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/// 通过整数形式的 RGBA 颜色值构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(NSInteger value) XZ_OVERLOAD XZ_OBJC {
    CGFloat const red   = (value>>24&0xFF) / 255.0;
    CGFloat const green = (value>>16&0xFF) / 255.0;
    CGFloat const blue  = (value>> 8&0xFF) / 255.0;
    CGFloat const alpha = (value>> 0&0xFF) / 255.0;
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

/// 通过字符串形式的 RGB 颜色值构造 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgb(NSString *string) XZ_OVERLOAD XZ_OBJC {
    XZColor const value = XZColorFromString(string);
    return rgb(value.red, value.green, value.blue);
}

#endif

NS_ASSUME_NONNULL_END
