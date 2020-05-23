//
//  UIImage.m
//  XZKit
//
//  Created by Xezun on 2017/10/30.
//

#import "UIImage+XZKit.h"
#import "NSBundle+XZKit.h"

@import CoreGraphics;
@import CoreImage;

#pragma mark - XZKit 图片

@implementation UIImage (XZKit)

+ (UIImage *)XZKit:(NSString *)name {
    return [self XZKit:name compatibleWithTraitCollection:nil];
}

+ (UIImage *)XZKit:(NSString *)name compatibleWithTraitCollection:(UITraitCollection *)traitCollection {
#if COCOAPODS
    NSURL *imageBundleURL = [NSBundle.XZKitBundle URLForResource:@"XZKit" withExtension:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithURL:imageBundleURL];
    return [UIImage imageNamed:name inBundle:imageBundle compatibleWithTraitCollection:traitCollection];
#else
    return [UIImage imageNamed:name inBundle:[NSBundle XZKitBundle] compatibleWithTraitCollection:traitCollection];
#endif
}

@end



#pragma mark - 绘制纯色图片

@implementation UIImage (XZKitDrawing)

+ (UIImage *)xz_imageWithFillColor:(UIColor *)fillColor borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius roundCorners:(UIRectCorner)roundCorners size:(CGSize)imageSize {
    CGRect imageRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    CGRect innerRect = CGRectInset(imageRect, borderWidth * 0.5, borderWidth * 0.5);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:innerRect byRoundingCorners:roundCorners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];;
    
    CGContextAddPath(context, path.CGPath);
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    // 无圆角时，关闭抗锯齿，避免发虚
    CGContextSetShouldAntialias(context, cornerRadius > 0);
    // 线条粗细必须使用 context 进行设置，对 path 进行设置无效
    CGContextSetLineWidth(context, borderWidth);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end




@implementation UIImage (XZKitBlending)

#pragma mark - 更改图片的透明度

- (UIImage *)xz_imageWithBlendingAlpha:(CGFloat)alpha {
    CGImageRef cgImage = self.CGImage;
    if (cgImage == nil) {
        return nil;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == nil) {
        return nil;
    }
    
    CGSize imageSize = self.size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -imageSize.height);
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    CGContextSetAlpha(context, alpha);
    CGContextDrawImage(context, CGRectMake(0, 0, imageSize.width, imageSize.height), cgImage);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)xz_imageWithBlendingColor:(UIColor *)tintColor {
    CGSize imageSize = self.size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, imageSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    UIImage * _Nullable newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

@end


XZColorLevels const XZColorLevelsIdentity = {0.0, 1.0, 1.0};

@implementation UIImage (XZKitFiltering)

#pragma mark - 图片亮度

- (UIImage *)xz_imageWithFilteringBrightness:(CGFloat)brightness {
    if (brightness == 0) {
        return self;
    }
    CGImageRef cgImage = [self CGImage];
    if (cgImage == nil) {
        return nil;
    }
    
    CIImage *inputImage = [CIImage imageWithCGImage:cgImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:@(brightness) forKey:kCIInputBrightnessKey];
    
    CIImage *outputImage = [filter outputImage];
    if (outputImage == nil) {
        return nil;
    }
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef dataImage = [context createCGImage:outputImage fromRect:outputImage.extent];
    if (dataImage == nil) {
        return nil;
    }
    UIImage *image = [UIImage imageWithCGImage:dataImage];
    CGImageRelease(dataImage);
    
    return image;
}

#pragma mark - 色阶

- (UIImage *)xz_imageWithFilteringColorLevels:(XZColorLevels)colorLevels {
    if (XZColorLevelsEqualToLevels(colorLevels, XZColorLevelsIdentity)) {
        return self;
    }
    
    // 检查并修正范围。
    
    colorLevels.min = MAX(0, MIN(1.00, colorLevels.min));
    colorLevels.max = MAX(colorLevels.min, MIN(1.00, colorLevels.max));
    colorLevels.mid = MAX(0, MIN(10.0, colorLevels.mid));
    
    CIImage *ciImage = [self CIImage];
    if (ciImage == nil) {
        CGImageRef cgImage = [self CGImage];
        if (cgImage == nil) {
            return  nil;
        }
        ciImage = [CIImage imageWithCGImage:cgImage];
    }
    
    // 改变色彩范围
    // Doc: https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/#//apple_ref/doc/filter/ci/CIColorClamp
    // 将小于最小值的值增加到最小值，将大于最大值的减少到最大值。
    
    CIFilter *filter1 = [CIFilter filterWithName:@"CIColorClamp"];
    [filter1 setDefaults];
    [filter1 setValue:ciImage forKey:kCIInputImageKey];
    
    CIVector *minComponents = [CIVector vectorWithX:colorLevels.min Y:colorLevels.min Z:colorLevels.min W:0.0];
    CIVector *maxComponents = [CIVector vectorWithX:colorLevels.max Y:colorLevels.max Z:colorLevels.max W:1.0];
    [filter1 setValue:minComponents forKey:@"inputMinComponents"];
    [filter1 setValue:maxComponents forKey:@"inputMaxComponents"];
    
    // 颜色多项式
    // Doc: https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/#//apple_ref/doc/filter/ci/CIColorPolynomial
    // 将上述步骤缩小的范围的颜色空间 [min, max] ，均匀分布到全部颜色空间 [0, 1.0] 。
    
    CIFilter *filter2 = [CIFilter filterWithName:@"CIColorPolynomial"];
    [filter2 setDefaults];
    [filter2 setValue:filter1.outputImage forKey:kCIInputImageKey];
    
    CGFloat x = colorLevels.min / (colorLevels.min - colorLevels.max);
    CGFloat y = 1.0 / (colorLevels.max - colorLevels.min);
    
    CIVector *inputCoefficients = [CIVector vectorWithX:x Y:y Z:0 W:0];
    [filter2 setValue:inputCoefficients forKey:@"inputRedCoefficients"];
    [filter2 setValue:inputCoefficients forKey:@"inputGreenCoefficients"];
    [filter2 setValue:inputCoefficients forKey:@"inputBlueCoefficients"];
    // [filter2 setValue:inputCoefficients forKey:@"inputAlphaCoefficients"];
    
    // 调整中间调，网上有大神推出 PS 中间调计算公式为 pow(x, 1 / mid) ：http://blog.sina.com.cn/s/blog_470fe4710100i084.html
    // OpenGL 代码示例：https://blog.csdn.net/panda1234lee/article/details/52269462
    // Doc: https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/#//apple_ref/doc/filter/ci/CIGammaAdjust
    // pow(s.rgb, vec3(power))
    
    CIFilter *filter3 = [CIFilter filterWithName:@"CIGammaAdjust"];
    [filter3 setDefaults];
    [filter3 setValue:filter2.outputImage forKey:kCIInputImageKey];
    [filter3 setValue:[NSNumber numberWithDouble:(double)(1.0 / colorLevels.mid)] forKey:@"inputPower"];
    
    CIImage *outputImage = filter3.outputImage;
    
    if (outputImage == nil) {
        return nil;
    }
    
    CIContext *context = [CIContext context];
    CGImageRef resultImage = [context createCGImage:outputImage fromRect:outputImage.extent];
    UIImage *image = [[UIImage alloc] initWithCGImage:resultImage];
    CGImageRelease(resultImage);
    
    return image;
}

@end




#import <XZKit/XZKit-Swift.h>
#import <XZKit/XZDatadigester.h>
#import <XZKit/NSString+XZKit.h>

@implementation UIImage (XZCacheColorImage)

#pragma mark - 指定大小

// -
+ (UIImage *)xz_imageFilled:(UIColor *)fillColor borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius roundCorners:(UIRectCorner)roundCorners size:(CGSize)imageSize {
    NSString *imageName = [NSString stringWithFormat:@"F%08lX_%d_%d_B%08lX_%d_R%lX",
                           (unsigned long)[fillColor xz_rgbaValue],
                           (int)(imageSize.width * 10),
                           (int)(imageSize.height * 10),
                           (unsigned long)[borderColor xz_rgbaValue],
                           (int)(borderWidth * 10),
                           (unsigned long)roundCorners];
    UIImage *image = [XZImageCacheManager.defaultManager imageNamed:imageName type:XZImageCacheTypePNG scale:UIScreen.mainScreen.scale];
    
    if (image != nil) {
        return image;
    }
    
    image = [self xz_imageWithFillColor:fillColor borderColor:borderColor borderWidth:borderWidth cornerRadius:cornerRadius roundCorners:roundCorners size:imageSize];
    
    [XZImageCacheManager.defaultManager cacheImage:image name:imageName type:XZImageCacheTypePNG scale:UIScreen.mainScreen.scale];
    
    return image;
}

// -roundCorners
+ (UIImage *)xz_imageFilled:(UIColor *)fillColor borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius size:(CGSize)imageSize {
    return [self xz_imageFilled:fillColor borderColor:borderColor borderWidth:borderWidth cornerRadius:cornerRadius roundCorners:(UIRectCornerAllCorners) size:imageSize];
}

// -roundCorners/cornerRadius
+ (UIImage *)xz_imageFilled:(UIColor *)fillColor borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth size:(CGSize)imageSize {
    return [self xz_imageFilled:fillColor borderColor:borderColor borderWidth:borderWidth cornerRadius:0 roundCorners:0 size:imageSize];
}

// -roundCorners/cornerRadius/borderWidth
+ (UIImage *)xz_imageFilled:(UIColor *)fillColor borderColor:(UIColor *)borderColor size:(CGSize)imageSize {
    return [self xz_imageFilled:fillColor borderColor:borderColor borderWidth:1.0/UIScreen.mainScreen.scale cornerRadius:0 roundCorners:0 size:imageSize];
}

// -roundCorners/cornerRadius/borderWidth/borderColor
+ (UIImage *)xz_imageFilled:(UIColor *)fillColor size:(CGSize)imageSize {
    return [self xz_imageFilled:fillColor borderColor:nil borderWidth:0 cornerRadius:0 roundCorners:0 size:imageSize];
}

// -borderWidth
+ (UIImage *)xz_imageFilled:(UIColor *)fillColor borderColor:(UIColor *)borderColor cornerRadius:(CGFloat)cornerRadius roundCorners:(UIRectCorner)roundCorners size:(CGSize)imageSize {
    return [self xz_imageFilled:fillColor borderColor:borderColor borderWidth:1.0/UIScreen.mainScreen.scale cornerRadius:cornerRadius roundCorners:roundCorners size:imageSize];
}

// -borderWidth/borderColor
+ (UIImage *)xz_imageFilled:(UIColor *)fillColor cornerRadius:(CGFloat)cornerRadius roundCorners:(UIRectCorner)roundCorners size:(CGSize)imageSize {
    return [self xz_imageFilled:fillColor borderColor:nil borderWidth:0 cornerRadius:cornerRadius roundCorners:roundCorners size:imageSize];
}

// -borderWidth/borderColor/roundCorners
+ (UIImage *)xz_imageFilled:(UIColor *)fillColor cornerRadius:(CGFloat)cornerRadius size:(CGSize)imageSize {
    return [self xz_imageFilled:fillColor borderColor:nil borderWidth:0 cornerRadius:cornerRadius roundCorners:UIRectCornerAllCorners size:imageSize];
}

// -borderWidth/borderColor/roundCorners/cornerRadius
// See: -roundCorners/cornerRadius/borderWidth/borderColor

+ (nullable UIImage *)xz_imageFilled:(nullable UIColor *)fillColor borderColor:(nullable UIColor *)borderColor cornerRadius:(CGFloat)cornerRadius size:(CGSize)imageSize {
    return [self xz_imageFilled:fillColor borderColor:borderColor borderWidth:1.0/UIScreen.mainScreen.scale cornerRadius:cornerRadius roundCorners:UIRectCornerAllCorners size:imageSize];
}

#pragma mark - 可拉伸大小的图片

// -imageSize
+ (UIImage *)xz_imageFilled:(UIColor *)fillColor borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius roundCorners:(UIRectCorner)roundCorners {
    CGFloat capInsets = ceil(cornerRadius + borderWidth);
    CGFloat length = capInsets * 2.0 + 1.0;
    CGSize imageSize = CGSizeMake(length, length);
    UIImage *image = [self xz_imageFilled:fillColor borderColor:borderColor borderWidth:borderWidth cornerRadius:cornerRadius roundCorners:roundCorners size:imageSize];
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(capInsets, capInsets, capInsets, capInsets)];
}

// -imageSize/borderWidth
+ (UIImage *)xz_imageFilled:(UIColor *)fillColor borderColor:(UIColor *)borderColor cornerRadius:(CGFloat)cornerRadius roundCorners:(UIRectCorner)roundCorners {
    return [self xz_imageFilled:fillColor borderColor:borderColor borderWidth:1.0/UIScreen.mainScreen.scale cornerRadius:cornerRadius roundCorners:roundCorners];
}

// -imageSize/borderWidth/borderColor
+ (UIImage *)xz_imageFilled:(UIColor *)fillColor cornerRadius:(CGFloat)cornerRadius roundCorners:(UIRectCorner)roundCorners {
    return [self xz_imageFilled:fillColor borderColor:nil borderWidth:0 cornerRadius:cornerRadius roundCorners:roundCorners];
}

// -imageSize/borderWidth/borderColor/roundCorners
+ (UIImage *)xz_imageFilled:(UIColor *)fillColor cornerRadius:(CGFloat)cornerRadius {
    return [self xz_imageFilled:fillColor borderColor:nil borderWidth:0 cornerRadius:cornerRadius roundCorners:UIRectCornerAllCorners];
}

// -imageSize/borderWidth/borderColor/roundCorners/cornerRadius
+ (UIImage *)xz_imageFilled:(UIColor *)fillColor {
    return [self xz_imageFilled:fillColor borderColor:nil borderWidth:0 cornerRadius:0 roundCorners:0];
}

// -imageSize/roundCorners
+ (UIImage *)xz_imageFilled:(UIColor *)fillColor borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius {
    return [self xz_imageFilled:fillColor borderColor:borderColor borderWidth:borderWidth cornerRadius:cornerRadius roundCorners:UIRectCornerAllCorners];
}

// -imageSize/roundCorners/cornerRadius
+ (UIImage *)xz_imageFilled:(UIColor *)fillColor borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth {
    return [self xz_imageFilled:fillColor borderColor:borderColor borderWidth:borderWidth cornerRadius:0 roundCorners:0];
}

// -imageSize/roundCorners/cornerRadius/borderWidth
+ (UIImage *)xz_imageFilled:(UIColor *)fillColor borderColor:(UIColor *)borderColor {
    return [self xz_imageFilled:fillColor borderColor:borderColor borderWidth:1.0/UIScreen.mainScreen.scale cornerRadius:0 roundCorners:0];
}

// -imageSize/roundCorners/cornerRadius/borderWidth/borderColor
// See: -imageSize/borderWidth/borderColor/roundCorners/cornerRadius

+ (nullable UIImage *)xz_imageFilled:(nullable UIColor *)fillColor borderColor:(nullable UIColor *)borderColor cornerRadius:(CGFloat)cornerRadius {
    return [self xz_imageFilled:fillColor borderColor:borderColor borderWidth:1.0/UIScreen.mainScreen.scale cornerRadius:cornerRadius roundCorners:UIRectCornerAllCorners];
}

@end





@implementation UIImage (XZCacheColorValueImage)

// -
+ (UIImage *)xz_imageFilledWithColorValue:(XZColorValue)fillColorValue borderColorValue:(XZColorValue)borderColorValue borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius roundCorners:(UIRectCorner)roundCorners size:(CGSize)imageSize {
    NSString *imageName = [NSString stringWithFormat:@"F%08lX_%d_%d_B%08lX_%d_R%lX",
                           (unsigned long)fillColorValue,
                           (int)(imageSize.width * 10),
                           (int)(imageSize.height * 10),
                           (unsigned long)borderColorValue,
                           (int)(borderWidth * 10),
                           (unsigned long)roundCorners];
    
    UIImage *image = [XZImageCacheManager.defaultManager imageNamed:imageName type:XZImageCacheTypePNG scale:UIScreen.mainScreen.scale];
    if (image != nil) {
        return image;
    }
    
    image = [self xz_imageWithFillColor:[UIColor xz_colorWithColorValue:fillColorValue]
                            borderColor:[UIColor xz_colorWithColorValue:borderColorValue]
                            borderWidth:borderWidth
                           cornerRadius:cornerRadius
                           roundCorners:roundCorners
                                   size:imageSize];
    
    [XZImageCacheManager.defaultManager cacheImage:image name:imageName type:XZImageCacheTypePNG scale:UIScreen.mainScreen.scale];
    
    return image;
}

// -roundCorners
+ (UIImage *)xz_imageFilledWithColorValue:(XZColorValue)fillColorValue borderColorValue:(XZColorValue)borderColorValue borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius size:(CGSize)imageSize {
    return [self xz_imageFilledWithColorValue:fillColorValue borderColorValue:borderColorValue borderWidth:borderWidth cornerRadius:cornerRadius roundCorners:(UIRectCornerAllCorners) size:imageSize];
}

// -roundCorners/cornerRadius
+ (UIImage *)xz_imageFilledWithColorValue:(XZColorValue)fillColorValue borderColorValue:(XZColorValue)borderColorValue borderWidth:(CGFloat)borderWidth size:(CGSize)imageSize {
    return [self xz_imageFilledWithColorValue:fillColorValue borderColorValue:borderColorValue borderWidth:borderWidth cornerRadius:0 roundCorners:0 size:imageSize];
}

// -roundCorners/cornerRadius/borderWidth
+ (UIImage *)xz_imageFilledWithColorValue:(XZColorValue)fillColorValue borderColorValue:(XZColorValue)borderColorValue size:(CGSize)imageSize {
    return [self xz_imageFilledWithColorValue:fillColorValue borderColorValue:borderColorValue borderWidth:1.0/UIScreen.mainScreen.scale cornerRadius:0 roundCorners:0 size:imageSize];
}

// -roundCorners/cornerRadius/borderWidth/borderColor
+ (UIImage *)xz_imageFilledWithColorValue:(XZColorValue)fillColorValue size:(CGSize)imageSize {
    return [self xz_imageFilledWithColorValue:fillColorValue borderColorValue:0 borderWidth:0 cornerRadius:0 roundCorners:0 size:imageSize];
}

// -borderWidth
+ (UIImage *)xz_imageFilledWithColorValue:(XZColorValue)fillColorValue borderColorValue:(XZColorValue)borderColorValue cornerRadius:(CGFloat)cornerRadius roundCorners:(UIRectCorner)roundCorners size:(CGSize)imageSize {
    return [self xz_imageFilledWithColorValue:fillColorValue borderColorValue:borderColorValue borderWidth:1.0/UIScreen.mainScreen.scale cornerRadius:cornerRadius roundCorners:roundCorners size:imageSize];
}

// -borderWidth/borderColor
+ (UIImage *)xz_imageFilledWithColorValue:(XZColorValue)fillColorValue cornerRadius:(CGFloat)cornerRadius roundCorners:(UIRectCorner)roundCorners size:(CGSize)imageSize {
    return [self xz_imageFilledWithColorValue:fillColorValue borderColorValue:0 borderWidth:0 cornerRadius:cornerRadius roundCorners:roundCorners size:imageSize];
}

// -borderWidth/borderColor/roundCorners
+ (UIImage *)xz_imageFilledWithColorValue:(XZColorValue)fillColorValue cornerRadius:(CGFloat)cornerRadius size:(CGSize)imageSize {
    return [self xz_imageFilledWithColorValue:fillColorValue borderColorValue:0 borderWidth:0 cornerRadius:cornerRadius roundCorners:UIRectCornerAllCorners size:imageSize];
}

// -borderWidth/borderColor/roundCorners/cornerRadius
// See: -roundCorners/cornerRadius/borderWidth/borderColor

+ (nullable UIImage *)xz_imageFilledWithColorValue:(XZColorValue)fillColorValue borderColorValue:(XZColorValue)borderColorValue cornerRadius:(CGFloat)cornerRadius size:(CGSize)imageSize {
    return [self xz_imageFilledWithColorValue:fillColorValue borderColorValue:borderColorValue borderWidth:1.0/UIScreen.mainScreen.scale cornerRadius:cornerRadius roundCorners:UIRectCornerAllCorners size:imageSize];
}

#pragma mark - 可拉伸大小的图片

// -imageSize
+ (UIImage *)xz_imageFilledWithColorValue:(XZColorValue)fillColorValue borderColorValue:(XZColorValue)borderColorValue borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius roundCorners:(UIRectCorner)roundCorners {
    CGFloat capInsets = ceil(cornerRadius + borderWidth);
    CGFloat length = capInsets * 2.0 + 1.0;
    CGSize imageSize = CGSizeMake(length, length);
    UIImage *image = [self xz_imageFilledWithColorValue:fillColorValue borderColorValue:borderColorValue borderWidth:borderWidth cornerRadius:cornerRadius roundCorners:roundCorners size:imageSize];
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(capInsets, capInsets, capInsets, capInsets)];
}

// -imageSize/borderWidth
+ (UIImage *)xz_imageFilledWithColorValue:(XZColorValue)fillColorValue borderColorValue:(XZColorValue)borderColorValue cornerRadius:(CGFloat)cornerRadius roundCorners:(UIRectCorner)roundCorners {
    return [self xz_imageFilledWithColorValue:fillColorValue borderColorValue:borderColorValue borderWidth:1.0/UIScreen.mainScreen.scale cornerRadius:cornerRadius roundCorners:roundCorners];
}

// -imageSize/borderWidth/borderColor
+ (UIImage *)xz_imageFilledWithColorValue:(XZColorValue)fillColorValue cornerRadius:(CGFloat)cornerRadius roundCorners:(UIRectCorner)roundCorners {
    return [self xz_imageFilledWithColorValue:fillColorValue borderColorValue:0 borderWidth:0 cornerRadius:cornerRadius roundCorners:roundCorners];
}

// -imageSize/borderWidth/borderColor/roundCorners
+ (UIImage *)xz_imageFilledWithColorValue:(XZColorValue)fillColorValue cornerRadius:(CGFloat)cornerRadius {
    return [self xz_imageFilledWithColorValue:fillColorValue borderColorValue:0 borderWidth:0 cornerRadius:cornerRadius roundCorners:UIRectCornerAllCorners];
}

// -imageSize/borderWidth/borderColor/roundCorners/cornerRadius
+ (UIImage *)xz_imageFilledWithColorValue:(XZColorValue)fillColorValue {
    return [self xz_imageFilledWithColorValue:fillColorValue borderColorValue:0 borderWidth:0 cornerRadius:0 roundCorners:0];
}

// -imageSize/roundCorners
+ (UIImage *)xz_imageFilledWithColorValue:(XZColorValue)fillColorValue borderColorValue:(XZColorValue)borderColorValue borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius {
    return [self xz_imageFilledWithColorValue:fillColorValue borderColorValue:borderColorValue borderWidth:borderWidth cornerRadius:cornerRadius roundCorners:UIRectCornerAllCorners];
}

// -imageSize/roundCorners/cornerRadius
+ (UIImage *)xz_imageFilledWithColorValue:(XZColorValue)fillColorValue borderColorValue:(XZColorValue)borderColorValue borderWidth:(CGFloat)borderWidth {
    return [self xz_imageFilledWithColorValue:fillColorValue borderColorValue:borderColorValue borderWidth:borderWidth cornerRadius:0 roundCorners:0];
}

// -imageSize/roundCorners/cornerRadius/borderWidth
+ (UIImage *)xz_imageFilledWithColorValue:(XZColorValue)fillColorValue borderColorValue:(XZColorValue)borderColorValue {
    return [self xz_imageFilledWithColorValue:fillColorValue borderColorValue:borderColorValue borderWidth:1.0/UIScreen.mainScreen.scale cornerRadius:0 roundCorners:0];
}

+ (nullable UIImage *)xz_imageFilledWithColorValue:(XZColorValue)fillColorValue borderColorValue:(XZColorValue)borderColorValue cornerRadius:(CGFloat)cornerRadius {
    return [self xz_imageFilledWithColorValue:fillColorValue borderColorValue:borderColorValue borderWidth:1.0/UIScreen.mainScreen.scale cornerRadius:cornerRadius roundCorners:UIRectCornerAllCorners];
}

@end


@implementation UIImage (XZCacheBlendingImage)

+ (UIImage *)xz_imageNamed:(NSString *)name blendingAlpha:(CGFloat)alpha {
    if (alpha >= 1.0) {
        return [UIImage imageNamed:name];
    }
    
    NSString * const md5 = [name xz_MD5];
    int const alphaInt   = (int)(alpha * 1000);
    
    NSString *imageName = [NSString stringWithFormat:@"BA_%@_%d", md5, alphaInt];
    
    UIImage *image = [XZImageCacheManager.defaultManager imageNamed:imageName type:XZImageCacheTypePNG scale:[UIScreen.mainScreen scale]];
    if (image != nil) {
        return image;
    }
    
    image = [[UIImage imageNamed:name] xz_imageWithBlendingAlpha:alpha];
    if (image == nil) {
        return nil;
    }
    
    [XZImageCacheManager.defaultManager cacheImage:image name:imageName type:XZImageCacheTypePNG scale:UIScreen.mainScreen.scale];
    
    return image;
}

+ (UIImage *)xz_imageNamed:(NSString *)name blendingColor:(nonnull UIColor *)tintColor {
    NSString * const md5 = [name xz_MD5];
    long const rgba      = (long)tintColor.xz_rgbaValue;
    NSString *imageName  = [NSString stringWithFormat:@"BC_%@_%08lX", md5, rgba];
    
    UIImage *image = [XZImageCacheManager.defaultManager imageNamed:imageName type:XZImageCacheTypePNG scale:UIScreen.mainScreen.scale];
    if (image != nil) {
        return image;
    }
    
    image = [[UIImage imageNamed:name] xz_imageWithBlendingColor:tintColor];
    if (image == nil) {
        return nil;
    }
    
    [XZImageCacheManager.defaultManager cacheImage:image name:imageName type:XZImageCacheTypePNG scale:UIScreen.mainScreen.scale];
    
    return image;
}

@end


@implementation UIImage (XZCacheFilteringImage)

#pragma mark - 图片亮度

+ (UIImage *)xz_imageNamed:(NSString *)name filteringBrightness:(CGFloat)brightness {
    if (brightness == 0.0) {
        return [UIImage imageNamed:name];
    }
    
    NSString *imageName = [NSString stringWithFormat:@"FB_%@_%d", [name xz_MD5], (int)(brightness * 1000)];
    
    UIImage *image = [XZImageCacheManager.defaultManager imageNamed:imageName type:XZImageCacheTypePNG scale:UIScreen.mainScreen.scale];
    if (image != nil) {
        return image;
    }
    
    image = [[UIImage imageNamed:name] xz_imageWithFilteringBrightness:brightness];
    if (image == nil) {
        return nil;
    }
    
    [XZImageCacheManager.defaultManager cacheImage:image name:imageName type:XZImageCacheTypePNG scale:UIScreen.mainScreen.scale];
    
    return image;
}


#pragma mark - 色阶

+ (UIImage *)xz_imageNamed:(NSString *)name filteringColorLevels:(XZColorLevels)colorLevels {
    if (XZColorLevelsEqualToLevels(colorLevels, XZColorLevelsIdentity)) {
        return [UIImage imageNamed:name];
    }
    
    NSString *imageName = [NSString stringWithFormat:@"FC_%@_%02X%02X%02X", name.xz_MD5, (int)(colorLevels.min * 255), (int)(colorLevels.max * 255), (int)(colorLevels.mid * 255)];
    
    UIImage *image = [XZImageCacheManager.defaultManager imageNamed:imageName type:XZImageCacheTypePNG scale:UIScreen.mainScreen.scale];
    if (image != nil) {
        return image;
    }
    
    image = [[UIImage imageNamed:name] xz_imageWithFilteringColorLevels:colorLevels];
    if (image == nil) {
        return nil;
    }
    
    [XZImageCacheManager.defaultManager cacheImage:image name:imageName type:XZImageCacheTypePNG scale:UIScreen.mainScreen.scale];
    
    return image;
}

@end
