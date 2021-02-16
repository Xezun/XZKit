//
//  UIImage.h
//  XZKit
//
//  Created by Xezun on 2017/10/30.
//

#import <UIKit/UIKit.h>
#import <XZKit/XZKitDefines.h>
#import <XZKit/UIColor+XZKit.h>
#import <XZKit/XZKit+Geometry.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct XZImageBorderDash {
    CGFloat width;
    CGFloat space;
} NS_SWIFT_NAME(XZImageBorder.Dash) XZImageBorderDash;

typedef struct XZImageBorderArrow {
    /// 底边中点，距离其所在边的中点的距离
    CGFloat center;
    /// 顶点，距离其所在边的中点的距离
    CGFloat vector;
    /// 底宽
    CGFloat width;
    /// 高
    CGFloat height;
} NS_SWIFT_NAME(XZImageBorder.Arrow) XZImageBorderArrow;

/// 图片边框。
typedef struct XZImageBorder {
    /// 边框颜色
    XZColor color;
    /// 边框粗细
    CGFloat width;
    /// 虚线
    XZImageBorderDash dash;
    /// 箭头
    XZImageBorderArrow arrow;
} NS_SWIFT_NAME(XZImageBorders.Item) XZImageBorder;

/// 图片矩形的四边。
typedef struct XZImageBorders {
    XZImageBorder top;
    XZImageBorder left;
    XZImageBorder bottom;
    XZImageBorder right;
} NS_SWIFT_NAME(XZImage.Borders) XZImageBorders;

/// 图片矩形的顶角。
typedef struct XZImageCorner {
    /// 圆角半径
    CGFloat radius;
    /// 线条颜色 RGBA
    XZColor color;
    /// 线条粗细
    CGFloat width;
} NS_SWIFT_NAME(XZImageCorners.Item) XZImageCorner;

/// 图片矩形的的四个角。
typedef struct XZImageCorners {
    XZImageCorner topLeft;
    XZImageCorner bottomLeft;
    XZImageCorner bottomRight;
    XZImageCorner topRight;
} NS_SWIFT_NAME(XZImage.Corners) XZImageCorners;

/// 描述了一种简单图片。
typedef struct XZImage {
    /// 图片大小。
    CGSize size;
    /// 背景色。
    XZColor backgroundColor;
    /// 四边。
    XZImageBorders borders;
    /// 四角。
    XZImageCorners corners;
    /// 内边距。
    UIEdgeInsets contentInsets;
} XZImage;

/// 图片色阶输入。
typedef struct XZImageLevelsInput {
    /// 阴影。范围 0 ~ 1.0 ，默认 0 。
    CGFloat shadows;
    /// 中间调。范围 0 ~ 9.99 ，默认 1.0 。
    CGFloat midtones;
    /// 高光。范围 0 ~ 1.0 ，默认 1.0 。
    CGFloat highlights;
} NS_SWIFT_NAME(XZImageLevels.Input) XZImageLevelsInput;

/// 图片色阶输出。
typedef struct XZImageLevelsOutput {
    /// 阴影。范围 0 ~ 1.0 ，默认 0 。
    CGFloat shadows;
    /// 高光。范围 0 ~ 1.0 ，默认 1.0 。
    CGFloat highlights;
} NS_SWIFT_NAME(XZImageLevels.Output) XZImageLevelsOutput;

/// 图片色阶。
/// @see [Adobe Photoshop User Guide - Image adjustments](https://helpx.adobe.com/photoshop/using/levels-adjustment.html)
typedef struct XZImageLevels {
    /// 输入
    XZImageLevelsInput input;
    /// 输出
    XZImageLevelsOutput output;
    /// 通道
    XZColorChannel channels;
} NS_SWIFT_NAME(XZImage.Levels) XZImageLevels;


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

/// 滤镜。改变图片色阶。
/// @note 图片处理属于高耗性能的操作。
/// @param levels 色阶。
/// @return UIImage
- (nullable UIImage *)xz_imageByFilteringImageLevels:(XZImageLevels)levels NS_SWIFT_NAME(filtering(_:));

@end

#pragma mark - XZImage

FOUNDATION_STATIC_INLINE XZImageBorder XZImageBorderMake(XZColor color, CGFloat width, CGFloat dashWidth, CGFloat dashSpace) {
    XZImageBorder border;
    border.width = width;
    border.color = color;
    border.dash  = (XZImageBorderDash){dashWidth, dashSpace};
    // 所有成员必须初始化，否则可能发生不预料的问题。
    border.arrow = (XZImageBorderArrow){0, 0, 0, 0};
    return border;
}

FOUNDATION_STATIC_INLINE XZImageCorner XZImageCornerMake(CGFloat radius, XZColor color, CGFloat width) {
    return (XZImageCorner){radius, color, width};
}

/// 创建 XZImage 结构体的便利函数。
/// @param size 图片大小
/// @param backgroundColor 背景色
/// @param borderColor 边颜色
/// @param borderWidth 边粗细
/// @param cornerRadius 圆角半径
FOUNDATION_STATIC_INLINE XZImage XZImageMake(CGSize size, XZColor backgroundColor, XZColor borderColor, CGFloat borderWidth, CGFloat cornerRadius) XZ_OVERLOAD {
    XZImageBorder const border = XZImageBorderMake(borderColor, borderWidth, 0, 0);
    XZImageCorner const corner = XZImageCornerMake(cornerRadius, borderColor, borderWidth);
    return (XZImage){size, backgroundColor, {border, border, border, border}, {corner, corner, corner, corner}};
}

//FOUNDATION_STATIC_INLINE XZImage XZImageMake(XZColor backgroundColor, XZColor borderColor, CGFloat borderWidth, CGFloat cornerRadius) XZ_OVERLOAD {
//    
//}

UIKIT_EXTERN void XZImageDrawAtPoint(const XZImage *image, CGPoint point);

@interface UIImage (XZKitDrawing)

/// 根据指定条件绘制图片。
/// @param image XZImage
/// @return 绘制的图片。
+ (nullable UIImage *)xz_imageWithXZImage:(XZImage)image NS_SWIFT_NAME(init(_:));

@end


UIKIT_EXTERN XZImageLevelsInput const XZImageLevelsInputIdentity NS_SWIFT_NAME(XZImageLevelsInput.identity);
UIKIT_EXTERN XZImageLevelsOutput const XZImageLevelsOutputIdentity NS_SWIFT_NAME(XZImageLevelsOutput.identity);

FOUNDATION_STATIC_INLINE XZImageLevelsInput XZImageLevelsInputMake(CGFloat shadows, CGFloat midtones, CGFloat highlights) NS_SWIFT_UNAVAILABLE("Use init instead") {
    return (XZImageLevelsInput){shadows, midtones, highlights};
}

FOUNDATION_STATIC_INLINE XZImageLevelsOutput XZImageLevelsOutputMake(CGFloat shadows, CGFloat highlights) {
    return (XZImageLevelsOutput){shadows, highlights};
}

UIKIT_STATIC_INLINE XZImageLevels XZImageLevelsMake(XZImageLevelsInput input, XZImageLevelsOutput output, XZColorChannel channels) XZ_OVERLOAD NS_SWIFT_UNAVAILABLE("Use init instead") {
    return (XZImageLevels){input, output, channels};
}

UIKIT_STATIC_INLINE XZImageLevels XZImageLevelsMake(XZImageLevelsInput input, XZImageLevelsOutput output) XZ_OVERLOAD NS_SWIFT_UNAVAILABLE("Use init instead") {
    return (XZImageLevels){input, output, XZColorChannelRGB};
}

/// 构造色阶。
UIKIT_STATIC_INLINE XZImageLevels XZImageLevelsMake(CGFloat shadows, CGFloat midtones, CGFloat highlights, CGFloat outputShadows, CGFloat outputHighlights, XZColorChannel channels) XZ_OVERLOAD NS_SWIFT_UNAVAILABLE("Use init instead") {
    return (XZImageLevels){{shadows, midtones, highlights}, {outputShadows, outputHighlights}, channels};
}

/// 构造色阶：默认输出，RGB通道。
UIKIT_STATIC_INLINE XZImageLevels XZImageLevelsMake(CGFloat shadows, CGFloat midtones, CGFloat highlights) XZ_OVERLOAD NS_SWIFT_UNAVAILABLE("Use init instead") {
    return (XZImageLevels){{shadows, midtones, highlights}, XZImageLevelsOutputIdentity, XZColorChannelRGB};
}

NS_ASSUME_NONNULL_END
