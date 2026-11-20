//
//  UIScrollView+XZRefresh.m
//  XZRefresh
//
//  Created by Xezun on 2019/10/12.
//  Copyright © 2019 Xezun. All rights reserved.
//

#import "UIScrollView+XZRefresh.h"
#import "XZRefreshManager.h"
#import "XZRefreshStyle1View.h"
#import "XZRefreshStyle2View.h"

static Class _headerRefreshClass = Nil;
static Class _footerRefreshClass = Nil;

@implementation UIScrollView (XZRefresh)

+ (Class)xz_headerRefreshClass {
    return _headerRefreshClass ?: [XZRefreshStyle1View class];
}

+ (void)xz_setHeaderRefreshClass:(Class const)headerRefreshClass {
    NSParameterAssert(headerRefreshClass == nil || ([headerRefreshClass isSubclassOfClass:[XZRefreshView class]] && headerRefreshClass != [XZRefreshView class]));
    _headerRefreshClass = headerRefreshClass;
}

+ (Class)xz_footerRefreshClass {
    return _footerRefreshClass ?: [XZRefreshStyle2View class];
}

+ (void)xz_setFooterRefreshClass:(Class const)footerRefreshClass {
    NSParameterAssert(footerRefreshClass == nil || ([footerRefreshClass isSubclassOfClass:[XZRefreshView class]] && footerRefreshClass != [XZRefreshView class]));
    _footerRefreshClass = footerRefreshClass;
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

- (XZRefreshView *)xz_headerRefreshViewIfLoaded {
    return self.xz_refreshManagerIfLoaded.headerRefreshViewIfLoaded;
}

- (XZRefreshView *)xz_footerRefreshViewIfLoaded {
    return self.xz_refreshManagerIfLoaded.footerRefreshViewIfLoaded;
}

- (void)xz_setNeedsLayoutRefreshViews {
    [self.xz_refreshManagerIfLoaded setNeedsLayoutRefreshViews];
}

- (void)xz_layoutRefreshViewsIfNeeded {
    [self.xz_refreshManagerIfLoaded layoutRefreshViewsIfNeeded];
}

@end



