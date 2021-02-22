//
//  UIColor+XZColor.h
//  XZKit
//
//  Created by Xezun on 2021/2/22.
//

#import <UIKit/UIKit.h>
#import <XZKit/XZColor.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (XZColor)

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

NS_ASSUME_NONNULL_END
