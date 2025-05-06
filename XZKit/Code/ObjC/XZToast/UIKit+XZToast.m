//
//  UIKit+XZToast.m
//  XZToast
//
//  Created by 徐臻 on 2025/4/29.
//

#import "UIKit+XZToast.h"
#import "UIApplication+XZKit.h"
#import "XZToast.h"
#import "XZToastTask.h"
#import "XZToastManager.h"
@import ObjectiveC;

@implementation UIResponder (XZToast)

- (XZToastTask *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position offset:(CGFloat)offset exclusive:(BOOL)exclusive completion:(void (^)(BOOL))completion {
    return [UIApplication.sharedApplication.xz_mainWindow xz_showToast:toast duration:duration position:position offset:offset exclusive:exclusive completion:completion];
}

- (XZToastTask *)xz_showToast:(XZToast *)toast {
    return [self xz_showToast:toast duration:3.0 position:(XZToastPositionBottom) offset:0 exclusive:false completion:nil];
}

- (void)xz_hideToast:(XZToastTask *)task completion:(void (^)(void))completion {
    [UIApplication.sharedApplication.xz_mainWindow xz_hideToast:task completion:completion];
}

- (void)xz_hideToast:(void (^)(void))completion {
    [self xz_hideToast:nil completion:completion];
}

- (void)xz_setNeedsLayoutToastViews {
    [UIApplication.sharedApplication.xz_mainWindow xz_setNeedsLayoutToastViews];
}

- (NSUInteger)xz_maximumNumberOfToasts {
    return [UIApplication.sharedApplication.xz_mainWindow xz_maximumNumberOfToasts];
}

- (void)xz_setMaximumNumberOfToasts:(NSUInteger)xz_maximumNumberOfToasts {
    [UIApplication.sharedApplication.xz_mainWindow xz_setMaximumNumberOfToasts:xz_maximumNumberOfToasts];
}

@end

@implementation UIView (XZToast)

- (void)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position offset:(CGFloat)offset exclusive:(BOOL)exclusive completion:(void (^)(BOOL))completion {
    [self.nextResponder xz_showToast:toast duration:duration position:position offset:offset exclusive:exclusive completion:completion];
}

- (void)xz_hideToast:(XZToastTask *)task completion:(void (^)(void))completion {
    [self.nextResponder xz_hideToast:task completion:completion];
}

@end


@implementation UIWindow (XZToast)

- (void)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position offset:(CGFloat)offset exclusive:(BOOL)exclusive completion:(void (^)(BOOL))completion {
    [self.rootViewController xz_showToast:toast duration:duration position:position offset:offset exclusive:exclusive completion:completion];
}

- (void)xz_hideToast:(XZToastTask *)task completion:(void (^)(void))completion {
    [self.rootViewController xz_hideToast:task completion:completion];
}

@end


@implementation UIViewController (XZToast)

- (void)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position offset:(CGFloat)offset exclusive:(BOOL)exclusive completion:(void (^)(BOOL))completion {
    XZToastTask *item = [[XZToastTask alloc] initWithToastView:toast.view duration:duration position:position offset:offset exclusive:exclusive completion:completion];
    [[XZToastManager managerForViewController:self] showToast:item];
}

- (void)xz_hideToast:(XZToastTask *)task completion:(void (^)(void))completion {
    [[XZToastManager managerForViewController:self] hideToast:task completion:completion];
}

- (void)xz_setNeedsLayoutToastViews {
    [[XZToastManager managerForViewController:self] setNeedsLayoutToastViews];
}

- (NSUInteger)xz_maximumNumberOfToasts {
    return [XZToastManager managerForViewController:self].maximumNumberOfToasts;
}

- (void)xz_setMaximumNumberOfToasts:(NSUInteger)xz_maximumNumberOfToasts {
    [XZToastManager managerForViewController:self].maximumNumberOfToasts = xz_maximumNumberOfToasts;
}

@end



