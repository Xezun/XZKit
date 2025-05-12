//
//  XZToastActivityIndicatorView.m
//  XZToast
//
//  Created by 徐臻 on 2025/5/9.
//

#import "XZToastActivityIndicatorView.h"

#define kPaddingT 15.0
#define kPaddingL 15.0
#define kPaddingR 15.0
#define kPaddingB 15.0
#define kIconSize 50.0
#define kTextLine 20.0
#define kSpacing  10.0

@implementation XZToastTextIconView

- (instancetype)init {
    CGFloat const width = kPaddingT + kIconSize + kSpacing + kTextLine + kPaddingB;
    return [self initWithFrame:CGRectMake(0, 0, width, width)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    NSString * const reason = @"需要使用子类，不可以直接创建使用";
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (instancetype)initWithFrame:(CGRect)frame iconView:(UIView *)iconView {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        self.layer.cornerRadius = 6.0;
        self.clipsToBounds = true;
        
        _iconView = iconView;
        [self addSubview:_iconView];
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor = UIColor.whiteColor;
        _textLabel.font = [UIFont monospacedDigitSystemFontOfSize:17.0 weight:(UIFontWeightRegular)];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect const bounds = self.bounds;
    
    {
        CGFloat const x = bounds.origin.x + (bounds.size.width - kIconSize) * 0.5;
        CGFloat const y = kPaddingT;
        CGFloat const w = kIconSize;
        CGFloat const h = kIconSize;
        _iconView.frame = CGRectMake(x, y, w, h);
    }
    
    if (_textLabel.text.length > 0) {
        CGSize  const s = [_textLabel sizeThatFits:CGSizeMake(bounds.size.width - kPaddingL - kPaddingR, 0)];
        CGFloat const w = MIN(bounds.size.width - kPaddingL - kPaddingR, s.width);
        CGFloat const h = kTextLine;
        CGFloat const x = bounds.origin.x + (bounds.size.width - w) * 0.5;
        CGFloat const y = kPaddingT + kIconSize + kSpacing;
        _textLabel.frame = CGRectMake(x, y, w, h);
    } else {
        CGFloat const x = CGRectGetMidX(bounds);
        CGFloat const y = kPaddingT + kIconSize + kSpacing;
        _textLabel.frame = CGRectMake(x, y, 0, kTextLine);
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (_textLabel.text.length > 0) {
        CGSize  const s = [_textLabel sizeThatFits:CGSizeMake(size.width - kPaddingL - kPaddingR, 0)];
        CGFloat const h = kPaddingT + kIconSize + kSpacing + kTextLine + kPaddingB;
        CGFloat const w = MAX(h, MIN(size.width, kPaddingB + s.width + kPaddingR));
        return CGSizeMake(w, h);
    }
    return CGSizeMake(kPaddingL + kIconSize + kPaddingR, kPaddingT + kIconSize + kPaddingB);
}

- (NSString *)text {
    return _textLabel.text;
}

- (void)setText:(NSString *)text {
    _textLabel.text = text;
    [self setNeedsLayout];
}

@end


@implementation XZToastActivityIndicatorView

- (instancetype)initWithFrame:(CGRect)frame  {
    UIActivityIndicatorView *_iconView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleLarge)];
    _iconView.color = UIColor.whiteColor;
    return [super initWithFrame:frame iconView:_iconView];
}

- (BOOL)isAnimating {
    return ((UIActivityIndicatorView *)_iconView).isAnimating;
}

- (void)startAnimating {
    [((UIActivityIndicatorView *)_iconView) startAnimating];
}

- (void)stopAnimating {
    [((UIActivityIndicatorView *)_iconView) stopAnimating];
}

@end

@implementation XZToastSuccessView

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(kIconSize, kIconSize);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 创建主圆形路径
        UIBezierPath *circlePath = [UIBezierPath bezierPath];
        [circlePath moveToPoint:CGPointMake(508.36, 74.97)];
        [circlePath addCurveToPoint:CGPointMake(44.22, 539.10)
                     controlPoint1:CGPointMake(252.03, 74.97)
                     controlPoint2:CGPointMake(44.22, 282.76)];
        [circlePath addCurveToPoint:CGPointMake(508.36, 1003.23)
                     controlPoint1:CGPointMake(44.22, 795.43)
                     controlPoint2:CGPointMake(252.03, 1003.23)];
        [circlePath addCurveToPoint:CGPointMake(972.49, 539.10)
                     controlPoint1:CGPointMake(764.70, 1003.23)
                     controlPoint2:CGPointMake(972.49, 795.43)];
        [circlePath addCurveToPoint:CGPointMake(508.36, 74.97)
                     controlPoint1:CGPointMake(972.49, 282.76)
                     controlPoint2:CGPointMake(764.70, 74.97)];
        [circlePath closePath];
        
        // 创建装饰路径
        UIBezierPath *decorativePath = [UIBezierPath bezierPath];
        [decorativePath moveToPoint:CGPointMake(807.32, 367.57)];
        [decorativePath addCurveToPoint:CGPointMake(427.84, 753.51)
                      controlPoint1:CGPointMake(807.32, 367.57)
                      controlPoint2:CGPointMake(577.32, 504.25)];
        [decorativePath addCurveToPoint:CGPointMake(253.63, 552.31)
                      controlPoint1:CGPointMake(354.43, 645.37)
                      controlPoint2:CGPointMake(253.63, 552.31)];
        [decorativePath addCurveToPoint:CGPointMake(301.74, 497.40)
                      controlPoint1:CGPointMake(253.63, 552.31)
                      controlPoint2:CGPointMake(250.17, 472.46)];
        [decorativePath addCurveToPoint:CGPointMake(414.21, 583.24)
                      controlPoint1:CGPointMake(301.74, 497.40)
                      controlPoint2:CGPointMake(342.98, 514.53)];
        [decorativePath addCurveToPoint:CGPointMake(786.16, 328.45)
                      controlPoint1:CGPointMake(622.94, 397.05)
                      controlPoint2:CGPointMake(786.16, 328.45)];
        [decorativePath addCurveToPoint:CGPointMake(807.32, 367.57)
                      controlPoint1:CGPointMake(826.21, 308.32)
                      controlPoint2:CGPointMake(807.32, 367.57)];
        [decorativePath closePath];
        
        [circlePath appendPath:decorativePath];
        
        CGFloat scale = 36.0 / 1024.0;
        [circlePath applyTransform:CGAffineTransformMakeScale(scale, scale)];
        [circlePath applyTransform:CGAffineTransformMakeTranslation(7.0, 7.0)];
        
        CAShapeLayer *layer = (CAShapeLayer *)self.layer;
        layer.path = circlePath.CGPath;
        layer.fillColor = UIColor.whiteColor.CGColor;
        layer.strokeColor = UIColor.whiteColor.CGColor;
        layer.borderWidth = 0;
    }
    return self;
}

@end


@implementation XZToastFailureView

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(kIconSize, kIconSize);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 绘制圆形背景
        UIBezierPath *circlePath = [UIBezierPath bezierPath];
        [circlePath moveToPoint:CGPointMake(511.07, 70.21)];
        [circlePath addCurveToPoint:CGPointMake(68.94, 512.28)
                     controlPoint1:CGPointMake(266.87, 70.21)
                     controlPoint2:CGPointMake(68.94, 268.14)];
        [circlePath addCurveToPoint:CGPointMake(511.07, 954.35)
                     controlPoint1:CGPointMake(68.94, 756.42)
                     controlPoint2:CGPointMake(266.87, 954.35)];
        [circlePath addCurveToPoint:CGPointMake(953.14, 512.28)
                     controlPoint1:CGPointMake(755.22, 954.35)
                     controlPoint2:CGPointMake(953.14, 756.42)];
        [circlePath addCurveToPoint:CGPointMake(511.07, 70.21)
                     controlPoint1:CGPointMake(953.14, 268.14)
                     controlPoint2:CGPointMake(755.22, 70.21)];
        [circlePath closePath];
        
        // 绘制中间减号
        UIBezierPath *minusPath = [UIBezierPath bezierPath];
        [minusPath moveToPoint:CGPointMake(706.20, 571.79)];
        [minusPath addLineToPoint:CGPointMake(315.95, 571.79)];
        
        // 创建减号矩形路径（通过计算高度）
        CGFloat lineHeight = 59.53;  // 根据 SVG 路径计算得出
        CGRect minusRect = CGRectMake(315.95, 571.79 - lineHeight/2, 706.20 - 315.95, lineHeight);
        UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:minusRect];
        
        // 组合路径
        [minusPath appendPath:rectPath];
        [circlePath appendPath:minusPath];
        
        CGFloat scale = 36.0 / 1024.0;
        [circlePath applyTransform:CGAffineTransformMakeScale(scale, scale)];
        [circlePath applyTransform:CGAffineTransformMakeTranslation(7.0, 7.0)];
        
        CAShapeLayer *layer = (CAShapeLayer *)self.layer;
        layer.path = circlePath.CGPath;
        layer.fillColor = UIColor.whiteColor.CGColor;
        layer.strokeColor = UIColor.whiteColor.CGColor;
        layer.borderWidth = 0;
    }
    return self;
}

@end


#import <UIKit/UIKit.h>

@interface MinusIconView : UIView
@end

@implementation MinusIconView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // 坐标系缩放（适配 1024x1024 的 viewBox）
    CGFloat scale = MIN(rect.size.width / 1024, rect.size.height / 1024);
    CGContextScaleCTM(context, scale, scale);
    
    // 绘制圆形背景
    UIBezierPath *circlePath = [UIBezierPath bezierPath];
    [circlePath moveToPoint:CGPointMake(511.07, 70.21)];
    [circlePath addCurveToPoint:CGPointMake(68.94, 512.28)
                 controlPoint1:CGPointMake(266.87, 70.21)
                 controlPoint2:CGPointMake(68.94, 268.14)];
    [circlePath addCurveToPoint:CGPointMake(511.07, 954.35)
                 controlPoint1:CGPointMake(68.94, 756.42)
                 controlPoint2:CGPointMake(266.87, 954.35)];
    [circlePath addCurveToPoint:CGPointMake(953.14, 512.28)
                 controlPoint1:CGPointMake(755.22, 954.35)
                 controlPoint2:CGPointMake(953.14, 756.42)];
    [circlePath addCurveToPoint:CGPointMake(511.07, 70.21)
                 controlPoint1:CGPointMake(953.14, 268.14)
                 controlPoint2:CGPointMake(755.22, 70.21)];
    [circlePath closePath];
    
    // 绘制中间减号
    UIBezierPath *minusPath = [UIBezierPath bezierPath];
    [minusPath moveToPoint:CGPointMake(706.20, 571.79)];
    [minusPath addLineToPoint:CGPointMake(315.95, 571.79)];
    
    // 创建减号矩形路径（通过计算高度）
    CGFloat lineHeight = 59.53;  // 根据 SVG 路径计算得出
    CGRect minusRect = CGRectMake(315.95, 571.79 - lineHeight/2, 706.20 - 315.95, lineHeight);
    UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:minusRect];
    
    // 组合路径
    [minusPath appendPath:rectPath];
    
    // 填充颜色
    [[UIColor whiteColor] setFill];
    [circlePath fill];
    [minusPath fill];
    
    CGContextRestoreGState(context);
}

@end

