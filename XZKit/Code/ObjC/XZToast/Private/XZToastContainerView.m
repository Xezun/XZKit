//
//  XZToastContainerView.m
//  XZToast
//
//  Created by 徐臻 on 2025/4/30.
//

#import "XZToastContainerView.h"

/// toast 与 container 之间的边距，为了显示阴影。
#define XZToastInsets 5.0

@implementation XZToastContainerView

- (instancetype)initWithToastView:(UIView *)toastView {
    CGSize const size = toastView.frame.size;
    self = [super initWithFrame:CGRectMake(0, 0, XZToastInsets + size.width + XZToastInsets, XZToastInsets + size.height + XZToastInsets)];
    if (self) {
        CALayer * const layer = self.layer;
        layer.shadowColor   = UIColor.blackColor.CGColor;
        layer.shadowOffset  = CGSizeZero;
        layer.shadowOpacity = 0.6;
        layer.shadowRadius  = XZToastInsets;
        
        _toastView = toastView;
        _toastView.frame = CGRectMake(XZToastInsets, XZToastInsets, size.width, size.height);
        [self addSubview:_toastView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect const bounds = self.bounds;
    CGFloat const w = MAX(bounds.size.width - XZToastInsets * 2.0, 0.0);
    CGFloat const h = MAX(bounds.size.height - XZToastInsets * 2.0, 0.0);
    _toastView.frame = CGRectMake(XZToastInsets, XZToastInsets, w, h);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat const maxToastWidth = size.width - XZToastInsets * 2.0;
    if (maxToastWidth <= 0) {
        return self.frame.size;
    }
    CGSize const toastSize = [_toastView sizeThatFits:CGSizeMake(maxToastWidth, 0)];
    return CGSizeMake(MIN(size.width, toastSize.width + XZToastInsets * 2.0), toastSize.height + XZToastInsets * 2.0);
}

@end
