//
//  XZToastWrapperView.m
//  XZToast
//
//  Created by Xezun on 2025/4/30.
//

#import "XZToastWrapperView.h"
#import "XZToastTask.h"
#import "XZToastView.h"

/// toast 与 container 之间的边距，为了显示阴影。
#define kPadding 5.0

@implementation XZToastWrapperView

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, 120.0, 120.0)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin);
        self.clipsToBounds = YES;
        // self.backgroundColor = UIColor.redColor;
        
        _shadowColor = XZToast.shadowColor;
        
        CALayer * const layer = self.layer;
        layer.shadowColor   = _shadowColor.CGColor;
        layer.shadowOffset  = CGSizeZero;
        layer.shadowOpacity = 0.3;
        layer.shadowRadius  = kPadding * 0.5;
    }
    return self;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (self.traitCollection.userInterfaceStyle != previousTraitCollection.userInterfaceStyle) {
        self.layer.shadowColor = [_shadowColor resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    }
}

- (void)setShadowColor:(UIColor *)shadowColor {
    if (_shadowColor != shadowColor) {
        _shadowColor = shadowColor ?: XZToast.shadowColor;
        self.layer.shadowColor = [_shadowColor resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    }
}

- (void)setView:(UIView *)view {
    if (_view != view) {
        [_view removeFromSuperview];
        _view = view;
        if (_view) {
            _view.frame = CGRectInset(self.bounds, kPadding, kPadding);
            [self addSubview:_view];
        }
    }
}

#pragma mark - 重写继承的方法

- (void)willRemoveSubview:(UIView *)subview {
    [super willRemoveSubview:subview];
    
    // 在复用的情况下，_view 可能会被其它的控制器拿走，如果是这样，就提前终止当前提示。
    if (self.window && subview == _view) {
        [self.task hide:nil];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect const bounds = self.bounds;
    CGFloat const x = kPadding;
    CGFloat const y = kPadding;
    CGFloat const w = bounds.size.width - kPadding * 2.0;
    CGFloat const h = bounds.size.height - kPadding * 2.0;
    _view.frame = CGRectMake(x, y, w, h);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat const maxToastWidth = size.width - kPadding * 2.0;
    CGSize  const toastSize = _view ? [_view sizeThatFits:CGSizeMake(maxToastWidth, 0)] : CGSizeMake(80, 80);
    CGFloat const width = MIN(size.width, toastSize.width + kPadding * 2.0);
    CGFloat const height = toastSize.height + kPadding * 2.0;
    return CGSizeMake(width, height);
}

@end



