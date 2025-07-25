//
//  XZToastWrapperView.m
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import "XZToastWrapperView.h"
#import "XZToastTask.h"

/// toast 与 container 之间的边距，为了显示阴影。
#define kPadding 5.0

@implementation XZToastWrapperView {
    /// 由于投影是 CGColor 不能自动适配 Dark 模式切换，需要记录下来，以便在切换时使用。
    UIColor *_shadowColor;
}

- (instancetype)initWithView:(UIView *)view {
    CGSize const size = view.frame.size;
    self = [super initWithFrame:CGRectMake(0, 0, kPadding + size.width + kPadding, kPadding + size.height + kPadding)];
    if (self) {
        self.clipsToBounds = YES;
        // self.backgroundColor = UIColor.redColor;
        
        CALayer * const layer = self.layer;
        layer.shadowColor   = XZToast.shadowColor.CGColor;
        layer.shadowOffset  = CGSizeZero;
        layer.shadowOpacity = 0.3;
        layer.shadowRadius  = kPadding * 0.5;
        
        _view = view;
        _view.frame = CGRectMake(kPadding, kPadding, size.width, size.height);
        [self addSubview:_view];
    }
    return self;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (self.traitCollection.userInterfaceStyle != previousTraitCollection.userInterfaceStyle) {
        UIColor * const shadowColor = _shadowColor ?: XZToast.shadowColor;
        self.layer.shadowColor = [shadowColor resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    }
}

#pragma mark - <XZToastView>

- (NSString *)text {
    UIView<XZToastView> * const view = (id)self.view;
    if ([view conformsToProtocol:@protocol(XZToastView)]) {
        return view.text;
    }
    return nil;
}

- (void)setText:(NSString *)text {
    UIView<XZToastView> * const view = (id)self.view;
    if ([view conformsToProtocol:@protocol(XZToastView)]) {
        view.text = text;
    }
}

- (void)willShowInViewController:(UIViewController *)viewController {
    UIView<XZToastView> * const view = (id)self.view;
    _shadowColor = viewController.xz_toastConfiguration.shadowColor;
    if (_shadowColor) {
        self.layer.shadowColor = [_shadowColor resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    }
    if ([view conformsToProtocol:@protocol(XZToastView)]) {
        [view willShowInViewController:viewController];
    }
}

- (void)setProgress:(CGFloat)progress {
    UIView<XZToastView> * const view = (id)self.view;
    if ([view conformsToProtocol:@protocol(XZToastView)]) {
        view.progress = progress;
    }
}

- (CGFloat)progress {
    UIView<XZToastView> * const view = (id)self.view;
    if ([view conformsToProtocol:@protocol(XZToastView)]) {
        return view.progress;
    }
    return 0;
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
    CGSize  const toastSize = [_view sizeThatFits:CGSizeMake(maxToastWidth, 0)];
    CGFloat const width = MIN(size.width, toastSize.width + kPadding * 2.0);
    CGFloat const height = toastSize.height + kPadding * 2.0;
    return CGSizeMake(width, height);
}

@end



