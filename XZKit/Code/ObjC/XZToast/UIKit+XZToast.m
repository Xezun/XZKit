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

- (XZToast *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion {
    return [UIApplication.sharedApplication.xz_mainWindow xz_showToast:toast duration:duration position:position exclusive:exclusive completion:completion];
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
    return [self xz_showToast:toast duration:3.0 position:(XZToastPositionMiddle) exclusive:false completion:completion];
}

- (XZToast *)xz_showToast:(XZToast *)toast {
    return [self xz_showToast:toast duration:3.0 position:(XZToastPositionMiddle) exclusive:false completion:nil];
}

- (void)xz_hideToast:(XZToast *)toast completion:(void (^)(void))completion {
    [UIApplication.sharedApplication.xz_mainWindow xz_hideToast:toast completion:completion];
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

- (void)xz_setOffset:(CGFloat)offset forToastInPosition:(XZToastPosition)position {
    [UIApplication.sharedApplication.xz_mainWindow xz_setOffset:offset forToastInPosition:position];
}

- (CGFloat)xz_offsetForToastInPosition:(XZToastPosition)position {
    return [UIApplication.sharedApplication.xz_mainWindow xz_offsetForToastInPosition:position];
}

@end

@implementation UIView (XZToast)

- (XZToast *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion {
    return [self.nextResponder xz_showToast:toast duration:duration position:position exclusive:exclusive completion:completion];
}

- (void)xz_hideToast:(XZToast *)toast completion:(void (^)(void))completion {
    [self.nextResponder xz_hideToast:toast completion:completion];
}

@end


@implementation UIWindow (XZToast)

- (XZToast *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion {
    return [self.rootViewController xz_showToast:toast duration:duration position:position exclusive:exclusive completion:completion];
}

- (void)xz_hideToast:(XZToast *)toast completion:(void (^)(void))completion {
    [self.rootViewController xz_hideToast:toast completion:completion];
}

@end


@implementation UIViewController (XZToast)

- (XZToast *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(XZToastCompletion)completion {
    NSParameterAssert(duration >= 0 && duration < DISPATCH_TIME_FOREVER);
    return [[XZToastManager managerForViewController:self] showToast:toast duration:duration position:position exclusive:exclusive completion:completion];
}

- (void)xz_hideToast:(XZToast *)toast completion:(void (^)(void))completion {
    [[XZToastManager managerForViewController:self] hideToast:toast completion:completion];
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

- (void)xz_setToastOffset:(CGFloat)offset forPosition:(XZToastPosition)position {
    [XZToastManager managerForViewController:self].offsets[position] = offset;
}

- (CGFloat)xz_offsetForToastInPosition:(XZToastPosition)position {
    return [XZToastManager managerForViewController:self].offsets[position];
}

@end



