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

@implementation XZRefreshContext

- (instancetype)init {
    self = [super init];
    if (self) {
        _state = XZRefreshStatePendinging;
        _needsLayout = NO;
        _isAutomatic = NO;
        _automaticRefreshDistance = 0;
        _frame = CGRectZero;
        _contentOffsetY = 0;
    }
    return self;
}

- (BOOL)needsLayoutForBounds:(CGRect)bounds {
    return NO;
}

- (BOOL)needsLayoutForAxises:(UIScrollView *)scrollView {
    return NO;
}

@end

@implementation XZRefreshHeaderContext

- (instancetype)init {
    self = [super init];
    if (self) {
        // 事件 scrollViewDidScroll 的触发可能比视图布局更早，避免事件发生时，此值不对而判断错了状态。
        _contentOffsetY = -CGFLOAT_MAX;
    }
    return self;
}

- (BOOL)needsLayoutForBounds:(CGRect)bounds {
    if (bounds.origin.x != _bounds.origin.x) {
        return YES;
    }
    if (bounds.size.width != _bounds.size.width) {
        return YES;
    }
    return NO;
}

- (BOOL)needsLayoutForAxises:(UIScrollView *)scrollView {
    CGRect const bounds = scrollView.bounds;
    if (bounds.origin.x != _bounds.origin.x) {
        return YES;
    }
    if (bounds.size.width != _bounds.size.width) {
        return YES;
    }
    
    UIEdgeInsets const adjustedContentInsets = scrollView.adjustedContentInset;
    if (adjustedContentInsets.top != _adjustedContentInsets.top) {
        return YES;
    }
    
    switch (_adjustment) {
        case XZRefreshAdjustmentAutomatic: {
            break;
        }
        case XZRefreshAdjustmentNormal: {
            UIEdgeInsets const contentInsets = scrollView.contentInset;
            if (contentInsets.top != _contentInsets.top) {
                return YES;
            }
            break;
        }
        case XZRefreshAdjustmentNone: {
            break;
        }
    }
    return NO;
}

@end

@implementation XZRefreshFooterContext

- (instancetype)init {
    self = [super init];
    if (self) {
        // 事件 scrollViewDidScroll 的触发可能比视图布局更早，避免事件发生时，此值不对而判断错了状态。
        _contentOffsetY = +CGFLOAT_MAX;
        _needsFollowPageScrollWhileRefreshing = NO;
    }
    return self;
}

- (BOOL)needsLayoutForBounds:(CGRect)bounds {
    if (bounds.origin.x != _bounds.origin.x) {
        return YES;
    }
    if (bounds.size.width != _bounds.size.width) {
        return YES;
    }
    if (bounds.size.height != _bounds.size.height) {
        return YES;
    }
    return NO;
}

- (BOOL)needsLayoutForContentSize:(CGSize)contentSize {
    return contentSize.height != _contentSize.height;
}

- (BOOL)needsLayoutForAxises:(UIScrollView *)scrollView {
    CGRect const bounds = scrollView.bounds;
    if (bounds.origin.x != _bounds.origin.x) {
        return YES;
    }
    if (bounds.size.width != _bounds.size.width) {
        return YES;
    }
    if (bounds.size.height != _bounds.size.height) {
        return YES;
    }
    
    UIEdgeInsets const adjustedContentInsets = scrollView.adjustedContentInset;
    if (adjustedContentInsets.top != _adjustedContentInsets.top) {
        return YES;
    }
    if (adjustedContentInsets.bottom != _adjustedContentInsets.bottom) {
        return YES;
    }
    
    switch (_adjustment) {
        case XZRefreshAdjustmentAutomatic: {
            break;
        }
        case XZRefreshAdjustmentNormal: {
            UIEdgeInsets const contentInsets = scrollView.contentInset;
            if (contentInsets.bottom != _contentInsets.bottom) {
                return YES;
            }
            break;
        }
        case XZRefreshAdjustmentNone: {
            break;
        }
    }
    
    CGSize const contentSize = scrollView.contentSize;
    return contentSize.height != _contentSize.height;
}

@end
