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

#define XZToastDuration -1.0

@implementation UIResponder (XZToastSupporting)

- (XZToastTask *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion {
    return [self.nextResponder xz_showToast:toast duration:duration position:position exclusive:exclusive completion:completion];
}

- (void)xz_hideToast:(XZToast *)toast completion:(void (^)(void))completion {
    [self.nextResponder xz_hideToast:toast completion:completion];
}

- (XZToastManager *)xz_toastManager {
    return self.nextResponder.xz_toastManager;
}

#pragma mark - 便利方法

- (XZToastTask *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position completion:(nullable XZToastCompletion)completion {
    return [self xz_showToast:toast duration:duration position:position exclusive:false completion:completion];
}

- (XZToastTask *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration exclusive:(BOOL)exclusive completion:(nullable XZToastCompletion)completion {
    return [self xz_showToast:toast duration:duration position:(XZToastPositionMiddle) exclusive:exclusive completion:completion];
}

- (XZToastTask *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration completion:(nullable XZToastCompletion)completion {
    return [self xz_showToast:toast duration:duration position:(XZToastPositionMiddle) exclusive:false completion:completion];
}

- (XZToastTask *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration {
    return [self xz_showToast:toast duration:duration position:(XZToastPositionMiddle) exclusive:false completion:nil];
}

- (XZToastTask *)xz_showToast:(XZToast *)toast completion:(nullable XZToastCompletion)completion {
    return [self xz_showToast:toast duration:XZToastDuration position:(XZToastPositionMiddle) exclusive:false completion:completion];
}

- (XZToastTask *)xz_showToast:(XZToast *)toast {
    return [self xz_showToast:toast duration:XZToastDuration position:(XZToastPositionMiddle) exclusive:false completion:nil];
}

- (XZToastTask *)xz_showToast:(XZToast *)toast position:(XZToastPosition)position {
    return [self xz_showToast:toast duration:XZToastDuration position:position exclusive:false completion:nil];
}

- (XZToastTask *)xz_showToast:(XZToast *)toast position:(XZToastPosition)position completion:(nullable XZToastCompletion)completion {
    return [self xz_showToast:toast duration:XZToastDuration position:position exclusive:false completion:completion];
}

- (XZToastTask *)xz_showToast:(XZToast *)toast exclusive:(BOOL)exclusive completion:(nullable XZToastCompletion)completion {
    return [self xz_showToast:toast duration:XZToastDuration position:(XZToastPositionMiddle) exclusive:exclusive completion:completion];
}

- (XZToastTask *)xz_showToast:(XZToast *)toast exclusive:(BOOL)exclusive {
    return [self xz_showToast:toast duration:XZToastDuration position:(XZToastPositionMiddle) exclusive:exclusive completion:nil];
}

- (void)xz_hideToast:(void (^)(void))completion {
    [self xz_hideToast:nil completion:completion];
}

@end

@implementation UIApplication (XZToastSupporting)

- (XZToastTask *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion {
    return [self.xz_mainWindow xz_showToast:toast duration:duration position:position exclusive:exclusive completion:completion];
}

- (void)xz_hideToast:(XZToast *)toast completion:(void (^)(void))completion {
    [self.xz_mainWindow xz_hideToast:toast completion:completion];
}

- (XZToastManager *)xz_toastManager {
    return self.xz_mainWindow.xz_toastManager;
}

@end


@implementation UIWindow (XZToastSupporting)

- (XZToastTask *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion {
    return [self.rootViewController xz_showToast:toast duration:duration position:position exclusive:exclusive completion:completion];
}

- (void)xz_hideToast:(XZToast *)toast completion:(void (^)(void))completion {
    [self.rootViewController xz_hideToast:toast completion:completion];
}

- (XZToastManager *)xz_toastManager {
    return self.rootViewController.xz_toastManager;
}

@end


@implementation UIViewController (XZToastSupporting)

- (XZToastTask *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion {
    return [self.xz_toastManager showToast:toast duration:duration position:position exclusive:exclusive completion:completion];
}

- (void)xz_hideToast:(XZToast *)toast completion:(void (^)(void))completion {
    [self.xz_toastManager hideToast:toast completion:completion];
}

- (XZToastManager *)xz_toastManager {
    return [XZToastManager managerForViewController:self];
}

@end

