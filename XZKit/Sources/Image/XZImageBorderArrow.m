//
//  XZImageBorderArrow.m
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import "XZImageBorderArrow.h"
#import "XZImageBorderArrow+Extension.h"

@implementation XZImageBorderArrow

- (instancetype)initWithArrow:(XZImageBorderArrow *)arrow {
    self = [super init];
    if (self && arrow) {
        _width  = arrow.width;
        _height = arrow.height;
        _vector = arrow.vector;
        _anchor = arrow.anchor;
        
        _lineOffset = arrow->_lineOffset;
        _vectorOffsets[0] = arrow->_vectorOffsets[0];
        _vectorOffsets[1] = arrow->_vectorOffsets[1];
        _vectorOffsets[2] = arrow->_vectorOffsets[2];
    }
    return self;
}

- (void)setWidth:(CGFloat)width {
    if (_width != width) {
        _width = width;
        [self updateOffsetsWithLineOffset:0];
    }
}

- (void)setHeight:(CGFloat)height {
    if (_height != height) {
        _height = height;
        [self updateOffsetsWithLineOffset:0];
    }
}

- (void)setAnchor:(CGFloat)anchor {
    if (_anchor != anchor) {
        _anchor = anchor;
        [self updateOffsetsWithLineOffset:0];
    }
}

- (void)setVector:(CGFloat)vector {
    if (_vector != vector) {
        _vector = vector;
        [self updateOffsetsWithLineOffset:0];
    }
}

- (void)adjustAnchorWithMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue {
    CGFloat const _width  = MAX(0.0, MIN(maxValue - minValue, self.width));
    CGFloat const w_2     = _width * 0.5;
    CGFloat const _anchor = MAX(minValue + w_2, MIN(maxValue - w_2, self.anchor));
    self.width  = _width;
    self.anchor = _anchor;
}

- (void)adjustVectorWithMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue {
    CGFloat const _vector = self.vector;
    self.vector = MAX(minValue, MIN(maxValue, _vector));
}

- (void)updateOffsetsWithLineOffset:(CGFloat)lineOffset {
    if (_lineOffset != lineOffset) {
        _lineOffset = lineOffset;
        
        CGFloat const onePix = 1.0 / UIScreen.mainScreen.scale;
        
        if (_lineOffset == 0) {
            _vectorOffsets[0] = CGPointZero;
            _vectorOffsets[1] = CGPointZero;
            _vectorOffsets[2] = CGPointZero;
        } else {
            CGFloat const _width = self.width;
            CGFloat const _height = self.height;
            CGFloat const _vector = self.vector;
            CGFloat const _anchor = self.anchor;
            
            CGFloat const lineOffset = _lineOffset;
            CGFloat const width2 = _width * 0.5;
            
            // 从顶部顶点开始顺时针三个角的度数 a, b, c
            if (fabs(_vector - (_anchor + width2)) < onePix) { // 小于 1 像素
                CGFloat const a = atan(_width / _height);
                // CGFloat const b = M_PI_2;
                CGFloat const c = M_PI_2 - a;
                
                _vectorOffsets[0] = CGPointMake(0, lineOffset / sin(a));
                _vectorOffsets[1] = CGPointMake(0, lineOffset);
                _vectorOffsets[2] = CGPointMake(lineOffset / sin(c) - lineOffset / tan(c), lineOffset);
            } else if (fabs(_vector - (_anchor - width2)) < onePix) {
                CGFloat const a = atan(_width / _height);
                CGFloat const b = M_PI_2 - a;
                // CGFloat const c = M_PI_2;
                
                _vectorOffsets[0] = CGPointMake(0, lineOffset / sin(a));
                _vectorOffsets[1] = CGPointMake(-lineOffset / sin(b) + lineOffset / tan(b), lineOffset);
                _vectorOffsets[2] = CGPointMake(0, lineOffset);
            } else {
                CGFloat const b = atan(_height / (_anchor + width2 - _vector));
                CGFloat const c = atan(_height / (_vector - (_anchor - width2)));
                CGFloat const a = M_PI - b - c;
                
                CGFloat const a_2 = a * 0.5; // 顶角的一半
                
                CGFloat d1 = lineOffset / sin(a_2);    // 外顶点到两斜边交点
                CGFloat const a1 = a_2 - M_PI_2 + b;
                
                _vectorOffsets[0] = CGPointMake(-d1 * sin(a1), d1 * cos(a1));
                _vectorOffsets[1] = CGPointMake(-lineOffset / sin(b) + lineOffset / tan(b), lineOffset);
                _vectorOffsets[2] = CGPointMake(lineOffset / sin(c) - lineOffset / tan(c), lineOffset);
            }
        }
    }
}

- (CGPoint)offsetForVectorAtIndex:(NSInteger)index lineOffset:(CGFloat)lineOffset {
    [self updateOffsetsWithLineOffset:MAX(0, lineOffset)];
    return _vectorOffsets[index];
}

@end
