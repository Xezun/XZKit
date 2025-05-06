//
//  UIApplication+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/6/23.
//

#import "UIApplication+XZKit.h"

@implementation UIApplication (XZKit)

+ (BOOL)xz_isViewControllerBasedStatusBarAppearance {
    NSNumber *setting = NSBundle.mainBundle.infoDictionary[@"UIViewControllerBasedStatusBarAppearance"];
    if (setting != nil) {
        return setting.boolValue;
    }
    return YES;
}

- (BOOL)xz_isViewControllerBasedStatusBarAppearance {
    return UIApplication.xz_isViewControllerBasedStatusBarAppearance;
}

- (UIWindow *)xz_mainWindow {
    if ([self.delegate respondsToSelector:@selector(window)]) {
        UIWindow * const window = self.delegate.window;
        if (window) {
            return window;
        }
    }
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in self.connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                if ([scene.delegate respondsToSelector:@selector(window)]) {
                    UIWindow * const window = ((id<UIWindowSceneDelegate>)scene.delegate).window;
                    if (window) {
                        return window;
                    }
                }
            }
        }
    }
    return nil;
}

@end
