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

+ (UIImage *)xz_imageWithXZImage:(XZImage)image {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    defer(^{
        UIGraphicsEndImageContext();
    });
    
    XZImageDrawAtPoint(&image, CGPointZero);
    
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
    CGFloat const hasR = (levels.channels & XZColorChannelRed)   ? 1.0 : 0;
    CGFloat const hasG = (levels.channels & XZColorChannelGreen) ? 1.0 : 0;
    CGFloat const hasB = (levels.channels & XZColorChannelBlue)  ? 1.0 : 0;
    CGFloat const hasA = (levels.channels & XZColorChannelAlpha) ? 1.0 : 0;
    
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
        
        CIVector *minComponents = [CIVector vectorWithX:shadows * hasR Y:shadows * hasG Z:shadows * hasB W:shadows * hasA];
        CIVector *maxComponents = [CIVector vectorWithX:highlights * hasR Y:highlights * hasG Z:highlights * hasB W:(hasA ? highlights : 1.0)];
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
    CGImageRef image = [context createCGImage:ciImage fromRect:ciImage.extent];
    defer(^{
        CGImageRelease(image);
    });
    return [[UIImage alloc] initWithCGImage:image];
}

@end

XZImageLevelsInput  const XZImageLevelsInputIdentity  = {0.0, 1.0, 1.0};
XZImageLevelsOutput const XZImageLevelsOutputIdentity = {0.0, 1.0};

typedef struct {
    XZImageBorder border;
    CGPoint startPoint;
    CGPoint endPoint;
    CGPoint pathPoint;
} XZImageBorderDescriptor;

typedef struct {
    XZImageCorner corner;
    CGFloat radius;
    CGPoint center;
    CGFloat startAngle;
    CGFloat endAngle;
} XZImageCornerDescriptor;

typedef struct {
    /// 顺时针，与圆角开头相连边的一半
    XZImageBorderDescriptor border1;
    /// 圆角
    XZImageCornerDescriptor corner;
    /// 顺时针，与圆角末尾相连边的一半
    XZImageBorderDescriptor border2;
} XZImageDescriptor;

/// 从箭头底底边开始，顺时针排列所有的边。
typedef struct {
    BOOL draws;
    XZImageBorderDescriptor borders[3];
} XZImageArrowDescriptor;

static void XZImageDrawBorder(CGContextRef context, const XZImageBorderDescriptor * const ctx) {
    CGContextSaveGState(context);
    CGContextMoveToPoint(context, ctx->startPoint.x, ctx->startPoint.y);
    CGContextSetStrokeColorWithColor(context, rgba(ctx->border.color).CGColor);
    CGContextSetLineWidth(context, ctx->border.width);
    if (ctx->border.dash.width > 0 && ctx->border.dash.space > 0) {
        CGFloat dashes[2] = {ctx->border.dash.width, ctx->border.dash.space};
        CGContextSetLineDash(context, 0, dashes, 2);
        // 虚线时不能加末端，不然斜线会糊一起。
        CGContextSetLineCap(context, kCGLineCapButt);
    }
    CGContextAddLineToPoint(context, ctx->endPoint.x, ctx->endPoint.y);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    NSLog(@"border: %@ -> %@", NSStringFromCGPoint(ctx->startPoint), NSStringFromCGPoint(ctx->endPoint));
};

static void XZImageDrawCorner(CGContextRef context, const XZImageCornerDescriptor * const ctx) {
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, rgba(ctx->corner.color).CGColor);
    CGContextSetLineWidth(context, ctx->corner.width);
    CGContextAddArc(context, ctx->center.x, ctx->center.y, ctx->radius, ctx->startAngle, ctx->endAngle, YES);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    NSLog(@"corner: %.2f - %.2f at %@", round(ctx->startAngle / M_PI), round(ctx->endAngle / M_PI), NSStringFromCGPoint(ctx->center));
};

static void XZImageDrawArrow(CGContextRef context, const XZImageArrowDescriptor * const ctx) {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:ctx->borders[0].pathPoint];
    for (NSInteger i = 0; i < 3; i++) {
        [path addLineToPoint:ctx->borders[i].pathPoint];
    }
    [path closePath];
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path.CGPath);
    CGContextSetFillColorWithColor(context, rgba(ctx->borders[0].border.color).CGColor);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    
    for (NSInteger i = 0; i < 3; i++) {
        XZImageDrawBorder(context, &ctx->borders[i]);
    }
}

static void XZImageContextCreate(const XZImage *image, XZImageDescriptor imageContexts[4], XZImageArrowDescriptor arrows[4], CGPoint point);

UIKIT_EXTERN void XZImageDrawAtPoint(const XZImage *image, CGPoint point) {
    XZImageDescriptor imageContexts[4];
    XZImageArrowDescriptor arrows[4];
    XZImageContextCreate(image, imageContexts, arrows, point);
    
    CGContextRef const context = UIGraphicsGetCurrentContext();
    // LineJion 拐角：kCGLineJoinMiter尖角、kCGLineJoinRound圆角、kCGLineJoinBevel缺角
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    
    { // 绘制背景
        UIBezierPath * const path = [[UIBezierPath alloc] init];
        [path moveToPoint:imageContexts[3].border2.pathPoint];
        for (NSInteger i = 0; i < 4; i++) {
            [path addLineToPoint:imageContexts[i].border1.pathPoint];
            if (imageContexts[i].corner.radius > 0) {
                [path addArcWithCenter:imageContexts[i].corner.center
                                radius:imageContexts[i].corner.radius + imageContexts[i].corner.corner.width * 0.5
                            startAngle:imageContexts[i].corner.endAngle
                              endAngle:imageContexts[i].corner.startAngle
                             clockwise:YES];
            }
            [path addLineToPoint:imageContexts[i].border2.pathPoint];
        }
        [path closePath];
        
        CGContextSaveGState(context);
        CGContextAddPath(context, path.CGPath);
        CGContextSetFillColorWithColor(context, rgba(image->backgroundColor).CGColor);
        CGContextFillPath(context);
        CGContextRestoreGState(context);
    }
    
    { // 绘制边框
        // LineCap 线端：kCGLineCapButt无、kCGLineCapRound圆形、kCGLineCapSquare方形
        CGContextSetLineCap(context, kCGLineCapButt);
        for (NSInteger i = 0; i < 4; i++) {
            XZImageDrawBorder(context, &imageContexts[i].border1);
            if (imageContexts[i].corner.radius > 0) {
                XZImageDrawCorner(context, &imageContexts[i].corner);
            }
            XZImageDrawBorder(context, &imageContexts[i].border2);
        }
    }
    
    { // 绘制箭头
        CGContextSetLineCap(context, kCGLineCapRound);
        for (NSInteger i = 0; i < 4; i++) {
            if (arrows[i].draws) {
                XZImageDrawArrow(context, &arrows[i]);
            }
        }
    }
}

static CGRect XZImageGetContentRect(const XZImage *image, CGPoint point);

static void XZImageContextCreate(const XZImage *image, XZImageDescriptor imageContexts[4], XZImageArrowDescriptor arrows[4], CGPoint point) {
    CGRect  const rect = XZImageGetContentRect(image, point);
    
    CGFloat const minX = CGRectGetMinX(rect);
    CGFloat const minY = CGRectGetMinY(rect);
    CGFloat const maxX = CGRectGetMaxX(rect);
    CGFloat const maxY = CGRectGetMaxY(rect);
    CGFloat const midX = CGRectGetMidX(rect);
    CGFloat const midY = CGRectGetMidY(rect);
    
    // 最大圆角值
    CGFloat const maxRadius = MIN(rect.size.width, rect.size.height) * 0.5;
    
    // 为了将整个矩形分割成可独立的部分，以每条边的中心点，划分成四个可独立绘制的图形。
    // - 因为每条边的起点与它连接的两个圆角的大小有关，所以整条边不适合作为一个可以重复的绘制单元。
    // - 因为背景与边会有一半的重叠，因此需先绘制背景后绘制边。
    
    { // 右下角
        XZImageCorner const corner = image->corners.bottomRight;
        CGFloat const radius = MIN(corner.radius, maxRadius);
        CGPoint const center = CGPointMake(maxX - radius, maxY - radius);
        
        imageContexts[0].border1 = (XZImageBorderDescriptor){
            image->borders.right,
            CGPointMake(maxX - image->borders.right.width * 0.5, midY),
            CGPointMake(maxX - image->borders.right.width * 0.5, maxY - radius),
            CGPointMake(maxX, maxY - radius),
        };
        
        imageContexts[0].corner = (XZImageCornerDescriptor){
            corner, radius - corner.width * 0.5, center, M_PI_2, 0
        };
        
        imageContexts[0].border2 = (XZImageBorderDescriptor){
            image->borders.bottom,
            CGPointMake(maxX - radius, maxY - image->borders.bottom.width * 0.5),
            CGPointMake(midX,          maxY - image->borders.bottom.width * 0.5),
            CGPointMake(midX,          maxY),
        };
    }

    { // 左下角
        XZImageCorner const corner = image->corners.bottomLeft;
        CGFloat const radius = MIN(corner.radius, maxRadius);
        CGPoint const center = CGPointMake(minX + radius, maxY - radius);
        
        imageContexts[1].border1 = (XZImageBorderDescriptor){
            image->borders.bottom,
            CGPointMake(midX,          maxY - image->borders.bottom.width * 0.5),
            CGPointMake(minX + radius, maxY - image->borders.bottom.width * 0.5),
            CGPointMake(minX + radius, maxY),
        };

        imageContexts[1].corner = (XZImageCornerDescriptor){
            corner, radius - corner.width * 0.5, center, M_PI, M_PI_2
        };

        imageContexts[1].border2 = (XZImageBorderDescriptor){
            image->borders.left,
            CGPointMake(minX + image->borders.left.width * 0.5, maxY - radius),
            CGPointMake(minX + image->borders.left.width * 0.5, midY),
            CGPointMake(minX, midY),
        };
    }

    { // 左上角
        XZImageCorner const corner = image->corners.topLeft;
        CGFloat const radius = MIN(corner.radius, maxRadius);
        CGPoint const center = CGPointMake(minX + radius, minY + radius);
        
        imageContexts[2].border1 = (XZImageBorderDescriptor){
            image->borders.left,
            CGPointMake(minX + image->borders.left.width * 0.5, midY),
            CGPointMake(minX + image->borders.left.width * 0.5, minY + radius),
            CGPointMake(minX, minY + radius),
        };

        imageContexts[2].corner = (XZImageCornerDescriptor){
            corner, radius - corner.width * 0.5, center, -M_PI_2, -M_PI
        };

        imageContexts[2].border2 = (XZImageBorderDescriptor){
            image->borders.top,
            CGPointMake(minX + radius, minY + image->borders.top.width * 0.5),
            CGPointMake(midX,          minY + image->borders.top.width * 0.5),
            CGPointMake(midX,          minY),
        };
    }

    { // 右上角
        XZImageCorner const corner = image->corners.topRight;
        CGFloat const radius = MIN(corner.radius, maxRadius);
        CGPoint const center = CGPointMake(maxX - radius, minY + radius);
        
        imageContexts[3].border1 = (XZImageBorderDescriptor){
            image->borders.top,
            CGPointMake(midX,          minY + image->borders.top.width * 0.5),
            CGPointMake(maxX - radius, minY + image->borders.top.width * 0.5),
            CGPointMake(maxX - radius, minY),
        };

        imageContexts[3].corner = (XZImageCornerDescriptor){
            corner, radius - corner.width * 0.5, center, 0, -M_PI_2
        };
        
        imageContexts[3].border2 = (XZImageBorderDescriptor){
            image->borders.right,
            CGPointMake(maxX - image->borders.right.width * 0.5, minY + radius),
            CGPointMake(maxX - image->borders.right.width * 0.5, midY),
            CGPointMake(maxX, midY),
        };
    }
    
    // TODO: 箭头不超过圆角
    
    { // 上箭头
        XZImageBorderArrow const arrow = image->borders.top.arrow;
        NSInteger const idx = 0;
        if (arrow.width > 0 && arrow.height > 0) {
            arrows[idx].draws = YES;
            
            // 复制边的信息
            arrows[idx].borders[0].border = image->borders.top;
            arrows[idx].borders[1].border = image->borders.top;
            arrows[idx].borders[2].border = image->borders.top;
            
            // 底边与背景同色。
            arrows[idx].borders[0].border.color = image->backgroundColor;
            arrows[idx].borders[0].border.dash  = (XZImageBorderDash){0, 0};
            
            CGFloat const b = image->borders.top.width * 0.5;
            CGFloat const w = arrow.width * 0.5 - b;
            CGFloat const y = minY + b;
            
            arrows[idx].borders[0].startPoint = CGPointMake(midX + arrow.center + w, y);
            arrows[idx].borders[0].endPoint   = CGPointMake(midX + arrow.center - w, y);
            arrows[idx].borders[0].pathPoint  = CGPointMake(midX + arrow.center + arrow.width * 0.5, minY);
            
            arrows[idx].borders[1].startPoint = arrows[idx].borders[0].endPoint;
            arrows[idx].borders[1].endPoint   = CGPointMake(midX + arrow.vector, y - arrow.height);
            arrows[idx].borders[1].pathPoint  = CGPointMake(midX + arrow.center - arrow.width * 0.5, minY);
            
            arrows[idx].borders[2].startPoint = arrows[idx].borders[1].endPoint;
            arrows[idx].borders[2].endPoint   = arrows[idx].borders[0].startPoint;
            arrows[idx].borders[2].pathPoint  = CGPointMake(midX + arrow.vector, minY - arrow.height);
        } else {
            arrows[idx].draws = NO;
        }
    }
    
    { // 左箭头
        XZImageBorderArrow const arrow = image->borders.left.arrow;
        NSInteger const idx = 1;
        if (arrow.width > 0 && arrow.height > 0) {
            arrows[idx].draws = YES;
            
            // 复制边的信息
            arrows[idx].borders[0].border = image->borders.left;
            arrows[idx].borders[1].border = image->borders.left;
            arrows[idx].borders[2].border = image->borders.left;
            
            // 底边与背景同色。
            arrows[idx].borders[0].border.color = image->backgroundColor;
            arrows[idx].borders[0].border.dash  = (XZImageBorderDash){0, 0};
            
            CGFloat const b = image->borders.left.width * 0.5;
            CGFloat const w = arrow.width * 0.5 - b;
            CGFloat const x = minX + b;
            
            arrows[idx].borders[0].startPoint = CGPointMake(x, midY + arrow.center - w);
            arrows[idx].borders[0].endPoint   = CGPointMake(x, midY + arrow.center + w);
            arrows[idx].borders[0].pathPoint  = CGPointMake(minX, midX + arrow.center + arrow.width * 0.5);
            
            arrows[idx].borders[1].startPoint = arrows[idx].borders[0].endPoint;
            arrows[idx].borders[1].endPoint   = CGPointMake(x - arrow.height, midY + arrow.vector);
            arrows[idx].borders[1].pathPoint  = CGPointMake(minX - arrow.height, midY + arrow.vector);
            
            arrows[idx].borders[2].startPoint = arrows[idx].borders[1].endPoint;
            arrows[idx].borders[2].endPoint   = arrows[idx].borders[0].startPoint;
            arrows[idx].borders[2].pathPoint  = CGPointMake(minX, midX + arrow.center - arrow.width * 0.5);
        } else {
            arrows[idx].draws = NO;
        }
    }
    
    { // 下箭头
        XZImageBorderArrow const arrow = image->borders.bottom.arrow;
        NSInteger const idx = 2;
        if (arrow.width > 0 && arrow.height > 0) {
            arrows[idx].draws = YES;
            
            // 复制边的信息
            arrows[idx].borders[0].border = image->borders.bottom;
            arrows[idx].borders[1].border = image->borders.bottom;
            arrows[idx].borders[2].border = image->borders.bottom;
            
            // 底边与背景同色。
            arrows[idx].borders[0].border.color = image->backgroundColor;
            arrows[idx].borders[0].border.dash  = (XZImageBorderDash){0, 0};
            
            CGFloat const b = image->borders.bottom.width * 0.5;
            CGFloat const w = arrow.width * 0.5 - b;
            CGFloat const y = maxY - b;
            
            arrows[idx].borders[0].startPoint = CGPointMake(midX + arrow.center + w, y);
            arrows[idx].borders[0].endPoint   = CGPointMake(midX + arrow.center - w, y);
            arrows[idx].borders[0].pathPoint  = CGPointMake(midX + arrow.center + arrow.width * 0.5, maxY);
            
            arrows[idx].borders[1].startPoint = arrows[idx].borders[0].endPoint;
            arrows[idx].borders[1].endPoint   = CGPointMake(midX + arrow.vector, y + arrow.height);
            arrows[idx].borders[1].pathPoint  = CGPointMake(midX + arrow.vector, maxY + arrow.height);
            
            arrows[idx].borders[2].startPoint = arrows[idx].borders[1].endPoint;
            arrows[idx].borders[2].endPoint   = arrows[idx].borders[0].startPoint;
            arrows[idx].borders[2].pathPoint  = CGPointMake(midX + arrow.center - arrow.width * 0.5, maxY);
        } else {
            arrows[idx].draws = NO;
        }
    }
    
    { // 右箭头
        XZImageBorderArrow const arrow = image->borders.right.arrow;
        NSInteger const idx = 3;
        if (arrow.width > 0 && arrow.height > 0) {
            arrows[idx].draws = YES;
            
            // 复制边的信息
            arrows[idx].borders[0].border = image->borders.right;
            arrows[idx].borders[1].border = image->borders.right;
            arrows[idx].borders[2].border = image->borders.right;
            
            // 底边与背景同色。
            arrows[idx].borders[0].border.color = image->backgroundColor;
            arrows[idx].borders[0].border.dash  = (XZImageBorderDash){0, 0};
            
            CGFloat const b = image->borders.right.width * 0.5;
            CGFloat const w = arrow.width * 0.5 - b;
            CGFloat const x = maxX - b;
            
            arrows[idx].borders[0].startPoint = CGPointMake(x, midY + arrow.center + w);
            arrows[idx].borders[0].endPoint   = CGPointMake(x, midY + arrow.center - w);
            arrows[idx].borders[0].pathPoint  = CGPointMake(maxX, midY + arrow.center + arrow.width * 0.5);
            
            arrows[idx].borders[1].startPoint = arrows[idx].borders[0].endPoint;
            arrows[idx].borders[1].endPoint   = CGPointMake(x + arrow.height, midY + arrow.vector);
            arrows[idx].borders[1].pathPoint  = CGPointMake(maxX, midY + arrow.center - arrow.width * 0.5);
            
            arrows[idx].borders[2].startPoint = arrows[idx].borders[1].endPoint;
            arrows[idx].borders[2].endPoint   = arrows[idx].borders[0].startPoint;
            arrows[idx].borders[2].pathPoint  = CGPointMake(maxX + arrow.height, midY + arrow.vector);
        } else {
            arrows[idx].draws = NO;
        }
    }

    // CGContextSetLineWidth(context, image->border.width);
    // CGContextSetStrokeColorWithColor(context, rgba(image->border.color).CGColor);
    // 无圆角时，关闭抗锯齿，避免发虚
    // CGContextSetShouldAntialias(context, descriptor.corner.radius > 0);
    // 线条粗细必须使用 context 进行设置，对 path 进行设置无效
    // CGContextDrawPath(context, kCGPathFillStroke);
    
    
}

static CGRect XZImageGetContentRect(const XZImage *image, CGPoint point) {
    CGFloat top    = (image->borders.top.arrow.height + image->contentInsets.top);
    CGFloat left   = (image->borders.left.arrow.height + image->contentInsets.left);
    CGFloat bottom = (image->borders.bottom.arrow.height + image->contentInsets.bottom);
    CGFloat right  = (image->borders.right.arrow.height + image->contentInsets.right);
    
    CGFloat width  = image->size.width - left - right;
    CGFloat height = image->size.height - top - bottom;
    
    return CGRectMake(point.x + left, point.y + top, width, height);
}
