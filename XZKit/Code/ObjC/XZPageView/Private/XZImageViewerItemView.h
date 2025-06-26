//
//  XZImageViewerItemView.h
//  XZKit
//
//  Created by 徐臻 on 2025/6/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XZImageViewerItemView;

/// XZImageViewerItemView 的缩放拖动事件协议。
@protocol XZImageViewerItemViewDelegate <NSObject>
- (void)XZImageViewerItemViewWillBeginDragging:(XZImageViewerItemView *)itemView;
- (void)XZImageViewerItemViewDidEndDragging:(XZImageViewerItemView *)itemView willDecelerate:(BOOL)decelerate;
- (void)XZImageViewerItemViewDidEndDecelerating:(XZImageViewerItemView *)itemView;
- (void)XZImageViewerItemViewWillBeginZooming:(XZImageViewerItemView *)itemView;
- (void)XZImageViewerItemViewDidZoom:(XZImageViewerItemView *)itemView;
- (void)XZImageViewerItemViewDidEndZooming:(XZImageViewerItemView *)itemView atScale:(CGFloat)scale;
@end

/// 单个内容视图的容器，提供了缩放功能。
@interface XZImageViewerItemView : UIView <UIScrollViewDelegate>

/// 事件代理。
@property (nonatomic, weak) id<XZImageViewerItemViewDelegate> delegate;
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

//@property (nonatomic, readonly) CGPoint contentOffset;
//- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;

/// 自定义过渡动画作用在此上视图，该视图直接添加到当前视图上。懒加载。
//@property (nonatomic, readonly, nonnull) UIView *transitionView;
//@property (nonatomic, readonly, nullable) UIView *transitionViewIfLoaded;
//- (void)bringBackTransitionViewIfNeeded;

/// 内容视图，改变该属性，请用设置方法。
@property (nonatomic, readonly) UIImageView *imageView;

/// 正值 左边留间距，负值右边留间距。间距作用于 zoomingView 。
@property (nonatomic) CGFloat interitemSpacing;
//@property (nonatomic) XZCarouselViewOrientation pagingOrientation;
/// 当前过渡百分比，针对当前视图，非整体进度。用来调整间距，使间距在过渡过程中始终保持一致。
//@property (nonatomic) CGFloat transition;

- (instancetype)init NS_UNAVAILABLE;
//- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
//- (instancetype)initWithFrame:(CGRect)frame pagingOrientation:(XZCarouselViewOrientation)pagingOrientation NS_DESIGNATED_INITIALIZER;

- (void)setIndex:(NSInteger)index contentView:(nullable UIView *)contentView preferredContentSize:(CGSize)preferredContentSize zoomScale:(CGFloat)zoomScale contentOffset:(CGPoint)contentOffset;

@end

NS_ASSUME_NONNULL_END
