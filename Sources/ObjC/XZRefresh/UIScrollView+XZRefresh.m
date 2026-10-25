//
//  UIScrollView+XZRefresh.m
//  XZRefresh
//
//  Created by Xezun on 2019/10/12.
//  Copyright © 2019 Xezun. All rights reserved.
//

#import "UIScrollView+XZRefresh.h"
#import "XZRefreshManager.h"

@implementation UIScrollView (XZRefresh)

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



