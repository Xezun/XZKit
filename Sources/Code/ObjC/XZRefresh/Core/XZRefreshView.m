//
//  XZRefreshView.m
//  XZRefresh
//
//  Created by Xezun on 2023/8/10.
//

#import "XZRefreshView.h"
#import "XZRefreshManager.h"
#import "UIScrollView+XZRefresh.h"
#import "XZRefreshStyle1View.h"
#import "XZRefreshStyle2View.h"

static Class _defaultHeaderClass = Nil;
static Class _defaultFooterClass = Nil;

@interface XZRefreshView () {
    // 由 manager 主动赋值
    XZRefreshManager * __weak _refreshManager;
}

@end

@implementation XZRefreshView

+ (Class)defaultHeaderClass {
    return _defaultHeaderClass ?: [XZRefreshStyle1View class];
}

+ (void)setDefaultHeaderClass:(Class)defaultHeaderClass {
    NSParameterAssert(defaultHeaderClass == nil || ([defaultHeaderClass isSubclassOfClass:[XZRefreshView class]] && defaultHeaderClass != [XZRefreshView class]));
    _defaultHeaderClass = defaultHeaderClass;
}

+ (Class)defaultFooterClass {
    return _defaultFooterClass ?: [XZRefreshStyle2View class];
}

+ (void)setDefaultFooterClass:(Class)defaultFooterClass {
    NSParameterAssert(defaultFooterClass == nil || ([defaultFooterClass isSubclassOfClass:[XZRefreshView class]] && defaultFooterClass != [XZRefreshView class]));
    _defaultFooterClass = defaultFooterClass;
}

@synthesize refreshHeight = _refreshHeight;

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, 320.0, XZRefreshHeight)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _refreshHeight = XZRefreshHeight;
        _adjustment = XZRefreshAdjustmentAutomatic;
        _automaticRefreshDistance = 0;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _refreshHeight = XZRefreshHeight;
        _adjustment = XZRefreshAdjustmentAutomatic;
        _automaticRefreshDistance = 0;
    }
    return self;
}

- (UIScrollView *)scrollView {
    return _refreshManager.scrollView;
}

- (void)setAdjustment:(XZRefreshAdjustment)adjustment {
    if (_adjustment != adjustment) {
        _adjustment = adjustment;
        [_refreshManager setNeedsLayoutRefreshViews];
    }
}

- (BOOL)isRefreshing {
    return [_refreshManager isRefreshViewAnimating:self];
}

- (void)setRefreshing:(BOOL)isRefreshing {
    [self setRefreshing:isRefreshing animated:YES];
}

- (void)setRefreshing:(BOOL)isRefreshing animated:(BOOL)animated {
    if (isRefreshing) {
        [self beginRefreshing:animated];
    } else {
        [self endRefreshing:animated];
    }
}

- (void)setOffset:(CGFloat)offset {
    if (_offset != offset) {
        _offset = offset;
        [_refreshManager setNeedsLayoutRefreshViews];
    }
}

- (void)beginRefreshing:(BOOL)animated completion:(nullable void (^)(BOOL))completion {
    [_refreshManager refreshingView:self beginAnimating:animated completion:completion];
}

- (void)beginRefreshing:(BOOL)animated {
    [self beginRefreshing:animated completion:nil];
}

- (void)endRefreshing:(BOOL)animated completion:(nullable void (^)(BOOL))completion {
    [_refreshManager refreshingView:self endAnimating:animated completion:completion];
}

- (void)endRefreshing:(BOOL)animated {
    [self endRefreshing:animated completion:nil];
}

- (void)setRefreshHeight:(CGFloat)height {
    if (_refreshHeight != height) {
        _refreshHeight = MAX(0, height);
        [_refreshManager setNeedsLayoutRefreshViews];
    }
}

- (void)scrollView:(UIScrollView *)scrollView didScrollRefreshing:(CGFloat)distance {
    
}

- (BOOL)scrollView:(UIScrollView *)scrollView shouldBeginRefreshing:(CGFloat)distance {
    return (distance >= self.refreshHeight);
}

- (void)scrollView:(UIScrollView *)scrollView didBeginRefreshing:(BOOL)animated {
    // Configure the refreshing animation.
}

- (void)scrollView:(UIScrollView *)scrollView willEndRefreshing:(BOOL)animated {
    
}

- (void)scrollView:(UIScrollView *)scrollView didEndRefreshing:(BOOL)animated {
    
}

@end


@implementation XZRefreshView (XZRefreshManager)

- (void)setRefreshManager:(XZRefreshManager * _Nullable)refreshManager {
    _refreshManager = refreshManager;
}

- (XZRefreshManager *)refreshManager {
    return _refreshManager;
}

@end
