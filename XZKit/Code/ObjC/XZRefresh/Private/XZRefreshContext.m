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

- (UIEdgeInsets)layoutInsets {
    NSString *reason = @"应该使用 XZRefreshContext 的子类";
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
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

- (UIEdgeInsets)layoutInsets {
    switch (_adjustment) {
        case XZRefreshAdjustmentAutomatic: {
            return _scrollView.adjustedContentInset;
        }
        case XZRefreshAdjustmentNormal: {
            return _scrollView.contentInset;
        }
        case XZRefreshAdjustmentNone: {
            switch (_state) {
                case XZRefreshStateRefreshing:
                case XZRefreshStateWillRecovering:
                    return UIEdgeInsetsMake(_refreshHeight, 0, 0, 0);
                default:
                    return UIEdgeInsetsZero;
            }
            break;
        }
        default: {
            NSString *reason = [NSString stringWithFormat:@"属性 adjustment 的值错误：%ld", (long)_adjustment];
            @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
        }
    }
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

- (UIEdgeInsets)layoutInsets {
    switch (_adjustment) {
        case XZRefreshAdjustmentAutomatic: {
            return _scrollView.adjustedContentInset;
        }
        case XZRefreshAdjustmentNormal: {
            return _scrollView.contentInset;
        }
        case XZRefreshAdjustmentNone: {
            switch (_state) {
                case XZRefreshStateRefreshing:
                case XZRefreshStateWillRecovering:
                    return UIEdgeInsetsMake(0, 0, _refreshHeight, 0);
                default:
                    return UIEdgeInsetsZero;
            }
            break;
        }
        default: {
            NSString *reason = [NSString stringWithFormat:@"属性 adjustment 的值错误：%ld", (long)_adjustment];
            @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
        }
    }
}

@end
