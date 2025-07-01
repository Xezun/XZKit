//
//  XZImageViewerItemView.h
//  XZKit
//
//  Created by 徐臻 on 2025/6/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XZImageViewer;

/// XZImageViewerItemView 的缩放拖动事件协议。
@protocol XZImageViewerDelegate;

/// 单个内容视图的容器，提供了缩放功能。
@interface XZImageViewerItemView : UIView <UIScrollViewDelegate> {
    XZImageViewer * __unsafe_unretained _imageViewer;
}

/// 当前容器所显示的内容的索引。
@property (nonatomic) NSInteger index;

@property (nonatomic) BOOL bouncesZoom;
@property (nonatomic, readonly) CGFloat minimumZoomScale;
@property (nonatomic, readonly) CGFloat maximumZoomScale;
- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale maximumZoomScale:(CGFloat)maximumZoomScale;

@property (nonatomic, readonly) CGFloat zoomScale;
- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated;
- (void)setZoomScale:(CGFloat)scale animated:(BOOL)animated;

/// 在入场退场的过程中，imageView 可能会离开当前视图。
/// 将 imageView 放回，调用 setter 方法即可。
@property (nonatomic, strong) UIImageView *imageView;
- (CGRect)imageRectForBounds:(CGRect)bounds;

- (instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithImageViewer:(XZImageViewer *)imageViewer NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
