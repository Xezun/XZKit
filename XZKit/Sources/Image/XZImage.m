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
        _corners = [[XZImageCorners alloc] initWithCorner:nil];
        _corners.superAttribute = self;
        
        _borders = [[XZImageBorders alloc] initWithBorder:nil];
        _borders.superAttribute = self;
        
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
    // 绘制图片
    CGRect rect = CGRectZero;
    CGRect frame = CGRectZero;
    [self prepareRect:&rect frame:&frame withPoint:CGPointZero size:self.defaultSize];
    
    CGFloat const w = frame.size.width + frame.origin.x * 2;
    CGFloat const h = frame.size.height + frame.origin.y * 2;
    
    CGSize const size = CGSizeMake(w, h);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [self drawWithRect:rect frame:frame];
    _image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
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
    [self prepareRect:&rect frame:&frame withPoint:point size:size];
    
    [self drawWithRect:rect frame:frame];
}

- (void)drawInRect:(CGRect)rect1 {
    CGRect rect = CGRectZero;
    CGRect frame = CGRectZero;
    [self prepareRect:&rect frame:&frame withPoint:rect1.origin size:rect1.size];
    [self drawWithRect:rect frame:frame];
}

#pragma mark - 构造绘图元素

/// 计算绘制的背景区域、边框区域。
- (void)prepareRect:(CGRect *)rect frame:(CGRect *)frame withPoint:(CGPoint)point size:(CGSize)size {
    UIEdgeInsets const contentInsets = self.contentInsets;
    
    XZImageBorder * const topBorder         = self.borders.topIfLoaded      ?: self.borders;
    XZImageBorder * const leftBorder        = self.borders.leftIfLoaded     ?: self.borders;
    XZImageBorder * const bottomBorder      = self.borders.bottomIfLoaded   ?: self.borders;
    XZImageBorder * const rightBorder       = self.borders.rightIfLoaded    ?: self.borders;
    
    XZImageCorner * const topLeftCorner     = self.corners.topLeftIfLoaded     ?: self.corners;
    XZImageCorner * const bottomLeftCorner  = self.corners.bottomLeftIfLoaded  ?: self.corners;
    XZImageCorner * const bottomRightCorner = self.corners.bottomRightIfLoaded ?: self.corners;
    XZImageCorner * const topRightCorner    = self.corners.topRightIfLoaded    ?: self.corners;
    
    // 内容边距
    CGFloat const top    = (topBorder.arrowIfLoaded.height    + contentInsets.top);
    CGFloat const left   = (leftBorder.arrowIfLoaded.height   + contentInsets.left);
    CGFloat const bottom = (bottomBorder.arrowIfLoaded.height + contentInsets.bottom);
    CGFloat const right  = (rightBorder.arrowIfLoaded.height  + contentInsets.right);
    
    // 所需的最小宽度、高度
    CGFloat width = left + right;
    width += MAX(topLeftCorner.radius,          bottomLeftCorner.radius);
    width += MAX(topBorder.arrowIfLoaded.width, bottomBorder.arrowIfLoaded.width);
    width += MAX(topRightCorner.radius,         bottomRightCorner.radius);
    CGFloat height = top + bottom;
    height += MAX(topLeftCorner.radius,           topRightCorner.radius);
    height += MAX(leftBorder.arrowIfLoaded.width, rightBorder.arrowIfLoaded.width);
    height += MAX(bottomLeftCorner.radius,        bottomRightCorner.radius);
    
    CGFloat const deltaW = MAX(0, size.width - point.x - width);
    CGFloat const deltaH = MAX(0, size.height - point.y - height);
    
    frame->origin.x = point.x + contentInsets.left;
    frame->origin.y = point.y + contentInsets.top;
    frame->size.width = (width - contentInsets.left - contentInsets.right) + deltaW;
    frame->size.height = (height - contentInsets.top - contentInsets.bottom) + deltaH;
    
    rect->origin.x = point.x + left;
    rect->origin.y = point.y + top;
    rect->size.width = width + deltaW - left - right;
    rect->size.height = height + deltaH - top - bottom;
}

/// 绘制。
/// @param rect 边框的绘制区域
/// @param frame 包括箭头在内的整体绘制区域
- (void)drawWithRect:(CGRect const)rect frame:(CGRect const)frame {
    NSMutableArray<XZImageLinePath *> * const contexts = [NSMutableArray arrayWithCapacity:8];
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [self createContexts:contexts path:path withRect:rect];

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
        CGContextAddPath(context, path.CGPath);
        CGContextFillPath(context);
        CGContextRestoreGState(context);
    }
    
    // 绘制背景图
    if (self.backgroundImage) {
        CGContextSaveGState(context);
        CGContextAddPath(context, path.CGPath);
        CGContextClip(context);
        CGSize size = self.backgroundImage.size;
        CGRect rect = CGSizeFitingInRectWithContentMode(size, frame, self.contentMode);
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
    CGContextAddPath(context, path.CGPath);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    // 绘制边框
    for (XZImageLinePath *imageContext in contexts) {
        CGContextSaveGState(context);
        
        [imageContext drawInContext:context];
        
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }
}

/// 创建绘制内容。
/// @param contexts 输出，边框的绘制内容将添加到此数组
/// @param backgroundPath 输出，背景色填充路径
/// @param rect 绘制区域（矩形所在的区域，不包括箭头，箭头绘制在此区域外）
- (void)createContexts:(nullable NSMutableArray<XZImageLinePath *> * const)contexts path:(nullable UIBezierPath * const)backgroundPath withRect:(CGRect const)rect {
    
    CGFloat const minX = CGRectGetMinX(rect);
    CGFloat const minY = CGRectGetMinY(rect);
    CGFloat const maxX = CGRectGetMaxX(rect);
    CGFloat const maxY = CGRectGetMaxY(rect);
    CGFloat const midX = CGRectGetMidX(rect);
    CGFloat const midY = CGRectGetMidY(rect);
    
    // 最大圆角半径
    CGFloat const maxR = MIN(rect.size.width, rect.size.height) * 0.5;
    
    XZImageBorder * const top         = self.borders.topIfLoaded      ?: self.borders;
    XZImageBorder * const left        = self.borders.leftIfLoaded     ?: self.borders;
    XZImageBorder * const bottom      = self.borders.bottomIfLoaded   ?: self.borders;
    XZImageBorder * const right       = self.borders.rightIfLoaded    ?: self.borders;
    
    XZImageCorner * const topLeft     = self.corners.topLeftIfLoaded     ?: self.corners;
    XZImageCorner * const bottomLeft  = self.corners.bottomLeftIfLoaded  ?: self.corners;
    XZImageCorner * const bottomRight = self.corners.bottomRightIfLoaded ?: self.corners;
    XZImageCorner * const topRight    = self.corners.topRightIfLoaded    ?: self.corners;
    
    CGFloat const radiusTR = RBS(MIN(maxR, topRight.radius), topRight.width);
    CGFloat const radiusBR = RBS(MIN(maxR, bottomRight.radius), bottomRight.width);
    CGFloat const radiusBL = RBS(MIN(maxR, bottomLeft.radius), bottomLeft.width);
    CGFloat const radiusTL = RBS(MIN(maxR, topLeft.radius), topLeft.width);
    
    { // 调整箭头位置
        CGFloat const w_2 = midX - minX;
        CGFloat const h_2 = midY - minY;
        [top.arrowIfLoaded adjustAnchorWithMinValue:-(w_2 - radiusTL - top.width) maxValue:(w_2 - radiusTR - top.width)];
        [top.arrowIfLoaded adjustVectorWithMinValue:-w_2 maxValue:w_2];
        
        [left.arrowIfLoaded adjustAnchorWithMinValue:-(h_2 - radiusBL - left.width) maxValue:(h_2 - radiusTL - left.width)];
        [left.arrowIfLoaded adjustVectorWithMinValue:-h_2 maxValue:h_2];
        
        [bottom.arrowIfLoaded adjustAnchorWithMinValue:-(w_2 - radiusBR - bottom.width) maxValue:(w_2 - radiusBL - bottom.width)];
        [bottom.arrowIfLoaded adjustVectorWithMinValue:-w_2 maxValue:w_2];
        
        [right.arrowIfLoaded adjustAnchorWithMinValue:-(h_2 - radiusTR - right.width) maxValue:(h_2 - radiusBR - right.width)];
        [right.arrowIfLoaded adjustVectorWithMinValue:-h_2 maxValue:h_2];
    }

    CGFloat const dT   = top.width;
    CGFloat const dT_2 = dT * 0.5;
    CGFloat const dR   = right.width;
    CGFloat const dR_2 = dR * 0.5;
    CGFloat const dB   = bottom.width;
    CGFloat const dB_2 = dB * 0.5;
    CGFloat const dL   = left.width;
    CGFloat const dL_2 = dL * 0.5;
    
    { // MARK: - Top line
        CGPoint start = CGPointMake(minX + radiusTL, minY);
        [backgroundPath moveToPoint:start];
        
        CGPointMove(&start, 0, dT_2);
        XZImageLinePath * const context = contexts ? [XZImageLinePath imagePathWithLine:top startPoint:start] : nil;
        
        XZImageBorderArrow const *arrow = top.arrowIfLoaded;
        if (arrow.width > 0 && arrow.height > 0) {
            CGFloat const w = arrow.width * 0.5;
            
            CGPoint point1 = CGPointMake(midX + arrow.anchor - w, minY);
            CGPoint point2 = CGPointMake(midX + arrow.vector, minY - arrow.height);
            CGPoint point3 = CGPointMake(midX + arrow.anchor + w, minY);
            [backgroundPath addLineToPoint:point1];
            [backgroundPath addLineToPoint:point2];
            [backgroundPath addLineToPoint:point3];
            
            if (context) {
                CGPoint const offset1 = [arrow offsetForVectorAtIndex:2 lineOffset:dT_2];
                CGPoint const offset2 = [arrow offsetForVectorAtIndex:0 lineOffset:dT_2];
                CGPoint const offset3 = [arrow offsetForVectorAtIndex:1 lineOffset:dT_2];
                CGPointMove(&point1, offset1.x, offset1.y);
                CGPointMove(&point2, offset2.x, offset2.y);
                CGPointMove(&point3, offset3.x, offset3.y);
                
                [context addLineToPoint:point1];
                [context addLineToPoint:point2];
                [context addLineToPoint:point3];
            }
        }
        
        CGPoint end = CGPointMake(maxX - radiusTR, minY);
        [backgroundPath addLineToPoint:end];
        
        if (context) {
            CGPointMoveY(&end, maxX - RDS(radiusTR, dR), dT_2);
            [context addLineToPoint:end];
            
            [contexts addObject:context];
        }
    }
    
    if (radiusTR > 0) { // MARK: - Top Right
        CGPoint const center = CGPointMake(maxX - radiusTR, minY + radiusTR);
        CGFloat const startAngle = -M_PI_2;
        CGFloat const endAngle   = 0;
        [backgroundPath addArcWithCenter:center radius:radiusTR startAngle:startAngle endAngle:endAngle clockwise:YES];
        
        if (contexts) {
            CGFloat const dTR_2 = topRight.width * 0.5;
            CGPoint const start = CGPointMake(maxX - radiusTR, minY + dTR_2);
            
            XZImageLinePath *context = [XZImageLinePath imagePathWithLine:topRight startPoint:start];
            [context addArcWithCenter:center
                               radius:(radiusTR - dTR_2)
                           startAngle:(startAngle)
                             endAngle:endAngle];
            [contexts addObject:context];
        }
    }
    
    { // MARK: - Right
        CGPoint start = CGPointMake(maxX, minY + radiusTR);
        [backgroundPath addLineToPoint:start];
        
        CGPointMove(&start, -dR_2, 0);
        XZImageLinePath *context = contexts ? [XZImageLinePath imagePathWithLine:right startPoint:start] : nil;
        
        XZImageBorderArrow const *arrow = right.arrowIfLoaded;
        if (arrow.width > 0 && arrow.height > 0) {
            CGFloat const w = arrow.width * 0.5;
            
            CGPoint point1 = CGPointMake(maxX, midY + arrow.anchor - w);
            CGPoint point2 = CGPointMake(maxX + arrow.height, midY + arrow.vector);
            CGPoint point3 = CGPointMake(maxX, midY + arrow.anchor + w);
            [backgroundPath addLineToPoint:point1];
            [backgroundPath addLineToPoint:point2];
            [backgroundPath addLineToPoint:point3];
            
            if (context) {
                CGPoint const offset1 = [arrow offsetForVectorAtIndex:2 lineOffset:dR_2];
                CGPoint const offset2 = [arrow offsetForVectorAtIndex:0 lineOffset:dR_2];
                CGPoint const offset3 = [arrow offsetForVectorAtIndex:1 lineOffset:dR_2];
                CGPointMove(&point1, -offset1.y, offset1.x);
                CGPointMove(&point2, -offset2.y, offset2.x);
                CGPointMove(&point3, -offset3.y, offset3.x);
                
                [context addLineToPoint:point1];
                [context addLineToPoint:point2];
                [context addLineToPoint:point3];
            }
        }
        
        CGPoint end = CGPointMake(maxX, maxY - radiusBR);
        [backgroundPath addLineToPoint:end];
        
        if (context) {
            CGPointMoveX(&end, -dR_2, maxY - RDS(radiusBR, dB));
            [context addLineToPoint:end];
            [contexts addObject:context];
        }
    }
    
    if (radiusBR > 0) { // MARK: - BottomRight
        CGPoint const center = CGPointMake(maxX - radiusBR, maxY - radiusBR);
        CGFloat const startAngle = 0;
        CGFloat const endAngle   = M_PI_2;
        [backgroundPath addArcWithCenter:center radius:radiusBR startAngle:startAngle endAngle:endAngle clockwise:YES];
        
        if (contexts) {
            CGFloat const dBR_2 = bottomRight.width * 0.5;
            CGPoint const start = CGPointMake(maxX - dBR_2, maxY - radiusBR);
            
            XZImageLinePath *context = [XZImageLinePath imagePathWithLine:bottomRight startPoint:start];
            [context addArcWithCenter:center
                               radius:(radiusBR - dBR_2)
                           startAngle:(startAngle)
                             endAngle:endAngle];
            [contexts addObject:context];
        }
    }
    
    { // MARK: - Bottom
        CGPoint start = CGPointMake(maxX - radiusBR, maxY);
        [backgroundPath addLineToPoint:start];
        
        CGPointMove(&start, 0, -dB_2);
        XZImageLinePath *context = contexts ? [XZImageLinePath imagePathWithLine:bottom startPoint:start] : nil;
        
        XZImageBorderArrow const *arrow = bottom.arrowIfLoaded;
        if (arrow.width > 0 && arrow.height > 0) {
            CGFloat const w = arrow.width * 0.5;
            
            CGPoint point1 = CGPointMake(midX - arrow.anchor + w, maxY);
            CGPoint point2 = CGPointMake(midX - arrow.vector, maxY + arrow.height);
            CGPoint point3 = CGPointMake(midX - arrow.anchor - w, maxY);
            [backgroundPath addLineToPoint:point1];
            [backgroundPath addLineToPoint:point2];
            [backgroundPath addLineToPoint:point3];
            
            if (context) {
                CGPoint const offset1 = [arrow offsetForVectorAtIndex:2 lineOffset:dB_2];
                CGPoint const offset2 = [arrow offsetForVectorAtIndex:0 lineOffset:dB_2];
                CGPoint const offset3 = [arrow offsetForVectorAtIndex:1 lineOffset:dB_2];
                CGPointMove(&point1, -offset1.x, -offset1.y);
                CGPointMove(&point2, -offset2.x, -offset2.y);
                CGPointMove(&point3, -offset3.x, -offset3.y);
                
                [context addLineToPoint:point1];
                [context addLineToPoint:point2];
                [context addLineToPoint:point3];
            }
        }
        
        CGPoint end = CGPointMake(minX + radiusBL, maxY);
        [backgroundPath addLineToPoint:end];
        
        if (context) {
            CGPointMoveY(&end, minX + RDS(radiusBL, dL), -dB_2);
            [context addLineToPoint:end];
            [contexts addObject:context];
        }
    }
    
    if (radiusBL > 0) { // MARK: - BottomLeft
        CGPoint const center = CGPointMake(minX + radiusBL, maxY - radiusBL);
        CGFloat const startAngle = M_PI_2;
        CGFloat const endAngle   = M_PI;
        [backgroundPath addArcWithCenter:center radius:radiusBL startAngle:startAngle endAngle:endAngle clockwise:YES];
        
        if (contexts) {
            CGFloat const dBL_2 = bottomLeft.width * 0.5;
            CGPoint const start = CGPointMake(minX + radiusBL, maxY - dBL_2);
            
            XZImageLinePath *context = [XZImageLinePath imagePathWithLine:bottomLeft startPoint:start];
            [context addArcWithCenter:center
                               radius:(radiusBL - dBL_2)
                           startAngle:(startAngle)
                             endAngle:endAngle];
            [contexts addObject:context];
        }
    }
    
    { // MARK: - Left
        CGPoint start = CGPointMake(minX, maxY - radiusBL);
        [backgroundPath addLineToPoint:start];
        
        CGPointMove(&start, dL_2, 0);
        XZImageLinePath *context = contexts ? [XZImageLinePath imagePathWithLine:left startPoint:start] : nil;
        
        XZImageBorderArrow const *arrow = left.arrowIfLoaded;
        if (arrow.width > 0 && arrow.height > 0) {
            CGFloat const w = arrow.width * 0.5;
            
            CGPoint point1 = CGPointMake(minX, midY - arrow.anchor + w);
            CGPoint point2 = CGPointMake(minX - arrow.height, midY - arrow.vector);
            CGPoint point3 = CGPointMake(minX, midY - arrow.anchor - w);
            [backgroundPath addLineToPoint:point1];
            [backgroundPath addLineToPoint:point2];
            [backgroundPath addLineToPoint:point3];
            
            if (context) {
                CGPoint const offset1 = [arrow offsetForVectorAtIndex:2 lineOffset:dL_2];
                CGPoint const offset2 = [arrow offsetForVectorAtIndex:0 lineOffset:dL_2];
                CGPoint const offset3 = [arrow offsetForVectorAtIndex:1 lineOffset:dL_2];
                CGPointMove(&point1, offset1.y, -offset1.x);
                CGPointMove(&point2, offset2.y, -offset2.x);
                CGPointMove(&point3, offset3.y, -offset3.x);
                
                [context addLineToPoint:point1];
                [context addLineToPoint:point2];
                [context addLineToPoint:point3];
            }
        }
        
        CGPoint end = CGPointMake(minX, minY + radiusTL);
        [backgroundPath addLineToPoint:end];
        
        if (context) {
            CGPointMoveX(&end, dL_2, minY + RDS(radiusTL, dT));
            [context addLineToPoint:end];
            [contexts addObject:context];
        }
    }
    
    if (radiusTL > 0) { // MARK: - TopLeft
        CGPoint const center = CGPointMake(minX + radiusTL, minY + radiusTL);
        CGFloat const startAngle = -M_PI;
        CGFloat const endAngle   = -M_PI_2;
        [backgroundPath addArcWithCenter:center radius:radiusTL startAngle:startAngle endAngle:endAngle clockwise:YES];
        
        if (contexts) {
            CGFloat const dTL_2 = topLeft.width * 0.5;
            CGPoint const start = CGPointMake(minX + dTL_2, minY + radiusTL);
            
            XZImageLinePath *context = [XZImageLinePath imagePathWithLine:topLeft startPoint:start];
            [context addArcWithCenter:center
                               radius:(radiusTL - dTL_2)
                           startAngle:(startAngle)
                             endAngle:endAngle];
            [contexts addObject:context];
        }
    }
    
    [backgroundPath closePath];
}

- (void)subAttribute:(__kindof XZImageAttribute *)subAttribute didUpdateAttribute:(id)attribute {
    if (subAttribute == _lineDash) {
        [self.borders.dash updateWithLineDash:_lineDash];
        [self.corners.dash updateWithLineDash:_lineDash];
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
        _lineDash = [XZImageLineDash lineDashWithLineDash:nil];
        _lineDash.superAttribute = self;
    }
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
    
    [self prepareRect:&rect frame:&frame withPoint:CGPointZero size:[self defaultSize]];
    
    CGFloat const w = frame.size.width + frame.origin.x * 2;
    CGFloat const h = frame.size.height + frame.origin.y * 2;
    
    return CGSizeMake(w, h);
}

- (UIBezierPath *)path {
    CGRect rect = CGRectZero;
    CGRect frame = CGRectZero;
    
    CGSize const size = [self defaultSize];
    [self prepareRect:&rect frame:&frame withPoint:CGPointZero size:size];
    
    UIBezierPath *backgroundPath = [[UIBezierPath alloc] init];
    [self createContexts:nil path:backgroundPath withRect:rect];
    
    return backgroundPath;
}

- (NSArray<id<XZImageLinePath>> *)linePaths {
    CGRect rect = CGRectZero;
    CGRect frame = CGRectZero;
    
    CGSize const size = [self defaultSize];
    [self prepareRect:&rect frame:&frame withPoint:CGPointZero size:size];
    
    NSMutableArray<XZImageLinePath *> * const contexts = [NSMutableArray arrayWithCapacity:8];
    [self createContexts:contexts path:nil withRect:rect];
    
    return contexts;
}

@end
