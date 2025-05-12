//
//  XZToastTextIconView.m
//  XZToast
//
//  Created by 徐臻 on 2025/5/9.
//

#import "XZToastTextIconView.h"

#define kPaddingT 15.0
#define kPaddingL 15.0
#define kPaddingR 15.0
#define kPaddingB 15.0
#define kIconSize 50.0
#define kTextLine 20.0
#define kSpacing  10.0

@implementation XZToastTextIconView {
    @package
    UILabel *_textLabel;
    UIView *_iconView;
}

- (instancetype)init {
    CGFloat const width = kPaddingT + kIconSize + kSpacing + kTextLine + kPaddingB;
    return [self initWithFrame:CGRectMake(0, 0, width, width)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    NSString * const reason = @"需要使用子类，不可以直接创建使用";
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (instancetype)initWithIconView:(UIView *)iconView {
    CGFloat const width = kPaddingT + kIconSize + kSpacing + kTextLine + kPaddingB;
    self = [super initWithFrame:CGRectMake(0, 0, width, width)];
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

- (instancetype)init {
    UIActivityIndicatorView *_iconView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleLarge)];
    _iconView.color = UIColor.whiteColor;
    return [super initWithIconView:_iconView];
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

@implementation XZToastTextImageView

- (instancetype)initWithImage:(XZToastBase64Image)base64image {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64image options:kNilOptions];
    UIImage *image = [[UIImage alloc] initWithData:data scale:3.0];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return [super initWithIconView:imageView];
}

@end


XZToastBase64Image const XZToastBase64ImageSuccess = @""
"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";

XZToastBase64Image const XZToastBase64ImageFailure = @""
"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";

XZToastBase64Image const XZToastBase64ImageWarning = @""
"iVBORw0KGgoAAAANSUhEUgAAAG8AAABvCAMAAADVG25SAAAAqFBMVEX///8AAAD/////////////////////////////////////////////////////////////////"
"////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
"//////////////////////82TosEAAAAN3RSTlP1APr0/Inwj1lk5iDTamASjBgJxkY9J+3LreqDQ7p4L+DAlzK9klLdSSSzck45NyzXnH4Nv6UHW/JU9AAABLNJREFU"
"aN7Vm9l24jAQRBtJYGODwWZfwh5CErJMtvr/PxtCjiMzWUZlPJxMvRfXdqRuqbsjJUqPcbcT+ZPyqyZ+1OnGj9wPELzLdn1xVVPIStWuFvX2ZeG8xvphcPEKMHIog50u"
"Bg/rRoG8TbO/fxktn0nvX7nvtYvhhaN+BTBiYZ8gxQCV1ig8mtf1AgOIiwATeN2jeDeLHowSVymDoXeTmxd7Bko4KaAc5+NV79MVwkgb1Ko5eNMzwNIYoABnU5ZX71kc"
"TQQCn+I1FoAcI6D56M5btiDHCk93rrxOBVqOBw47bjy/AilCqPguvKqCFCOo6rc8HscD5QNOSXFSqvo9b22gC+RpmPV3vLF2wHFAPf6ad+OwMvlVevsVr0FscwK4Sr7g"
"nYPIOlDOwObnvKojTu9os/49nLMV/M940x7ccKh427v4cuO5hj0Mp5/wzuD4tLNxuppnrpazj7wIRrvh7HrrDOGY8qM/eY0aHCNGVLKKHKMRag3Lo9YmWqWs5q620SHv"
"VpTb0jTlA54HcfNVlge8X45LTenoMLyLcgPiPMvr9pS48Sr+H7nZ1TjsZngexNGmq4fvpx15As/ywsA4h5bmAa8JV54JwnfeyLi68vOUGaW8lz7EVRgc8AaEs5Xy2hXC"
"NWf3n02E4zee/Sj8fm9BhPrT73iN9HMykclGQeJRkz1vqwzDizO88J7hSXvPe4AQpiB7HOkElPd6zxtAE57eOMMb9wiexvMrL7xgntGIf5CPDPN+F+GO14ai7uf1DK9O"
"etsl2Xk05ZlkeA8UT6O+4y0gjLBIYUQaszFbkqtjeKR3kEhcM5znKsMjn9XUYgmVcLyzDG8FzqxC6YDk9W1Ai2usuSMRa7nv2mLePWuOxGctwdLWTQLW7MuEtShbV20r"
"1jyRJmkxZvvO2xpD8ppSJnmSCWh12lv+D3j2RJ/DK03a8ysTznjehPY8v/Oeae+1+LRnngaYxor2+hLl58Ut2htJh/bMLtNwFtDeDp0fBL20cHvXY3kqpPOfKJUG0Nud"
"k85/yVXuDX9NOwcJfX4RUbNwj7sMFMvz7PmMOWb1/aSU+H3eWLfnTy4n9Vd9vu6s0KbP17araWgXZiFxfzhaGgN7P8ot/n60VkZOIUjb3m9Z2TVG329LHlgnlCjQrqat"
"T3D9xOFTOSo/DSGawVXGtv5C4Vadt8ttC9zn5OpL9gKRdhKTOQFUZkTWz+ymTRXOrI+on1ErBue5OhYCL0/9U4zyMzzfeeuqXtfyXh9Uu15XbrINpwCusczj6td2VW8y"
"vK02rvXru4/1eb4+MYJQ9Xm+/6Axt+2uZAWyysf3V7IFn2sotr/C94+MVN+bASZ//6g0HcK1cDrwp43p+hnqmP5YyYd7fghagc0PbP/PFtuJkRNI7v6mXW6n7d+WlkMU"
"jxsuj++/U/Xg084XbH/U/ETh8yE/bv6lyPme9Y+cX9rtw34h81knnT/zHk86XxflmR8UfYr5wVTV2knmI63iMnLMf6pRnH++9Zydb+01l//R/O7bfHKrgr+sHS04fj7Z"
"auPNBYD6ZnpK5t6mwPnyl83k2/ny683Lv5if9wYf5ucHHjk/Tyn58P8BCfcDvwH1PJFqyEDOJQAAAABJRU5ErkJggg==";

XZToastBase64Image const XZToastBase64ImageWaiting = @""
"iVBORw0KGgoAAAANSUhEUgAAAG8AAABvCAMAAADVG25SAAAAolBMVEUAAAD/////////////////////////////////////////////////////////////////////"
"////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
"//////////////8ELnaCAAAANXRSTlMAhUfC8RAnyQR7Vgh/PQy9+Nbk6MujkjgwF+vQoHC5XNKujHTuqE9E4dofHN6mnWpfFLRlK8lcy6gAAAMLSURBVGje3dvZcuIw"
"EAXQ63g3NtisNjthSSAkIUv//69NhReRMRNLltxF5rynbrnUyHKrAxWulyzige3bmeM4me13XuIo8dpoxGg2nThU5vjTWQ6z3MX7MqV/cybbnQtDWg/3ParWtZLAxKOF"
"PsmyQ92HfAqPpOIYvumkWSmp6q4L1PT6SHXsP+rV/5zqWn2qF+U9aUgtqMl90tPxoGDhkK5xBGlDMsGCnPaWzJjKVcqcTHlvoZJnkzn2U2Vcj0zKKgJbNpnVaf9YKiLO"
"WCB+8EwK9KtUaQ/T/x1G1IwdrvIcasb4cLU0fZLQtf3+mb0naXZQe/EsIDjDHcmLUZKr/mVCCrxSXke12O5IwRx/+aBG8+iEb4pew3ndN1yyqOE8WuOCO248r+dCCKnx"
"PApFnNvTyVN/wJAY8sQKBkuWvEkgdgqOPErEcZMlb4iz9pgpr9sWr1mOPIrwZcWWNzhX554tbxkAGKVseekIwIzY8mgGYMCYNwDaE8a8fgteypjneBgRYx6NsGDNixCz"
"5sUYsOa9wGbN68BnzfOZn89GxpqXwWHNc/77POb1467P3/P7O8xJXUd9/xR2kxr7Z1w/D+3ZhtTEtd5/gjckJVHN97uQvJOCker5JUTJ4qhwflE9n/kP167QNvLnM9UC"
"pWcPJZ9T+Q+IGSlyYhclD77s+XqUkqosQtnrnqqkOYAgI3V2gpLCogrL+k3rdHhASb6tWHqdNvJmHVxZxm719607pnqW5WUsNhXf73rXYasc380l+hNIqL5hgQs7qf5L"
"sNQIfHwVy9jKpPpLiEmH2OJCya3X7ZGWlYcvB0e2ARqSno3lVnYCwlJ/V8fxhFy+vwuLtM378v1rFF1SptOfx4madVK7XzF/y5lTkzyOy00hVrn/02cHN3C/yX1/q/4i"
"1J8T2ZJ50xuaL2CenzA/H9IveOdfCtb5nlXrBueXzM1n3ez8mZH5upueH9Sdj/wF85/n+dYNy3yrUIRqz/gYvkGPGyvMJ69dM/PXY5b5a8GNVjzz5UKQGJmf5/7/gD/5"
"YSxK2yYMJwAAAABJRU5ErkJggg==";
