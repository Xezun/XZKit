//
//  XZImageLevels.m
//  XZKit
//
//  Created by Xezun on 2021/2/18.
//

#import "XZImageLevels.h"

XZImageLevelsInput  const XZImageLevelsInputIdentity  = {0.0, 1.0, 1.0};
XZImageLevelsOutput const XZImageLevelsOutputIdentity = {0.0, 1.0};

UIImage *XZImageLevelsFilteringImage(XZImageLevels levels, UIImage *image) {
    // 没有要处理的通道，返回自身
    if (levels.channels == 0) {
        return image;
    }
    
    // 检查参数 限定 highlights 的最小值
    levels.input.shadows    = MIN(1.0, MAX(0, levels.input.shadows));
    levels.input.midtones   = MIN(10.0, MAX(0.0, levels.input.midtones));
    levels.input.highlights = MIN(1.0, MAX(MAX(1e-20, levels.input.shadows), levels.input.highlights));
    levels.output.shadows   = MIN(1.0, MAX(0, levels.output.shadows));
    levels.output.highlights = MIN(1.0, MAX(MAX(1e-20, levels.output.shadows), levels.output.highlights));
    
    // 获得当前图片的 CIImage 对象
    CIImage *ciImage = [image CIImage];
    if (ciImage == nil) {
        CGImageRef cgImage = [image CGImage];
        if (cgImage == nil) {
            return  nil;
        }
        ciImage = [CIImage imageWithCGImage:cgImage];
    }
    
    // 通道
    BOOL const hasR = (levels.channels & XZColorChannelRed);
    BOOL const hasG = (levels.channels & XZColorChannelGreen);
    BOOL const hasB = (levels.channels & XZColorChannelBlue);
    BOOL const hasA = (levels.channels & XZColorChannelAlpha);
    
    XZImageLevelsInput const  input  = levels.input;
    XZImageLevelsOutput const output = levels.output;
    
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
            CIVector *minComponents = [CIVector vectorWithX:(hasR ? shadows : 0)
                                                          Y:(hasG ? shadows : 0)
                                                          Z:(hasB ? shadows : 0)
                                                          W:(hasA ? shadows : 0)];
            [filter1 setValue:minComponents forKey:@"inputMinComponents"];
        }
        if (highlights < 1.0) {
            CIVector *maxComponents = [CIVector vectorWithX:(hasR ? highlights : 1.0)
                                                          Y:(hasG ? highlights : 1.0)
                                                          Z:(hasB ? highlights : 1.0)
                                                          W:(hasA ? highlights : 1.0)];
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
        if (hasR) {
            [filter setValue:inputCoefficients forKey:@"inputRedCoefficients"];
        }
        if (hasG) {
            [filter setValue:inputCoefficients forKey:@"inputGreenCoefficients"];
        }
        if (hasB) {
            [filter setValue:inputCoefficients forKey:@"inputBlueCoefficients"];
        }
        if (hasA) {
            [filter setValue:inputCoefficients forKey:@"inputAlphaCoefficients"];
        }
        
        ciImage = filter.outputImage;
        
        if (ciImage == nil) {
            return nil;
        }
    }
    
    CIContext *context = [CIContext context];
    CGImageRef cgImage = [context createCGImage:ciImage fromRect:ciImage.extent];
    image = [[UIImage alloc] initWithCGImage:cgImage scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(cgImage);
    cgImage = NULL;
    
    return image;
}
