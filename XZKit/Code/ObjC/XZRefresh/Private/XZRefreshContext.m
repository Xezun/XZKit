//
//  XZRefreshContext.m
//  XZRefresh
//
//  Created by Xezun on 2023/8/12.
//

#import "XZRefreshContext.h"
#import "XZRefreshView.h"
#import "UIScrollView+XZRefresh.h"
#import "XZRefreshDefines.h"

@interface XZRefreshHeaderContext : XZRefreshContext
@end

@interface XZRefreshFooterContext : XZRefreshContext
@end

@interface XZRefreshContext () {
    @package
    XZRefreshAdjustment   _adjustment;
    XZRefreshState        _state;
    CGFloat               _refreshHeight;
    CGFloat               _contentOffsetY;
    UIScrollView * __weak _scrollView;
}
- (instancetype)initWithScrollView:(UIScrollView *)scrollView NS_DESIGNATED_INITIALIZER;
@end

@implementation XZRefreshContext

+ (XZRefreshContext *)headerContextForScrollView:(UIScrollView *)scrollView {
    return [[XZRefreshHeaderContext alloc] initWithScrollView:scrollView];
}

+ (XZRefreshContext *)footerContextForScrollView:(UIScrollView *)scrollView {
    return [[XZRefreshFooterContext alloc] initWithScrollView:scrollView];
}

+ (instancetype)contextWithScrollView:(UIScrollView *)scrollView {
    return [[self alloc] initWithScrollView:scrollView];
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView {
    self = [super init];
    if (self) {
        _scrollView = scrollView;
        _state = XZRefreshStatePendinging;
        _needsAnimatedTransitioning = NO;
    }
    return self;
}

@end

@implementation XZRefreshHeaderContext

- (instancetype)initWithScrollView:(UIScrollView *)scrollView {
    self = [super initWithScrollView:scrollView];
    if (self) {
        // 事件 scrollViewDidScroll 的触发可能比视图布局更早，避免事件发生时，此值不对而判断错了状态。
        _contentOffsetY = -CGFLOAT_MAX;
    }
    return self;
}

@end

@implementation XZRefreshFooterContext

- (instancetype)initWithScrollView:(UIScrollView *)scrollView {
    self = [super initWithScrollView:scrollView];
    if (self) {
        // 事件 scrollViewDidScroll 的触发可能比视图布局更早，避免事件发生时，此值不对而判断错了状态。
        _contentOffsetY = +CGFLOAT_MAX;
    }
    return self;
}

@end
