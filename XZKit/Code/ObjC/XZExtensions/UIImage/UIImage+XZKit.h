//
//  UIImage+XZKit.h
//  XZExtensions
//
//  Created by Xezun on 2024/6/12.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZDefines/XZMacros.h>)
#import <XZDefines/XZMacros.h>
#else
#import "XZMacros.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (XZKit)

/// 返回图片在指定倍率下的大小。
/// - Parameter scale: 倍率
- (CGSize)xz_sizeInScale:(CGFloat)targetScale NS_SWIFT_NAME(size(in:));

/// 绘制指定颜色、指定大小的图片。
/// - Parameters:
///   - color: 图片颜色
///   - size: 图片大小
+ (nullable UIImage *)xz_imageWithColor:(UIColor *)color size:(CGSize)size NS_SWIFT_NAME(init(_:size:));

/// 绘制指定颜色的图片，图片为长宽 1 像素。
/// - Parameter color: 图片颜色
+ (nullable UIImage *)xz_imageWithColor:(UIColor *)color NS_SWIFT_NAME(init(_:));

/// 绘制指定颜色的圆角图片。
/// - Parameters:
///   - color: 图片颜色
///   - radius: 圆角半径
+ (nullable UIImage *)xz_imageWithColor:(UIColor *)color radius:(CGFloat)radius NS_SWIFT_NAME(init(_:radius:));

/// 绘制图片。
/// - Parameters:
///   - imageGraphics: 绘制图片
///   - size: 图片大小
+ (nullable UIImage *)xz_imageWithGraphics:(void (^NS_NOESCAPE)(CGContextRef context))imageGraphics size:(CGSize)size NS_SWIFT_NAME(init(_:size:));

+ (nullable UIImage *)xz_animatedImageWithGIFImageData:(nullable NSData *)GIFImageData repeatCount:(NSInteger * _Nullable)repeatCount;
+ (nullable UIImage *)xz_animatedImageWithGIFImagePath:(nullable NSString *)GIFImagePath repeatCount:(NSInteger * _Nullable)repeatCount;

@end

#pragma mark - 图片颜色混合

@interface UIImage (XZKitBlending)

// 命名：blend 需要宾语，因此用 blending 而不是 bended ：
// image blend (with) alpha => new image

/// 混合。改变图片透明度。
/// @param alpha 透明度
/// @return UIImage
- (nullable UIImage *)xz_imageByBlendingAlpha:(CGFloat)alpha NS_SWIFT_NAME(blending(alpha:));

/// 混合，重新渲染图片颜色。
/// @param tintColor 图片渲染色。
/// @return 渲染后的图片。
- (nullable UIImage *)xz_imageByBlendingTintColor:(UIColor *)tintColor NS_SWIFT_NAME(blending(tintColor:));

@end

#pragma mark - 滤镜

/// 图片颜色通道。
typedef NS_OPTIONS(NSUInteger, XZImageColorChannels) {
    /// 红色通道。
    XZImageColorChannelRed   = 1 << 0,
    /// 绿色通道。
    XZImageColorChannelGreen = 1 << 1,
    /// 蓝色通道。
    XZImageColorChannelBlue  = 1 << 2,
    /// 透明通道。
    XZImageColorChannelAlpha = 1 << 3,
    /// RGB三通道。
    XZImageColorChannelRGB   = XZImageColorChannelRed | XZImageColorChannelGreen | XZImageColorChannelBlue,
    /// 所有通道。
    XZImageColorChannelRGBA  = XZImageColorChannelRGB | XZImageColorChannelAlpha,
};

/// 图片色阶输入。
typedef struct XZImageInputColorLevels {
    /// 输入阴影色阶。范围 0 ~ 1.0 ，默认 0 。
    CGFloat shadows;
    /// 输入中间调色阶。范围 0.01 ~ 9.99 ，默认 1.0 。
    CGFloat midtones;
    /// 输入高光色阶。范围 0 ~ 1.0 ，默认 1.0 。
    CGFloat highlights;
} XZImageInputColorLevels NS_SWIFT_NAME(XZImageColorLevels.Input);

/// 图片色阶输出。
typedef struct XZImageOutputColorLevels {
    /// 输出阴影色阶。范围 0 ~ 1.0 ，默认 0 。
    CGFloat shadows;
    /// 输出高光色阶。范围 0 ~ 1.0 ，默认 1.0 。
    CGFloat highlights;
} XZImageOutputColorLevels NS_SWIFT_NAME(XZImageColorLevels.Output);

/// 图片色阶。
typedef struct XZImageColorLevels {
    /// 输入色阶。
    XZImageInputColorLevels input;
    /// 输出色阶。
    XZImageOutputColorLevels output;
} XZImageColorLevels;

/// 构造图片色阶。
/// - Parameters:
///   - inShadows: 输入阴影色阶
///   - inMidtones: 输入中间色阶调
///   - inHighlights: 输入高亮色阶
///   - outShadows: 输出阴影色阶
///   - outHighlights: 高亮色阶输出
FOUNDATION_STATIC_INLINE XZImageColorLevels XZImageColorLevelsMake(CGFloat inputShadows, CGFloat midtones, CGFloat inputHighlights, CGFloat outputShadows, CGFloat outputHighlights) XZ_ATTR_OVERLOAD {
    return (XZImageColorLevels){{inputShadows, midtones, inputHighlights}, {outputShadows, outputHighlights}};
}

/// 构造图片色阶，仅输入。
/// - Parameters:
///   - inShadows: 输入阴影色阶
///   - inMidtones: 输入中间色阶调
///   - inHighlights: 输入高亮色阶
FOUNDATION_STATIC_INLINE XZImageColorLevels XZImageColorLevelsMake(CGFloat inputShadows, CGFloat midtones, CGFloat inputHighlights) XZ_ATTR_OVERLOAD {
    return (XZImageColorLevels){{ inputShadows, midtones, inputHighlights }, { 0, 1.0 }};
}

/// 构造图片色阶，仅输出。
/// - Parameters:
///   - outShadows: 输出阴影色阶
///   - outHighlights: 高亮色阶输出
FOUNDATION_STATIC_INLINE XZImageColorLevels XZImageColorLevelsMake(CGFloat outputShadows, CGFloat outputHighlights) XZ_ATTR_OVERLOAD {
    return (XZImageColorLevels){{ 0, 1.0, 1.0 }, { outputShadows, outputHighlights }};
}

@interface UIImage (XZKitFiltering)

/// 滤镜。改变图片亮度。
/// @note 图片处理属于高耗性能的操作。
/// @param brightness 图片亮度，取值范围 [0, 1.0]，默认 0.5
/// @return UIImage
- (nullable UIImage *)xz_imageByFilteringBrightness:(CGFloat)brightness NS_SWIFT_NAME(filtering(brightness:));

/// 图片色阶调整。
/// @seealso [Adobe Photoshop User Guide - Image adjustments](https://helpx.adobe.com/photoshop/using/levels-adjustment.html)
/// @param levels 色阶
/// @param channels 颜色通道
- (nullable UIImage *)xz_imageByFilteringLevels:(XZImageColorLevels)levels channels:(XZImageColorChannels)channels NS_SWIFT_NAME(filtering(levels:channels:));

@end

NS_ASSUME_NONNULL_END
