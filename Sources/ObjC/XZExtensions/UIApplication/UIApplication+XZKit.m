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
    if (@available(iOS 27.0, *)) {
        return YES;
    }
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
    
    if (window) {
        return window;
    }
    
    UIWindow *inactiveWindow = nil;
    UIWindow *backgroundWindow = nil;
    UIWindow *unattachedWindow = nil;
    
    for (UIWindowScene *scene in self.connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            switch (scene.activationState) {
                case UISceneActivationStateUnattached: {
                    if (!unattachedWindow) {
                        unattachedWindow = scene.keyWindow ?: scene.windows.firstObject;
                    }
                    break;
                }
                case UISceneActivationStateForegroundActive: {
                    if ((window = scene.keyWindow ?: scene.windows.firstObject)) {
                        return window;
                    }
                    break;
                }
                case UISceneActivationStateForegroundInactive: {
                    if (!inactiveWindow) {
                        inactiveWindow = scene.keyWindow ?: scene.windows.firstObject;
                    }
                    break;
                }
                case UISceneActivationStateBackground: {
                    if (!backgroundWindow) {
                        backgroundWindow = scene.keyWindow ?: scene.windows.firstObject;
                    }
                    break;
                }
            }
        }
    }
    
    if (inactiveWindow) {
        return inactiveWindow;
    }
    
    if (backgroundWindow) {
        return backgroundWindow;
    }
    
    if (unattachedWindow) {
        return unattachedWindow;
    }
    
    if ([self.delegate respondsToSelector:@selector(window)]) {
        if ((window = self.delegate.window)) {
            return window;
        }
    }
    
    return nil;
}

- (void)xz_setMainWindow:(UIWindow *)xz_mainWindow {
    objc_setAssociatedObject(self, _mainWindow, xz_mainWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
