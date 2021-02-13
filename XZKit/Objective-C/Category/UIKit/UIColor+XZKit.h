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
    NSInteger red   : 8;
    NSInteger green : 8;
    NSInteger blue  : 8;
    NSInteger alpha : 8;
} XZRGBA NS_SWIFT_NAME(RGBA);

/// 颜色通道。
typedef NS_OPTIONS(NSUInteger, XZColorChannel) {
    XZColorChannelRed   NS_SWIFT_NAME(red)   = 1 << 0,
    XZColorChannelGreen NS_SWIFT_NAME(green) = 1 << 1,
    XZColorChannelBlue  NS_SWIFT_NAME(blue)  = 1 << 2,
    XZColorChannelAlpha NS_SWIFT_NAME(alpha) = 1 << 3,
    XZColorChannelsRGB  NS_SWIFT_NAME(rgb)   = XZColorChannelRed | XZColorChannelGreen | XZColorChannelBlue,
    XZColorChannelsAll  NS_SWIFT_NAME(all)   = ~0l,
};

@interface UIColor (XZKit)

/// 颜色的 RGBA 值。
@property (nonatomic, readonly) XZRGBA xz_rgbaValue NS_SWIFT_NAME(rgba);

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

FOUNDATION_STATIC_INLINE XZRGBA XZRGBAMake(NSInteger red, NSInteger green, NSInteger blue, NSInteger alpha) {
    return (XZRGBA){red&0xFF, green&0xFF, blue&0xFF, alpha&0xFF};
}

FOUNDATION_STATIC_INLINE XZRGBA XZRGBAFromNSInteger(NSInteger value) {
    return XZRGBAMake(value>>24, value>>16, value>>8, value);
}

FOUNDATION_STATIC_INLINE NSInteger NSIntegerFromXZRGBA(XZRGBA rgba) {
    return rgba.alpha + (rgba.blue << 8) + (rgba.green << 16) + (rgba.red << 24);
}

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

FOUNDATION_STATIC_INLINE UIColor *rgba(NSInteger red, NSInteger green, NSInteger blue, NSInteger alpha) XZ_OVERLOAD {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

FOUNDATION_STATIC_INLINE UIColor *rgba(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) XZ_OVERLOAD {
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/// 通过 RGB 值构造 UIColor 对象。
/// @param value RGB 颜色值
FOUNDATION_STATIC_INLINE UIColor *rgb(NSInteger value) XZ_OVERLOAD {
    CGFloat const red   = (value>>16&0xFF) / 255.0;
    CGFloat const green = (value>> 8&0xFF) / 255.0;
    CGFloat const blue  = (value>> 0&0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

FOUNDATION_STATIC_INLINE UIColor *rgb(NSInteger red, NSInteger green, NSInteger blue) XZ_OVERLOAD {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

FOUNDATION_STATIC_INLINE UIColor *rgb(CGFloat red, CGFloat green, CGFloat blue) XZ_OVERLOAD {
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

/// 通过形如“#1A2B3C”十六进制的字符串构造 UIColor 对象。
/// @param colorString 颜色值字符串
/// @param alpha 指定 alpha 通道，如果小于 0 则表示不指定，默认 1.0
FOUNDATION_EXPORT UIColor *XZUIColorFromNSString(NSString *colorString, CGFloat alpha);

FOUNDATION_STATIC_INLINE UIColor *rgb(NSString *colorString) XZ_OVERLOAD {
    return XZUIColorFromNSString(colorString, +1.0);
}

FOUNDATION_STATIC_INLINE UIColor *rgba(NSString *colorString) XZ_OVERLOAD {
    return XZUIColorFromNSString(colorString, -1.0);
}

NS_ASSUME_NONNULL_END
