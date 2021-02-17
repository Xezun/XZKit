//
//  UIImage.m
//  XZKit
//
//  Created by Xezun on 2017/10/30.
//

#import "UIImage+XZKit.h"
#import "NSBundle+XZKit.h"
#import "XZDefer.h"

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

+ (UIImage *)xz_imageWithXZImage:(XZImage *)image {
    return image.image;
}

@end


@implementation UIImage (XZKitBlending)

#pragma mark - 更改图片的透明度

- (UIImage *)xz_imageByBlendingAlpha:(CGFloat)alpha {
    CGImageRef cgImage = self.CGImage;
    if (cgImage == nil) {
        return nil;
    }
    
    CGSize const imageSize = self.size;
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    defer(^{
        UIGraphicsEndImageContext();
    });
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == nil) {
        return nil;
    }
    
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -imageSize.height);
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    CGContextSetAlpha(context, alpha);
    CGContextDrawImage(context, CGRectMake(0, 0, imageSize.width, imageSize.height), cgImage);
    
    return UIGraphicsGetImageFromCurrentImageContext();
}

- (UIImage *)xz_imageByBlendingColor:(UIColor *)tintColor {
    CGImageRef image = self.CGImage;
    if (image == nil) {
        return nil;
    }
    
    CGSize const imageSize = self.size;
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    defer(^{
        UIGraphicsEndImageContext();
    });
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, imageSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    CGContextClipToMask(context, rect, image);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    
    return UIGraphicsGetImageFromCurrentImageContext();
}

@end

@implementation UIImage (XZKitFiltering)

#pragma mark - 图片亮度

- (UIImage *)xz_imageByFilteringBrightness:(CGFloat)brightness {
    if (brightness == 0.5) {
        return self;
    }
    CGImageRef image = [self CGImage];
    if (image == nil) {
        return nil;
    }
    
    // 转换值 [-1, +1]
    brightness *= 2.0;
    brightness -= 1.0;
    
    CIImage *inputImage = [CIImage imageWithCGImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:@(brightness) forKey:kCIInputBrightnessKey];
    
    CIImage *outputImage = [filter outputImage];
    if (outputImage == nil) {
        return nil;
    }
    
    CIContext *context = [CIContext contextWithOptions:nil];
    image = [context createCGImage:outputImage fromRect:outputImage.extent];
    defer(^{
        CGImageRelease(image);
    });
    return [UIImage imageWithCGImage:image];
}

#pragma mark - 色阶

- (UIImage *)xz_imageByFilteringImageLevels:(XZImageLevels)levels {
    return XZImageFilterImageWithLevels(self, levels);
}

@end

