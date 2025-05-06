//
//  UIApplication+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/6/23.
//

#import "UIApplication+XZKit.h"
@import ObjectiveC;

static const void * const _mainWindow = &_mainWindow;

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
    UIWindow *window = objc_getAssociatedObject(self, _mainWindow);
    
    if (window == nil) {
        if ([self.delegate respondsToSelector:@selector(window)]) {
            window = self.delegate.window;
        }
        if (window == nil) {
            if (@available(iOS 13.0, *)) {
                for (UIWindowScene *scene in self.connectedScenes) {
                    if ([scene isKindOfClass:[UIWindowScene class]]) {
                        if ([scene.delegate respondsToSelector:@selector(window)]) {
                            window = ((id<UIWindowSceneDelegate>)scene.delegate).window;
                            if (window) {
                                break;
                            }
                        }
                    }
                }
            }
        }
        if (window) {
            self.xz_mainWindow = window;
        }
    }
    
    return window;
}

- (void)xz_setMainWindow:(UIWindow *)xz_mainWindow {
    objc_setAssociatedObject(self, _mainWindow, xz_mainWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
