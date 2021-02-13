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
typedef struct XZRGBA {
    /// 红色 [0, 255]
    NSInteger red  : 8;
    /// 绿色 [0, 255]
    NSInteger green: 8;
    /// 蓝色 [0, 255]
    NSInteger blue : 8;
    /// 透明 [0, 255]
    NSInteger alpha: 8;
} NS_SWIFT_NAME(Color) XZRGBA;

/// 颜色通道。
typedef NS_OPTIONS(NSUInteger, XZRGBAChannel) {
    /// 红色通道。
    XZRGBAChannelRed   = 1 << 0,
    /// 绿色通道。
    XZRGBAChannelGreen = 1 << 1,
    /// 蓝色通道。
    XZRGBAChannelBlue  = 1 << 2,
    /// 透明通道。
    XZRGBAChannelAlpha = 1 << 3,
    /// RGB三通道。
    XZRGBAChannelRGB   = XZRGBAChannelRed | XZRGBAChannelGreen | XZRGBAChannelBlue,
    /// 所有通道。
    XZRGBAChannelAll   = ~0l,
} NS_SWIFT_NAME(Color.Channel);

@interface UIColor (XZKit)

/// 颜色的 RGBA 值。
@property (nonatomic, readonly) XZRGBA xz_rgbaValue NS_SWIFT_NAME(color);

/// 通过一个用十六进制数表示的 RGBA 颜色值创建 UIColor 对象。
/// @note 数字必须是 RGBA 值。
/// @param rgbaValue An RGBA value like 0xAABBCCFF.
/// @return UIColor
+ (UIColor *)xz_colorWithRGBA:(XZRGBA)rgbaValue NS_SWIFT_NAME(init(_:));

/// 通过十六进制数表示的颜色值字符串，创建 UIColor 。
/// @param string A string like #F00 or #1A2B3C or #1A2B3CFF.
/// @return UIColor
+ (UIColor *)xz_colorWithString:(NSString *)string NS_SWIFT_NAME(init(_:));

@end

FOUNDATION_STATIC_INLINE XZRGBA XZRGBAMake(NSInteger red, NSInteger green, NSInteger blue, NSInteger alpha) NS_SWIFT_UNAVAILABLE("Use Color.init instead") {
    return (XZRGBA){red&0xFF, green&0xFF, blue&0xFF, alpha&0xFF};
}

/// 通过 RGBA 的整数形式构造 RGBA 颜色。
/// @param rgbaValue RGBA 的整数形式
UIKIT_EXTERN XZRGBA XZRGBAFromNSInteger(NSInteger rgbaValue) NS_SWIFT_NAME(Color.init(_:));

/// 将 RGBA 转换成整数形式。
/// @param rgba rgba 颜色
UIKIT_EXTERN NSInteger NSIntegerFromXZRGBA(XZRGBA rgba) NS_REFINED_FOR_SWIFT;

/// 通过 XZRGBA 构造 UIColor 对象。
/// @param rgba RGBA 颜色值
FOUNDATION_STATIC_INLINE UIColor *rgba(XZRGBA rgba) XZ_OVERLOAD {
    CGFloat const red   = rgba.red   / 255.0;
    CGFloat const green = rgba.green / 255.0;
    CGFloat const blue  = rgba.blue  / 255.0;
    CGFloat const alpha = rgba.alpha / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/// 通过 RGBA 值构造 UIColor 对象。
/// @param value RGBA 颜色值
FOUNDATION_STATIC_INLINE UIColor *rgba(NSInteger value) XZ_OVERLOAD {
    CGFloat const red   = (value>>24&0xFF) / 255.0;
    CGFloat const green = (value>>16&0xFF) / 255.0;
    CGFloat const blue  = (value>> 8&0xFF) / 255.0;
    CGFloat const alpha = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/// 通过 RGBA[0, 255] 通道值构建 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(NSInteger red, NSInteger green, NSInteger blue, NSInteger alpha) XZ_OVERLOAD {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

/// 通过 RGBA[0, 1.0] 通道值构建 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgba(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) XZ_OVERLOAD {
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/// 通过整数形式的 RGB 值构造 UIColor 对象。
/// @param value RGB 颜色值
FOUNDATION_STATIC_INLINE UIColor *rgb(NSInteger value) XZ_OVERLOAD {
    CGFloat const red   = (value>>16&0xFF) / 255.0;
    CGFloat const green = (value>> 8&0xFF) / 255.0;
    CGFloat const blue  = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

/// 通过 RGB[0, 255] 通道值构建 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgb(NSInteger red, NSInteger green, NSInteger blue) XZ_OVERLOAD {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

/// 通过 RGB[0, 1.0] 通道值构建 UIColor 对象。
FOUNDATION_STATIC_INLINE UIColor *rgb(CGFloat red, CGFloat green, CGFloat blue) XZ_OVERLOAD {
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

/// 通过形如“#1A2B3C”十六进制的字符串构造 UIColor 对象。
/// @param colorString 颜色值字符串
/// @param alpha 指定 alpha 通道，如果小于 0 则表示不指定，默认 1.0
FOUNDATION_EXPORT UIColor *XZUIColorFromNSString(NSString *colorString, CGFloat alpha) NS_SWIFT_UNAVAILABLE("User UIColor.init(_:) instead");

/// 通过颜色值字符串创建 UIColor 对象，忽略 alpha 通道。
FOUNDATION_STATIC_INLINE UIColor *rgb(NSString *colorString) XZ_OVERLOAD {
    return XZUIColorFromNSString(colorString, +1.0);
}

/// 通过颜色值字符串创建 UIColor 对象，默认 alpha 通道为 1.0 。
FOUNDATION_STATIC_INLINE UIColor *rgba(NSString *colorString) XZ_OVERLOAD {
    return XZUIColorFromNSString(colorString, -1.0);
}

NS_ASSUME_NONNULL_END
