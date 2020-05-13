//
//  XZRedirection.m
//  XZKit
//
//  Created by mlibai on 2018/6/12.
//  Copyright © 2018年 mlibai. All rights reserved.
//

#import "XZAppRedirection.h"
#import <objc/runtime.h>
#import <XZKit/XZKitDefines.h>

static const void * const _redirection = &_redirection;
static const void * const _isAppearing = &_isAppearing;

@implementation UIViewController (XZAppRedirection)

+ (void)load {
    // 使用 dispatch_once ，是为了避免意外情况，但是从 load 设计角度看，此举没有必要。
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = [UIViewController class];
        
        // viewDidAppear
        Method m21 = class_getInstanceMethod(cls, @selector(viewDidAppear:));
        Method m22 = class_getInstanceMethod(cls, @selector(_XZAppRedirectionViewDidAppear:));
        method_exchangeImplementations(m21, m22);
        
        // viewWillDisappear
        Method m41 = class_getInstanceMethod(cls, @selector(viewWillDisappear:));
        Method m42 = class_getInstanceMethod(cls, @selector(_XZAppRedirectionViewWillDisappear:));
        method_exchangeImplementations(m41, m42);
    });
}

- (void)_XZAppRedirectionViewDidAppear:(BOOL)animated {
    // isAppearing
    objc_setAssociatedObject(self, _isAppearing, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _XZAppRedirectionViewDidAppear:animated];
    // 视图显示后，处理重定向信息。
    // 在自定义了转场动画的导航控制器中，如果在 viewDidAppear 中直接 push 的话，会导致转场动画丢失，
    // 甚至导致 tabBar 的显示也不正常，而且根据转场顺序，viewDidAppear 是在转场完成前执行，因此不适合执行重定向任务。
    // 而且 xz_isAppearing 逻辑与本方法的先后执行顺序也不一定，所以这里使用异步执行。
    dispatch_async(dispatch_get_main_queue(), ^{
        [self xz_redirectIfNeeded];
    });
}


- (void)_XZAppRedirectionViewWillDisappear:(BOOL)animated {
    // isAppearing
    objc_setAssociatedObject(self, _isAppearing, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _XZAppRedirectionViewWillDisappear:animated];
}


#pragma mark - 公开方法

- (BOOL)xz_isAppearing {
    return [objc_getAssociatedObject(self, _isAppearing) boolValue];
}

- (void)xz_setNeedsRedirectWithRedirection:(id)redirection {
    id oldValue = objc_getAssociatedObject(self, _redirection);
    
    objc_setAssociatedObject(self, _redirection, redirection, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 取消了重定向。
    if (redirection == nil) {
        return;
    }
    
    // 如果已经有重定向。
    if (oldValue != nil) {
        return;
    }
    
    // 控制器正在显示中，异步执行。
    if ([self xz_isAppearing]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self xz_redirectIfNeeded];
        });
    }
}

- (void)xz_redirectIfNeeded {
    // 获取重定向信息。
    id redirection = objc_getAssociatedObject(self, _redirection);
    
    // 没有重定向信息。
    if (redirection == nil) {
        return;
    }
    
    // 控制器显示中。
    if ([self xz_isAppearing]) {
        // 移除当前控制器的重定向任务。
        objc_setAssociatedObject(self, _redirection, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        // 执行重定向。
        UIViewController *nextVC = [self xz_didRecevieRedirection:redirection];
        // 转发重定向。
        [nextVC xz_setNeedsRedirectWithRedirection:redirection];
    }
}

- (UIViewController *)xz_didRecevieRedirection:(id)redirection {
    return self.childViewControllers.firstObject ?: self.presentedViewController;
}

@end
