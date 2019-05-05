//
//  XZCarouselView.ItemView.h
//  XZKit
//
//  Created by 徐臻 on 2019/4/25.
//  Copyright © 2019 mlibai. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifdef XZKIT_FRAMEWORK
#import <XZKit/XZCarouselView.h>
#else
#import "XZCarouselView.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class _XZCarouselViewItemView;

@protocol _XZCarouselViewItemViewDelegate <NSObject>
- (void)_XZCarouselViewItemViewWillBeginDragging:(_XZCarouselViewItemView *)itemView;
- (void)_XZCarouselViewItemViewDidEndDragging:(_XZCarouselViewItemView *)itemView willDecelerate:(BOOL)decelerate;
- (void)_XZCarouselViewItemViewDidEndDecelerating:(_XZCarouselViewItemView *)itemView;
- (void)_XZCarouselViewItemViewWillBeginZooming:(_XZCarouselViewItemView *)itemView;
- (void)_XZCarouselViewItemViewDidZoom:(_XZCarouselViewItemView *)itemView;
- (void)_XZCarouselViewItemViewDidEndZooming:(_XZCarouselViewItemView *)itemView atScale:(CGFloat)scale;
@end

/// 单个内容视图的容器，提供了缩放功能。
@interface _XZCarouselViewItemView : UIView <UIScrollViewDelegate>
@property (nonatomic) UIViewContentMode contentMode;
@property (nonatomic, weak) id<_XZCarouselViewItemViewDelegate> delegate;
@property (nonatomic, readonly) NSInteger index;

@property (nonatomic, readonly) CGSize preferredContentSize;
- (void)setPreferredContentSize:(CGSize)preferredSize animated:(BOOL)animated;

@property (nonatomic) BOOL bouncesZoom;
@property (nonatomic, readonly) CGFloat minimumZoomScale;
@property (nonatomic, readonly) CGFloat maximumZoomScale;
- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale maximumZoomScale:(CGFloat)maximumZoomScale;

@property (nonatomic, readonly) CGFloat zoomScale;
- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated;
- (void)setZoomScale:(CGFloat)scale animated:(BOOL)animated;

@property (nonatomic, readonly) CGPoint contentOffset;
- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;

/// 动画作用的视图。
@property (nonatomic, readonly, nonnull) UIView *transitionView;
@property (nonatomic, readonly, nullable) UIView *transitionViewIfLoaded;
/// 收回 transitionView（需先判断是否存在）。
- (void)bringBackTransitionViewIfNeeded;

/// 内容视图，请用提供的三个方法设置内容视图。
@property (nonatomic, readonly, nullable) UIView *contentView;

/// 正值 左边留间距，负值右边留间距。间距作用于 zoomingView 。
@property (nonatomic) CGFloat interitemSpacing;
@property (nonatomic) XZCarouselViewPagingOrientation pagingOrientation;
/// 当前过渡百分比，针对当前视图，非整体进度。用来调整间距，使间距在过渡过程中始终保持一致。
@property (nonatomic) CGFloat transition;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame pagingOrientation:(XZCarouselViewPagingOrientation)pagingOrientation NS_DESIGNATED_INITIALIZER;

- (void)setIndex:(NSInteger)index contentView:(nullable UIView *)contentView preferredContentSize:(CGSize)preferredContentSize zoomScale:(CGFloat)zoomScale contentOffset:(CGPoint)contentOffset;

@end
NS_ASSUME_NONNULL_END
