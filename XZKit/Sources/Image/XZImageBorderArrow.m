//
//  XZImageBorderArrow.m
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import "XZImageBorderArrow.h"
#import "XZImageBorderArrow+Extension.h"

/// 从反正切值得到三角形角度。
static inline CGFloat triangleArc(CGFloat tanValue) {
    return tanValue > 0 ? tanValue : (M_PI + tanValue);
}

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
    if ([self xz_setWidth:width]) {
        [self didUpdateAttribute:@"width"];
    }
}

- (void)setHeight:(CGFloat)height {
    if ([self xz_setHeight:height]) {
        [self didUpdateAttribute:@"height"];
    }
}

- (void)setAnchor:(CGFloat)anchor {
    if ([self xz_setAnchor:anchor]) {
        [self didUpdateAttribute:@"anchor"];
    }
}

- (void)setVector:(CGFloat)vector {
    if ([self xz_setVector:vector]) {
        [self didUpdateAttribute:@"vector"];
    }
}

- (BOOL)xz_setWidth:(CGFloat)width {
    if (_width == width) {
        return NO;
    }
    _width = width;
    [self updateOffsetsWithLineOffset:0];
    return YES;
}

- (BOOL)xz_setHeight:(CGFloat)height {
    if (_height == height) {
        return NO;
    }
    _height = height;
    [self updateOffsetsWithLineOffset:0];
    return YES;
}

- (BOOL)xz_setAnchor:(CGFloat)anchor {
    if (_anchor == anchor) {
        return NO;
    }
    _anchor = anchor;
    [self updateOffsetsWithLineOffset:0];
    return YES;
}

- (BOOL)xz_setVector:(CGFloat)vector {
    if (_vector == vector) {
        return NO;
    }
    _vector = vector;
    [self updateOffsetsWithLineOffset:0];
    return YES;
}

- (BOOL)isEffective {
    return _width > 0 && _height > 0;
}

- (CGFloat)effectiveWidth {
    return _height > 0 ? (_width > _minWidth ? _width : _minWidth) : 0;
}

- (CGFloat)effectiveHeight {
    return _width > 0 ? (_height > 0 ? _height : 0) : 0;
}

- (void)adjustAnchorWithMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue {
    CGFloat const w_2 = self.width * 0.5;
    _effectiveAnchor = MAX(minValue + w_2, MIN(maxValue - w_2, self.anchor));
}

- (void)adjustVectorWithMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue {
    CGFloat const _vector = self.vector;
    _effectiveVector = MAX(minValue, MIN(maxValue, _vector));
}

- (void)updateOffsetsWithLineOffset:(CGFloat)lineOffset {
    if (_lineOffset != lineOffset) {
        _lineOffset = lineOffset;
        
        CGFloat const onePix = 1.0 / UIScreen.mainScreen.scale;
        CGFloat const width  = self.effectiveWidth;
        CGFloat const height = self.effectiveHeight;
        
        if (_lineOffset == 0 || width == 0 || height == 0) {
            _vectorOffsets[0] = CGPointZero;
            _vectorOffsets[1] = CGPointZero;
            _vectorOffsets[2] = CGPointZero;
        } else {
            CGFloat const vector = self.effectiveVector;
            CGFloat const anchor = self.effectiveAnchor;
            
            CGFloat const width_2 = width * 0.5;
            CGFloat const lineOffset = _lineOffset;
            
            // 从顶部顶点开始顺时针三个角的度数 a, b, c
            if (fabs(vector - (anchor + width_2)) < onePix) { // 小于 1 像素
                CGFloat const a = atan(width / height);
                // CGFloat const b = M_PI_2;
                CGFloat const c = M_PI_2 - a;
                
                _vectorOffsets[0] = CGPointMake(0, lineOffset / sin(a));
                _vectorOffsets[1] = CGPointMake(0, lineOffset);
                _vectorOffsets[2] = CGPointMake(lineOffset / sin(c) - lineOffset / tan(c), lineOffset);
            } else if (fabs(vector - (anchor - width_2)) < onePix) {
                CGFloat const a = atan(width / height);
                CGFloat const b = M_PI_2 - a;
                // CGFloat const c = M_PI_2;
                
                _vectorOffsets[0] = CGPointMake(0, lineOffset / sin(a));
                _vectorOffsets[1] = CGPointMake(-lineOffset / sin(b) + lineOffset / tan(b), lineOffset);
                _vectorOffsets[2] = CGPointMake(0, lineOffset);
            } else {
                CGFloat const b = triangleArc(atan(height / (anchor + width_2 - vector)));
                CGFloat const c = triangleArc(atan(height / (vector - (anchor - width_2))));
                CGFloat const a = M_PI - b - c;
                
                CGFloat const a_2 = a * 0.5; // 顶角的一半
                
                CGFloat const d1 = lineOffset / sin(a_2); // 顶点到两斜边中心线交点的距离
                CGFloat const a1 = a_2 - M_PI_2 + b;      // 顶角平分线与底边的夹角
                
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
