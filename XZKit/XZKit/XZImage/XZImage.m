//
//  XZImage.m
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import "XZImage.h"
#import "XZImage+Extension.h"

@implementation XZImage

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:UIApplicationDidReceiveMemoryWarningNotification
                                                object:nil];;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _corners = [[XZImageCorners alloc] initWithSuperAttribute:self];
        _borders = [[XZImageBorders alloc] initWithSuperAttribute:self];
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(didReceiveMemoryWarningNotification:)
                                                   name:UIApplicationDidReceiveMemoryWarningNotification
                                                 object:nil];
    }
    return self;
}

#pragma mark - 公开方法

@synthesize image = _image;

- (UIImage *)image {
    if (_image != nil) {
        return _image;
    }
    
    // 如果没设置任何属性，直接返回背景图。
    if (!self.borders.isEffective
        && !self.corners.isEffective
        && !self.lineDashIfLoaded.isEffective
        && UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, self.contentInsets)
        && self.backgroundColor == nil
        && CGSizeEqualToSize(CGSizeZero, self.size)) {
        return _backgroundImage;
    }
    
    // 绘制图片
    CGRect rect = CGRectZero;
    CGRect frame = CGRectZero;
    [self rect:&rect frame:&frame forDrawingInSize:self.defaultSize atPoint:CGPointZero];
    
    CGFloat const w = frame.size.width + frame.origin.x * 2;
    CGFloat const h = frame.size.height + frame.origin.y * 2;
    
    CGSize const size = CGSizeMake(w, h);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [self drawWithRect:rect frame:frame];
    _image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _image;
}

- (UIImage *)imageIfLoaded {
    return _image;
}

/// 如果当前设置了大小，则返回该大小；
/// 如果设置了背景图，则根据背景图自动确定一个大小；
/// 否则返回 CGSizeZero 。
- (CGSize)defaultSize {
    CGSize size = self.size;
    if (size.width > 0 && size.height > 0) {
        return size;
    }
    UIImage *backgroundImage = self.backgroundImage;
    if (backgroundImage == nil) {
        return CGSizeZero;
    }
    size = backgroundImage.size;
    if (size.width <= 0 || size.height <= 0) {
        return CGSizeZero;
    }
    if (self.backgroundImage.scale == UIScreen.mainScreen.scale) {
        return size;
    }
    CGFloat const as = UIScreen.mainScreen.scale / self.backgroundImage.scale;
    size.width  = size.width / as + _contentInsets.left + _contentInsets.right;
    size.height = size.height / as + _contentInsets.top + _contentInsets.bottom;
    return size;
}

#pragma mark - 绘图

- (void)drawAtPoint:(CGPoint)point {
    CGRect rect = CGRectZero;
    CGRect frame = CGRectZero;
    
    CGSize const size = [self defaultSize];
    [self rect:&rect frame:&frame forDrawingInSize:size atPoint:point];
    
    [self drawWithRect:rect frame:frame];
}

- (void)drawInRect:(CGRect)rect {
    CGRect borderRect = CGRectZero;
    CGRect imageFrame = CGRectZero;
    [self rect:&borderRect frame:&imageFrame forDrawingInSize:rect.size atPoint:rect.origin];
    [self drawWithRect:borderRect frame:imageFrame];
}

/// 绘制。
/// @param rect 边框的绘制区域
/// @param frame 包括箭头在内的整体绘制区域
- (void)drawWithRect:(CGRect const)rect frame:(CGRect const)frame {
    NSMutableArray<XZImageLinePath *> * const linePaths = [NSMutableArray arrayWithCapacity:8];
    UIBezierPath * const backgroundPath = [[UIBezierPath alloc] init];
    [self linePaths:linePaths backgroundPath:backgroundPath forDrawingWithRect:rect];

    CGContextRef const context = UIGraphicsGetCurrentContext();
    // LineJion 拐角：kCGLineJoinMiter尖角、kCGLineJoinRound圆角、kCGLineJoinBevel缺角
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    // LineCap 线端：kCGLineCapButt无、kCGLineCapRound圆形、kCGLineCapSquare方形
    CGContextSetLineCap(context, kCGLineCapButt);
    CGContextSetFillColorWithColor(context, UIColor.clearColor.CGColor);
    
    // 绘制背景色
    if (self.backgroundColor) {
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
        CGContextAddPath(context, backgroundPath.CGPath);
        CGContextFillPath(context);
        CGContextRestoreGState(context);
    }
    
    // 绘制背景图
    if (self.backgroundImage) {
        CGContextSaveGState(context);
        CGContextAddPath(context, backgroundPath.CGPath);
        CGContextClip(context);
        CGSize size = self.backgroundImage.size;
        
        CGRect rect = CGRectAdjustSize(frame, size, self.contentMode);
        [self.backgroundImage drawInRect:rect];
        CGContextRestoreGState(context);
    }
    
    // 切去最外层的一像素，避免border因为抗锯齿或误差盖不住底色。
    // 因为透明色会被其它颜色覆盖，也没办法覆盖其它颜色，所以只能在绘制完底色后
    // 用 kCGBlendModeCopy 覆盖。
    CGContextSaveGState(context);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextSetStrokeColorWithColor(context, UIColor.clearColor.CGColor);
    CGContextSetLineWidth(context, 1.0 / UIScreen.mainScreen.scale);
    CGContextAddPath(context, backgroundPath.CGPath);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    // 绘制边框
    for (XZImageLinePath *linePath in linePaths) {
        CGContextSaveGState(context);
        
        [linePath drawInContext:context];
        
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }
}

#pragma mark - 确定绘制区域

/// 获取在指定 size 和 point 位置进行绘制时的主体区域 rect 和绘制区域 frame 。
/// @param rect 绘制 borders 和 corners 所在的区域，不包含箭头
/// @param frame 包含箭头在内的绘制区域
/// @param size 绘制大小
/// @param point 绘制位置
- (void)rect:(CGRect *)rect frame:(CGRect *)frame forDrawingInSize:(CGSize)size atPoint:(CGPoint)point {
    UIEdgeInsets const contentInsets = self.contentInsets;
    
    XZImageBorder * const borderT = self.borders.topIfLoaded      ?: self.borders;
    XZImageBorder * const borderL = self.borders.leftIfLoaded     ?: self.borders;
    XZImageBorder * const borderB = self.borders.bottomIfLoaded   ?: self.borders;
    XZImageBorder * const borderR = self.borders.rightIfLoaded    ?: self.borders;
    
    XZImageCorner * const cornerTL = self.corners.topLeftIfLoaded     ?: self.corners;
    XZImageCorner * const cornerBL = self.corners.bottomLeftIfLoaded  ?: self.corners;
    XZImageCorner * const cornerBR = self.corners.bottomRightIfLoaded ?: self.corners;
    XZImageCorner * const cornerTR = self.corners.topRightIfLoaded    ?: self.corners;
    
    XZImageArrow * const arrowT = borderT.arrowIfLoaded;
    XZImageArrow * const arrowL = borderL.arrowIfLoaded;
    XZImageArrow * const arrowB = borderB.arrowIfLoaded;
    XZImageArrow * const arrowR = borderR.arrowIfLoaded;
    
    // 内容边距
    CGFloat const top    = (arrowT.effectiveHeight + contentInsets.top);
    CGFloat const left   = (arrowL.effectiveHeight + contentInsets.left);
    CGFloat const bottom = (arrowB.effectiveHeight + contentInsets.bottom);
    CGFloat const right  = (arrowR.effectiveHeight + contentInsets.right);
    
    // 最小宽度
    CGFloat width = left + right; // 左右箭头、边距
    width += XZImageMAX(cornerTL.radius, cornerBL.radius); // 左边最大圆角
    width += XZImageMAX(arrowT.effectiveWidth, arrowB.effectiveWidth); // 箭头宽度
    width += XZImageMAX(cornerTR.radius, cornerBR.radius); // 右边最大圆角
    
    // 最小高度
    CGFloat height = top + bottom;
    height += XZImageMAX(cornerTL.radius, cornerTR.radius);
    height += XZImageMAX(borderL.arrowIfLoaded.effectiveWidth, borderR.arrowIfLoaded.effectiveWidth);
    height += XZImageMAX(cornerBL.radius, cornerBR.radius);
    
    CGFloat const deltaW = XZImageMAX(0, size.width - point.x - width);
    CGFloat const deltaH = XZImageMAX(0, size.height - point.y - height);
    
    frame->origin.x = point.x + contentInsets.left;
    frame->origin.y = point.y + contentInsets.top;
    frame->size.width = (width - contentInsets.left - contentInsets.right) + deltaW;
    frame->size.height = (height - contentInsets.top - contentInsets.bottom) + deltaH;
    
    rect->origin.x = point.x + left;
    rect->origin.y = point.y + top;
    rect->size.width = width + deltaW - left - right;
    rect->size.height = height + deltaH - top - bottom;
}

#pragma mark - 构造绘图元素

/// 创建绘制内容。
/// @param linePaths 输出，边框的绘制内容将添加到此数组
/// @param backgroundPath 输出，背景色填充路径
/// @param rect 绘制区域（矩形所在的区域，不包括箭头，箭头绘制在此区域外）
- (void)linePaths:(nullable NSMutableArray<XZImageLinePath *> * const)linePaths backgroundPath:(nullable UIBezierPath * const)backgroundPath forDrawingWithRect:(CGRect const)rect {
    // 基础坐标
    CGFloat const minX = CGRectGetMinX(rect);
    CGFloat const minY = CGRectGetMinY(rect);
    CGFloat const maxX = CGRectGetMaxX(rect);
    CGFloat const maxY = CGRectGetMaxY(rect);
    CGFloat const midX = CGRectGetMidX(rect);
    CGFloat const midY = CGRectGetMidY(rect);
    
    // 最大圆角半径
    CGFloat const maxRadius = XZImageMIN(rect.size.width, rect.size.height) * 0.5;
    
    XZImageBorder * const top         = self.borders.topIfLoaded      ?: self.borders;
    XZImageBorder * const left        = self.borders.leftIfLoaded     ?: self.borders;
    XZImageBorder * const bottom      = self.borders.bottomIfLoaded   ?: self.borders;
    XZImageBorder * const right       = self.borders.rightIfLoaded    ?: self.borders;
    
    XZImageCorner * const topLeft     = self.corners.topLeftIfLoaded     ?: self.corners;
    XZImageCorner * const bottomLeft  = self.corners.bottomLeftIfLoaded  ?: self.corners;
    XZImageCorner * const bottomRight = self.corners.bottomRightIfLoaded ?: self.corners;
    XZImageCorner * const topRight    = self.corners.topRightIfLoaded    ?: self.corners;
    
    CGFloat const radiusTR = XZImageGetEffectiveRadius(XZImageMIN(maxRadius, topRight.radius), topRight.width);
    CGFloat const radiusBR = XZImageGetEffectiveRadius(XZImageMIN(maxRadius, bottomRight.radius), bottomRight.width);
    CGFloat const radiusBL = XZImageGetEffectiveRadius(XZImageMIN(maxRadius, bottomLeft.radius), bottomLeft.width);
    CGFloat const radiusTL = XZImageGetEffectiveRadius(XZImageMIN(maxRadius, topLeft.radius), topLeft.width);
    
    { // 调整箭头位置
        CGFloat const w_2 = midX - minX;
        CGFloat const h_2 = midY - minY;
        [top.arrowIfLoaded updateEffectiveAnchorWithMinValue:-(w_2 - radiusTL) maxValue:(w_2 - radiusTR)];
        [top.arrowIfLoaded updateEffectiveVectorWithMinValue:-w_2 maxValue:w_2];
        
        [left.arrowIfLoaded updateEffectiveAnchorWithMinValue:-(h_2 - radiusBL) maxValue:(h_2 - radiusTL)];
        [left.arrowIfLoaded updateEffectiveVectorWithMinValue:-h_2 maxValue:h_2];
        
        [bottom.arrowIfLoaded updateEffectiveAnchorWithMinValue:-(w_2 - radiusBR) maxValue:(w_2 - radiusBL)];
        [bottom.arrowIfLoaded updateEffectiveVectorWithMinValue:-w_2 maxValue:w_2];
        
        [right.arrowIfLoaded updateEffectiveAnchorWithMinValue:-(h_2 - radiusTR) maxValue:(h_2 - radiusBR)];
        [right.arrowIfLoaded updateEffectiveVectorWithMinValue:-h_2 maxValue:h_2];
    }

    CGFloat const borderWidthT   = top.width;
    CGFloat const borderWidthT_2 = borderWidthT * 0.5;
    CGFloat const borderWidthR   = right.width;
    CGFloat const borderWidthR_2 = borderWidthR * 0.5;
    CGFloat const borderWidthB   = bottom.width;
    CGFloat const borderWidthB_2 = borderWidthB * 0.5;
    CGFloat const borderWidthL   = left.width;
    CGFloat const borderWidthL_2 = borderWidthL * 0.5;
    
    { // MARK: - Top line
        CGPoint start = CGPointMake(minX + radiusTL, minY);
        [backgroundPath moveToPoint:start];
        
        CGPointMove(&start, 0, borderWidthT_2);
        XZImageLinePath * const context = linePaths ? [XZImageLinePath imagePathWithLine:top startPoint:start] : nil;
        
        XZImageArrow const *arrow = top.arrowIfLoaded;
        if (arrow.isEffective) {
            CGFloat const w = arrow.effectiveWidth * 0.5;
            
            CGPoint point1 = CGPointMake(midX + arrow.effectiveAnchor - w, minY);
            CGPoint point2 = CGPointMake(midX + arrow.effectiveVector, minY - arrow.effectiveHeight);
            CGPoint point3 = CGPointMake(midX + arrow.effectiveAnchor + w, minY);
            [backgroundPath addLineToPoint:point1];
            [backgroundPath addLineToPoint:point2];
            [backgroundPath addLineToPoint:point3];
            
            if (context) {
                CGPoint const offset1 = [arrow offsetForVectorAtIndex:2 lineOffset:borderWidthT_2];
                CGPoint const offset2 = [arrow offsetForVectorAtIndex:0 lineOffset:borderWidthT_2];
                CGPoint const offset3 = [arrow offsetForVectorAtIndex:1 lineOffset:borderWidthT_2];
                CGPointMove(&point1, offset1.x, offset1.y);
                CGPointMove(&point2, offset2.x, offset2.y);
                CGPointMove(&point3, offset3.x, offset3.y);
                
                [context appendLineToPoint:point1];
                [context appendLineToPoint:point2];
                [context appendLineToPoint:point3];
            }
        }
        
        CGPoint end = CGPointMake(maxX - radiusTR, minY);
        [backgroundPath addLineToPoint:end];
        
        if (context) {
            CGPointMoveY(&end, maxX - XZImageGetBorderEndOffset(radiusTR, borderWidthR), borderWidthT_2);
            [context appendLineToPoint:end];
            
            [linePaths addObject:context];
        }
    }
    
    if (radiusTR > 0) { // MARK: - Top Right
        CGPoint const center = CGPointMake(maxX - radiusTR, minY + radiusTR);
        CGFloat const startAngle = -M_PI_2;
        CGFloat const endAngle   = 0;
        [backgroundPath addArcWithCenter:center radius:radiusTR startAngle:startAngle endAngle:endAngle clockwise:YES];
        
        if (linePaths) {
            CGFloat const dTR_2 = topRight.width * 0.5;
            CGPoint const start = CGPointMake(maxX - radiusTR, minY + dTR_2);
            
            XZImageLinePath *context = [XZImageLinePath imagePathWithLine:topRight startPoint:start];
            [context appendArcWithCenter:center
                               radius:(radiusTR - dTR_2)
                           startAngle:(startAngle)
                             endAngle:endAngle];
            [linePaths addObject:context];
        }
    }
    
    { // MARK: - Right
        CGPoint start = CGPointMake(maxX, minY + radiusTR);
        [backgroundPath addLineToPoint:start];
        
        CGPointMove(&start, -borderWidthR_2, 0);
        XZImageLinePath *context = linePaths ? [XZImageLinePath imagePathWithLine:right startPoint:start] : nil;
        
        XZImageArrow const *arrow = right.arrowIfLoaded;
        if (arrow.isEffective) {
            CGFloat const w = arrow.effectiveWidth * 0.5;
            
            CGPoint point1 = CGPointMake(maxX, midY + arrow.effectiveAnchor - w);
            CGPoint point2 = CGPointMake(maxX + arrow.effectiveHeight, midY + arrow.effectiveVector);
            CGPoint point3 = CGPointMake(maxX, midY + arrow.effectiveAnchor + w);
            [backgroundPath addLineToPoint:point1];
            [backgroundPath addLineToPoint:point2];
            [backgroundPath addLineToPoint:point3];
            
            if (context) {
                CGPoint const offset1 = [arrow offsetForVectorAtIndex:2 lineOffset:borderWidthR_2];
                CGPoint const offset2 = [arrow offsetForVectorAtIndex:0 lineOffset:borderWidthR_2];
                CGPoint const offset3 = [arrow offsetForVectorAtIndex:1 lineOffset:borderWidthR_2];
                CGPointMove(&point1, -offset1.y, offset1.x);
                CGPointMove(&point2, -offset2.y, offset2.x);
                CGPointMove(&point3, -offset3.y, offset3.x);
                
                [context appendLineToPoint:point1];
                [context appendLineToPoint:point2];
                [context appendLineToPoint:point3];
            }
        }
        
        CGPoint end = CGPointMake(maxX, maxY - radiusBR);
        [backgroundPath addLineToPoint:end];
        
        if (context) {
            CGPointMoveX(&end, -borderWidthR_2, maxY - XZImageGetBorderEndOffset(radiusBR, borderWidthB));
            [context appendLineToPoint:end];
            [linePaths addObject:context];
        }
    }
    
    if (radiusBR > 0) { // MARK: - BottomRight
        CGPoint const center = CGPointMake(maxX - radiusBR, maxY - radiusBR);
        CGFloat const startAngle = 0;
        CGFloat const endAngle   = M_PI_2;
        [backgroundPath addArcWithCenter:center radius:radiusBR startAngle:startAngle endAngle:endAngle clockwise:YES];
        
        if (linePaths) {
            CGFloat const dBR_2 = bottomRight.width * 0.5;
            CGPoint const start = CGPointMake(maxX - dBR_2, maxY - radiusBR);
            
            XZImageLinePath *context = [XZImageLinePath imagePathWithLine:bottomRight startPoint:start];
            [context appendArcWithCenter:center
                               radius:(radiusBR - dBR_2)
                           startAngle:(startAngle)
                             endAngle:endAngle];
            [linePaths addObject:context];
        }
    }
    
    { // MARK: - Bottom
        CGPoint start = CGPointMake(maxX - radiusBR, maxY);
        [backgroundPath addLineToPoint:start];
        
        CGPointMove(&start, 0, -borderWidthB_2);
        XZImageLinePath *context = linePaths ? [XZImageLinePath imagePathWithLine:bottom startPoint:start] : nil;
        
        XZImageArrow const *arrow = bottom.arrowIfLoaded;
        if (arrow.isEffective) {
            CGFloat const w = arrow.effectiveWidth * 0.5;
            
            CGPoint point1 = CGPointMake(midX - arrow.effectiveAnchor + w, maxY);
            CGPoint point2 = CGPointMake(midX - arrow.effectiveVector, maxY + arrow.effectiveHeight);
            CGPoint point3 = CGPointMake(midX - arrow.effectiveAnchor - w, maxY);
            [backgroundPath addLineToPoint:point1];
            [backgroundPath addLineToPoint:point2];
            [backgroundPath addLineToPoint:point3];
            
            if (context) {
                CGPoint const offset1 = [arrow offsetForVectorAtIndex:2 lineOffset:borderWidthB_2];
                CGPoint const offset2 = [arrow offsetForVectorAtIndex:0 lineOffset:borderWidthB_2];
                CGPoint const offset3 = [arrow offsetForVectorAtIndex:1 lineOffset:borderWidthB_2];
                CGPointMove(&point1, -offset1.x, -offset1.y);
                CGPointMove(&point2, -offset2.x, -offset2.y);
                CGPointMove(&point3, -offset3.x, -offset3.y);
                
                [context appendLineToPoint:point1];
                [context appendLineToPoint:point2];
                [context appendLineToPoint:point3];
            }
        }
        
        CGPoint end = CGPointMake(minX + radiusBL, maxY);
        [backgroundPath addLineToPoint:end];
        
        if (context) {
            CGPointMoveY(&end, minX + XZImageGetBorderEndOffset(radiusBL, borderWidthL), -borderWidthB_2);
            [context appendLineToPoint:end];
            [linePaths addObject:context];
        }
    }
    
    if (radiusBL > 0) { // MARK: - BottomLeft
        CGPoint const center = CGPointMake(minX + radiusBL, maxY - radiusBL);
        CGFloat const startAngle = M_PI_2;
        CGFloat const endAngle   = M_PI;
        [backgroundPath addArcWithCenter:center radius:radiusBL startAngle:startAngle endAngle:endAngle clockwise:YES];
        
        if (linePaths) {
            CGFloat const dBL_2 = bottomLeft.width * 0.5;
            CGPoint const start = CGPointMake(minX + radiusBL, maxY - dBL_2);
            
            XZImageLinePath *context = [XZImageLinePath imagePathWithLine:bottomLeft startPoint:start];
            [context appendArcWithCenter:center
                               radius:(radiusBL - dBL_2)
                           startAngle:(startAngle)
                             endAngle:endAngle];
            [linePaths addObject:context];
        }
    }
    
    { // MARK: - Left
        CGPoint start = CGPointMake(minX, maxY - radiusBL);
        [backgroundPath addLineToPoint:start];
        
        CGPointMove(&start, borderWidthL_2, 0);
        XZImageLinePath *context = linePaths ? [XZImageLinePath imagePathWithLine:left startPoint:start] : nil;
        
        XZImageArrow const *arrow = left.arrowIfLoaded;
        if (arrow.isEffective) {
            CGFloat const w = arrow.effectiveWidth * 0.5;
            
            CGPoint point1 = CGPointMake(minX, midY - arrow.effectiveAnchor + w);
            CGPoint point2 = CGPointMake(minX - arrow.effectiveHeight, midY - arrow.effectiveVector);
            CGPoint point3 = CGPointMake(minX, midY - arrow.effectiveAnchor - w);
            [backgroundPath addLineToPoint:point1];
            [backgroundPath addLineToPoint:point2];
            [backgroundPath addLineToPoint:point3];
            
            if (context) {
                CGPoint const offset1 = [arrow offsetForVectorAtIndex:2 lineOffset:borderWidthL_2];
                CGPoint const offset2 = [arrow offsetForVectorAtIndex:0 lineOffset:borderWidthL_2];
                CGPoint const offset3 = [arrow offsetForVectorAtIndex:1 lineOffset:borderWidthL_2];
                CGPointMove(&point1, offset1.y, -offset1.x);
                CGPointMove(&point2, offset2.y, -offset2.x);
                CGPointMove(&point3, offset3.y, -offset3.x);
                
                [context appendLineToPoint:point1];
                [context appendLineToPoint:point2];
                [context appendLineToPoint:point3];
            }
        }
        
        CGPoint end = CGPointMake(minX, minY + radiusTL);
        [backgroundPath addLineToPoint:end];
        
        if (context) {
            CGPointMoveX(&end, borderWidthL_2, minY + XZImageGetBorderEndOffset(radiusTL, borderWidthT));
            [context appendLineToPoint:end];
            [linePaths addObject:context];
        }
    }
    
    if (radiusTL > 0) { // MARK: - TopLeft
        CGPoint const center = CGPointMake(minX + radiusTL, minY + radiusTL);
        CGFloat const startAngle = -M_PI;
        CGFloat const endAngle   = -M_PI_2;
        [backgroundPath addArcWithCenter:center radius:radiusTL startAngle:startAngle endAngle:endAngle clockwise:YES];
        
        if (linePaths) {
            CGFloat const dTL_2 = topLeft.width * 0.5;
            CGPoint const start = CGPointMake(minX + dTL_2, minY + radiusTL);
            
            XZImageLinePath *context = [XZImageLinePath imagePathWithLine:topLeft startPoint:start];
            [context appendArcWithCenter:center
                               radius:(radiusTL - dTL_2)
                           startAngle:(startAngle)
                             endAngle:endAngle];
            [linePaths addObject:context];
        }
    }
    
    [backgroundPath closePath];
}

- (void)subAttribute:(__kindof XZImageAttribute *)subAttribute didUpdateAttribute:(id)attribute {
    if (subAttribute == _lineDash) {
        [self.borders.dash updateLineDashValue:_lineDash];
        [self.corners.dash updateLineDashValue:_lineDash];
    }
    [self didReceiveMemoryWarning];
}

- (void)didReceiveMemoryWarningNotification:(NSNotification *)notification {
    [self didReceiveMemoryWarning];
}

- (void)didReceiveMemoryWarning {
    _image = nil;
}

@end


@implementation XZImage (XZExtendedImage)

- (CGFloat)lineWidth {
    return self.borders.width;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    self.borders.width = lineWidth;
    self.corners.width = lineWidth;
}

- (UIColor *)lineColor {
    return self.borders.color;
}

- (void)setLineColor:(UIColor *)lineColor {
    self.borders.color = lineColor;
    self.corners.color = lineColor;
}

- (XZImageLineDash *)lineDash {
    if (_lineDash == nil) {
        _lineDash = [[XZImageLineDash alloc] initWithSuperAttribute:self];
    }
    return _lineDash;
}

- (XZImageLineDash *)lineDashIfLoaded {
    return _lineDash;
}

- (CGFloat)cornerRadius {
    return self.corners.radius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.corners.radius = cornerRadius;
}

- (CGSize)preferredSize {
    CGRect rect = CGRectZero;
    CGRect frame = CGRectZero;
    
    [self rect:&rect frame:&frame forDrawingInSize:[self defaultSize] atPoint:CGPointZero];
    
    CGFloat const w = frame.size.width + frame.origin.x * 2;
    CGFloat const h = frame.size.height + frame.origin.y * 2;
    
    return CGSizeMake(w, h);
}

- (UIBezierPath *)path {
    CGRect rect = CGRectZero;
    CGRect frame = CGRectZero;
    
    CGSize const size = [self defaultSize];
    [self rect:&rect frame:&frame forDrawingInSize:size atPoint:CGPointZero];
    
    UIBezierPath *backgroundPath = [[UIBezierPath alloc] init];
    [self linePaths:nil backgroundPath:backgroundPath forDrawingWithRect:rect];
    
    return backgroundPath;
}

- (NSArray<id<XZImageLinePath>> *)linePaths {
    CGRect rect = CGRectZero;
    CGRect frame = CGRectZero;
    
    CGSize const size = [self defaultSize];
    [self rect:&rect frame:&frame forDrawingInSize:size atPoint:CGPointZero];
    
    NSMutableArray<XZImageLinePath *> * const linePaths = [NSMutableArray arrayWithCapacity:8];
    [self linePaths:linePaths backgroundPath:nil forDrawingWithRect:rect];
    
    return linePaths;
}

@end
