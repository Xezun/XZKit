//
//  UIColor.h
//  XZKit
//
//  Created by mlibai on 2017/10/24.
//

#import <UIKit/UIKit.h>

/// 用十六进制值的整数表示颜色 RGBA 值，如 0xFF0000FF 。
/// @note UInt32 整数。
typedef UInt32 XZColorValue NS_SWIFT_NAME(ColorValue);

@interface UIColor (XZKit)

@property (nonatomic, readonly) XZColorValue xz_rgbaValue NS_SWIFT_NAME(rgbaValue);

/// 通过十六进制数表示的颜色值字符串，创建 UIColor 。
/// @note 1. 字符串必须以 # 开头。
/// @note 2. 颜色值将按照十六进制数的位数来决定，有效位数为 3、6、8 ，优先最小位数。
/// @note 3. 默认返回值为 UIColor.clearColor 。
///
/// @param string A string like #F00 or #1A2B3C or #1A2B3CFF.
/// @return UIColor
+ (nonnull UIColor *)xz_colorWithString:(nonnull NSString *)string NS_SWIFT_NAME(init(_:));

/// 通过一个用十六进制数表示的 RGBA 颜色值创建 UIColor 对象。
/// @note 数字必须是 RGBA 值。
///
/// @param colorValue An RGBA value like 0xAABBCCFF.
/// @return UIColor
+ (nonnull UIColor *)xz_colorWithColorValue:(XZColorValue)colorValue NS_SWIFT_NAME(init(_:));

/// 通过用 0 ~ 255 表示的颜色通道分量值，创建 UIColor 。
///
/// @param redValue The red value, 0 ~ 255 .
/// @param greenValue The green value, 0 ~ 255 .
/// @param blueValue The blue value, 0 ~ 255 .
/// @param alphaValue The alpha value, 0 ~ 255 .
/// @return UIColor
+ (nonnull UIColor *)xz_colorWithRedValue:(XZColorValue)redValue greenValue:(XZColorValue)greenValue blueValue:(XZColorValue)blueValue alphaValue:(XZColorValue)alphaValue NS_SWIFT_NAME(init(Red:Green:Blue:Alpha:));

@end
