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
    NSInteger red;
    /// 绿色 [0, 255]
    NSInteger green;
    /// 蓝色 [0, 255]
    NSInteger blue;
    /// 透明 [0, 255]
    NSInteger alpha;
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
@property (nonatomic, readonly) XZRGBA xz_rgbaValue NS_SWIFT_NAME(xzColor);

/// 通过一个用十六进制数表示的 RGBA 颜色值创建 UIColor 对象。
/// @note 数字必须是 RGBA 值。
/// @param rgbaValue An RGBA value like 0xAABBCCFF.
/// @return UIColor
+ (UIColor *)xz_colorWithRGBA:(XZRGBA)rgbaValue NS_SWIFT_NAME(init(_:));

/// 通过十六进制数表示的颜色值字符串，创建 UIColor 。
/// @param string A string like #F00 or #1A2B3C or #1A2B3CFF.
/// @return UIColor
+ (UIColor *)xz_colorWithString:(NSString *)string NS_SWIFT_NAME(init(_:));

/// 通过十六进制数表示的颜色值字符串，创建 UIColor 。
/// @note 如果 alpha 参数小于 0 将被忽略。
/// @param string A string like #F00 or #1A2B3C or #1A2B3CFF
/// @param alpha The alpha
+ (UIColor *)xz_colorWithString:(NSString *)string alpha:(CGFloat)alpha NS_SWIFT_NAME(init(_:alpha:));

@end

FOUNDATION_STATIC_INLINE XZRGBA XZRGBAMake(NSInteger red, NSInteger green, NSInteger blue, NSInteger alpha) NS_SWIFT_UNAVAILABLE("Use Color.init instead") {
    return (XZRGBA){red, green, blue, alpha};
}

/// 通过 RGBA 的整数形式构造 RGBA 颜色。
/// @param rgbaValue RGBA 的整数形式
UIKIT_EXTERN XZRGBA XZRGBAFromInteger(NSInteger rgbaValue) NS_SWIFT_NAME(Color.init(_:));
/// 解析字符串中符合颜色值（连续3位以上的十六进制字符）的部分。
/// @param string 包含颜色值的字符串
UIKIT_EXTERN XZRGBA XZRGBAFromString(NSString *string) NS_SWIFT_NAME(Color.init(_:));
/// 将 RGBA 转换成整数形式。
/// @param rgba rgba 颜色
UIKIT_EXTERN NSInteger XZIntegerFromRGBA(XZRGBA rgba) NS_REFINED_FOR_SWIFT;


/// 通过 XZRGBA 构造 UIColor 对象。
/// @param rgba RGBA 颜色值
UIKIT_EXTERN UIColor *__XZ_RGBA_COLOR__(XZRGBA rgba) XZ_OVERLOAD XZ_OBJC;

UIKIT_EXTERN UIColor *__XZ_RGBA_COLOR__(NSInteger value) XZ_OVERLOAD XZ_OBJC;
UIKIT_EXTERN UIColor *__XZ_RGBA_COLOR__(NSString *string) XZ_OVERLOAD XZ_OBJC;
UIKIT_EXTERN UIColor *__XZ_RGBA_COLOR__(long red, long green, long blue, long alpha) XZ_OVERLOAD XZ_OBJC;
UIKIT_EXTERN UIColor *__XZ_RGBA_COLOR__(int red, int green, int blue, int alpha) XZ_OVERLOAD XZ_OBJC;
UIKIT_EXTERN UIColor *__XZ_RGBA_COLOR__(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) XZ_OVERLOAD XZ_OBJC;

UIKIT_EXTERN UIColor *__XZ_RGB_COLOR__(NSInteger value) XZ_OVERLOAD XZ_OBJC;
UIKIT_EXTERN UIColor *__XZ_RGB_COLOR__(NSString *string) XZ_OVERLOAD XZ_OBJC;
UIKIT_EXTERN UIColor *__XZ_RGB_COLOR__(long red, long green, long blue) XZ_OVERLOAD XZ_OBJC;
UIKIT_EXTERN UIColor *__XZ_RGB_COLOR__(int red, int green, int blue) XZ_OVERLOAD XZ_OBJC;
UIKIT_EXTERN UIColor *__XZ_RGB_COLOR__(CGFloat red, CGFloat green, CGFloat blue) XZ_OVERLOAD XZ_OBJC;


#ifndef XZ_RGBA_COLOR
/// 如果 rgb/rgba 已使用，可通过 XZ_RGBA_COLOR 宏屏蔽这里的定义，避免冲突。
#define XZ_RGBA_COLOR
/// 通过字符串形式的 RGB 颜色值构造 UIColor 对象。
UIKIT_EXTERN UIColor *rgb(NSString *string) XZ_OVERLOAD XZ_OBJC;
/// 通过整数形式的 RGB 颜色值构造 UIColor 对象。
UIKIT_EXTERN UIColor *rgb(NSInteger value) XZ_OVERLOAD XZ_OBJC;
/// 通过 RGB 值 [0, 255] 构造 UIColor 对象。
UIKIT_EXTERN UIColor *rgb(NSInteger red, NSInteger green, NSInteger blue) XZ_OVERLOAD XZ_OBJC;
/// 通过 RGB 值 [0, 1.0] 构造 UIColor 对象。
UIKIT_EXTERN UIColor *rgb(CGFloat red, CGFloat green, CGFloat blue) XZ_OVERLOAD XZ_OBJC;
#undef rgb
#define rgb(...) __XZ_RGB_COLOR__(__VA_ARGS__)
UIKIT_EXTERN UIColor *rgba(XZRGBA rgba) XZ_OVERLOAD XZ_OBJC;
/// 通过字符串形式的 RGBA 颜色值构造 UIColor 对象。
UIKIT_EXTERN UIColor *rgba(NSString *string) XZ_OVERLOAD XZ_OBJC;
/// 通过整数形式的 RGBA 颜色值构造 UIColor 对象。
UIKIT_EXTERN UIColor *rgba(NSInteger value) XZ_OVERLOAD XZ_OBJC;
/// 通过 RGBA 值 [0, 255] 构造 UIColor 对象。
UIKIT_EXTERN UIColor *rgba(NSInteger red, NSInteger green, NSInteger blue, NSInteger alpha) XZ_OVERLOAD XZ_OBJC;
/// 通过 RGBA 值 [0, 1.0] 构造 UIColor 对象。
UIKIT_EXTERN UIColor *rgba(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) XZ_OVERLOAD XZ_OBJC;
#undef rgba
#define rgba(...) __XZ_RGBA_COLOR__(__VA_ARGS__)
#else
#define XZRGBColor(...)   __XZ_RGB_COLOR__(__VA_ARGS__)
#define XZRGBAColor(...)  __XZ_RGBA_COLOR__(__VA_ARGS__)
#endif

NS_ASSUME_NONNULL_END
