//
//  XZToastView.m
//  XZToast
//
//  Created by 徐臻 on 2025/5/9.
//

#import "XZToastView.h"
#import "XZGeometry.h"

#define kPaddingT 15.0
#define kPaddingL 15.0
#define kPaddingR 15.0
#define kPaddingB 15.0
#define kIconSize 50.0
#define kTextLine 20.0
#define kSpacing  10.0

@interface XZToastView ()
@end

@implementation XZToastView {
    @package
    UILabel *_textLabel;
    UIView *_iconView;
}

- (instancetype)init {
    CGFloat const width = kPaddingT + kIconSize + kSpacing + kTextLine + kPaddingB;
    return [self initWithFrame:CGRectMake(0, 0, width, width)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor    = XZToast.backgroundColor;
        self.layer.cornerRadius = 6.0;
        self.clipsToBounds      = true;
        
        _style = XZToastStyleMessage;
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor     = XZToast.textColor; // UIColor.whiteColor;
        _textLabel.font          = XZToast.font;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 3;
        _textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
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
        CGSize  const iconSize = [_iconView sizeThatFits:CGSizeMake(w, h)];
        _iconView.frame = CGRectScaleAspectRatioInsideWithMode(CGRectMake(x, y, w, h), iconSize, UIViewContentModeCenter) ;
    }
    
    {
        CGSize  const textSize = [_textLabel sizeThatFits:CGSizeMake(bounds.size.width - kPaddingL - kPaddingR, 0)];
        CGFloat const w = MIN(bounds.size.width - kPaddingL - kPaddingR, textSize.width);
        CGFloat const h = MAX(textSize.height, kTextLine);
        CGFloat const x = bounds.origin.x + (bounds.size.width - w) * 0.5;
        CGFloat const y = CGRectGetMaxY(bounds) - kPaddingB - h;
        _textLabel.frame = CGRectMake(x, y, w, h);
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize const iconSize = [_iconView sizeThatFits:CGSizeMake(kIconSize, kIconSize)];
    CGSize const textSize = [_textLabel sizeThatFits:CGSizeMake(size.width - kPaddingL - kPaddingR, 0)];
    
    BOOL const hasIcon = (iconSize.width > 0 && iconSize.height > 0);
    BOOL const hasText = (textSize.width > 0);
    
    if (hasIcon && hasText) {
        CGFloat const h = kPaddingT + kIconSize + kSpacing + MAX(textSize.height, kTextLine) + kPaddingB;
        CGFloat const w = MAX(h, MIN(size.width, kPaddingB + textSize.width + kPaddingR));
        return CGSizeMake(w, h);
    }
    
    if (hasIcon) {
        return CGSizeMake(kPaddingL + kIconSize + kPaddingR, kPaddingT + kIconSize + kPaddingB);
    }
    
    if (hasText) {
        CGFloat const h = kPaddingT + MAX(textSize.height, kTextLine) + kPaddingB;
        CGFloat const w = MAX(h, MIN(size.width, kPaddingB + textSize.width + kPaddingR));
        return CGSizeMake(w, h);
    }
    
    return CGSizeZero;
}

- (void)willShowInViewController:(UIViewController *)viewController {
    id<XZToastConfiguration> const configuration = viewController.xz_toastConfiguration;
    UIColor * const backgroundColor = configuration.backgroundColor;
    if (backgroundColor) {
        self.backgroundColor = backgroundColor;
    }
    UIColor * const textColor = configuration.textColor;
    if (textColor) {
        _textLabel.textColor = textColor;
    }
    UIFont * const font = configuration.font;
    if (font) {
        _textLabel.font = font;
    }
}

- (NSString *)text {
    return _textLabel.text;
}

- (void)setText:(NSString *)text {
    _textLabel.text = text;
    [self setNeedsLayout];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p: %@, text: %@, icon: %@>", self, self.class, self.text, _iconView];
}

- (UIImage *)image {
    if ([_iconView isKindOfClass:UIImageView.class]) {
        return ((UIImageView *)_iconView).image;
    }
    return nil;
}

- (void)setStyle:(XZToastStyle)style image:(UIImage *)image {
    _style = style;
    if (image) {
        if (![_iconView isKindOfClass:UIImageView.class]) {
            [_iconView removeFromSuperview];
            _iconView = nil;
        }
        
        if (_iconView == nil) {
            _iconView = [[UIImageView alloc] initWithImage:image];
        } else {
            [(UIImageView *)_iconView setImage:image];
        }
        
        _iconView.frame = CGRectMake(CGRectGetMidX(self.bounds), kPaddingT + kIconSize * 0.5, kIconSize, kIconSize);
        [self addSubview:_iconView];
        
        // 动图
        if (image.images.count > 0) {
            [(UIImageView *)_iconView startAnimating];
        }
    } else {
        if ([_iconView isKindOfClass:UIImageView.class]) {
            [(UIImageView *)_iconView setImage:nil];
        }
    }
    switch (_style) {
        case XZToastStyleMessage:
            break;
        case XZToastStyleSuccess:
            break;
        case XZToastStyleFailure:
            break;
        case XZToastStyleWarning:
            break;
        case XZToastStyleWaiting:
            break;
        case XZToastStyleLoading:
            // 已有图片
            if (image != nil) {
                break;
            }
            // 默认使用 UIActivityIndicatorView
            if (![_iconView isKindOfClass:UIActivityIndicatorView.class]) {
                [_iconView removeFromSuperview];
                UIActivityIndicatorView *iconView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleLarge)];
                iconView.color = UIColor.whiteColor;
                [self addSubview:iconView];
                _iconView = iconView;
                [iconView startAnimating];
            }
            break;
        default:
            return;
    }
}

@end

static NSString * const XZToastBase64ImageSuccess = @""
"iVBORw0KGgoAAAANSUhEUgAAAG8AAABvCAMAAADVG25SAAAAOVBMVEUAAAD/////////////////////////////////////////////////////////////////////"
"//8KOjVvAAAAEnRSTlMAEPDQgMCgYDAgUECwkOBw36+FtWvYAAAC80lEQVRo3tWb2bLbMAiGJbRZy/HC+z9sTy9aZU4dGwHqOP9VJpnJF2wQi4kZU03+CCHgb4UQDp+q"
"maS8HYBngmPL2rASd7zSHosebImA94K4aMCs35Gq3VsxDXBE4K0WbT4xAXIEieclAbkKjPjwKJEfDW6HMrkhEwugVFDouC/U0Bc1CiLqKNJwDrXkLBsnB8pxcmDH6QPl"
"ODkwor4iM+7047DgHJVzXAacI8inPKfsKC8vCQlIqHWp1+lp0fURa8yKXf9e0aBpXDXf2rAr/MQlZeO+ZQG7Ukf1z1QE9cwEsJOcJdjzK+bnmOff3SCwE8yD+t4fvL55"
"Lp/gTgz02gdzuq5Jdw0apGsc7qpHCyy3R9WimGVd7ji4ybwgxzVLcD5QS7NftBKoKF3ORDz3o4p3QiJUXN1Ds9gx6Wkm9zSlgquEC99kcbCMVFxNGg3OEqvzHhEqOKqj"
"G1N1cERHqCZp4RZaqe2VcHanpf929emyUnHmQIqaCZfnhnUUHD2Kgwk3gRxJuAWFvP6FiYCzO5l3n9AqnNjO7YsNoSfN7gZXkMG7+ELbLnEZpDyEfNEcJkFrZYhjjARv"
"cRuO8AIR+Df0I6/t7/FAAfZs05iNaudRgSaevbnhGK8NTIY2hCwbojTjcQBYF/NDx2h7mEQT2jI8aqooANp9kFfv6pdNd7B+X5/16FaYEUGvPznAMMprPYAYwMRqbDLh"
"Jnexhyh9jLYSWwT5QHHtyXkcmLmj7IIsYGQPloEzEq7jOBj4pc7K56VxJGydFZrX5y9mpQGF5q2Dnu2szDw/GrlRZB7Y4dCNIvMYR1OUmMc5m6LYPLqBPf9GjnnM3JJ4"
"E6nEzp2J0/IHQW2Q9nFeFqcz+fqGw1lyj3i+Oe/57UOeT096/v6f9wuetD/xAvzIhRRnH7ffo7m/9Mz9LK39swfv18n3Bx+/HynZ//yQ/Vb+/q6IuJJp62Y/bv/6z375"
"em1ZLEZZOTU4N6ylbCapJt9e/h/QfKlmSL8A4VNXuCzbHDYAAAAASUVORK5CYII=";

static NSString * const XZToastBase64ImageFailure = @""
"iVBORw0KGgoAAAANSUhEUgAAAG8AAABvCAMAAADVG25SAAAAPFBMVEUAAAD/////////////////////////////////////////////////////////////////////"
"///////YSWgTAAAAE3RSTlMAEGDQ8IAwwKDvIFCwQN+Q4HCviFmp3wAAAtVJREFUaN7V29uWoyAQBdACQeRmLuf//3W6n6o7k2VBRRjnPLvcVpaISIX6Uq1/hhDwnRDC"
"09tKg5Iez4h3ic9HOhvL246j7Fs+D1u3CDlxW8/AjN/Rmt2bj7WInkQW9dos0bLWJVqVtgZoE1I/5/FJfKeWFnyWpavEHPFpYm7nbjgjt0bNbDgnWxu34KwsZhLH4CSO"
"wUkcgxI3E9xwfraOcTd2HGaMSX7PpYgxiemtt2BUFsUEdPb0tGJk0l9ewMiEV85ibOxvzkSMTTRTbhaOn1QeF3huecFXH4QC28oLlWjdjjWX6TvVNRXoG67LHnIrP4Ib"
"CtxbRo6Vua+Ug9VT06OlEoMyR4+DU60ts6whBmWOasPMGwWPQYET6ost02ylY5A5+bfK8iF40i9Q4GrDq8ze86S1h5zZAQh3aAK6wCNuaZgGH+gEVRyfqaAXVHMoPBp6"
"QAXHIwLoBzs5Dt/BfaCSQyULFajjkMlDBRoVB08FKlDHoVBAN6jnENjrB5kb5MFqOfbQFavjOAQlyNxQzxnFolHvufXDdQ6pOD1IQcHpwUBByzGo9mROC7JXFJweLOQV"
"nB70ZFWcWawKzFR1HKACK5GS04FE5FScDnREVDScEiz8ft3F9YN8fOrn1GCir9x7OTV4b1j/PQ65V7A0rP+ycEkv3CGYxA/LwojYBI5B+VyuYc3tXzgJ3BuufRVGzA9O"
"Ag2k7y/CHbqbn5wIeuFWkI+6yRyDa9sHQuPEw9Ydh/GGyNgovknKBWK/ef+EmCUAYnlc4Og4M/379cwCnZm8/zB5f+Wf7x+N3R+7wP4fJYcxcekS+7fD9qcvs/8+pL/g"
"Sv0Tv8H/ryFlMZfr7zmzf+ma/Vlfye5jzeUL99fN6x/kpEn9kRzrVJqz+v5W16992FHrJmks3pu1+8Oc03/tWkrb1jP7y+/HlW2ZTk6yxb0vrNhEg1KtLz/+H1B8rtSV"
"P0M2b1OW+lTZAAAAAElFTkSuQmCC";

static NSString * const XZToastBase64ImageWarning = @""
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

static NSString * const XZToastBase64ImageWaiting = @""
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

UIImage *UIImageFromXZToastStyle(XZToastStyle style) {
    NSString * base64Image = nil;
    switch (style) {
        case XZToastStyleMessage:
            return nil;
            break;
        case XZToastStyleLoading:
            return nil;
            break;
        case XZToastStyleSuccess:
            base64Image = XZToastBase64ImageSuccess;
            break;
        case XZToastStyleFailure:
            base64Image = XZToastBase64ImageFailure;
            break;
        case XZToastStyleWarning:
            base64Image = XZToastBase64ImageWarning;
            break;
        case XZToastStyleWaiting:
            base64Image = XZToastBase64ImageWaiting;
            break;
    }
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64Image options:kNilOptions];
    return [[UIImage alloc] initWithData:data scale:3.0];;
}

