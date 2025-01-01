//
//  XZCarouselView.ItemView.h
//  XZKit
//
//  Created by Xezun on 2019/4/25.
//  Copyright © 2019 XEZUN INC. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifdef XZKIT_FRAMEWORK
#import <XZKit/XZCarouselView.h>
#else
#import "XZCarouselView.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class _XZCarouselViewItemView;

/// _XZCarouselViewItemView 的缩放拖动事件协议。
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
/// 该属性已被重写，原有的功能被屏蔽，现在只起记录作用，并在调整布局时通过此属性的值来优化布局。
@property (nonatomic) UIViewContentMode contentMode;
/// 事件代理。
@property (nonatomic, weak) id<_XZCarouselViewItemViewDelegate> delegate;
/// 当前容器所显示的内容的索引。
@property (nonatomic, readonly) NSInteger index;

/// 偏好大小。默认为 contentView 设置时的大小。
@property (nonatomic, readonly) CGSize preferredContentSize;
/// 更新偏好大小。
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

/// 自定义过渡动画作用在此上视图，该视图直接添加到当前视图上。懒加载。
@property (nonatomic, readonly, nonnull) UIView *transitionView;
@property (nonatomic, readonly, nullable) UIView *transitionViewIfLoaded;
- (void)bringBackTransitionViewIfNeeded;

/// 内容视图，改变该属性，请用设置方法。
@property (nonatomic, readonly, nullable) UIView *contentView;

/// 正值 左边留间距，负值右边留间距。间距作用于 zoomingView 。
@property (nonatomic) CGFloat interitemSpacing;
@property (nonatomic) XZCarouselViewOrientation pagingOrientation;
/// 当前过渡百分比，针对当前视图，非整体进度。用来调整间距，使间距在过渡过程中始终保持一致。
@property (nonatomic) CGFloat transition;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame pagingOrientation:(XZCarouselViewOrientation)pagingOrientation NS_DESIGNATED_INITIALIZER;

- (void)setIndex:(NSInteger)index contentView:(nullable UIView *)contentView preferredContentSize:(CGSize)preferredContentSize zoomScale:(CGFloat)zoomScale contentOffset:(CGPoint)contentOffset;

@end
NS_ASSUME_NONNULL_END
