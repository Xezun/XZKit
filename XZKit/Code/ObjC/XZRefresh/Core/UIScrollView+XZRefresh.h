//
//  UIScrollView+XZRefresh.h
//  XZRefresh
//
//  Created by Xezun on 2019/10/12.
//  Copyright © 2019 Xezun. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZRefreshDefines.h>
#else
#import "XZRefreshDefines.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (XZRefresh)

/// 头部刷新视图。
/// > 懒加载，默认为 Style1 刷新样式。
@property (nonatomic, strong, null_resettable, setter=xz_setHeaderRefreshView:) __kindof XZRefreshView *xz_headerRefreshView NS_SWIFT_NAME(headerRefreshView);

/// 尾部刷新视图。
/// > 懒加载，默认为 Style2 刷新样式。
@property (nonatomic, strong, null_resettable, setter=xz_setFooterRefreshView:) __kindof XZRefreshView *xz_footerRefreshView NS_SWIFT_NAME(footerRefreshView);

/// 头部刷新视图，非懒加载。
@property (nonatomic, strong, nullable, readonly) __kindof XZRefreshView *xz_headerRefreshViewIfNeeded NS_SWIFT_NAME(headerRefreshViewIfNeeded);

/// 尾部刷新视图，非懒加载。
@property (nonatomic, strong, nullable, readonly) __kindof XZRefreshView *xz_footerRefreshViewIfNeeded NS_SWIFT_NAME(footerRefreshViewIfNeeded);

/// 标记需要调整头部与尾部刷新视图的布局。
- (void)xz_setNeedsLayoutRefreshViews NS_SWIFT_NAME(setNeedsLayoutRefreshViews());

/// 如果已标记，则立即调整头部与尾部刷新视图的布局。
- (void)xz_layoutRefreshViewsIfNeeded NS_SWIFT_NAME(layoutRefreshViewsIfNeeded());

@end

NS_ASSUME_NONNULL_END
