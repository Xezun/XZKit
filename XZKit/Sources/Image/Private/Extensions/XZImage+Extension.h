//
//  XZImage+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import <XZKit/XZImage.h>
#import <XZKit/XZImageBorders+Extension.h>
#import <XZKit/XZImageCorners+Extension.h>
#import <XZKit/XZImageLinePath.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZImage () <XZImageAttribute> {
    XZImageLineDash *_lineDash;
}

@end

/// 连接另一条边时，如果连接的是圆角，则使用圆角半径，否则使用边的一半。
FOUNDATION_STATIC_INLINE CGFloat RDS(CGFloat radius, CGFloat d) {
    return radius > 0 ? radius : d;
}
/// 避免画的圆角异常：
/// radius < borderWidth / 2 不能画出圆角；
/// radius < borderWidth 会以中心点画出两个半圆。
FOUNDATION_STATIC_INLINE CGFloat RBS(CGFloat radius, CGFloat b) {
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


NS_ASSUME_NONNULL_END
