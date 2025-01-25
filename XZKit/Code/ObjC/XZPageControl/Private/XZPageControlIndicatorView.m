//
//  XZPageControlIndicatorView.m
//  XZPageControl
//
//  Created by Xezun on 2024/6/10.
//

#import "XZPageControlIndicatorView.h"
#if __has_include(<XZExtensions/XZShapeView.h>)
#import <XZExtensions/XZShapeView.h>
#else
#import "XZShapeView.h"
#endif

#define XZPageControlAnimationDuration 0.35

@implementation XZPageControlIndicatorView {
    // _imageView 与 _shapeView 并非完全互斥，
    // 因为可以在 isCurrent 两种状态之间分别选择其中一种样式，用来展示。
    UIImageView *_imageView;
    XZShapeView *_shapeView;
    BOOL _needsUpdate;
}

@synthesize isCurrent = _isCurrent;

@synthesize transition = _transition;

@synthesize fillColor = _fillColor;
@synthesize currentFillColor = _currentFillColor;

@synthesize strokeColor = _strokeColor;
@synthesize currentStrokeColor = _currentStrokeColor;

@synthesize shape = _shape;
@synthesize currentShape = _currentShape;

@synthesize image = _image;
@synthesize currentImage = _currentImage;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        _needsUpdate = NO;
    }
    return self;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    if (_strokeColor != strokeColor) {
        _strokeColor = strokeColor;
        [self setNeedsUpdate];
    }
}

- (void)setCurrentStrokeColor:(UIColor *)currentStrokeColor {
    if (_currentStrokeColor != currentStrokeColor) {
        _currentStrokeColor = currentStrokeColor;
        [self setNeedsUpdate];
    }
}

- (UIColor *)fillColor {
    if (_fillColor == nil) {
        _fillColor = UIColor.grayColor;
    }
    return _fillColor;
}

- (void)setFillColor:(UIColor *)fillColor {
    if (_fillColor != fillColor) {
        _fillColor = fillColor;
        [self setNeedsUpdate];
    }
}

- (UIColor *)currentFillColor {
    if (_currentFillColor == nil) {
        _currentFillColor = UIColor.whiteColor;
    }
    return _currentFillColor;
}

- (void)setCurrentFillColor:(UIColor *)currentFillColor {
    if (_currentFillColor != currentFillColor) {
        _currentFillColor = currentFillColor;
        [self setNeedsUpdate];
    }
}

- (UIBezierPath *)shape {
    if (_shape == nil) {
        _shape = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 6.0, 6.0)];
    }
    return _shape;
}

- (void)setShape:(UIBezierPath *)shape {
    if (_shape != shape) {
        _shape = shape.copy;
        [self setNeedsUpdate];
    }
}

- (UIBezierPath *)currentShape {
    if (_currentShape == nil) {
        _currentShape = self.shape;
    }
    return _currentShape;
}

- (void)setCurrentShape:(UIBezierPath *)currentShape {
    if (_currentShape != currentShape) {
        _currentShape = currentShape.copy;
        [self setNeedsUpdate];
    }
}

- (void)setImage:(UIImage *)image {
    if (_image != image) {
        _image = image;
        [self setNeedsUpdate];
    }
}

- (void)setCurrent:(BOOL)isCurrent animated:(BOOL)animated {
    if (_isCurrent != isCurrent) {
        _isCurrent = isCurrent;
        
        // 更新样式
        [self setNeedsUpdate];
        [self updateIfNeeded:animated];
        // 重置进度
        _transition = 0;
    }
}

- (void)setNeedsUpdate {
    if (_needsUpdate) {
        return;
    }
    _needsUpdate = YES;
    
    typeof(self) __weak wself = self;
    [NSRunLoop.mainRunLoop performInModes:@[NSRunLoopCommonModes] block:^{
        [wself updateIfNeeded:NO];
    }];
}

- (void)updateIfNeeded:(BOOL)animated {
    if (!_needsUpdate) {
        return;
    }
    _needsUpdate = NO;
    
    if (self.isCurrent) {
        if (self.currentImage) {
            [self updateWithImage:self.currentImage];
        } else {
            [self updateWithShape:self.currentShape fillColor:self.currentFillColor strokeColor:self.currentStrokeColor animated:animated];
        }
    } else {
        if (self.image) {
            [self updateWithImage:self.image];
        } else {
            [self updateWithShape:self.shape fillColor:self.fillColor strokeColor:self.strokeColor animated:animated];
        }
    }
}

- (void)updateWithImage:(UIImage *)image {
    _shapeView.hidden = YES;
    
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_imageView];
    } else {
        _imageView.hidden = NO;
    }
    
    _imageView.image = image;
    
    CGSize const size = [self intrinsicContentSizeForImage:image];
    _imageView.bounds = CGRectMake(0, 0, size.width, size.height);
}

- (void)updateWithShape:(UIBezierPath *)shape fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor animated:(BOOL)animated {
    _imageView.hidden = YES;
    
    if (_shapeView == nil) {
        _shapeView = [[XZShapeView alloc] initWithFrame:self.bounds];
        _shapeView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        _shapeView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_shapeView];
    } else {
        _shapeView.hidden = NO;
    }
    
    CGPathRef const path = shape.CGPath;
    CGSize    const size = [self intrinsicContentSizeForShape:path];
    _shapeView.bounds = CGRectMake(0, 0, size.width, size.height);
    
    if (animated) {
        if (_shapeView.layer.speed == 0) {
            // 完成交互式转场的剩余进度
            [UIView performWithoutAnimation:^{
                self->_shapeView.path        = path;
                self->_shapeView.fillColor   = fillColor.CGColor;
                self->_shapeView.strokeColor = strokeColor.CGColor;
            }];
            CGFloat const offset = _shapeView.layer.timeOffset;
            _shapeView.layer.speed = 1.0;
            _shapeView.layer.beginTime = CACurrentMediaTime() - offset;
            _shapeView.layer.timeOffset = 0;
        } else {
            [UIView animateWithDuration:XZPageControlAnimationDuration animations:^{
                self->_shapeView.path        = path;
                self->_shapeView.fillColor   = fillColor.CGColor;
                self->_shapeView.strokeColor = strokeColor.CGColor;
            }];
        }
    } else {
        [UIView performWithoutAnimation:^{
            self->_shapeView.path        = path;
            self->_shapeView.fillColor   = fillColor.CGColor;
            self->_shapeView.strokeColor = strokeColor.CGColor;
        }];
        if (_shapeView.layer.speed == 0) {
            _shapeView.layer.speed = 1.0;
            _shapeView.layer.beginTime = 0;
            _shapeView.layer.timeOffset = 0;
            [_shapeView.layer removeAllAnimations];
        }
    }
}

- (CGSize)intrinsicContentSizeForImage:(UIImage *)image {
    CGSize  const size        = image.size;
    CGFloat const screenScale = UIScreen.mainScreen.scale;
    CGFloat const imageScale  = image.scale;
    
    if (imageScale == screenScale || imageScale <= 0) {
        return size;
    }
    
    CGFloat const scale = imageScale / screenScale;
    return CGSizeMake(size.width * scale, size.height * scale);
}

- (CGSize)intrinsicContentSizeForShape:(CGPathRef)shape {
    CGRect  const bounds = CGPathGetPathBoundingBox(shape);
    CGFloat const width  = bounds.size.width + bounds.origin.x * 2.0;
    CGFloat const height = bounds.size.height + bounds.origin.y * 2.0;
    return CGSizeMake(width, height);
}

- (void)setTransition:(CGFloat)transition {
    if (_transition != transition) {
        _transition = transition;
        
        if (_image || _currentImage) {
            return;
        }
        
        if (_shapeView.layer.speed != 0) {
            _shapeView.layer.speed = 0;
            
            CABasicAnimation *pathAnimation        = [CABasicAnimation animationWithKeyPath:@"path"];
            CABasicAnimation *fillColorAnimation   = [CABasicAnimation animationWithKeyPath:@"fillColor"];
            CABasicAnimation *strokeColorAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
            if (_isCurrent) {
                pathAnimation.fromValue         = (__bridge id)(_currentShape.CGPath);
                pathAnimation.toValue           = (__bridge id)(_shape.CGPath);
                fillColorAnimation.fromValue    = (__bridge id)(_currentFillColor.CGColor);
                fillColorAnimation.toValue      = (__bridge id)(_fillColor.CGColor);
                strokeColorAnimation.fromValue  = (__bridge id)(_currentStrokeColor.CGColor);
                strokeColorAnimation.toValue    = (__bridge id)(_strokeColor.CGColor);
            } else {
                pathAnimation.fromValue         = (__bridge id)(_shape.CGPath);
                pathAnimation.toValue           = (__bridge id)(_currentShape.CGPath);
                fillColorAnimation.fromValue    = (__bridge id)(_fillColor.CGColor);
                fillColorAnimation.toValue      = (__bridge id)(_currentFillColor.CGColor);
                strokeColorAnimation.fromValue  = (__bridge id)(_strokeColor.CGColor);
                strokeColorAnimation.toValue    = (__bridge id)(_currentStrokeColor.CGColor);
            }
            
            CAAnimationGroup *animation = [CAAnimationGroup animation];
            animation.animations = @[pathAnimation, fillColorAnimation, strokeColorAnimation];
            animation.duration = XZPageControlAnimationDuration;
            animation.removedOnCompletion = YES;
            [_shapeView.layer addAnimation:animation forKey:@"transition"];
        }
        
        _shapeView.layer.timeOffset = transition * XZPageControlAnimationDuration;
    }
}

@end
