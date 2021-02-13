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

+ (UIImage *)xz_imageWithDescriptor:(XZImageDescriptor)descriptor {
    if (descriptor.size.width == 0 || descriptor.size.height == 0) {
        return nil;
    }
    
    CGFloat const minX = descriptor.border.width * 0.5;
    CGFloat const minY = minX;
    CGFloat const maxX = descriptor.size.width - minX;
    CGFloat const maxY = descriptor.size.height - minY;
    CGRect  const rect = CGRectMake(minX, minY, descriptor.size.width - descriptor.border.width, descriptor.size.height - descriptor.border.width);
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    CGFloat const maxRadius = MIN(rect.size.width, rect.size.height) * 0.5;
    
    { // 绘制左上角
        CGFloat const radius = MIN(descriptor.radius.topLeft, maxRadius);
        [path moveToPoint:CGPointMake(minX, minY + radius)];
        
        CGPoint const center = CGPointMake(minX + radius, minY + radius);
        [path addArcWithCenter:center radius:radius startAngle:-M_PI endAngle:-M_PI_2 clockwise:YES];
        
        [path addLineToPoint:CGPointMake(minX + radius, minY)];
    }
    
    {
        CGFloat const radius = MIN(descriptor.radius.topRight, maxRadius);
        [path addLineToPoint:CGPointMake(maxX - radius, minY)];
        
        CGPoint const center = CGPointMake(maxX - radius, minY + radius);
        [path addArcWithCenter:center radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
        
        [path addLineToPoint:CGPointMake(maxX, minY + radius)];
    }
    
    {
        CGFloat const radius = MIN(descriptor.radius.bottomRight, maxRadius);
        [path addLineToPoint:CGPointMake(maxX, maxY - radius)];
        
        CGPoint const center = CGPointMake(maxX - radius, maxY - radius);
        [path addArcWithCenter:center radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
        
        [path addLineToPoint:CGPointMake(maxX - radius, maxY)];
    }
    
    {
        CGFloat const radius = MIN(descriptor.radius.bottomLeft, maxRadius);
        [path addLineToPoint:CGPointMake(minX + radius, maxY)];
        
        CGPoint const center = CGPointMake(minX + radius, maxY - radius);
        [path addArcWithCenter:center radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        
        [path addLineToPoint:CGPointMake(minX, maxY - radius)];
    }
    
    [path closePath];
    
    UIGraphicsBeginImageContextWithOptions(descriptor.size, NO, 0);
    defer(^{
        UIGraphicsEndImageContext();
    });
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddPath(context, path.CGPath);
    CGContextSetFillColorWithColor(context, rgba(descriptor.backgroundColor).CGColor);
    CGContextSetLineWidth(context, descriptor.border.width);
    CGContextSetStrokeColorWithColor(context, rgba(descriptor.border.color).CGColor);
    // 无圆角时，关闭抗锯齿，避免发虚
    // CGContextSetShouldAntialias(context, descriptor.corner.radius > 0);
    // 线条粗细必须使用 context 进行设置，对 path 进行设置无效
    CGContextDrawPath(context, kCGPathFillStroke);
    
    return UIGraphicsGetImageFromCurrentImageContext();
}

@end




@implementation UIImage (XZKitBlending)

#pragma mark - 更改图片的透明度

- (UIImage *)xz_imageByBlendingAlpha:(CGFloat)alpha {
    CGImageRef cgImage = self.CGImage;
    if (cgImage == nil) {
        return nil;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == nil) {
        return nil;
    }
    
    CGSize const imageSize = self.size;
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    defer(^{
        UIGraphicsEndImageContext();
    });
    
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

XZImageLevelsInput  const XZImageLevelsInputIdentity  = {0.0, 1.0, 1.0};
XZImageLevelsOutput const XZImageLevelsOutputIdentity = {0.0, 1.0};

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
    // 检查参数
    if (levels.input.highlights <= levels.input.shadows) {
        NSAssert(NO, @"输入色阶 shadows 必须小于 highlights");
        return nil;
    }
    if (levels.output.highlights <= levels.output.shadows) {
        NSAssert(NO, @"输出色阶 shadows 必须小于 highlights");
        return nil;
    }
    // 没有要处理的通道，返回自身
    if (levels.channels == 0) {
        return self;
    }
    
    // 获得当前图片的 CIImage 对象
    CIImage *ciImage = [self CIImage];
    if (ciImage == nil) {
        CGImageRef cgImage = [self CGImage];
        if (cgImage == nil) {
            return  nil;
        }
        ciImage = [CIImage imageWithCGImage:cgImage];
    }
    
    // 通道
    CGFloat const RED   = (levels.channels & XZRGBAChannelRed)   ? 1.0 : 0;
    CGFloat const GREEN = (levels.channels & XZRGBAChannelGreen) ? 1.0 : 0;
    CGFloat const BLUE  = (levels.channels & XZRGBAChannelBlue)  ? 1.0 : 0;
    CGFloat const ALPHA = (levels.channels & XZRGBAChannelAlpha) ? 1.0 : 0;
    
    XZImageLevelsInput const  input  = levels.input;
    XZImageLevelsOutput const output = levels.output;
    
    // 关于滤镜的相关文档
    // [Apple Documentation - Core Image Filter Reference]
    // (https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference)
    
    // 丢掉输入的色彩范围之外的颜色
    // CIColorClamp 滤镜：将小于最小值的值增加到最小值，将大于最大值的减少到最大值。
    if (input.shadows > 0 || input.highlights < 1.0) {
        CIFilter *filter1 = [CIFilter filterWithName:@"CIColorClamp"];
        [filter1 setDefaults];
        [filter1 setValue:ciImage forKey:kCIInputImageKey];
        
        CGFloat const shadows = input.shadows;
        CGFloat const highlights = input.highlights;
        
        CIVector *minComponents = [CIVector vectorWithX:shadows * RED Y:shadows * GREEN Z:shadows * BLUE W:shadows * ALPHA];
        CIVector *maxComponents = [CIVector vectorWithX:highlights * RED Y:highlights * GREEN Z:highlights * BLUE W:(ALPHA ? highlights : 1.0)];
        [filter1 setValue:minComponents forKey:@"inputMinComponents"];
        [filter1 setValue:maxComponents forKey:@"inputMaxComponents"];
        
        ciImage = filter1.outputImage;
        
        if (ciImage == nil) {
            return nil;
        }
    }
    
    // 调整中间调。
    // PhotoShop 中间调计算公式为 pow(x, 1 / mid) ：http://blog.sina.com.cn/s/blog_470fe4710100i084.html
    // OpenGL 代码示例：https://blog.csdn.net/panda1234lee/article/details/52269462
    // CIGammaAdjust 灰度调整滤镜：对中间值 power 应用公式：pow(s.rgb, vec3(power))
    // osg::Vec2可以用于保存2D纹理坐标。
    // osg::Vec3是一个三维浮点数数组。
    // osg::Vec4用于保存颜色数据。
    if (input.midtones != 1.0) {
        CIFilter *filter = [CIFilter filterWithName:@"CIGammaAdjust"];
        [filter setDefaults];
        [filter setValue:ciImage forKey:kCIInputImageKey];
        
        CGFloat const power = (1.0 / input.midtones);
        [filter setValue:@(power) forKey:@"inputPower"];
        
        ciImage = filter.outputImage;
        
        if (ciImage == nil) {
            return nil;
        }
    }
    
    // 将输入颜色 [input.shadows, input.highlights] 均匀分布到输出颜色 [output.shadows, output.highlights] 。
    // CIColorPolynomial 滤镜：颜色多项式，对颜色所有通道值 v 应用公式 `v = X + Y * v + Z * v*v + W * v*v*v` 。
    if (input.shadows != output.shadows || input.highlights != output.highlights) {
        CIFilter *filter = [CIFilter filterWithName:@"CIColorPolynomial"];
        [filter setDefaults];
        [filter setValue:ciImage forKey:kCIInputImageKey];
        
        // => output.shadows + outputSize * (v - input.shadows) / inputSize
        // => output.shadows + outputSize * v / inputSize - outputSize * input.shadows / inputSize
        // => output.shadows - outputSize * input.shadows / inputSize + v * outputSize / inputSize
        
        CGFloat const outputSize = output.highlights - output.shadows;
        CGFloat const inputSize = input.highlights - input.shadows;
        
        CGFloat const x = output.shadows - outputSize * input.shadows / inputSize;
        CGFloat const y = outputSize / inputSize;
        
        CIVector *inputCoefficients = [CIVector vectorWithX:x Y:y Z:0 W:0];
        if (RED) {
            [filter setValue:inputCoefficients forKey:@"inputRedCoefficients"];
        }
        if (GREEN) {
            [filter setValue:inputCoefficients forKey:@"inputGreenCoefficients"];
        }
        if (BLUE) {
            [filter setValue:inputCoefficients forKey:@"inputBlueCoefficients"];
        }
        if (ALPHA) {
            [filter setValue:inputCoefficients forKey:@"inputAlphaCoefficients"];
        }
        
        ciImage = filter.outputImage;
        
        if (ciImage == nil) {
            return nil;
        }
    }
    
    CIContext *context = [CIContext context];
    CGImageRef image = [context createCGImage:ciImage fromRect:ciImage.extent];
    defer(^{
        CGImageRelease(image);
    });
    return [[UIImage alloc] initWithCGImage:image];
}

@end
