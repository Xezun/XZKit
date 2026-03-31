//
//  XZPageControl.m
//  XZKit
//
//  Created by Xezun on 2021/9/13.
//

#import "XZPageControl.h"
#import "XZPageControlAttributes.h"
#import "XZPageControlIndicator.h"

@interface XZPageControl ()
@end

@implementation XZPageControl {
    /// 记录指示器默认样式的对象。
    XZPageControlAttributes *_defaultAttributes;
    NSMutableArray<XZPageControlIndicator *> *_indicators;
}

- (instancetype)initWithFrame:(CGRect)frame orientation:(XZPageControlOrientation)orientation {
    self = [self initWithFrame:frame];
    if (self) {
        _orientation = orientation;
    }
    return self;
}

- (instancetype)initWithOrientation:(XZPageControlOrientation)orientation {
    return [self initWithFrame:(CGRectZero) orientation:orientation];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self XZPageControlDidInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self XZPageControlDidInitialize];
    }
    return self;
}

- (void)XZPageControlDidInitialize {
    super.hidden = YES;
    super.contentMode = UIViewContentModeCenter;
    
    _hidesForSinglePage      = YES;
    _maximumIndicatorSpacing = 30.0;
    _indicators              = [NSMutableArray array];
    _defaultAttributes       = nil;
    _currentPage             = 0;
}

- (XZPageControlAttributes *)defaultAttributes {
    if (_defaultAttributes == nil) {
        _defaultAttributes = [[XZPageControlAttributes alloc] init];
    }
    return _defaultAttributes;
}

@dynamic contentMode;

- (void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:contentMode];
    [self setNeedsLayout];
}

// MARK: - Tracking

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (self.allowsContinuousInteraction) {
        CGPoint    const point = [event.allTouches.anyObject locationInView:self];
        NSUInteger const count = _indicators.count;
        for (NSInteger i = 0; i < count; i++) {
            if (CGRectContainsPoint(_indicators[i].frame, point)) {
                [self XZPageControlSetCurrentPage:i animated:YES sendsEvents:YES];
                break;
            }
        }
    }
    return [super continueTrackingWithTouch:touch withEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    
    if (!self.isTouchInside || _indicators.count < 2) {
        return;
    }
    
    CGPoint    const point = [touch locationInView:self];
    NSUInteger const count = _indicators.count;
    
    switch (self.orientation) {
        case XZPageControlOrientationHorizontal: {
            BOOL const isLTR = self.effectiveUserInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight;
            
            // 点击左边减小页数
            if ( (isLTR && point.x < CGRectGetMinX(_indicators.firstObject.frame)) || (!isLTR && point.x > CGRectGetMaxX(_indicators.firstObject.frame)) ) {
                if (_currentPage > 0) {
                    [self XZPageControlSetCurrentPage:_currentPage - 1 animated:YES sendsEvents:YES];
                }
                return;
            }
            
            // 点击右边增加页数
            if ( (isLTR && point.x > CGRectGetMaxX(_indicators.lastObject.frame)) || (!isLTR && point.x < CGRectGetMinX(_indicators.lastObject.frame)) ) {
                if (_currentPage < _indicators.count - 1) {
                    [self XZPageControlSetCurrentPage:_currentPage + 1 animated:YES sendsEvents:YES];
                }
                return;
            }
            break;
        }
        case XZPageControlOrientationVertical: {
            // 点击上边减小页数
            if ( point.y < CGRectGetMinY(_indicators.firstObject.frame) ) {
                if (_currentPage > 0) {
                    [self XZPageControlSetCurrentPage:_currentPage - 1 animated:YES sendsEvents:YES];
                }
                return;
            }
            
            // 点击下边增加页数
            if ( point.y > CGRectGetMaxY(_indicators.lastObject.frame) ) {
                if (_currentPage < _indicators.count - 1) {
                    [self XZPageControlSetCurrentPage:_currentPage + 1 animated:YES sendsEvents:YES];
                }
                return;
            }
            break;
        }
    }
    
    // 点击了指定页面
    for (NSInteger i = 0; i < count; i++) {
        if (CGRectContainsPoint(_indicators[i].frame, point)) {
            [self XZPageControlSetCurrentPage:i animated:YES sendsEvents:YES];
            break;
        }
    }
}

- (void)layoutMarginsDidChange {
    [super layoutMarginsDidChange];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    NSUInteger const count = _indicators.count;
    if (count == 0) {
        return;
    }
    
    switch (self.orientation) {
        case XZPageControlOrientationHorizontal: {
            CGRect  const bounds = UIEdgeInsetsInsetRect(self.bounds, self.layoutMargins);
            CGFloat const width  = MIN(_maximumIndicatorSpacing, bounds.size.width / count);
            CGFloat __block x    = 0;
            
            // 根据 contentMode 确定布局起点。
            switch (self.contentMode) {
                case UIViewContentModeLeft:
                case UIViewContentModeTop:
                    x = CGRectGetMinX(bounds);
                    break;
                case UIViewContentModeRight:
                case UIViewContentModeBottom:
                    x = CGRectGetMaxX(bounds) - width * count;
                    break;
                default:
                    x = CGRectGetMinX(bounds) + (bounds.size.width - width * count) * 0.5;
                    break;
            }
            
            // 根据布局方向，逐个排列指示器。
            switch (self.effectiveUserInterfaceLayoutDirection) {
                case UIUserInterfaceLayoutDirectionLeftToRight:
                    [_indicators enumerateObjectsUsingBlock:^(XZPageControlIndicator *indicator, NSUInteger idx, BOOL *stop) {
                        indicator.frame = CGRectMake(x, bounds.origin.y, width, bounds.size.height);
                        x += width;
                    }];
                    break;
                    
                case UIUserInterfaceLayoutDirectionRightToLeft:
                    [_indicators enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZPageControlIndicator *indicator, NSUInteger idx, BOOL *stop) {
                        indicator.frame = CGRectMake(x, bounds.origin.y, width, bounds.size.height);
                        x += width;
                    }];
                    break;
            }
            break;
        }
            
        case XZPageControlOrientationVertical: {
            CGRect  const bounds = UIEdgeInsetsInsetRect(self.bounds, self.layoutMargins);
            CGFloat const height = MIN(_maximumIndicatorSpacing, bounds.size.height / count);
            CGFloat __block y    = 0;
            
            // 根据 contentMode 确定布局起点。
            switch (self.contentMode) {
                case UIViewContentModeLeft:
                case UIViewContentModeTop:
                    y = CGRectGetMinY(bounds);
                    break;
                case UIViewContentModeRight:
                case UIViewContentModeBottom:
                    y = CGRectGetMaxY(bounds) - height * count;
                    break;
                default:
                    y = CGRectGetMinY(bounds) + (bounds.size.height - height * count) * 0.5;
                    break;
            }
            
            // 根据布局方向，逐个排列指示器。
            [_indicators enumerateObjectsUsingBlock:^(XZPageControlIndicator *indicator, NSUInteger idx, BOOL *stop) {
                indicator.frame = CGRectMake(bounds.origin.x, y, bounds.size.width, height);
                y += height;
            }];
            break;
        }
    }
}

#pragma mark - Public Methods

- (void)setOrientation:(XZPageControlOrientation)orientation {
    if (_orientation != orientation) {
        _orientation = orientation;
        [self setNeedsLayout];
    }
}

- (NSInteger)numberOfPages {
    return _indicators.count;
}

- (void)setNumberOfPages:(NSInteger const)numberOfPages {
    NSUInteger const count = _indicators.count;
    if (count != numberOfPages) {
        if (numberOfPages == 0) {
            [self XZPageControlSetCurrentPage:0 animated:NO sendsEvents:NO];
            [_indicators removeAllObjects];
        } else {
            // 同步数量
            for (NSInteger i = count; i < numberOfPages; i++) {
                XZPageControlIndicator *indicator = [[XZPageControlIndicator alloc] initWithPageControl:self attributes:_defaultAttributes.copy];
                [indicator setCurrent:(i == _currentPage) animated:NO];
                [_indicators addObject:indicator];
            }
            for (NSInteger i = count - 1; i >= numberOfPages; i--) {
                [_indicators removeObjectAtIndex:i];
            }
            
            // 修正当前指示器
            if (_currentPage >= numberOfPages) {
                [self XZPageControlSetCurrentPage:numberOfPages - 1 animated:NO sendsEvents:NO];
            }
        }
        
        self.hidden = (_hidesForSinglePage && numberOfPages <= 1);
        
        [self setNeedsLayout];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    [self setCurrentPage:currentPage animated:NO];
}

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated {
    NSParameterAssert(currentPage >= 0 && currentPage < _indicators.count);
    [self XZPageControlSetCurrentPage:currentPage animated:animated sendsEvents:NO];
}

- (void)setTransition:(CGFloat)transition {
    [self setTransition:transition isLooped:NO];
}

- (void)setTransition:(CGFloat)transition isLooped:(BOOL)isLooped {
    NSUInteger const numberOfPages = _indicators.count;
    if (transition > 0) {
        _indicators[_currentPage].transition = transition;
        if (_currentPage < numberOfPages - 1) {
            _indicators[_currentPage + 1].transition = transition;
        } else if (isLooped) {
            _indicators[0].transition = transition;
        }
    } else if (transition < 0) {
        _indicators[_currentPage].transition = -transition;
        if (_currentPage > 0) {
            _indicators[_currentPage - 1].transition = -transition;
        } else if (isLooped) {
            _indicators[numberOfPages - 1].transition = -transition;
        }
    }
}

- (CGFloat)transition {
    if (_currentPage < _indicators.count - 1) {
        return _indicators[_currentPage].transition;
    }
    return 0;
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage {
    if (_hidesForSinglePage != hidesForSinglePage) {
        _hidesForSinglePage = hidesForSinglePage;
        
        self.hidden = (_hidesForSinglePage && _indicators.count <= 1);
    }
}

- (void)setMaximumIndicatorSpacing:(CGFloat)maximumIndicatorSpacing {
    if (_maximumIndicatorSpacing != maximumIndicatorSpacing) {
        _maximumIndicatorSpacing = MAX(0, maximumIndicatorSpacing);
        [self setNeedsLayout];
    }
}

#pragma mark - 全局样式.StrokeColor

- (UIColor *)indicatorStrokeColor {
    return _defaultAttributes.strokeColor;
}

- (void)setIndicatorStrokeColor:(UIColor *)indicatorStrokeColor {
    self.defaultAttributes.strokeColor = indicatorStrokeColor;
    for (XZPageControlIndicator *indicator in _indicators) {
        indicator.strokeColor = indicatorStrokeColor;
    }
}

- (UIColor *)currentIndicatorStrokeColor {
    return _defaultAttributes.currentStrokeColor;
}

- (void)setCurrentIndicatorStrokeColor:(UIColor *)currentIndicatorStrokeColor {
    self.defaultAttributes.currentStrokeColor = currentIndicatorStrokeColor;
    for (XZPageControlIndicator *indicator in _indicators) {
        indicator.currentStrokeColor = currentIndicatorStrokeColor;
    }
}

#pragma mark - 全局样式.FillColor

- (UIColor *)indicatorFillColor {
    return _defaultAttributes.fillColor;
}

- (void)setIndicatorFillColor:(UIColor *)indicatorFillColor {
    self.defaultAttributes.fillColor = indicatorFillColor;
    for (XZPageControlIndicator *indicator in _indicators) {
        indicator.fillColor = indicatorFillColor;
    }
}

- (UIColor *)currentIndicatorFillColor {
    return _defaultAttributes.currentFillColor;
}

- (void)setCurrentIndicatorFillColor:(UIColor *)currentIndicatorFillColor {
    self.defaultAttributes.currentFillColor = currentIndicatorFillColor;
    for (XZPageControlIndicator *indicator in _indicators) {
        indicator.currentFillColor = currentIndicatorFillColor;
    }
}

#pragma mark - 全局样式.Shape

- (UIBezierPath *)indicatorShape {
    return _defaultAttributes.shape;
}

- (void)setIndicatorShape:(UIBezierPath *)indicatorShape {
    self.defaultAttributes.shape = indicatorShape;
    for (XZPageControlIndicator *indicator in _indicators) {
        indicator.shape = indicatorShape;
    }
}

- (UIBezierPath *)currentIndicatorShape {
    return _defaultAttributes.currentShape;
}

- (void)setCurrentIndicatorShape:(UIBezierPath *)currentIndicatorShape {
    self.defaultAttributes.currentShape = currentIndicatorShape;
    for (XZPageControlIndicator *indicator in _indicators) {
        indicator.currentShape = currentIndicatorShape;
    }
}

#pragma mark - 全局样式.Image

- (UIImage *)indicatorImage {
    return _defaultAttributes.image;
}

- (void)setIndicatorImage:(UIImage *)indicatorImage {
    self.defaultAttributes.image = indicatorImage;
    for (XZPageControlIndicator *indicator in _indicators) {
        indicator.image = indicatorImage;
    }
}

- (UIImage *)currentIndicatorImage {
    return _defaultAttributes.currentImage;
}

- (void)setCurrentIndicatorImage:(UIImage *)currentIndicatorImage {
    self.defaultAttributes.currentImage = currentIndicatorImage;
    for (XZPageControlIndicator *indicator in _indicators) {
        indicator.currentImage = currentIndicatorImage;
    }
}

#pragma mark - 独立样式.StrokeColor

- (UIColor *)indicatorStrokeColorForPage:(NSInteger)page {
    return _indicators[page].strokeColor;
}

- (void)setIndicatorStrokeColor:(nullable UIColor *)indicatorColor forPage:(NSInteger)page {
    _indicators[page].strokeColor = indicatorColor;
}

- (UIColor *)currentIndicatorStrokeColorForPage:(NSInteger)page {
    return _indicators[page].currentStrokeColor;
}

- (void)setCurrentIndicatorStrokeColor:(nullable UIColor *)currentIndicatorColor forPage:(NSInteger)page {
    _indicators[page].currentStrokeColor = currentIndicatorColor;
}

#pragma mark - 独立样式.FillColor

- (UIColor *)indicatorFillColorForPage:(NSInteger)page {
    return _indicators[page].fillColor;
}

- (void)setIndicatorFillColor:(UIColor *)indicatorColor forPage:(NSInteger)page {
    _indicators[page].fillColor = indicatorColor;
}

- (UIColor *)currentIndicatorFillColorForPage:(NSInteger)page {
    return _indicators[page].currentFillColor;
}

- (void)setCurrentIndicatorFillColor:(UIColor *)currentIndicatorColor forPage:(NSInteger)page {
    _indicators[page].currentFillColor = currentIndicatorColor;
}

#pragma mark - 独立样式.Shape

- (UIBezierPath *)indicatorShapeForPage:(NSInteger)page {
    return _indicators[page].shape;
}

- (void)setIndicatorShape:(UIBezierPath *)indicatorShape forPage:(NSInteger)page {
    _indicators[page].shape = indicatorShape;
}

- (UIBezierPath *)currentIndicatorShapeForPage:(NSInteger)page {
    return _indicators[page].currentShape;
}

- (void)setCurrentIndicatorShape:(UIBezierPath *)currentIndicatorShape forPage:(NSInteger)page {
    _indicators[page].currentShape = currentIndicatorShape;
}

#pragma mark - 独立样式.Image

- (UIImage *)indicatorImageForPage:(NSInteger)page {
    return _indicators[page].image;
}

- (void)setIndicatorImage:(UIImage *)indicatorImage forPage:(NSInteger)page {
    _indicators[page].image = indicatorImage;
}

- (UIImage *)currentIndicatorImageForPage:(NSInteger)page {
    return _indicators[page].currentImage;
}

- (void)setCurrentIndicatorImage:(UIImage *)currentIndicatorImage forPage:(NSInteger)page {
    _indicators[page].currentImage = currentIndicatorImage;
}

#pragma mark - 自定义样式

- (UIView<XZPageControlIndicator> *)indicatorForPage:(NSInteger)page {
    return _indicators[page].view;
}

- (void)setIndicator:(UIView<XZPageControlIndicator> *)indicator forPage:(NSInteger)page {
    _indicators[page].view = indicator;
}

#pragma mark - Private Methods

- (void)XZPageControlSetCurrentPage:(NSInteger)currentPage animated:(BOOL)animated sendsEvents:(BOOL)sendsEvents {
    if (_currentPage != currentPage) {
        if (_currentPage < _indicators.count) {
            [_indicators[_currentPage] setCurrent:NO animated:animated];
        }
        _currentPage = currentPage;
        if (_currentPage < _indicators.count) {
            [_indicators[_currentPage] setCurrent:YES animated:animated];
        }
        if (sendsEvents) {
            [self sendActionsForControlEvents:(UIControlEventValueChanged)];
        }
    }
}

@end
