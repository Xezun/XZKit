//
//  UIImage+XZImage.h
//  XZKit
//
//  Created by Xezun on 2021/2/23.
//

#import <UIKit/UIKit.h>
#import <XZKit/XZImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (XZImage)

/// 根据指定条件绘制图片。
/// @param image XZImage
/// @return 绘制的图片。
+ (nullable UIImage *)xz_imageWithXZImage:(XZImage *)image NS_SWIFT_NAME(init(_:));

/// 滤镜。改变图片色阶。
/// @note 图片处理属于高耗性能的操作。
/// @param levels 色阶。
/// @return UIImage
- (nullable UIImage *)xz_imageByFilteringImageLevels:(XZImageLevels)levels NS_SWIFT_NAME(filtering(_:));

@end

NS_ASSUME_NONNULL_END
