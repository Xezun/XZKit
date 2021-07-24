//
//  UIImage.h
//  XZKit
//
//  Created by Xezun on 2017/10/30.
//

#import <UIKit/UIKit.h>

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
- (nullable UIImage *)xz_imageByBlendingAlpha:(CGFloat)alpha NS_SWIFT_NAME(blending(alpha:));

/// 混合，重新渲染图片颜色。
/// @param tintColor 图片渲染色。
/// @return 渲染后的图片。
- (nullable UIImage *)xz_imageByBlendingColor:(UIColor *)tintColor NS_SWIFT_NAME(blending(_:));

@end

#pragma mark - 滤镜

@interface UIImage (XZKitFiltering)

/// 滤镜。改变图片亮度。
/// @note 图片处理属于高耗性能的操作。
/// @param brightness 图片亮度，取值范围 [0, 1.0]，默认 0.5
/// @return UIImage
- (nullable UIImage *)xz_imageByFilteringBrightness:(CGFloat)brightness NS_SWIFT_NAME(filtering(brightness:));

@end


NS_ASSUME_NONNULL_END
