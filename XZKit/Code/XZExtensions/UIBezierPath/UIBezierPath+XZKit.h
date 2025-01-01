//
//  UIBezierPath+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/9/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBezierPath (XZKit)

/// 生成中心在在指定点上的五角星路径。
/// @param center 五角星中心点
/// @param outerRadius 五角星外接圆半径
/// @param innerRadius 五角星内接圆半径，若小于或等于 0 则生成正五角星路径。
+ (instancetype)xz_bezierPathWithPentacleCenter:(CGPoint)center circumcircle:(CGFloat)outerRadius incircle:(CGFloat)innerRadius NS_SWIFT_NAME(init(pentacle:circumcircle:incircle:));

/// 生成中心在在指定点上的正五角星路径。
/// @param center 五角星中心点
/// @param outerRadius 五角星外接圆半径
+ (instancetype)xz_bezierPathWithPentacleCenter:(CGPoint)center circumcircle:(CGFloat)outerRadius NS_SWIFT_NAME(init(pentacle:circumcircle:));

@end

NS_ASSUME_NONNULL_END
