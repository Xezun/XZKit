//
//  XZImageLinePath.h
//  XZKit
//
//  Created by Xezun on 2021/2/19.
//

#import <UIKit/UIKit.h>
#import <XZKit/XZImage.h>

NS_ASSUME_NONNULL_BEGIN

/// 连接另一条边时，如果连接的是圆角，则使用圆角半径，否则使用边的一半。
FOUNDATION_STATIC_INLINE CGFloat DRS(CGFloat radius, CGFloat d) {
    return radius > 0 ? radius : d;
}

/// 避免画的圆角异常：
/// radius < borderWidth / 2 不能画出圆角；
/// radius < borderWidth 会以中心点画出两个半圆。
FOUNDATION_STATIC_INLINE CGFloat BRS(CGFloat radius, CGFloat b) {
    return radius > 0 ? (radius > b ? radius : b) : 0;
}
/// 给纵横坐标分别增加 dx 和 dy
FOUNDATION_STATIC_INLINE void CGPointMove(CGPoint *point, CGFloat dx, CGFloat dy) {
    point->x += (dx); point->y += (dy);
}
/// 设置横坐标为 x 并给纵坐标增加 dy
FOUNDATION_STATIC_INLINE void CGPointMoveY(CGPoint *point, CGFloat x, CGFloat dy) {
    point->x = x; point->y += (dy);
}
/// 给横坐标增加 dx 并设置纵坐标为 y
FOUNDATION_STATIC_INLINE void CGPointMoveX(CGPoint *point, CGFloat dx, CGFloat y) {
    point->x += dx; point->y = y;
}

@class UIBezierPath;

@interface XZImageLinePath : NSObject <XZImageLinePath>

/// 构造
+ (instancetype)imagePathWithLine:(XZImageLine *)line startPoint:(CGPoint)startPoint;
/// 起点
@property (nonatomic, readonly) CGPoint startPoint;
/// 线型
@property (nonatomic, strong, readonly) XZImageLine *line;
/// 添加一条直线
- (void)addLineToPoint:(CGPoint)endPoint;
/// 添加一个圆角
- (void)addArcWithCenter:(CGPoint)center radius:(CGFloat)radiusTR startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle;

@end

@protocol XZImagePathItem <NSObject>
- (void)drawInContext:(CGContextRef)context;
- (void)addToPath:(UIBezierPath *)path;
@end

NS_ASSUME_NONNULL_END
