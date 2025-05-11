//
//  XZToastShadowView.m
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import "XZToastShadowView.h"
#import "UIKit+XZToast.h"

/// toast 与 container 之间的边距，为了显示阴影。
#define XZToastInsets 5.0

@implementation XZToastShadowView

- (instancetype)initWithView:(UIView *)view {
    CGSize const size = view.frame.size;
    self = [super initWithFrame:CGRectMake(0, 0, XZToastInsets + size.width + XZToastInsets, XZToastInsets + size.height + XZToastInsets)];
    if (self) {
        self.clipsToBounds = YES;
        // self.backgroundColor = UIColor.redColor;
        
        CALayer * const layer = self.layer;
        layer.shadowColor   = UIColor.blackColor.CGColor;
        layer.shadowOffset  = CGSizeZero;
        layer.shadowOpacity = 0.8;
        layer.shadowRadius  = XZToastInsets * 0.5;
        
        _view = view;
        _view.frame = CGRectMake(XZToastInsets, XZToastInsets, size.width, size.height);
        [self addSubview:_view];
    }
    return self;
}

- (void)willRemoveSubview:(UIView *)subview {
    [super willRemoveSubview:subview];
    
    // 在复用的情况下，_view 可能会被其它的控制器拿走，如果是这样，就提前终止。
    if (self.window && subview == _view) {
        [self xz_hideToast:nil];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect const bounds = self.bounds;
    CGFloat const x = XZToastInsets;
    CGFloat const y = XZToastInsets;
    CGFloat const w = bounds.size.width - XZToastInsets * 2.0;
    CGFloat const h = bounds.size.height - XZToastInsets * 2.0;
    _view.frame = CGRectMake(x, y, w, h);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat const maxToastWidth = size.width - XZToastInsets * 2.0;
    CGSize const toastSize = [_view sizeThatFits:CGSizeMake(maxToastWidth, 0)];
    CGFloat const width = MIN(size.width, toastSize.width + XZToastInsets * 2.0);
    CGFloat const height = toastSize.height + XZToastInsets * 2.0;
    return CGSizeMake(width, height);
}

@end



