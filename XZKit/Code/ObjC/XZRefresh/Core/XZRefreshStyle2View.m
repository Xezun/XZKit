//
//  XZRefreshStyle2View.m
//  XZRefresh
//
//  Created by Xezun on 2019/10/12.
//  Copyright © 2019 Xezun. All rights reserved.
//

#import "XZRefreshStyle2View.h"
#import "UIScrollView+XZRefresh.h"
#import "XZRefreshDefines.h"

#define XZRefreshViewAnimationDuration    1.5
#define XZRefreshViewDotWidth             20.0

@implementation XZRefreshStyle2View {
    UIView *_dotsView;
    CAShapeLayer *_dot0Layer;
    CAShapeLayer *_dot1Layer;
    CAShapeLayer *_dot2Layer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self XZRefreshDidInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self XZRefreshDidInitialize];
    }
    return self;
}

- (void)XZRefreshDidInitialize {
    _colors = @[
        [UIColor colorWithWhite:0.50 alpha:1.0],
        [UIColor colorWithWhite:0.70 alpha:1.0],
        [UIColor colorWithWhite:0.90 alpha:1.0]
    ];
    
    CGRect const bounds = self.bounds;
    CGFloat const x = CGRectGetMidX(bounds) - XZRefreshViewDotWidth * 3.0 * 0.5;
    CGFloat const y = CGRectGetMidY(bounds) - XZRefreshViewDotWidth * 0.5;
    
    _dotsView = [[UIView alloc] initWithFrame:CGRectMake(x, y, XZRefreshViewDotWidth * 3.0, XZRefreshViewDotWidth)];
    _dotsView.userInteractionEnabled = NO;
    _dotsView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:_dotsView];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(XZRefreshViewDotWidth * 0.5, XZRefreshViewDotWidth * 0.5) radius:3.0 startAngle:-M_PI endAngle:+M_PI clockwise:YES];
    [path closePath];
    
    _dot0Layer = [[CAShapeLayer alloc] init];
    _dot0Layer.frame = CGRectMake(0, 0, XZRefreshViewDotWidth, XZRefreshViewDotWidth);
    _dot0Layer.path  = path.CGPath;
    [_dotsView.layer addSublayer:_dot0Layer];
    
    _dot2Layer = [[CAShapeLayer alloc] init];
    _dot2Layer.frame  = CGRectMake(2.0 * XZRefreshViewDotWidth, 0, XZRefreshViewDotWidth, XZRefreshViewDotWidth);
    _dot2Layer.path  = path.CGPath;
    [_dotsView.layer addSublayer:_dot2Layer];
    
    _dot1Layer = [[CAShapeLayer alloc] init];
    _dot1Layer.frame = CGRectMake(XZRefreshViewDotWidth, 0, XZRefreshViewDotWidth, XZRefreshViewDotWidth);
    _dot1Layer.path  = path.CGPath;
    [_dotsView.layer addSublayer:_dot1Layer];
    
    // 初始状态
    _dot0Layer.fillColor = _colors[1].CGColor;
    _dot0Layer.transform = CATransform3DScale(CATransform3DMakeTranslation(+XZRefreshViewDotWidth, 0, 0), 0, 0, 1.0);
    _dot1Layer.fillColor = _colors[1].CGColor;
    _dot1Layer.transform = CATransform3DMakeScale(0, 0, 1.0);
    _dot2Layer.fillColor = _colors[1].CGColor;
    _dot2Layer.transform = CATransform3DScale(CATransform3DMakeTranslation(-XZRefreshViewDotWidth, 0, 0), 0, 0, 1.0);
}

- (void)setColors:(NSArray<UIColor *> *)colors {
    NSParameterAssert(colors.count >= 3);
    _colors = [colors subarrayWithRange:NSMakeRange(0, 3)];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _dot0Layer.fillColor = _colors[1].CGColor;
    _dot1Layer.fillColor = _colors[1].CGColor;
    _dot2Layer.fillColor = _colors[1].CGColor;
    [CATransaction commit];
}

- (void)scrollView:(UIScrollView *)scrollView didScrollRefreshing:(CGFloat)distance {
    CGFloat const value = distance / self.refreshHeight;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (value < 0.5) {
        // 等待进场
        _dot0Layer.transform = CATransform3DScale(CATransform3DMakeTranslation(+XZRefreshViewDotWidth, 0, 0), 0, 0, 1.0);
        _dot1Layer.transform = CATransform3DMakeScale(0, 0, 1.0);
        _dot2Layer.transform = CATransform3DScale(CATransform3DMakeTranslation(-XZRefreshViewDotWidth, 0, 0), 0, 0, 1.0);
    } else if (value < 1.0) {
        // 变大进场，放大到 2 倍
        CGFloat const scale = 2.0 * ((value - 0.5) * 2.0);
        _dot0Layer.transform = CATransform3DScale(CATransform3DMakeTranslation(+XZRefreshViewDotWidth, 0, 0), scale, scale, 1.0);
        _dot1Layer.transform = CATransform3DMakeScale(scale, scale, 1.0);
        _dot2Layer.transform = CATransform3DScale(CATransform3DMakeTranslation(-XZRefreshViewDotWidth, 0, 0), scale, scale, 1.0);
    } else if (value < 1.5) {
        // 蓄力刷新，缩小到 1 倍，并分散开
        CGFloat const trans = 1.0 - (value - 1.0) * 2.0;
        CGFloat const scale = 1.0 + 1.0 * MAX(0, (trans * 3.0 - 2.0));
        _dot0Layer.transform = CATransform3DScale(CATransform3DMakeTranslation(+XZRefreshViewDotWidth * trans, 0, 0), scale, scale, 1.0);
        _dot1Layer.transform = CATransform3DMakeScale(scale, scale, 1.0);
        _dot2Layer.transform = CATransform3DScale(CATransform3DMakeTranslation(-XZRefreshViewDotWidth * trans, 0, 0), scale, scale, 1.0);
    } else {
        // 等待刷新
        _dot0Layer.transform = CATransform3DIdentity;
        _dot1Layer.transform = CATransform3DIdentity;
        _dot2Layer.transform = CATransform3DIdentity;
    }
    [CATransaction commit];
}

- (BOOL)scrollView:(UIScrollView *)scrollView shouldBeginRefreshing:(CGFloat)distance {
    return (distance >= self.refreshHeight * 1.5);
}

- (void)scrollView:(UIScrollView *)scrollView didBeginRefreshing:(BOOL)animated {
    _dot0Layer.transform = CATransform3DIdentity;
    _dot1Layer.transform = CATransform3DIdentity;
    _dot2Layer.transform = CATransform3DIdentity;
    
    CFTimeInterval beginTime = 0;
    if (animated) {
        beginTime = [_dot1Layer convertTime:CACurrentMediaTime() toLayer:nil] + XZRefreshAnimationDuration;
        
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        animation.keyTimes = @[@(0), @(0.5), @(1.0)];
        animation.duration = XZRefreshAnimationDuration;
        animation.removedOnCompletion = YES;
        
        animation.values = @[
            @(CATransform3DScale(CATransform3DMakeTranslation(+XZRefreshViewDotWidth, 0, 0), 0, 0, 1.0)),
            @(CATransform3DScale(CATransform3DMakeTranslation(+XZRefreshViewDotWidth, 0, 0), 0, 0, 1.0)),
            @(CATransform3DIdentity)
        ];
        [_dot0Layer addAnimation:animation forKey:@"entering"];
        animation.values = @[
            @(CATransform3DMakeScale(0, 0, 1.0)),
            @(CATransform3DMakeScale(0, 0, 1.0)),
            @(CATransform3DIdentity)
        ];
        [_dot1Layer addAnimation:animation forKey:@"entering"];
        animation.values = @[
            @(CATransform3DScale(CATransform3DMakeTranslation(-XZRefreshViewDotWidth, 0, 0), 0, 0, 1.0)),
            @(CATransform3DScale(CATransform3DMakeTranslation(-XZRefreshViewDotWidth, 0, 0), 0, 0, 1.0)),
            @(CATransform3DIdentity)
        ];
        [_dot2Layer addAnimation:animation forKey:@"entering"];
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"fillColor"];
    animation.beginTime   = beginTime;
    animation.duration    = XZRefreshViewAnimationDuration;
    animation.repeatCount = FLT_MAX;
    animation.removedOnCompletion = NO;
    
    animation.values = @[
        (__bridge id)_colors[0].CGColor,
        (__bridge id)_colors[1].CGColor,
        (__bridge id)_colors[2].CGColor,
        (__bridge id)_colors[1].CGColor,
        (__bridge id)_colors[0].CGColor,
    ];
    [_dot0Layer addAnimation:animation forKey:@"refreshing"];
    
    animation.values = @[
        (__bridge id)_colors[1].CGColor,
        (__bridge id)_colors[0].CGColor,
        (__bridge id)_colors[1].CGColor,
        (__bridge id)_colors[2].CGColor,
        (__bridge id)_colors[1].CGColor,
    ];
    [_dot1Layer addAnimation:animation forKey:@"refreshing"];
    
    animation.values = @[
        (__bridge id)_colors[2].CGColor,
        (__bridge id)_colors[1].CGColor,
        (__bridge id)_colors[0].CGColor,
        (__bridge id)_colors[1].CGColor,
        (__bridge id)_colors[2].CGColor,
    ];
    [_dot2Layer addAnimation:animation forKey:@"refreshing"];
}

- (void)scrollView:(UIScrollView *)scrollView willEndRefreshing:(BOOL)animated {
    [_dot0Layer removeAnimationForKey:@"refreshing"];
    [_dot1Layer removeAnimationForKey:@"refreshing"];
    [_dot2Layer removeAnimationForKey:@"refreshing"];
    
    if (animated) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        animation.keyTimes = @[@(0), @(0.5), @(1.0)];
        animation.duration = XZRefreshAnimationDuration;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeBoth;
        
        animation.values = @[
            @(CATransform3DIdentity),
            @(CATransform3DScale(CATransform3DMakeTranslation(+XZRefreshViewDotWidth, 0, 0), 0, 0, 1.0)),
            @(CATransform3DScale(CATransform3DMakeTranslation(+XZRefreshViewDotWidth, 0, 0), 0, 0, 1.0)),
        ];
        [_dot0Layer addAnimation:animation forKey:@"recovering"];
        animation.values = @[
            @(CATransform3DIdentity),
            @(CATransform3DMakeScale(0, 0, 1.0)),
            @(CATransform3DMakeScale(0, 0, 1.0)),
        ];
        [_dot1Layer addAnimation:animation forKey:@"recovering"];
        animation.values = @[
            @(CATransform3DIdentity),
            @(CATransform3DScale(CATransform3DMakeTranslation(-XZRefreshViewDotWidth, 0, 0), 0, 0, 1.0)),
            @(CATransform3DScale(CATransform3DMakeTranslation(-XZRefreshViewDotWidth, 0, 0), 0, 0, 1.0)),
        ];
        [_dot2Layer addAnimation:animation forKey:@"recovering"];
    } else {
        // 不需要动画时，直接执行 didEndRefreshing 的收尾过程即可。
    }
}

- (void)scrollView:(UIScrollView *)scrollView didEndRefreshing:(BOOL)animated {
    [_dot0Layer removeAnimationForKey:@"recovering"];
    [_dot1Layer removeAnimationForKey:@"recovering"];
    [_dot2Layer removeAnimationForKey:@"recovering"];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _dot0Layer.transform = CATransform3DScale(CATransform3DMakeTranslation(+XZRefreshViewDotWidth, 0, 0), 0, 0, 1.0);
    _dot1Layer.transform = CATransform3DMakeScale(0, 0, 1.0);
    _dot2Layer.transform = CATransform3DScale(CATransform3DMakeTranslation(-XZRefreshViewDotWidth, 0, 0), 0, 0, 1.0);
    [CATransaction commit];
}

@end
