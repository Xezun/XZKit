//
//  XZShapeView.m
//  XZKit
//
//  Created by Xezun on 2021/9/27.
//

#import "XZShapeView.h"

@implementation XZShapeView

@dynamic layer;

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (CGPathRef)path {
    return self.layer.path;
}

- (void)setPath:(CGPathRef)path {
    self.layer.path = path;
}

- (CGColorRef)fillColor {
    return self.layer.fillColor;
}

- (void)setFillColor:(CGColorRef)fillColor {
    self.layer.fillColor = fillColor;
}

- (CGColorRef)strokeColor {
    return self.layer.strokeColor;
}

- (void)setStrokeColor:(CGColorRef)strokeColor {
    self.layer.strokeColor = strokeColor;
}

- (CGFloat)lineWidth {
    return self.layer.lineWidth;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    self.layer.lineWidth = lineWidth;
}

@end
