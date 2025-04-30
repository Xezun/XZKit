//
//  UIKit+XZToast.m
//  XZToast
//
//  Created by 徐臻 on 2025/4/29.
//

#import "UIKit+XZToast.h"
#import "XZToast.h"
#import "XZToastItem.h"
#import "XZToastManager.h"
@import ObjectiveC;

static UIWindow *mainWindow(void) {
    UIWindow *window = nil;
    if ([UIApplication.sharedApplication.delegate respondsToSelector:@selector(window)]) {
        window = UIApplication.sharedApplication.delegate.window;
    }
    if (window == nil) {
        for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
            id<UIWindowSceneDelegate> const delegate = (id)scene.delegate;
            if ([delegate conformsToProtocol:@protocol(UIWindowSceneDelegate)]) {
                window = delegate.window;
                break;
            }
        }
    }
    return window;
}

@implementation UIResponder (XZToast)

- (void)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(NSDirectionalRectEdge)position offset:(CGFloat)offset isExclusive:(BOOL)isExclusive completion:(void (^)(BOOL))completion {
    [mainWindow() xz_showToast:toast duration:duration position:position offset:offset isExclusive:isExclusive completion:completion];
}

- (void)xz_hideToast:(void (^)(BOOL))completion {
    [mainWindow() xz_hideToast:completion];
}

- (void)xz_showToast:(XZToast *)toast {
    [self xz_showToast:toast duration:3.0 position:(NSDirectionalRectEdgeBottom) offset:0 isExclusive:false completion:nil];
}

@end

@implementation UIView (XZToast)

- (void)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(NSDirectionalRectEdge)position offset:(CGFloat)offset isExclusive:(BOOL)isExclusive completion:(void (^)(BOOL))completion {
    [self.nextResponder xz_showToast:toast duration:duration position:position offset:offset isExclusive:isExclusive completion:completion];
}

- (void)xz_hideToast:(void (^)(BOOL))completion {
    [self.nextResponder xz_hideToast:completion];
}

@end


@implementation UIWindow (XZToast)

- (void)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(NSDirectionalRectEdge)position offset:(CGFloat)offset isExclusive:(BOOL)isExclusive completion:(void (^)(BOOL))completion {
    [self.rootViewController xz_showToast:toast duration:duration position:position offset:offset isExclusive:isExclusive completion:completion];
}

- (void)xz_hideToast:(void (^)(BOOL))completion {
    [self.rootViewController xz_hideToast:completion];
}

@end


@implementation UIViewController (XZToast)

- (void)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(NSDirectionalRectEdge)position offset:(CGFloat)offset isExclusive:(BOOL)isExclusive completion:(void (^)(BOOL))completion {
    XZToastItem *item = [[XZToastItem alloc] initWithToastView:toast.contentView duration:duration position:position offset:offset isExclusive:isExclusive completion:completion];
    [[XZToastManager managerForViewController:self] showToast:item];
}

- (void)xz_hideToast:(void (^)(BOOL))completion {
    [XZToastManager managerForViewController:self];
}

@end



