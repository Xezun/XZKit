//
//  XZImage.m
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import "XZImage.h"
#import "XZImageBorderArrow+XZImageDrawing.h"
#import "XZImageBorder+XZImageDrawing.h"

/// 连接另一条边时，如果连接的是圆角，则使用圆角半径，否则使用边的一半。
static inline CGFloat DRS(CGFloat radius, CGFloat d) {
    return radius > 0 ? radius : d;
}

/// 避免画的圆角异常：
/// radius < borderWidth / 2 不能画出圆角；
/// radius < borderWidth 会以中心点画出两个半圆。
static inline CGFloat BRS(CGFloat radius, CGFloat b) {
    return radius > 0 ? (radius > b ? radius : b) : 0;
}

@interface XZImageContext : NSObject
@property (nonatomic, strong) XZImageLine *line;
- (void)drawInContext:(CGContextRef)context;
+ (instancetype)contextForLine:(XZImageLine *)line;
/// 处于线型交接的线条需要起点。
@property (nonatomic) CGPoint startPoint;
@end

@interface XZImageBorderContext : XZImageContext
@property (nonatomic) CGPoint endPoint;
@end

@interface XZImageCornerContext : XZImageContext
@property (nonatomic) CGPoint center;
@property (nonatomic) CGFloat radius;
@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat endAngle;
@end

@implementation XZImage

@synthesize corners = _corners;
@synthesize borders = _borders;

- (XZImageCorners *)corners {
    if (_corners == nil) {
        _corners = [[XZImageCorners alloc] init];
    }
    return _corners;
}

- (XZImageBorders *)borders {
    if (_borders == nil) {
        _borders = [[XZImageBorders alloc] init];
    }
    return _borders;
}

- (CGFloat)borderWidth {
    return _borders.width;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.borders.width = borderWidth;
    self.corners.width = borderWidth;
}

- (UIColor *)borderColor {
    return _borders.color;
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.borders.color = borderColor;
    self.corners.color = borderColor;
}

- (XZImageLineDash)borderDash {
    return _borders.dash;
}

- (void)setBorderDash:(XZImageLineDash)borderDash {
    self.borders.dash = borderDash;
    self.corners.dash = borderDash;
}

- (CGFloat)cornerRadius {
    return _corners.radius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.corners.radius = cornerRadius;
}

/// 默认绘制区域大小。
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
    CGFloat as = UIScreen.mainScreen.scale / self.backgroundImage.scale;
    size.width /= as;
    size.height /= as;
    return size;
}

- (UIImage *)image {
    CGRect rect = CGRectZero;
    CGRect frame = CGRectZero;
    
    CGSize const size = [self defaultSize];
    [self prepareRect:&rect frame:&frame withPoint:CGPointZero size:size];
    
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0);
    [self drawWithRect:rect frame:frame];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

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

/// 计算绘制的背景区域、边框区域。
- (void)prepareRect:(CGRect *)rect frame:(CGRect *)frame withPoint:(CGPoint)point size:(CGSize)size {
    UIEdgeInsets const contentInsets = self.contentInsets;
    XZImageBorders *const borders = self.borders;
    XZImageCorners *const corners = self.corners;
    // 内容边距
    CGFloat const top    = (borders.top.arrowIfLoaded.height    + contentInsets.top);
    CGFloat const left   = (borders.left.arrowIfLoaded.height   + contentInsets.left);
    CGFloat const bottom = (borders.bottom.arrowIfLoaded.height + contentInsets.bottom);
    CGFloat const right  = (borders.right.arrowIfLoaded.height  + contentInsets.right);
    
    // 所需的最小宽度、高度
    CGFloat width = left + right;
    width += MAX(corners.topLeft.radius, corners.bottomLeft.radius);
    width += MAX(borders.top.arrowIfLoaded.width, borders.bottom.arrowIfLoaded.width);
    width += MAX(corners.topRight.radius, corners.bottomRight.radius);
    CGFloat height = top + bottom;
    height += MAX(corners.topLeft.radius, corners.topRight.radius);
    height += MAX(borders.left.arrowIfLoaded.width, borders.right.arrowIfLoaded.width);
    height += MAX(corners.bottomLeft.radius, corners.bottomRight.radius);
    
    CGFloat const deltaW = MAX(0, size.width - point.x - width);
    CGFloat const deltaH = MAX(0, size.height - point.y - height);
    
    frame->origin.x = point.x + contentInsets.left;
    frame->origin.y = point.y + contentInsets.top;
    frame->size.width = width + deltaW - contentInsets.left - contentInsets.right;
    frame->size.height = height + deltaH - contentInsets.top - contentInsets.bottom;
    
    rect->origin.x = point.x + left;
    rect->origin.y = point.y + top;
    rect->size.width = width + deltaW - left - right;
    rect->size.height = height + deltaH - top - bottom;
}

/// 绘制。
/// @param rect 边框的绘制区域
/// @param frame 包括箭头在内的整体绘制区域
- (void)drawWithRect:(CGRect const)rect frame:(CGRect const)frame {
    NSMutableArray<XZImageContext *> *images = [NSMutableArray arrayWithCapacity:20];
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [self createContexts:images path:path withRect:rect];

    CGContextRef const context = UIGraphicsGetCurrentContext();
    // LineJion 拐角：kCGLineJoinMiter尖角、kCGLineJoinRound圆角、kCGLineJoinBevel缺角
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    // LineCap 线端：kCGLineCapButt无、kCGLineCapRound圆形、kCGLineCapSquare方形
    CGContextSetLineCap(context, kCGLineCapButt);
    CGContextSetFillColorWithColor(context, UIColor.clearColor.CGColor);
    
    // 绘制背景
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
    CGContextAddPath(context, path.CGPath);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
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
    CGContextSaveGState(context);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextSetStrokeColorWithColor(context, UIColor.clearColor.CGColor);
    CGContextSetLineWidth(context, 1.0 / UIScreen.mainScreen.scale);
    CGContextAddPath(context, path.CGPath);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    { // 移动笔尖到起点
        CGPoint const start = images.firstObject.startPoint;
        CGContextMoveToPoint(context, start.x, start.y);
    }
    
    // 开始新的绘制
    CGContextSaveGState(context);
    
    // 绘制边框
    XZImageLine *line = nil;
    for (XZImageContext * const image in images) {
        if (![line isEqual:image.line]) {
            // 线型不一样，结束上一个绘制
            if (line != nil) {
                CGContextStrokePath(context);
                CGContextRestoreGState(context);
                
                // 开始新的绘制
                CGContextSaveGState(context);
                // 线型切换了，上一条线的终点有可能不是当前线的起点。
                CGContextMoveToPoint(context, image.startPoint.x, image.startPoint.y);
            }
            
            line = image.line;
            
            // 配置样式
            CGContextSetStrokeColorWithColor(context, line.color.CGColor);
            CGContextSetLineWidth(context, line.width);
            if (line.dash.width > 0 && line.dash.space > 0) {
                CGFloat const dashes[2] = {line.dash.width, line.dash.space};
                CGContextSetLineDash(context, 0, dashes, 2);
            }
        }
        
        // 绘制
        [image drawInContext:context];
    }
    
    // 结束绘制
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

/// 创建绘制内容。
/// @param contexts 输出，边框的绘制内容将添加到此数组
/// @param backgroundPath 输出，背景色填充路径
/// @param rect 绘制区域（矩形所在的区域，不包括箭头，箭头绘制在此区域外）
- (void)createContexts:(NSMutableArray<XZImageContext *> * const)contexts path:(UIBezierPath * const)backgroundPath withRect:(CGRect const)rect {
    
    CGFloat const minX = CGRectGetMinX(rect);
    CGFloat const minY = CGRectGetMinY(rect);
    CGFloat const maxX = CGRectGetMaxX(rect);
    CGFloat const maxY = CGRectGetMaxY(rect);
    CGFloat const midX = CGRectGetMidX(rect);
    CGFloat const midY = CGRectGetMidY(rect);
    
    // 最大圆角半径
    CGFloat const maxR = MIN(rect.size.width, rect.size.height) * 0.5;
    
    XZImageCorner * const topLeft     = self.corners.topLeft;
    XZImageBorder * const top         = self.borders.top;
    XZImageCorner * const topRight    = self.corners.topRight;
    XZImageBorder * const right       = self.borders.right;
    XZImageCorner * const bottomRight = self.corners.bottomRight;
    XZImageBorder * const bottom      = self.borders.bottom;
    XZImageCorner * const bottomLeft  = self.corners.bottomLeft;
    XZImageBorder * const left        = self.borders.left;
    
    CGFloat const radiusTR = BRS(MIN(maxR, topRight.radius), topRight.width);
    CGFloat const radiusBR = BRS(MIN(maxR, bottomRight.radius), bottomRight.width);
    CGFloat const radiusBL = BRS(MIN(maxR, bottomLeft.radius), bottomLeft.width);
    CGFloat const radiusTL = BRS(MIN(maxR, topLeft.radius), topLeft.width);
    
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

    CGFloat const dT = top.width * 0.5;
    CGFloat const dR = right.width * 0.5;
    CGFloat const dB = bottom.width * 0.5;
    CGFloat const dL = left.width * 0.5;
    
    // 从顶边中点或箭头的顶点开始顺时针开始绘制。
    { // 右上角
        {
            XZImageBorderArrow const *arrow = top.arrowIfLoaded;
            
            if (arrow.width == 0 || arrow.height == 0) {
                CGPoint start = CGPointMake(midX, minY);
                [backgroundPath moveToPoint:start];
                start.y += dT;
                
                CGPoint point = CGPointMake(maxX - DRS(radiusTR, dR), minY);
                [backgroundPath addLineToPoint:point];
                
                point.y += dT;
                
                // 因为要移动笔尖，所以即使没有 border 也创建context
                XZImageBorderContext *border = [XZImageBorderContext contextForLine:top];
                border.startPoint = start;
                border.endPoint = point;
                [contexts addObject:border];
            } else {
                CGPoint start = CGPointMake(midX + arrow.vector, minY - arrow.height);
                [backgroundPath moveToPoint:start];
                
                CGFloat const w = arrow.width * 0.5;
                CGFloat const anchor = MIN(arrow.anchor, maxX - radiusTR - w);
                
                CGPoint point1 = CGPointMake(midX + anchor + w, minY);
                CGPoint point2 = CGPointMake(maxX - DRS(radiusTR, dR), minY);
                [backgroundPath addLineToPoint:point1];
                [backgroundPath addLineToPoint:point2];
                
                CGPoint const offset1 = [arrow offsetForVectorAtIndex:0 lineOffset:dT];
                CGPoint const offset2 = [arrow offsetForVectorAtIndex:1 lineOffset:dT];
                start.x += offset1.x;
                start.y += offset1.y;
                point1.x += offset2.x;
                point1.y += offset2.y;
                point2.y += (dT);
                
                XZImageBorderContext *border1 = [XZImageBorderContext contextForLine:top];
                border1.startPoint = start;
                border1.endPoint = point1;
                [contexts addObject:border1];
                
                XZImageBorderContext *border2 = [XZImageBorderContext contextForLine:top];
                border2.endPoint = point2;
                [contexts addObject:border2];
            }
        }
        
        CGPoint const center = CGPointMake(maxX - radiusTR, minY + radiusTR);
        CGFloat const startAngle = -M_PI_2;
        CGFloat const endAngle   = 0;
        [backgroundPath addArcWithCenter:center radius:radiusTR startAngle:startAngle endAngle:endAngle clockwise:YES];
        
        if (radiusTR > 0) {
            XZImageCornerContext *corner = [XZImageCornerContext contextForLine:topRight];
            corner.radius = radiusTR - topRight.width * 0.5;
            corner.center = center;
            corner.startAngle = startAngle;
            corner.endAngle   = endAngle;
            corner.startPoint = CGPointMake(maxX - radiusTR, minY + topRight.width * 0.5);
            [contexts addObject:corner];
        }
        
        {
            XZImageBorderArrow const *arrow = right.arrowIfLoaded;
            if (arrow.width == 0 || arrow.height == 0) {
                CGPoint point = CGPointMake(maxX, midY);
                [backgroundPath addLineToPoint:point];
                
                point.x -= dR;
                
                XZImageBorderContext *border = [XZImageBorderContext contextForLine:right];
                border.startPoint = CGPointMake(maxX - dR, minY + DRS(radiusTR, dT));
                border.endPoint = point;
                [contexts addObject:border];
            } else {
                CGFloat const w = arrow.width * 0.5;
                
                CGPoint point1 = CGPointMake(maxX, midY + arrow.anchor - w);
                CGPoint point2 = CGPointMake(maxX + arrow.height, midY + arrow.vector);
                [backgroundPath addLineToPoint:point1];
                [backgroundPath addLineToPoint:point2];
                
                CGPoint const offset1 = [arrow offsetForVectorAtIndex:2 lineOffset:dR];
                CGPoint const offset2 = [arrow offsetForVectorAtIndex:0 lineOffset:dR];
                point1.x -= offset1.y;
                point1.y += offset1.x;
                point2.x -= offset2.y;
                point2.y += offset2.x;
                
                XZImageBorderContext *border1 = [XZImageBorderContext contextForLine:right];
                border1.startPoint = CGPointMake(maxX - dR, minY + DRS(radiusTR, dT));
                border1.endPoint = point1;
                [contexts addObject:border1];

                XZImageBorderContext *border2 = [XZImageBorderContext contextForLine:right];
                border2.endPoint = point2;
                [contexts addObject:border2];
            }
        }
    }
    
    { // 右下角
        {
            XZImageBorderArrow const *arrow = right.arrowIfLoaded;
            if (arrow.width == 0 || arrow.height == 0) {
                CGPoint point = CGPointMake(maxX, maxY - DRS(radiusBR, dB));
                [backgroundPath addLineToPoint:point];
                
                point.x -= dR;
                
                XZImageBorderContext *border = [XZImageBorderContext contextForLine:right];
                border.endPoint = point;
                [contexts addObject:border];
            } else {
                CGFloat const w = arrow.width * 0.5;
                
                CGPoint point1 = CGPointMake(maxX, midY + arrow.anchor + w);
                CGPoint point2 = CGPointMake(maxX, maxY - DRS(radiusBR, dB));
                [backgroundPath addLineToPoint:point1];
                [backgroundPath addLineToPoint:point2];
                
                CGPoint const offset1 = [arrow offsetForVectorAtIndex:1 lineOffset:dR];
                point1.x -= offset1.y;
                point1.y += offset1.x;
                
                point2.x -= (dR);
                
                XZImageBorderContext *border1 = [XZImageBorderContext contextForLine:right];
                border1.endPoint = point1;
                [contexts addObject:border1];

                XZImageBorderContext *border2 = [XZImageBorderContext contextForLine:right];
                border2.endPoint = point2;
                [contexts addObject:border2];
            }
        }
        
        CGPoint const center = CGPointMake(maxX - radiusBR, maxY - radiusBR);
        CGFloat const startAngle = 0;
        CGFloat const endAngle   = M_PI_2;
        [backgroundPath addArcWithCenter:center radius:radiusBR startAngle:startAngle endAngle:endAngle clockwise:YES];
        
        if (radiusBR > 0) {
            XZImageCornerContext *corner = [XZImageCornerContext contextForLine:bottomRight];
            corner.radius = radiusBR - bottomRight.width * 0.5;
            corner.center = center;
            corner.startAngle = startAngle;
            corner.endAngle   = endAngle;
            corner.startPoint = CGPointMake(maxX - bottomRight.width * 0.5, maxY - radiusBR);
            [contexts addObject:corner];
        }
        
        {
            XZImageBorderArrow const *arrow = bottom.arrowIfLoaded;
            if (arrow.width == 0 || arrow.height == 0) {
                CGPoint point   = CGPointMake(midX, maxY);
                [backgroundPath addLineToPoint:point];
                
                point.y -= dB;
                
                XZImageBorderContext *border = [XZImageBorderContext contextForLine:bottom];
                border.startPoint = CGPointMake(maxX - DRS(radiusBR, dR), maxY - dB);
                border.endPoint = point;
                [contexts addObject:border];
            } else {
                CGFloat const w = arrow.width * 0.5;
                
                CGPoint point1 = CGPointMake(midX + arrow.anchor + w, maxY);
                CGPoint point2 = CGPointMake(midX + arrow.vector, maxY + arrow.height);
                [backgroundPath addLineToPoint:point1];
                [backgroundPath addLineToPoint:point2];
                
                CGPoint const offset1 = [arrow offsetForVectorAtIndex:2 lineOffset:dB];
                CGPoint const offset2 = [arrow offsetForVectorAtIndex:0 lineOffset:dB];
                point1.x -= offset1.x;
                point1.y -= offset1.y;
                point2.x -= offset2.x;
                point2.y -= offset2.y;
                
                XZImageBorderContext *border1 = [XZImageBorderContext contextForLine:bottom];
                border1.startPoint = CGPointMake(maxX - DRS(radiusBR, dR), maxY - dB);
                border1.endPoint = point1;
                [contexts addObject:border1];

                XZImageBorderContext *border2 = [XZImageBorderContext contextForLine:bottom];
                border2.endPoint = point2;
                [contexts addObject:border2];
            }
        }
    }
    
    { // 左下角
        {
            XZImageBorderArrow const *arrow = bottom.arrowIfLoaded;
            if (arrow.width == 0 || arrow.height == 0) {
                CGPoint point = CGPointMake(minX + DRS(radiusBL, dL), maxY);
                [backgroundPath addLineToPoint:point];
                
                point.y -= dB;
                
                XZImageBorderContext *border = [XZImageBorderContext contextForLine:bottom];
                border.endPoint = point;
                [contexts addObject:border];
            } else {
                CGFloat const w = arrow.width * 0.5;
                
                CGPoint point1 = CGPointMake(midX + arrow.anchor - w, maxY);
                CGPoint point2 = CGPointMake(minX + DRS(radiusBL, dL), maxY);
                [backgroundPath addLineToPoint:point1];
                [backgroundPath addLineToPoint:point2];
                
                CGPoint const offset1 = [arrow offsetForVectorAtIndex:1 lineOffset:dB];
                point1.x -= offset1.x;
                point1.y -= offset1.y;
                
                point2.y -= (dB);
                
                XZImageBorderContext *border1 = [XZImageBorderContext contextForLine:bottom];
                border1.endPoint = point1;
                [contexts addObject:border1];

                XZImageBorderContext *border2 = [XZImageBorderContext contextForLine:bottom];
                border2.endPoint = point2;
                [contexts addObject:border2];
            }
        }
        
        CGPoint const center = CGPointMake(minX + radiusBL, maxY - radiusBL);
        CGFloat const startAngle = M_PI_2;
        CGFloat const endAngle   = M_PI;
        [backgroundPath addArcWithCenter:center radius:radiusBL startAngle:startAngle endAngle:endAngle clockwise:YES];
        
        if (radiusBL > 0) {
            XZImageCornerContext *corner = [XZImageCornerContext contextForLine:bottomLeft];
            corner.radius = radiusBL - bottomLeft.width * 0.5;
            corner.center = center;
            corner.startAngle = startAngle;
            corner.endAngle   = endAngle;
            corner.startPoint = CGPointMake(minX + radiusBL, maxY - bottomLeft.width * 0.5);
            [contexts addObject:corner];
        }
        
        {
            XZImageBorderArrow const *arrow = left.arrowIfLoaded;
            if (arrow.width == 0 || arrow.height == 0) {
                CGPoint point = CGPointMake(minX, midY);
                [backgroundPath addLineToPoint:point];
                
                point.x += dL;
                
                XZImageBorderContext *border = [XZImageBorderContext contextForLine:left];
                border.startPoint = CGPointMake(minX + dL, maxY - DRS(radiusBL, dB));
                border.endPoint = point;
                [contexts addObject:border];
            } else {
                CGFloat const w = arrow.width * 0.5;
                
                CGPoint point1 = CGPointMake(minX, midY + arrow.anchor + w);
                CGPoint point2 = CGPointMake(minX - arrow.height, midY + arrow.vector);
                [backgroundPath addLineToPoint:point1];
                [backgroundPath addLineToPoint:point2];
                
                CGPoint const offset1 = [arrow offsetForVectorAtIndex:2 lineOffset:dL];
                CGPoint const offset2 = [arrow offsetForVectorAtIndex:0 lineOffset:dL];
                point1.x += offset1.y;
                point1.y -= offset1.x;
                point2.x += offset2.y;
                point2.y -= offset2.x;
                
                XZImageBorderContext *border1 = [XZImageBorderContext contextForLine:left];
                border1.startPoint = CGPointMake(minX + dL, maxY - DRS(radiusBL, dB));
                border1.endPoint = point1;
                [contexts addObject:border1];

                XZImageBorderContext *border2 = [XZImageBorderContext contextForLine:left];
                border2.endPoint = point2;
                [contexts addObject:border2];
            }
        }
    }
    
    { // 左上角
        {
            XZImageBorderArrow const *arrow = left.arrowIfLoaded;
            if (arrow.width == 0 || arrow.height == 0) {
                CGPoint point = CGPointMake(minX, minY + DRS(radiusTL, dT));
                [backgroundPath addLineToPoint:point];
                
                point.x += dL;
                
                XZImageBorderContext *border = [XZImageBorderContext contextForLine:left];
                border.endPoint = point;
                [contexts addObject:border];
            } else {
                CGFloat const w = arrow.width * 0.5;
                
                CGPoint point1 = CGPointMake(minX, midY + arrow.anchor - w);
                CGPoint point2 = CGPointMake(minX, minY + DRS(radiusTL, dT * 2.0)); // MARK: 👈 终点（不与顶线相交）
                [backgroundPath addLineToPoint:point1];
                [backgroundPath addLineToPoint:point2];
                
                CGPoint const offset1 = [arrow offsetForVectorAtIndex:1 lineOffset:dL];
                point1.x += offset1.y;
                point1.y -= offset1.x;
                
                point2.x += (dL);
                
                XZImageBorderContext *border1 = [XZImageBorderContext contextForLine:left];
                border1.endPoint = point1;
                [contexts addObject:border1];
                
                
                XZImageBorderContext *border2 = [XZImageBorderContext contextForLine:left];
                border2.endPoint = point2;
                [contexts addObject:border2];
            }
        }
        
        CGPoint const center = CGPointMake(minX + radiusTL, minY + radiusTL);
        CGFloat const startAngle = -M_PI;
        CGFloat const endAngle   = -M_PI_2;
        [backgroundPath addArcWithCenter:center radius:radiusTL startAngle:startAngle endAngle:endAngle clockwise:YES];
        
        if (radiusTL > 0) {
            XZImageCornerContext *corner = [XZImageCornerContext contextForLine:topLeft];
            corner.radius = radiusTL - topLeft.width * 0.5;
            corner.center = center;
            corner.startAngle = startAngle;
            corner.endAngle   = endAngle;
            corner.startPoint = CGPointMake(minX + topLeft.width * 0.5, minY + radiusTL);
            [contexts addObject:corner];
        }
        
        {
            XZImageBorderArrow const *arrow = top.arrowIfLoaded;
            if (arrow.width == 0 || arrow.height == 0) {
                CGPoint point = CGPointMake(midX, minY);
                [backgroundPath addLineToPoint:point];
                
                point.y += dT;
                
                XZImageBorderContext *border = [XZImageBorderContext contextForLine:top];
                border.startPoint = CGPointMake(minX + DRS(radiusTL, dL), minY + dT);
                border.endPoint = point;
                [contexts insertObject:border atIndex:0];
            } else {
                CGFloat const w = arrow.width * 0.5;
                
                CGPoint point1 = CGPointMake(midX + arrow.anchor - w, minY); // MARK: 👈 起点
                CGPoint point2 = CGPointMake(midX + arrow.vector, minY - arrow.height);
                [backgroundPath addLineToPoint:point1];
                [backgroundPath addLineToPoint:point2];
                
                CGPoint const offset1 = [arrow offsetForVectorAtIndex:2 lineOffset:dT];
                CGPoint const offset2 = [arrow offsetForVectorAtIndex:0 lineOffset:dT];
                point1.x += offset1.x;
                point1.y += offset1.y;
                point2.x += offset2.x;
                point2.y += offset2.y;
                
                // 虽然起点和终点是同一个点，但是如果把它们放在两条线上的话，
                // CG 不能很好的处理它们的交汇和拐角。
                // 所以这里的操作就是让绘制从顶边开始绘制，避免点交汇缺口的问题。
                // 而且起点是从左上角最左边开始，而不是从左边线条粗细的一半开始，避免左上角缺角。
                
                XZImageBorderContext *border1 = [XZImageBorderContext contextForLine:top];
                border1.startPoint = CGPointMake(minX + radiusTL, minY + dT); // 👈 起点从最左边开始
                border1.endPoint = point1;
                [contexts insertObject:border1 atIndex:0];

                XZImageBorderContext *border2 = [XZImageBorderContext contextForLine:top];
                border2.endPoint = point2;
                [contexts insertObject:border2 atIndex:1];
                
            }
        }
    }
    
    [backgroundPath closePath];
}

@end



@implementation XZImageContext

+ (instancetype)contextForLine:(XZImageLine *)line {
    return [[self alloc] initWithLine:line];
}

- (instancetype)initWithLine:(XZImageLine *)line {
    self = [super init];
    if (self) {
        _line = line;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context {
    NSAssert(NO, @"");
}

@end

@implementation XZImageCornerContext

- (void)drawInContext:(CGContextRef)context {
    // CG 的坐标系 顺时针方向 跟 UI 是反的
    CGContextAddArc(context, _center.x, _center.y, _radius, _startAngle, _endAngle, NO);
}

@end

@implementation XZImageBorderContext

- (void)drawInContext:(CGContextRef)context {
    CGContextAddLineToPoint(context, _endPoint.x, _endPoint.y);
    
    // NSLog(@"addLine: (%.2f, %.2f)", _endPoint.x, _endPoint.y);
}

@end
