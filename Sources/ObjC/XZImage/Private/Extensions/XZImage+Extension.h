//
//  XZImage+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import "XZImage.h"
#import "XZImageBorders+Extension.h"
#import "XZImageCorners+Extension.h"
#import "XZImageLinePath.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZImage () <XZImageSuperAttribute> {
    XZImageLineDash *_lineDash;
}

@end

/// 边的终点偏移，如果有圆角，使用圆角半径，否则使用另一条边的粗细。
/// 即每条边都是与另一条边或圆角“相接但不相交”。
/// @param borderRadius 被相接的边的半径
/// @param borderWidth 被相接的边的线条粗细
FOUNDATION_STATIC_INLINE CGFloat XZImageGetBorderEndOffset(CGFloat borderRadius, CGFloat borderWidth) {
    return borderRadius > 0 ? borderRadius : borderWidth;
}
/// 保证圆角不小于线的粗细，以避免以下异常情况：
/// - 当 radius < borderWidth * 0.5 时，不能画出圆角；
/// - 当 radius < borderWidth 时，会以中心点画出两个半圆。
FOUNDATION_STATIC_INLINE CGFloat XZImageGetEffectiveRadius(CGFloat borderRadius, CGFloat borderWidth) {
    return borderRadius > 0 ? (borderRadius > borderWidth ? borderRadius : borderWidth) : 0;
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


/// 返回两个数中的最大的。
FOUNDATION_STATIC_INLINE CGFloat XZImageMAX(CGFloat a, CGFloat b) {
    return a > b ? a : b;
}

/// 返回两个数中的最小的。
FOUNDATION_STATIC_INLINE CGFloat XZImageMIN(CGFloat a, CGFloat b) {
    return a > b ? b : a;
}


NS_ASSUME_NONNULL_END
