//
//  UIImage.h
//  XZKit
//
//  Created by Xezun on 2017/10/30.
//

#import <UIKit/UIKit.h>
#import <XZKit/XZColor.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (XZKit)

/// 读取 XZKit 中的资源库图片。
/// @param name 图片名字
/// @param traitCollection UITraitCollection
/// @return UIImage
+ (nullable UIImage *)XZKit:(NSString *)name compatibleWithTraitCollection:(nullable UITraitCollection *)traitCollection NS_SWIFT_NAME(init(XZKit:compatibleWith:));

/// 读取 XZKit 中的资源库图片。
/// @param name 图片名称
/// @return UIImage
+ (nullable UIImage *)XZKit:(NSString *)name NS_SWIFT_NAME(init(XZKit:));

@end

#pragma mark - 图片颜色混合

@interface UIImage (XZKitBlending)

// 命名：blend 需要宾语，因此用 blending 而不是 bended ：
// image blend (with) alpha => new image

/// 混合。改变图片透明度。
/// @param alpha 透明度
/// @return UIImage
- (nullable UIImage *)xz_imageByBlendingAlpha:(CGFloat)alpha NS_SWIFT_NAME(blendingAlpha(_:));

/// 混合，重新渲染图片颜色。
/// @param tintColor 图片渲染色。
/// @return 渲染后的图片。
- (nullable UIImage *)xz_imageByBlendingTintColor:(UIColor *)tintColor NS_SWIFT_NAME(blendingTintColor(_:));

@end

#pragma mark - 滤镜

/// 图片色阶输入。
typedef struct XZImageLevelsInput {
    /// 阴影。范围 0 ~ 1.0 ，默认 0 。
    CGFloat shadows;
    /// 中间调。范围 0 ~ 9.99 ，默认 1.0 。
    CGFloat midtones;
    /// 高光。范围 0 ~ 1.0 ，默认 1.0 。
    CGFloat highlights;
} XZImageLevelsInput;

/// 图片色阶输入默认值。
UIKIT_EXTERN XZImageLevelsInput const XZImageLevelsInputIdentity NS_SWIFT_NAME(XZImageLevelsInput.identity);

/// 构造图片色阶输入结构体。
FOUNDATION_STATIC_INLINE XZImageLevelsInput XZImageLevelsInputMake(CGFloat shadows, CGFloat midtones, CGFloat highlights) {
    return (XZImageLevelsInput){shadows, midtones, highlights};
}

/// 图片色阶输出。
typedef struct XZImageLevelsOutput {
    /// 阴影。范围 0 ~ 1.0 ，默认 0 。
    CGFloat shadows;
    /// 高光。范围 0 ~ 1.0 ，默认 1.0 。
    CGFloat highlights;
} XZImageLevelsOutput;

/// 图片色阶输出默认值。
UIKIT_EXTERN XZImageLevelsOutput const XZImageLevelsOutputIdentity NS_SWIFT_NAME(XZImageLevelsOutput.identity);

/// 构造图片色阶输出结构体。
FOUNDATION_STATIC_INLINE XZImageLevelsOutput XZImageLevelsOutputMake(CGFloat shadows, CGFloat highlights) {
    return (XZImageLevelsOutput){shadows, highlights};
}

@interface UIImage (XZKitFiltering)

/// 滤镜。改变图片亮度。
/// @note 图片处理属于高耗性能的操作。
/// @param brightness 图片亮度，取值范围 [0, 1.0]，默认 0.5
/// @return UIImage
- (nullable UIImage *)xz_imageByFilteringBrightness:(CGFloat)brightness NS_SWIFT_NAME(filteringBrightness(_:));

/// 图片色阶调整。
/// @see [Adobe Photoshop User Guide - Image adjustments](https://helpx.adobe.com/photoshop/using/levels-adjustment.html)
/// @param input 色阶输入
/// @param output 色阶输出
/// @param channels 待调整色阶的颜色通道
- (nullable UIImage *)xz_imageByFilteringLevelsInput:(XZImageLevelsInput)input output:(XZImageLevelsOutput)output inChannels:(XZColorChannels)channels NS_SWIFT_NAME(filteringLevels(input:output:in:));

@end

NS_ASSUME_NONNULL_END
