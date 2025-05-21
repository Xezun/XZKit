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

#define XZToastDuration 1.0

@implementation UIResponder (XZToast)

- (XZToast *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion {
    return [self.nextResponder xz_showToast:toast duration:duration position:position exclusive:exclusive completion:completion];
}

- (void)xz_hideToast:(XZToast *)toast completion:(void (^)(void))completion {
    [self.nextResponder xz_hideToast:toast completion:completion];
}

- (void)xz_setNeedsLayoutToasts {
    [self.nextResponder xz_setNeedsLayoutToasts];
}

- (void)xz_layoutToastsIfNeeded {
    [self.nextResponder xz_layoutToastsIfNeeded];
}

- (NSInteger)xz_maximumNumberOfToasts {
    return [self.nextResponder xz_maximumNumberOfToasts];
}

- (void)xz_setMaximumNumberOfToasts:(NSInteger)xz_maximumNumberOfToasts {
    [self.nextResponder xz_setMaximumNumberOfToasts:xz_maximumNumberOfToasts];
}

- (void)xz_setToastOffset:(CGFloat)offset forPosition:(XZToastPosition)position {
    [self.nextResponder xz_setToastOffset:offset forPosition:position];
}

- (CGFloat)xz_toastOffsetForPosition:(XZToastPosition)position {
    return [self.nextResponder xz_toastOffsetForPosition:position];
}

- (nullable XZToast *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position completion:(nullable XZToastCompletion)completion {
    return [self xz_showToast:toast duration:duration position:position exclusive:false completion:completion];
}

- (nullable XZToast *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration exclusive:(BOOL)exclusive completion:(nullable XZToastCompletion)completion {
    return [self xz_showToast:toast duration:duration position:(XZToastPositionMiddle) exclusive:exclusive completion:completion];
}

- (nullable XZToast *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration completion:(nullable XZToastCompletion)completion {
    return [self xz_showToast:toast duration:duration position:(XZToastPositionMiddle) exclusive:false completion:completion];
}

- (nullable XZToast *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration {
    return [self xz_showToast:toast duration:duration position:(XZToastPositionMiddle) exclusive:false completion:nil];
}

- (nullable XZToast *)xz_showToast:(XZToast *)toast completion:(nullable XZToastCompletion)completion {
    return [self xz_showToast:toast duration:XZToastDuration position:(XZToastPositionMiddle) exclusive:false completion:completion];
}

- (XZToast *)xz_showToast:(XZToast *)toast {
    return [self xz_showToast:toast duration:XZToastDuration position:(XZToastPositionMiddle) exclusive:false completion:nil];
}

- (nullable XZToast *)xz_showToast:(XZToast *)toast position:(XZToastPosition)position {
    return [self xz_showToast:toast duration:XZToastDuration position:position exclusive:false completion:nil];
}

- (nullable XZToast *)xz_showToast:(XZToast *)toast position:(XZToastPosition)position completion:(nullable XZToastCompletion)completion {
    return [self xz_showToast:toast duration:XZToastDuration position:position exclusive:false completion:completion];
}

- (nullable XZToast *)xz_showToast:(XZToast *)toast exclusive:(BOOL)exclusive completion:(nullable XZToastCompletion)completion {
    return [self xz_showToast:toast duration:XZToastDuration position:(XZToastPositionMiddle) exclusive:exclusive completion:completion];
}

- (nullable XZToast *)xz_showToast:(XZToast *)toast exclusive:(BOOL)exclusive {
    return [self xz_showToast:toast duration:XZToastDuration position:(XZToastPositionMiddle) exclusive:exclusive completion:nil];
}

- (void)xz_hideToast:(void (^)(void))completion {
    [self xz_hideToast:nil completion:completion];
}

@end

@implementation UIApplication (XZToast)

- (XZToast *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion {
    return [self.xz_mainWindow xz_showToast:toast duration:duration position:position exclusive:exclusive completion:completion];
}

- (void)xz_hideToast:(XZToast *)toast completion:(void (^)(void))completion {
    [self.xz_mainWindow xz_hideToast:toast completion:completion];
}

- (void)xz_setNeedsLayoutToasts {
    [self.xz_mainWindow xz_setNeedsLayoutToasts];
}

- (void)xz_layoutToastsIfNeeded {
    [self.xz_mainWindow xz_layoutToastsIfNeeded];
}

- (NSInteger)xz_maximumNumberOfToasts {
    return [self.xz_mainWindow xz_maximumNumberOfToasts];
}

- (void)xz_setMaximumNumberOfToasts:(NSInteger)xz_maximumNumberOfToasts {
    [self.xz_mainWindow xz_setMaximumNumberOfToasts:xz_maximumNumberOfToasts];
}

- (void)xz_setToastOffset:(CGFloat)offset forPosition:(XZToastPosition)position {
    [self.xz_mainWindow xz_setToastOffset:offset forPosition:position];
}

- (CGFloat)xz_toastOffsetForPosition:(XZToastPosition)position {
    return [self.xz_mainWindow xz_toastOffsetForPosition:position];
}

@end

@implementation UIWindow (XZToast)

- (XZToast *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion {
    return [self.rootViewController xz_showToast:toast duration:duration position:position exclusive:exclusive completion:completion];
}

- (void)xz_hideToast:(XZToast *)toast completion:(void (^)(void))completion {
    [self.rootViewController xz_hideToast:toast completion:completion];
}

- (void)xz_setNeedsLayoutToasts {
    [self.rootViewController xz_setNeedsLayoutToasts];
}

- (void)xz_layoutToastsIfNeeded {
    [self.rootViewController xz_layoutToastsIfNeeded];
}

- (NSInteger)xz_maximumNumberOfToasts {
    return [self.rootViewController xz_maximumNumberOfToasts];
}

- (void)xz_setMaximumNumberOfToasts:(NSInteger)xz_maximumNumberOfToasts {
    [self.rootViewController xz_setMaximumNumberOfToasts:xz_maximumNumberOfToasts];
}

- (void)xz_setToastOffset:(CGFloat)offset forPosition:(XZToastPosition)position {
    [self.rootViewController xz_setToastOffset:offset forPosition:position];
}

- (CGFloat)xz_toastOffsetForPosition:(XZToastPosition)position {
    return [self.rootViewController xz_toastOffsetForPosition:position];
}

@end


@implementation UIViewController (XZToast)

- (UIViewController *)xz_toastController {
    return self.presentedViewController ?: self.tabBarController ?: self.navigationController ?: self;
}

- (XZToast *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion {
    return [[XZToastManager managerForViewController:self] showToast:toast duration:duration position:position exclusive:exclusive completion:completion];
}

- (void)xz_hideToast:(XZToast *)toast completion:(void (^)(void))completion {
    [[XZToastManager managerForViewController:self] hideToast:toast completion:completion];
}

- (void)xz_setNeedsLayoutToasts {
    [[XZToastManager managerForViewController:self] setNeedsLayoutToasts];
}

- (void)xz_layoutToastsIfNeeded {
    [[XZToastManager managerForViewController:self] layoutToastsIfNeeded];
}

- (NSInteger)xz_maximumNumberOfToasts {
    return [XZToastManager managerForViewController:self].maximumNumberOfToasts;
}

- (void)xz_setMaximumNumberOfToasts:(NSInteger)xz_maximumNumberOfToasts {
    [XZToastManager managerForViewController:self].maximumNumberOfToasts = xz_maximumNumberOfToasts;
}

- (void)xz_setToastOffset:(CGFloat)offset forPosition:(XZToastPosition)position {
    [XZToastManager managerForViewController:self].offsets[position] = offset;
}

- (CGFloat)xz_toastOffsetForPosition:(XZToastPosition)position {
    return [XZToastManager managerForViewController:self].offsets[position];
}

@end

