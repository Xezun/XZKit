//
//  XZImageLevels.h
//  XZKit
//
//  Created by Xezun on 2021/2/18.
//

#import <UIKit/UIKit.h>
#import <XZKit/XZKitDefines.h>
#import <XZKit/UIColor+XZKit.h>

NS_ASSUME_NONNULL_BEGIN

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

UIKIT_EXTERN UIImage *XZImageFilterImageWithLevels(UIImage *image, XZImageLevels const levels);

NS_ASSUME_NONNULL_END
