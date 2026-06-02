//
//  XZToastProgressView.m
//  XZKit
//
//  Created by 徐臻 on 2025/7/7.
//

#import "XZToastProgressView.h"
#import "XZToast.h"
#import "XZGeometry.h"
#import "XZShapeView.h"
#import "UIView+XZKit.h"

#define kSize       ((CGSize){37.0, 37.0})
#define kTrackWidth 4.0
#define kShapeWidth 3.0

@implementation XZToastProgressView {
    XZShapeView *_trackView;
    XZShapeView *_shapeView;
}

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, 50.0, 50.0)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _color      = XZToast.tintColor;
        _trackColor = XZToast.color;
        
        CGRect         const frame = CGRectAdjustSizeWithMode(self.bounds, kSize, UIViewContentModeCenter);
        UIBezierPath * const path  = [UIBezierPath bezierPathWithArcCenter:CGPointMake(18.5, 18.5) radius:16.5 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
        
        _trackView = [[XZShapeView alloc] initWithFrame:frame];
        _trackView.autoresizingMask  = UIViewAutoresizingFlexibleMargin;
        _trackView.lineWidth         = (kTrackWidth + 1.0);
        _trackView.strokeColor       = _trackColor.CGColor;
        _trackView.fillColor         = UIColor.clearColor.CGColor;
        _trackView.layer.strokeStart = 0;
        _trackView.layer.strokeEnd   = 1.0;
        _trackView.layer.path        = path.CGPath;
        [self addSubview:_trackView];
        
        _shapeView = [[XZShapeView alloc] initWithFrame:frame];
        _shapeView.autoresizingMask     = UIViewAutoresizingFlexibleMargin;
        _shapeView.lineWidth            = kShapeWidth;
        _shapeView.layer.lineCap        = kCALineCapRound;
        _shapeView.strokeColor          = _color.CGColor;
        _shapeView.fillColor            = UIColor.clearColor.CGColor;
        _shapeView.layer.strokeStart    = 0;
        _shapeView.layer.strokeEnd      = 0;
        _shapeView.layer.repeatCount    = FLT_MAX;
        _shapeView.layer.autoreverses   = YES;
        _shapeView.layer.path           = path.CGPath;
        [self addSubview:_shapeView];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(50.0, 50.0);
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    UITraitCollection * const traitCollection = self.traitCollection;
    _trackView.strokeColor = [_trackColor resolvedColorWithTraitCollection:traitCollection].CGColor;
    _shapeView.strokeColor = [_color resolvedColorWithTraitCollection:traitCollection].CGColor;
}

- (CGFloat)progress {
    return _shapeView.layer.strokeEnd;
}

- (void)setProgress:(CGFloat)progress {
    _shapeView.layer.strokeEnd = progress;
}

- (void)setColor:(UIColor *)color {
    if (_color != color) {
        _color = color ?: UIColor.systemBlueColor;
        _shapeView.strokeColor = [_color resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    }
}

- (void)setTrackColor:(UIColor *)trackColor {
    if (_trackColor != trackColor) {
        _trackColor = trackColor ?: UIColor.systemGray5Color;
        _trackView.strokeColor = [_trackColor resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    }
}

@end

