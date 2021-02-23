//
//  XZImageBorderArrow+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/18.
//

#import <UIKit/UIKit.h>
#import <XZKit/XZImageBorder.h>
#import <XZKit/XZImageAttribute+Extension.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZImageBorderArrow () {
    CGFloat _lineOffset;
    CGPoint _vectorOffsets[3];
}

/// 最小宽度，由其所在的边赋值。
@property (nonatomic) CGFloat minWidth;

/// 宽高都大于0
@property (nonatomic, readonly) BOOL isEffective;
@property (nonatomic, readonly) CGFloat effectiveWidth;
@property (nonatomic, readonly) CGFloat effectiveHeight;

@property (nonatomic, readonly) CGFloat effectiveAnchor;
@property (nonatomic, readonly) CGFloat effectiveVector;
/// 根据最大值、最小值，调整 anchor 到合适的位置
- (void)adjustAnchorWithMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue;
/// 根据最大值、最小值，调整 vector 到合适的位置
- (void)adjustVectorWithMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue;

- (BOOL)xz_setWidth:(CGFloat)width;
- (BOOL)xz_setHeight:(CGFloat)height;
- (BOOL)xz_setAnchor:(CGFloat)anchor;
- (BOOL)xz_setVector:(CGFloat)vector;

/// 根据边距的移动距离，更新三个点的偏移值。
/// @note 顶点位置发生改变时，重置 offsets
- (void)updateOffsetsWithLineOffset:(CGFloat)lineOffset;
/// 获取点的偏移值：从顶点开始，顺时针方向分别为 0/1/2 点
- (CGPoint)offsetForVectorAtIndex:(NSInteger)index lineOffset:(CGFloat)lineOffset;

@end

NS_ASSUME_NONNULL_END
