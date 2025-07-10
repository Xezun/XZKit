//
//  UIViewController+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/6/23.
//

@import ObjectiveC;
#import "UIViewController+XZKit.h"
#import "UIApplication+XZKit.h"
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZRuntime.h>
#else
#import "XZRuntime.h"
#endif

static const void * const _prefersStatusBarAppearance = &_prefersStatusBarAppearance;
static const void * const _preferredStatusBarStyle = &_preferredStatusBarStyle;
static const void * const _prefersStatusBarHidden = &_prefersStatusBarHidden;

@implementation UIViewController (XZKit)

- (BOOL)xz_prefersStatusBarAppearance {
    return objc_getAssociatedObject(self.class, _prefersStatusBarAppearance);
}

- (BOOL)xz_setPrefersStatusBarAppearance {
    Class const aClass = self.class;
    if (objc_getAssociatedObject(aClass, _prefersStatusBarAppearance)) {
        return NO;
    }
    objc_setAssociatedObject(aClass, _prefersStatusBarAppearance, @(YES), OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    NSAssert(UIApplication.xz_isViewControllerBasedStatusBarAppearance, @"必须在 Info.plist 中配置键 UIViewControllerBasedStatusBarAppearance 对应的值为 YES 才能开启控制器状态栏配置能力。");
    
    // 重写超类不调用超类实现，因为超类一般是 UIViewController 没有必要调用。
    // 交换自身则调用自身实现，以避免自身实现中的业务逻辑丢失。
    
    xz_objc_class_addMethodWithBlock(aClass, @selector(preferredStatusBarStyle), nil, nil, ^UIStatusBarStyle(UIViewController *self) {
        return self.xz_preferredStatusBarStyle;
    }, ^id (SEL selector) {
        return ^UIStatusBarStyle(UIViewController *self) {
            ((UIStatusBarStyle (*)(UIViewController *, SEL))objc_msgSend)(self, selector);
            return self.xz_preferredStatusBarStyle;
        };
    });
    
    xz_objc_class_addMethodWithBlock(aClass, @selector(prefersStatusBarHidden), nil, nil, ^BOOL(UIViewController *self) {
        return self.xz_prefersStatusBarHidden;
    }, ^id (SEL selector) {
        return ^BOOL(UIViewController *self) {
            ((BOOL (*)(UIViewController *, SEL))objc_msgSend)(self, selector);
            return self.xz_prefersStatusBarHidden;
        };
    });
    
    return YES;
}

#pragma mark - 状态栏样式

- (UIStatusBarStyle)xz_preferredStatusBarStyle {
    if (self.xz_prefersStatusBarAppearance) {
        NSNumber *value = objc_getAssociatedObject(self, _preferredStatusBarStyle);
        return value ? value.integerValue : UIStatusBarStyleDefault;
    } else if (UIApplication.xz_isViewControllerBasedStatusBarAppearance) {
        return UIStatusBarStyleDefault;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        return UIApplication.sharedApplication.statusBarStyle;
#pragma clang diagnostic pop
    }
}

- (void)xz_setPreferredStatusBarStyle:(UIStatusBarStyle)xz_preferredStatusBarStyle {
    [self xz_setPreferredStatusBarStyle:xz_preferredStatusBarStyle animated:NO];
}

- (void)xz_setPreferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle animated:(BOOL)animated {
    if ([self xz_prefersStatusBarAppearance]) {
        objc_setAssociatedObject(self, _preferredStatusBarStyle, @(preferredStatusBarStyle), OBJC_ASSOCIATION_COPY_NONATOMIC);
        if (animated) {
            [UIView animateWithDuration:0.35 animations:^{
                [self setNeedsStatusBarAppearanceUpdate];
            }];
        } else {
            [self setNeedsStatusBarAppearanceUpdate];
        }
    } else if (UIApplication.xz_isViewControllerBasedStatusBarAppearance) {
        [self xz_setPrefersStatusBarAppearance];
        [self xz_setPreferredStatusBarStyle:preferredStatusBarStyle animated:animated];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [UIApplication.sharedApplication setStatusBarStyle:preferredStatusBarStyle animated:animated];
#pragma clang diagnostic pop
    }
}

#pragma mark - 状态栏显示或隐藏

- (BOOL)xz_prefersStatusBarHidden {
    if ([self xz_prefersStatusBarAppearance]) {
        NSNumber *value = objc_getAssociatedObject(self, _prefersStatusBarHidden);
        return value ? value.boolValue : NO;
    } else if (UIApplication.xz_isViewControllerBasedStatusBarAppearance) {
        return NO;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        return UIApplication.sharedApplication.statusBarHidden;
#pragma clang diagnostic pop
    }
}

- (void)xz_setPrefersStatusBarHidden:(BOOL)xz_prefersStatusBarHidden {
    [self xz_setPrefersStatusBarHidden:xz_prefersStatusBarHidden animated:NO];
}

- (void)xz_setPrefersStatusBarHidden:(BOOL)prefersStatusBarHidden animated:(BOOL)animated {
    if ([self xz_prefersStatusBarAppearance]) {
        objc_setAssociatedObject(self, _prefersStatusBarHidden, @(prefersStatusBarHidden), OBJC_ASSOCIATION_COPY_NONATOMIC);
        if (animated) {
            [UIView animateWithDuration:0.35 animations:^{
                [self setNeedsStatusBarAppearanceUpdate];
            }];
        } else {
            [self setNeedsStatusBarAppearanceUpdate];
        }
    } else if (UIApplication.xz_isViewControllerBasedStatusBarAppearance) {
        [self xz_setPrefersStatusBarAppearance];
        [self xz_setPrefersStatusBarHidden:prefersStatusBarHidden animated:animated];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] setStatusBarHidden:prefersStatusBarHidden animated:animated];
#pragma clang diagnostic pop
    }
}

@end
