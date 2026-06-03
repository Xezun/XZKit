//
//  XZImageViewer.h
//  XZKit
//
//  Created by Xezun on 2025/6/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XZImageViewer;

/// XZImageViewer 代理。
@protocol XZImageViewerDelegate <NSObject>
@optional

/// 指定的图片被展示时，此方法会被调用。
///
/// @param imageViewer 调用此方法的 XZImageViewer 对象。
/// @param index 图片的索引。
- (void)imageViewer:(XZImageViewer *)imageViewer didShowImageAtIndex:(NSInteger)index;

- (void)imageViewer:(XZImageViewer *)imageViewer willBeginZoomingImageAtIndex:(NSInteger)index;
- (void)imageViewer:(XZImageViewer *)imageViewer didZoomImageAtIndex:(NSInteger)index;
- (void)imageViewer:(XZImageViewer *)imageViewer didEndZoomingImageAtIndex:(NSInteger)index atScale:(CGFloat)scale;
@end

@protocol UITableViewDataSource, UICollectionViewDataSource;

@protocol XZImageViewerDataSource <NSObject>
@required

/// 获取图片的数量。
///
/// @param imageViewer 调用此方法的 XZImageViewer 对象
/// @returns 图片数量
- (NSInteger)numberOfItemsInImageViewer:(XZImageViewer *)imageViewer;

/// 加载图片。
///
/// 如果是本地图片，可以直接在本方法中设置。
///
/// 如果是网络图片，那么在网络图片加载完成之后，必须要执行 completion 回调函数。
///
/// @param imageViewer 调用此方法的 XZImageViewer 对象
/// @param index 图片的索引
/// @param completion 网络图片加载完成，必须执行此回调函数，以通知 XZImageViewer 调整布局。
- (void)imageViewer:(XZImageViewer *)imageViewer imageView:(UIImageView *)imageView loadImageForItemAtIndex:(NSInteger)index completion:(void (^)(BOOL success))completion;

@end


@class XZPageView;

/// 图片查看器，全屏查看图片的控制器。
@interface XZImageViewer : UIViewController

@property (nonatomic, readonly) XZPageView *pageView;

/// 源视图，如果设置，XZImageViewer 将展示从 sourceView 缩放入场的动画过程。
@property (nonatomic, weak) UIView *sourceView;

/// 设置当前展示的图片，或默认展示的图片。
@property (nonatomic) NSInteger currentIndex;
- (void)setCurrentIndex:(NSInteger)newIndex animated:(BOOL)animated;

/// 代理。
@property (nonatomic, weak, nullable) id<XZImageViewerDelegate> delegate;
@property (nonatomic, weak, nullable) id<XZImageViewerDataSource> dataSource;

@property (nonatomic, readonly) CGFloat minimumZoomScale;
@property (nonatomic, readonly) CGFloat maximumZoomScale;
- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale maximumZoomScale:(CGFloat)maximumZoomScale;

@end

NS_ASSUME_NONNULL_END
