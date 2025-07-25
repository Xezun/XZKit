//
//  XZImageViewer.h
//  XZKit
//
//  Created by 徐臻 on 2025/6/24.
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
/// @param imageViewer 调用此方法的 XZImageViewer 对象
/// @param index 图片的索引
/// @param completion 如果是网络图片，图片加载完成后，通过此回调更新
/// @returns 待展示的图片，或网络图片的占位图
- (nullable UIImage *)imageViewer:(XZImageViewer *)imageViewer loadImageForItemAtIndex:(NSInteger)index completion:(void (^)(UIImage *image))completion;

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
