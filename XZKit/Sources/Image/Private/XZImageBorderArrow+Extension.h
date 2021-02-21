//
//  XZImageBorderArrow+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/18.
//

#import <UIKit/UIKit.h>
#import <XZKit/XZImageBorder.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZImageBorderArrow () {
    CGFloat _lineOffset;
    CGPoint _vectorOffsets[3];
}

- (void)adjustAnchorWithMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue;
- (void)adjustVectorWithMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue;

- (void)updateOffsetsWithLineOffset:(CGFloat)lineOffset;
- (CGPoint)offsetForVectorAtIndex:(NSInteger)index lineOffset:(CGFloat)lineOffset;

@end

NS_ASSUME_NONNULL_END
