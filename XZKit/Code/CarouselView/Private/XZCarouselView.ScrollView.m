//
//  XZCarouselView.ScrollView.m
//  XZKit
//
//  Created by 徐臻 on 2019/4/25.
//  Copyright © 2019 mlibai. All rights reserved.
//

#import "XZCarouselView.ScrollView.h"

/// 获取视图的布局方向。
static UIUserInterfaceLayoutDirection UIViewGetUserInterfaceLayoutDirection(UIView * const _Nonnull view);

@implementation _XZCarouselViewScrollView

@synthesize itemView0 = _itemView0;
@synthesize itemView4 = _itemView4;
@synthesize prevItemViewVisiable = _isPrevItemViewVisiable;
@synthesize nextItemViewVisiable = _isNextItemViewVisiable;

- (instancetype)initWithFrame:(CGRect)frame carouselView:(XZCarouselView *)carouselView pagingOrientation:(XZCarouselViewPagingOrientation)pagingOrientation {
    self = [super initWithFrame:frame];
    if (self) {
        _carouselView = carouselView;
        [self _XZCarouselViewScrollViewDidInitialize:pagingOrientation];
    }
    return self;
}

- (void)_XZCarouselViewScrollViewDidInitialize:(XZCarouselViewPagingOrientation)pagingOrientation {
    _pagingOrientation = pagingOrientation;
    
    self.alwaysBounceVertical           = (_pagingOrientation == XZCarouselViewPagingOrientationVertical);
    self.alwaysBounceHorizontal         = (_pagingOrientation == XZCarouselViewPagingOrientationHorizontal);
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator   = NO;
    self.pagingEnabled                  = YES;
    
    CGRect const kBounds = self.bounds;
    
    _itemView1 = [[_XZCarouselViewItemView alloc] initWithFrame:kBounds pagingOrientation:_pagingOrientation];
    [self addSubview:_itemView1];
    
    _itemView3 = [[_XZCarouselViewItemView alloc] initWithFrame:kBounds pagingOrientation:_pagingOrientation];
    [self addSubview:_itemView3];
    
    _itemView2 = [[_XZCarouselViewItemView alloc] initWithFrame:kBounds pagingOrientation:_pagingOrientation];
    [self addSubview:_itemView2];
    
    [self _XZCarouselViewScrollViewLayoutItemViews];
}

- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale {
    NSLog(@"设置 XZCarouselView 的 scrollView 支持缩放是无效的。");
}

- (void)setMaximumZoomScale:(CGFloat)maximumZoomScale {
    NSLog(@"设置 XZCarouselView 的 scrollView 支持缩放是无效的。");
}

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate {
    if (delegate == nil || delegate == _carouselView) {
        [super setDelegate:delegate];
    }
}

- (_XZCarouselViewItemView *)itemView0 {
    if (_itemView0 != nil) {
        return _itemView0;
    }
    _itemView0 = [[_XZCarouselViewItemView alloc] initWithFrame:self.bounds pagingOrientation:_pagingOrientation];
    _itemView0.interitemSpacing = _itemView2.interitemSpacing;
    _itemView0.contentMode = _itemView2.contentMode;
    _itemView0.pagingOrientation = _itemView2.pagingOrientation;
    [_itemView0 setMinimumZoomScale:_itemView2.minimumZoomScale maximumZoomScale:_itemView2.maximumZoomScale];
    switch (_itemViewHierarchy) {
        case XZCarouselViewTransitionViewHierarchyCarousel:
            [self insertSubview:_itemView0 atIndex:0];
            break;
        case XZCarouselViewTransitionViewHierarchyInvertedCarousel:
            [self addSubview:_itemView0];
            break;
        case XZCarouselViewTransitionViewHierarchyPageCurl:
            [self addSubview:_itemView0];
            break;
        case XZCarouselViewTransitionViewHierarchyNavigation:
            [self insertSubview:_itemView0 atIndex:0];
            break;
    }
    return _itemView0;
}

- (_XZCarouselViewItemView *)itemView4 {
    if (_itemView4 != nil) {
        return _itemView4;
    }
    _itemView4 = [[_XZCarouselViewItemView alloc] initWithFrame:self.bounds pagingOrientation:_pagingOrientation];
    _itemView4.interitemSpacing = _itemView2.interitemSpacing;
    _itemView4.contentMode = _itemView2.contentMode;
    _itemView4.pagingOrientation = _itemView2.pagingOrientation;
    [_itemView4 setMinimumZoomScale:_itemView2.minimumZoomScale maximumZoomScale:_itemView2.maximumZoomScale];
    switch (_itemViewHierarchy) {
        case XZCarouselViewTransitionViewHierarchyCarousel:
            [self insertSubview:_itemView4 atIndex:0];
            break;
        case XZCarouselViewTransitionViewHierarchyInvertedCarousel:
            [self addSubview:_itemView4];
            break;
        case XZCarouselViewTransitionViewHierarchyPageCurl:
            [self insertSubview:_itemView4 atIndex:0];
            break;
        case XZCarouselViewTransitionViewHierarchyNavigation:
            [self addSubview:_itemView4];
            break;
    }
    return _itemView4;
}

- (void)setItemViewHierarchy:(XZCarouselViewTransitionViewHierarchy)itemViewHierarchy {
    if (_itemViewHierarchy != itemViewHierarchy) {
        _itemViewHierarchy = itemViewHierarchy;
        switch (_itemViewHierarchy) {
            case XZCarouselViewTransitionViewHierarchyCarousel:
                [self bringSubviewToFront:_itemView1];
                [self bringSubviewToFront:_itemView3];
                [self bringSubviewToFront:_itemView2];
                break;
            case XZCarouselViewTransitionViewHierarchyInvertedCarousel:
                [self bringSubviewToFront:_itemView1];
                [self bringSubviewToFront:_itemView3];
                if (_itemView0) { [self bringSubviewToFront:_itemView0]; }
                if (_itemView4) { [self bringSubviewToFront:_itemView4]; }
                break;
            case XZCarouselViewTransitionViewHierarchyPageCurl:
                [self bringSubviewToFront:_itemView3];
                [self bringSubviewToFront:_itemView2];
                [self bringSubviewToFront:_itemView1];
                if (_itemView0) { [self bringSubviewToFront:_itemView0]; }
                break;
            case XZCarouselViewTransitionViewHierarchyNavigation:
                [self bringSubviewToFront:_itemView1];
                [self bringSubviewToFront:_itemView2];
                [self bringSubviewToFront:_itemView3];
                if (_itemView4) { [self bringSubviewToFront:_itemView4]; }
                break;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self _XZCarouselViewScrollViewLayoutItemViews];
}

- (BOOL)setPrevItemViewVisiable:(BOOL)isPrevItemViewVisiable nextItemViewVisiable:(BOOL)isNextItemViewVisiable {
    if (_isPrevItemViewVisiable == isPrevItemViewVisiable && _isNextItemViewVisiable == isNextItemViewVisiable) {
        return NO;
    }
    _isPrevItemViewVisiable = isPrevItemViewVisiable;
    _isNextItemViewVisiable = isNextItemViewVisiable;
    
    CGPoint const oldOffset = _itemView2.frame.origin;
    CGPoint const contentOffset = self.contentOffset;
    
    CGPoint const deltaOffset = CGPointMake(contentOffset.x - oldOffset.x, contentOffset.y - oldOffset.y);
    
    [self _XZCarouselViewScrollViewLayoutItemViews];
    
    CGPoint const newOffset = _itemView2.frame.origin;
    
    if (CGPointEqualToPoint(oldOffset, newOffset)) {
        return NO;
    }
    
    // 不影响滚动。
    self.contentOffset = CGPointMake(newOffset.x + deltaOffset.x, newOffset.y + deltaOffset.y);
    return YES;
}

- (void)setPagingOrientation:(XZCarouselViewPagingOrientation const)pagingOrientation {
    if (_pagingOrientation != pagingOrientation) {
        _pagingOrientation = pagingOrientation;
        [_itemView0 setPagingOrientation:_pagingOrientation];
        [_itemView1 setPagingOrientation:_pagingOrientation];
        [_itemView2 setPagingOrientation:_pagingOrientation];
        [_itemView3 setPagingOrientation:_pagingOrientation];
        [_itemView4 setPagingOrientation:_pagingOrientation];
        self.alwaysBounceVertical = (_pagingOrientation == XZCarouselViewPagingOrientationVertical);
        self.alwaysBounceHorizontal = (_pagingOrientation == XZCarouselViewPagingOrientationHorizontal);
        [self _XZCarouselViewScrollViewLayoutItemViews];
        // 重置滚动位置到 2 ，并结束所有滚动。
        [self setContentOffset:_itemView2.frame.origin animated:NO];
    }
}

- (void)_XZCarouselViewScrollViewLayoutItemViews {
    CGRect const kBounds = self.bounds;
    
    switch (_pagingOrientation) {
        case XZCarouselViewPagingOrientationHorizontal:
            switch (UIViewGetUserInterfaceLayoutDirection(self)) {
                case UIUserInterfaceLayoutDirectionLeftToRight:
                    if (_isPrevItemViewVisiable && _isNextItemViewVisiable) {
                        _itemView0.frame = CGRectMake(kBounds.size.width * -1, 0, kBounds.size.width, kBounds.size.height);
                        _itemView1.frame = CGRectMake(kBounds.size.width * +0, 0, kBounds.size.width, kBounds.size.height);
                        _itemView2.frame = CGRectMake(kBounds.size.width * +1, 0, kBounds.size.width, kBounds.size.height);
                        _itemView3.frame = CGRectMake(kBounds.size.width * +2, 0, kBounds.size.width, kBounds.size.height);
                        _itemView4.frame = CGRectMake(kBounds.size.width * +3, 0, kBounds.size.width, kBounds.size.height);
                        [self setContentSize:CGSizeMake(kBounds.size.width * 3.0, kBounds.size.height)]; // 可能会触发 scrollViewDidScroll: 方法。
                    } else if (_isPrevItemViewVisiable) {
                        _itemView0.frame = CGRectMake(kBounds.size.width * -1, 0, kBounds.size.width, kBounds.size.height);
                        _itemView1.frame = CGRectMake(kBounds.size.width * +0, 0, kBounds.size.width, kBounds.size.height);
                        _itemView2.frame = CGRectMake(kBounds.size.width * +1, 0, kBounds.size.width, kBounds.size.height);
                        _itemView3.frame = CGRectMake(kBounds.size.width * +2, 0, kBounds.size.width, kBounds.size.height);
                        _itemView4.frame = CGRectMake(kBounds.size.width * +3, 0, kBounds.size.width, kBounds.size.height);
                        [self setContentSize:CGSizeMake(kBounds.size.width * 2.0, kBounds.size.height)];
                    } else {
                        _itemView0.frame = CGRectMake(kBounds.size.width * -2, 0, kBounds.size.width, kBounds.size.height);
                        _itemView1.frame = CGRectMake(kBounds.size.width * -1, 0, kBounds.size.width, kBounds.size.height);
                        _itemView2.frame = CGRectMake(kBounds.size.width * +0, 0, kBounds.size.width, kBounds.size.height);
                        _itemView3.frame = CGRectMake(kBounds.size.width * +1, 0, kBounds.size.width, kBounds.size.height);
                        _itemView4.frame = CGRectMake(kBounds.size.width * +2, 0, kBounds.size.width, kBounds.size.height);
                        [self setContentSize:(_isNextItemViewVisiable ? CGSizeMake(kBounds.size.width * 2.0, kBounds.size.height) : kBounds.size)];
                    }
                    break;
                    
                case UIUserInterfaceLayoutDirectionRightToLeft:
                    if (_isPrevItemViewVisiable && _isNextItemViewVisiable) {
                        _itemView4.frame = CGRectMake(kBounds.size.width * -1, 0, kBounds.size.width, kBounds.size.height);
                        _itemView3.frame = CGRectMake(kBounds.size.width * +0, 0, kBounds.size.width, kBounds.size.height);
                        _itemView2.frame = CGRectMake(kBounds.size.width * +1, 0, kBounds.size.width, kBounds.size.height);
                        _itemView1.frame = CGRectMake(kBounds.size.width * +2, 0, kBounds.size.width, kBounds.size.height);
                        _itemView0.frame = CGRectMake(kBounds.size.width * +3, 0, kBounds.size.width, kBounds.size.height);
                        [self setContentSize:CGSizeMake(kBounds.size.width * 3.0, kBounds.size.height)];
                    } else if (_isPrevItemViewVisiable) {
                        _itemView4.frame = CGRectMake(kBounds.size.width * -1, 0, kBounds.size.width, kBounds.size.height);
                        _itemView3.frame = CGRectMake(kBounds.size.width * +0, 0, kBounds.size.width, kBounds.size.height);
                        _itemView2.frame = CGRectMake(kBounds.size.width * +1, 0, kBounds.size.width, kBounds.size.height);
                        _itemView1.frame = CGRectMake(kBounds.size.width * +2, 0, kBounds.size.width, kBounds.size.height);
                        _itemView0.frame = CGRectMake(kBounds.size.width * +3, 0, kBounds.size.width, kBounds.size.height);
                        [self setContentSize:CGSizeMake(kBounds.size.width * 2.0, kBounds.size.height)];
                    } else {
                        _itemView4.frame = CGRectMake(kBounds.size.width * -2, 0, kBounds.size.width, kBounds.size.height);
                        _itemView3.frame = CGRectMake(kBounds.size.width * -1, 0, kBounds.size.width, kBounds.size.height);
                        _itemView2.frame = CGRectMake(kBounds.size.width * +0, 0, kBounds.size.width, kBounds.size.height);
                        _itemView1.frame = CGRectMake(kBounds.size.width * +1, 0, kBounds.size.width, kBounds.size.height);
                        _itemView0.frame = CGRectMake(kBounds.size.width * +2, 0, kBounds.size.width, kBounds.size.height);
                        [self setContentSize:(_isNextItemViewVisiable ? CGSizeMake(kBounds.size.width, kBounds.size.height * 2.0) : kBounds.size)];
                    }
                    break;
            }
            break;
            
        case XZCarouselViewPagingOrientationVertical:
            if (_isPrevItemViewVisiable && _isNextItemViewVisiable) {
                [self setContentSize:CGSizeMake(kBounds.size.width, kBounds.size.height * 3.0)];
                _itemView0.frame = CGRectMake(0, kBounds.size.height * -1, kBounds.size.width, kBounds.size.height);
                _itemView1.frame = CGRectMake(0, kBounds.size.height * +0, kBounds.size.width, kBounds.size.height);
                _itemView2.frame = CGRectMake(0, kBounds.size.height * +1, kBounds.size.width, kBounds.size.height);
                _itemView3.frame = CGRectMake(0, kBounds.size.height * +2, kBounds.size.width, kBounds.size.height);
                _itemView4.frame = CGRectMake(0, kBounds.size.height * +3, kBounds.size.width, kBounds.size.height);
            } else if (_isPrevItemViewVisiable) {
                [self setContentSize:CGSizeMake(kBounds.size.width, kBounds.size.height * 2.0)];
                _itemView0.frame = CGRectMake(0, kBounds.size.height * -1, kBounds.size.width, kBounds.size.height);
                _itemView1.frame = CGRectMake(0, kBounds.size.height * +0, kBounds.size.width, kBounds.size.height);
                _itemView2.frame = CGRectMake(0, kBounds.size.height * +1, kBounds.size.width, kBounds.size.height);
                _itemView3.frame = CGRectMake(0, kBounds.size.height * +2, kBounds.size.width, kBounds.size.height);
                _itemView4.frame = CGRectMake(0, kBounds.size.height * +3, kBounds.size.width, kBounds.size.height);
            } else {
                [self setContentSize:(_isNextItemViewVisiable ? CGSizeMake(kBounds.size.width, kBounds.size.height * 2.0) : kBounds.size)];
                _itemView0.frame = CGRectMake(0, kBounds.size.height * -2, kBounds.size.width, kBounds.size.height);
                _itemView1.frame = CGRectMake(0, kBounds.size.height * -1, kBounds.size.width, kBounds.size.height);
                _itemView2.frame = CGRectMake(0, kBounds.size.height * +0, kBounds.size.width, kBounds.size.height);
                _itemView3.frame = CGRectMake(0, kBounds.size.height * +1, kBounds.size.width, kBounds.size.height);
                _itemView4.frame = CGRectMake(0, kBounds.size.height * +2, kBounds.size.width, kBounds.size.height);
            }
            break;
    }
}

- (void)updateTransitionForItemViews:(CGFloat const)transition {
    if (_pagingOrientation == XZCarouselViewPagingOrientationVertical || UIViewGetUserInterfaceLayoutDirection(self) == UIUserInterfaceLayoutDirectionLeftToRight) {
        _itemView0.transition = -(2.0 + transition);
        _itemView1.transition = -(1.0 + transition);
        _itemView2.transition = -transition;
        _itemView3.transition = +(1.0 - transition);
        _itemView4.transition = +(2.0 - transition);
    } else {
        _itemView0.transition = +(2.0 + transition);
        _itemView1.transition = +(1.0 + transition);
        _itemView2.transition = +transition;
        _itemView3.transition = -(1.0 - transition);
        _itemView4.transition = -(2.0 - transition);
    }
}

@end


UIUserInterfaceLayoutDirection UIViewGetUserInterfaceLayoutDirection(UIView * const view) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0
    if (@available(iOS 10.0, *)) {
        return view.effectiveUserInterfaceLayoutDirection;
    }
    if (@available(iOS 9.0, *)) {
        return [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:view.semanticContentAttribute];
    }
    return UIApplication.sharedApplication.userInterfaceLayoutDirection;
#elif __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_10_0
    if (@available(iOS 10.0, *)) {
        return view.effectiveUserInterfaceLayoutDirection;
    }
    return [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:view.semanticContentAttribute];
#else
    return view.effectiveUserInterfaceLayoutDirection;
#endif
}
