//
//  XZImageBorder.m
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import "XZImageBorder.h"
#import "XZImageBorderArrow+XZImageDrawing.h"

@implementation XZImageBorder

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (XZImageBorderArrow *)arrow {
    if (_arrow == nil) {
        _arrow = [[XZImageBorderArrow alloc] init];
    }
    return _arrow;
}

@end

@implementation XZImageBorderArrow

- (instancetype)init {
    self = [super init];
    if (self) {
        _width = 0;
        _height = 0;
        _vector = 0;
        _anchor = 0;
        
        _lineOffset = 0;
        _vectorOffsets[0] = CGPointZero;
        _vectorOffsets[1] = CGPointZero;
        _vectorOffsets[2] = CGPointZero;
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

@end
