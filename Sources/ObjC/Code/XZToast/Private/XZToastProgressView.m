//
//  XZToastProgressView.m
//  XZKit
//
//  Created by 徐臻 on 2025/7/7.
//

#import "XZToastProgressView.h"
#import "XZToast.h"

@implementation XZToastProgressView {
    CAShapeLayer *_trackLayer;
    CAShapeLayer *_shapeLayer;
}

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, 50.0, 50.0)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CALayer * const layer = self.layer;
        
        _color = XZToast.color;
        _trackColor = XZToast.trackColor;
        
        CGRect         const frame = CGRectMake(6.5, 6.5, 37.0, 37.0);
        UIBezierPath * const path  = [UIBezierPath bezierPathWithArcCenter:CGPointMake(18.5, 18.5) radius:16.5 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
        
        _trackLayer = [[CAShapeLayer alloc] init];
        _trackLayer.frame = frame;
        _trackLayer.lineWidth = 3.0;
        _trackLayer.strokeColor = _trackColor.CGColor;
        _trackLayer.fillColor   = UIColor.clearColor.CGColor;
        _trackLayer.strokeStart = 0;
        _trackLayer.strokeEnd   = 1.0;
        _trackLayer.path = path.CGPath;
        [layer addSublayer:_trackLayer];
        
        _shapeLayer = [[CAShapeLayer alloc] init];
        _shapeLayer.frame = frame;
        _shapeLayer.lineWidth = 3.0;
        _shapeLayer.lineCap = kCALineCapRound;
        _shapeLayer.strokeColor = _color.CGColor;
        _shapeLayer.fillColor   = UIColor.clearColor.CGColor;
        _shapeLayer.strokeStart = 0;
        _shapeLayer.strokeEnd   = 0;
        _shapeLayer.repeatCount = FLT_MAX;
        _shapeLayer.autoreverses = YES;
        _shapeLayer.path = _trackLayer.path;
        [layer addSublayer:_shapeLayer];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(50.0, 50.0);
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    UITraitCollection * const traitCollection = self.traitCollection;
    _trackLayer.strokeColor = [_trackColor resolvedColorWithTraitCollection:traitCollection].CGColor;
    _shapeLayer.strokeColor = [_color resolvedColorWithTraitCollection:traitCollection].CGColor;
}

- (CGFloat)progress {
    return _shapeLayer.strokeEnd;
}

- (void)setProgress:(CGFloat)progress {
    _shapeLayer.strokeEnd = progress;
}

- (void)setColor:(UIColor *)color {
    if (_color != color) {
        _color = color ?: UIColor.systemBlueColor;
        _shapeLayer.strokeColor = [_color resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    }
}

- (void)setTrackColor:(UIColor *)trackColor {
    if (_trackColor != trackColor) {
        _trackColor = trackColor ?: UIColor.systemGray5Color;
        _trackLayer.strokeColor = [_trackColor resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    }
}

@end

