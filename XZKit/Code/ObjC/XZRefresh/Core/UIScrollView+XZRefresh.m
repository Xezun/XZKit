//
//  UIScrollView+XZRefresh.m
//  XZRefresh
//
//  Created by Xezun on 2019/10/12.
//  Copyright © 2019 Xezun. All rights reserved.
//

#import "UIScrollView+XZRefresh.h"
#import "XZRefreshManager.h"
#import "XZRuntime.h"

@implementation UIScrollView (XZRefresh)

+ (void)load {
    if (self == [UIScrollView class]) {
        // 让 UIScrollView 支持 XZRefresh
        // 会影响所有的 UIScrollView 及子类，但是由于在 UIScrollView 外，无法监听 adjustedContentInsetDidChange 事件，只能如此处理
        xz_objc_class_addMethodWithBlock(self, @selector(adjustedContentInsetDidChange), NULL, ^(UIScrollView *self) {
            [self xz_setNeedsLayoutRefreshViews];
        }, ^(UIScrollView *self) {
            struct objc_super super = {
                .receiver = self,
                .super_class = class_getSuperclass([UIScrollView class])
            };
            ((void (*)(struct objc_super *, SEL))objc_msgSendSuper)(&super, @selector(adjustedContentInsetDidChange));
            [self.xz_refreshManagerIfLoaded adjustedContentInsetsDidChange:self.adjustedContentInset];
        }, ^id _Nonnull(SEL  _Nonnull const selector) {
            return ^(UIScrollView *self) {
                ((void (*)(id, SEL))objc_msgSend)(self, selector);
                [self.xz_refreshManagerIfLoaded adjustedContentInsetsDidChange:self.adjustedContentInset];
            };
        });
        
        xz_objc_class_addMethodWithBlock(self, @selector(setContentSize:), NULL, nil, ^(UIScrollView *self, CGSize contentSize) {
            struct objc_super super = {
                .receiver = self,
                .super_class = class_getSuperclass([UIScrollView class])
            };
            ((void (*)(struct objc_super *, SEL, CGSize))objc_msgSendSuper)(&super, @selector(setContentSize:), contentSize);
            [self.xz_refreshManagerIfLoaded contentSizeDidChange:contentSize];
        }, ^id _Nonnull(SEL  _Nonnull const selector) {
            return ^(UIScrollView *self, CGSize contentSize) {
                ((void (*)(id, SEL, CGSize))objc_msgSend)(self, selector, contentSize);
                [self.xz_refreshManagerIfLoaded contentSizeDidChange:contentSize];
            };
        });
        
        xz_objc_class_addMethodWithBlock(self, @selector(setFrame:), NULL, nil, ^(UIScrollView *self, CGRect frame) {
            struct objc_super super = {
                .receiver = self,
                .super_class = class_getSuperclass([UIScrollView class])
            };
            ((void (*)(struct objc_super *, SEL, CGRect))objc_msgSendSuper)(&super, @selector(setFrame:), frame);
            [self.xz_refreshManagerIfLoaded sizeDidChange:frame.size];
        }, ^id _Nonnull(SEL  _Nonnull const selector) {
            return ^(UIScrollView *self, CGRect frame) {
                ((void (*)(id, SEL, CGRect))objc_msgSend)(self, selector, frame);
                [self.xz_refreshManagerIfLoaded sizeDidChange:frame.size];
            };
        });
        
        xz_objc_class_addMethodWithBlock(self, @selector(setBounds:), NULL, nil, ^(UIScrollView *self, CGRect bounds) {
            struct objc_super super = {
                .receiver = self,
                .super_class = class_getSuperclass([UIScrollView class])
            };
            ((void (*)(struct objc_super *, SEL, CGRect))objc_msgSendSuper)(&super, @selector(setBounds:), bounds);
            [self.xz_refreshManagerIfLoaded sizeDidChange:bounds.size];
        }, ^id _Nonnull(SEL  _Nonnull const selector) {
            return ^(UIScrollView *self, CGRect bounds) {
                ((void (*)(id, SEL, CGRect))objc_msgSend)(self, selector, bounds);
                [self.xz_refreshManagerIfLoaded sizeDidChange:bounds.size];
            };
        });
        
        xz_objc_class_addMethodWithBlock(self, @selector(setDelegate:), NULL, nil, ^(UIScrollView *self, id<UIScrollViewDelegate> delegate) {
            [self.xz_refreshManagerIfLoaded scrollView:self delegateWillChange:delegate];
            struct objc_super super = {
                .receiver = self,
                .super_class = class_getSuperclass([UIScrollView class])
            };
            ((void (*)(struct objc_super *, SEL, id<UIScrollViewDelegate>))objc_msgSendSuper)(&super, @selector(setDelegate:), delegate);
        }, ^id _Nonnull(SEL  _Nonnull const selector) {
            return ^(UIScrollView *self, id<UIScrollViewDelegate> delegate) {
                [self.xz_refreshManagerIfLoaded scrollView:self delegateWillChange:delegate];
                ((void (*)(id, SEL, id<UIScrollViewDelegate>))objc_msgSend)(self, selector, delegate);
            };
        });
    }
}

- (XZRefreshView *)xz_headerRefreshView {
    return self.xz_refreshManager.headerRefreshView;
}

- (void)xz_setHeaderRefreshView:(XZRefreshView *)xz_headerRefreshView {
    self.xz_refreshManager.headerRefreshView = xz_headerRefreshView;
}

- (XZRefreshView *)xz_footerRefreshView {
    return self.xz_refreshManager.footerRefreshView;
}

- (void)xz_setFooterRefreshView:(XZRefreshView *)xz_footerRefreshView {
    self.xz_refreshManager.footerRefreshView = xz_footerRefreshView;
}

- (XZRefreshView *)xz_headerRefreshViewIfNeeded {
    return self.xz_refreshManagerIfLoaded.headerRefreshViewIfLoaded;
}

- (XZRefreshView *)xz_footerRefreshViewIfNeeded {
    return self.xz_refreshManagerIfLoaded.footerRefreshViewIfLoaded;
}

- (void)xz_setNeedsLayoutRefreshViews {
    [self.xz_refreshManagerIfLoaded setNeedsLayoutRefreshViews];
}

- (void)xz_layoutRefreshViewsIfNeeded {
    [self.xz_refreshManagerIfLoaded layoutRefreshViewsIfNeeded];
}

@end



