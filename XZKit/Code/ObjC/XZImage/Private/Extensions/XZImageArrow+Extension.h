//
//  XZImageArrow+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/18.
//

#import <UIKit/UIKit.h>
#import "XZImageBorder.h"
#import "XZImageAttribute+Extension.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZImageArrow () {
    CGFloat _lineOffset;
    CGPoint _vectorOffsets[3];
}

- (instancetype)initWithSuperAttribute:(id<XZImageSuperAttribute>)superAttribute NS_UNAVAILABLE;
- (instancetype)initWithBorder:(nullable XZImageBorder *)border NS_DESIGNATED_INITIALIZER;

/// 宽高都大于0
@property (nonatomic, readonly) BOOL isEffective;
@property (nonatomic, readonly) CGFloat effectiveWidth;
@property (nonatomic, readonly) CGFloat effectiveHeight;

@property (nonatomic, readonly) CGFloat effectiveAnchor;
/// 根据最大值、最小值，调整 anchor 到合适的位置
- (void)updateEffectiveAnchorWithMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue;

@property (nonatomic, readonly) CGFloat effectiveVector;
/// 根据最大值、最小值，调整 vector 到合适的位置
- (void)updateEffectiveVectorWithMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue;

- (BOOL)setWidthValue:(CGFloat)width;
- (BOOL)setHeightValue:(CGFloat)height;
- (BOOL)setAnchorValue:(CGFloat)anchor;
- (BOOL)setVectorValue:(CGFloat)vector;
- (void)updateWithBorderArrowValue:(nullable XZImageArrow *)borderArrow;

/// 根据边距的移动距离，更新三个点的偏移值。
/// @note 顶点位置发生改变时，重置 offsets
- (void)updateOffsetsWithLineOffset:(CGFloat)lineOffset;
/// 获取点的偏移值：从顶点开始，顺时针方向分别为 0/1/2 点
- (CGPoint)offsetForVectorAtIndex:(NSInteger)index lineOffset:(CGFloat)lineOffset;

@end

NS_ASSUME_NONNULL_END
