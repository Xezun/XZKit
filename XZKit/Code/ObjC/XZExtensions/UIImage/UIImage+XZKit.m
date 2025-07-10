//
//  UIImage+XZKit.m
//  XZExtensions
//
//  Created by Xezun on 2024/6/12.
//

#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <objc/runtime.h>
#import "UIImage+XZKit.h"
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZDefer.h>
#else
#import "XZDefer.h"
#endif
@import CoreGraphics;
@import CoreImage;
@import UniformTypeIdentifiers;

// 最大公约数。GreatestCommonDivisor
static inline NSInteger GreatestCommonDivisor(NSInteger a, NSInteger b) {
    while (a != 0) {
        a = b % a;
        b = a;
    }
    return b;
};

@interface XZGIFImageFrame : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) NSInteger delay;
@end

static const void * const _repeatCount = &_repeatCount;

@implementation UIImage (XZKit)

- (CGSize)xz_sizeInScale:(CGFloat)targetScale {
    if (targetScale < 1.0) {
        return CGSizeZero;
    }
    CGFloat const imageScale = self.scale;
    if (imageScale == targetScale) {
        return self.size;
    }
    CGSize const imageSize = self.size;
    CGFloat const scale = imageScale / targetScale;
    return CGSizeMake(imageSize.width * scale, imageSize.height * scale);
}

+ (UIImage *)xz_imageWithColor:(UIColor *)color size:(CGSize)size {
    return [self xz_imageWithGraphics:^(CGContextRef  _Nonnull context) {
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    } size:size];
}

+ (UIImage *)xz_imageWithColor:(UIColor *)color {
    return [self xz_imageWithColor:color size:CGSizeMake(1.0, 1.0)];
}

+ (nullable UIImage *)xz_imageWithColor:(UIColor *)color radius:(CGFloat)radius {
    return [self xz_imageWithGraphics:^(CGContextRef _Nonnull context) {
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius startAngle:-M_PI endAngle:+M_PI clockwise:YES];
        [path closePath];
        path.lineWidth = 0;
        [color setFill];
        [path fill];
        [path addClip];
    } size:CGSizeMake(radius * 2.0, radius * 2.0)];
}

+ (UIImage *)xz_imageWithGraphics:(void (^NS_NOESCAPE)(CGContextRef context))imageGraphics size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    defer(^{
        UIGraphicsEndImageContext();
    });
    imageGraphics(UIGraphicsGetCurrentContext());
    return UIGraphicsGetImageFromCurrentImageContext();
}

+ (UIImage *)xz_animatedImageWithGIFImagePath:(NSString *)GIFImagePath {
    if (GIFImagePath == nil) {
        return nil;
    }
    NSData *data = [NSData dataWithContentsOfFile:GIFImagePath];
    return [self xz_animatedImageWithGIFImageData:data];
}

+ (UIImage *)xz_animatedImageWithGIFImageData:(NSData *)GIFImageData {
    if (GIFImageData == nil) {
        return nil;
    }
    
    CGImageSourceRef const imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)GIFImageData, (__bridge CFDictionaryRef)@{(NSString *)kCGImageSourceShouldCache: @(NO)});
    if (imageSource == nil) {
        return nil;
    }
    
    defer(^{
        CFRelease(imageSource);
    });
    
    // 判断是否为 GIF 图片
    if (@available(iOS 15.0, *)) {
        NSString * const imageType = (__bridge NSString *)CGImageSourceGetType(imageSource);
        if (!imageType) {
            return nil;
        }
        if (![[UTType typeWithIdentifier:imageType] conformsToType:UTTypeGIF]) {
            return nil;
        }
    } else {
        if (!UTTypeConformsTo(CGImageSourceGetType(imageSource), kUTTypeGIF)) {
            return nil;
        }
    }
    
    NSDictionary * const imageProperties = (__bridge_transfer NSDictionary *)CGImageSourceCopyProperties(imageSource, NULL);
    NSInteger      const imageCount      = CGImageSourceGetCount(imageSource);
    
    NSMutableArray<XZGIFImageFrame *> * const frames = [NSMutableArray arrayWithCapacity:imageCount];
    
    // 浏览器（Chrome/Firefox）默认 GIF 帧率为 25帧/秒，即一帧 40 毫秒。
    NSInteger const kMinFrameInterval = 40;
    // 最大公约数：所有帧的时长的公约数，以优化总帧数。
    NSInteger divisor = kMinFrameInterval;
    
    NSTimeInterval duration = 0; // GIF 时长。
    for (NSInteger i = 0; i < imageCount; i++) {
        @autoreleasepool {
            XZGIFImageFrame * const frame = (^XZGIFImageFrame *(NSArray *frames, CGImageSourceRef imageSource, NSInteger i){
                CGImageRef frameImageRef = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
                if (frameImageRef) {
                    XZGIFImageFrame *frame = [[XZGIFImageFrame alloc] init];
                    frame.image = [UIImage imageWithCGImage:frameImageRef];
                    CFRelease(frameImageRef);
                    frameImageRef = nil;
                }
                return frames.lastObject;
            })(frames, imageSource, i);
            
            if (frame == nil) {
                continue;
            }
            [frames addObject:frame];
            
            NSDictionary *frameProperties = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imageSource, i, NULL);
            if (!frameProperties) {
                continue;
            }
            NSDictionary *GIFProperties = [frameProperties objectForKey:(id)kCGImagePropertyGIFDictionary];
            
            NSInteger const frameDelay = (^NSInteger (NSDictionary *GIFProperties) {
                NSNumber *value = [GIFProperties objectForKey:(id)kCGImagePropertyGIFUnclampedDelayTime];
                if (value != nil) {
                    return MAX((NSInteger)(value.doubleValue * 1000), kMinFrameInterval);
                }
                value = [GIFProperties objectForKey:(id)kCGImagePropertyGIFDelayTime];
                if (value == nil) {
                    return kMinFrameInterval;
                }
                NSInteger delay = (NSInteger)(value.doubleValue * 1000);
                return (delay > 50 ? delay : 100);
            })(GIFProperties);
            
            divisor = GreatestCommonDivisor(frameDelay, divisor);
            duration += frameDelay;
            
            frame.delay = frameDelay;
        }
    }
    
    NSMutableArray<UIImage *> * const images = [NSMutableArray arrayWithCapacity:(NSUInteger)(duration * 40)];

    for (NSInteger i = 0; i < imageCount; i++) {
        XZGIFImageFrame * const frame = frames[i];
        NSInteger const count = frame.delay / divisor;
        for (NSInteger j = 0; j < count; j++) {
            [images addObject:frame.image];
        }
    }
    
    UIImage * const image = [UIImage animatedImageWithImages:images duration:duration / 1000.0];
    
    if (image) {
        NSNumber * const repeatCount = [[imageProperties objectForKey:(id)kCGImagePropertyGIFDictionary] objectForKey:(id)kCGImagePropertyGIFLoopCount];
        objc_setAssociatedObject(image, &_repeatCount, (repeatCount ?: @(1)), OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    return image;
}

- (NSInteger)xz_repeatCount {
    return [objc_getAssociatedObject(self, &_repeatCount) integerValue];
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

- (UIImage *)xz_imageByBlendingTintColor:(UIColor *)tintColor {
    if (@available(iOS 13.0, *)) {
        return [self imageWithTintColor:tintColor];
    }
    
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
    CGContextTranslateCTM(context, 0, imageSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    CGContextClipToMask(context, rect, cgImage);
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
    
    CIImage *ciImage = [self CIImage];
    if (ciImage == nil) {
        CGImageRef cgImage = self.CGImage;
        if (cgImage == nil) {
            return nil;
        }
        ciImage = [CIImage imageWithCGImage:cgImage];
    }
    
    // 转换值 [-1, +1]
    brightness *= 2.0;
    brightness -= 1.0;
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setValue:ciImage forKey:kCIInputImageKey];
    [filter setValue:@(brightness) forKey:kCIInputBrightnessKey];
    
    ciImage = [filter outputImage];
    if (ciImage == nil) {
        return nil;
    }
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef cgImage = [context createCGImage:ciImage fromRect:ciImage.extent];
    defer(^{
        CGImageRelease(cgImage);
    });
    
    // 必须保持 Scale 一致，否则可能只会渲染出部分图片
    return [UIImage imageWithCGImage:cgImage scale:self.scale orientation:self.imageOrientation];
}

- (UIImage *)xz_imageByFilteringLevels:(XZImageColorLevels)levels channels:(XZImageColorChannels)channels {
    XZImageInputColorLevels input   = levels.input;
    XZImageOutputColorLevels output = levels.output;
    
    // 检查参数
    input.shadows     = MIN(1.0, MAX(0, input.shadows));
    input.midtones    = MIN(10.0, MAX(0.01, input.midtones));
    input.highlights  = MIN(1.0, MAX(input.shadows, input.highlights));
    
    output.shadows    = MIN(1.0, MAX(0, output.shadows));
    output.highlights = MIN(1.0, MAX(output.shadows, output.highlights));
    
    // 没有要处理的通道，返回自身
    if (channels == 0) {
        return self;
    }
    
    // 获得当前图片的 CIImage 对象
    CIImage *ciImage = [self CIImage];
    if (ciImage == nil) {
        CGImageRef cgImage = [self CGImage];
        if (cgImage == nil) {
            return nil;
        }
        ciImage = [CIImage imageWithCGImage:cgImage];
    }
    
    // 通道
    BOOL const channelR = (channels & XZImageColorChannelRed);
    BOOL const channelG = (channels & XZImageColorChannelGreen);
    BOOL const channelB = (channels & XZImageColorChannelBlue);
    BOOL const channelA = (channels & XZImageColorChannelAlpha);
    
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
        
        if (shadows > 0) {
            CIVector *minComponents = [CIVector vectorWithX:(channelR ? shadows : 0)
                                                          Y:(channelG ? shadows : 0)
                                                          Z:(channelB ? shadows : 0)
                                                          W:(channelA ? shadows : 0)];
            [filter1 setValue:minComponents forKey:@"inputMinComponents"];
        }
        if (highlights < 1.0) {
            CIVector *maxComponents = [CIVector vectorWithX:(channelR ? highlights : 1.0)
                                                          Y:(channelG ? highlights : 1.0)
                                                          Z:(channelB ? highlights : 1.0)
                                                          W:(channelA ? highlights : 1.0)];
            [filter1 setValue:maxComponents forKey:@"inputMaxComponents"];
        }
        
        ciImage = filter1.outputImage;
        
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
        if (channelR) {
            [filter setValue:inputCoefficients forKey:@"inputRedCoefficients"];
        }
        if (channelG) {
            [filter setValue:inputCoefficients forKey:@"inputGreenCoefficients"];
        }
        if (channelB) {
            [filter setValue:inputCoefficients forKey:@"inputBlueCoefficients"];
        }
        if (channelA) {
            [filter setValue:inputCoefficients forKey:@"inputAlphaCoefficients"];
        }
        
        ciImage = filter.outputImage;
        
        if (ciImage == nil) {
            return nil;
        }
    }
    
    CIContext *context = [CIContext context];
    CGImageRef cgImage = [context createCGImage:ciImage fromRect:ciImage.extent];
    UIImage *image = [[UIImage alloc] initWithCGImage:cgImage scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(cgImage);
    cgImage = NULL;
    
    return image;
}

@end

@implementation XZGIFImageFrame
@end
