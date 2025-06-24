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

/// 获取原始图片视图相对于其所在 window 的位置。
///
/// @note 如果此方法没有实现或者没有返回了具体的位置，那么 viewer 被 present 时，将无法展示从源位置到全屏的动画。
///
/// @param imageViewer 调用此方法的 XZImageViewer 对象。
/// @param index 图片的索引。
/// @return 源图片视图的位置。
- (CGRect)imageViewer:(XZImageViewer *)imageViewer rectForImageAtIndex:(NSInteger)index;

/// 获取原始图片视图显示图片的模式。
/// @note 如果此方法没有实现，那么 viewer 被 present 时，将无法展示从源位置到全屏的动画。
///
/// @param imageViewer 调用此方法的 XZImageViewer 对象。
/// @param index 图片的索引。
/// @return 源图片视图的 UIViewContentMode 。
- (UIViewContentMode)imageViewer:(XZImageViewer *)imageViewer sourceContentModeForImageAtIndex:(NSInteger)index;

/// 指定的图片被展示时，此方法会被调用。
///
/// @param imageViewer 调用此方法的 XZImageViewer 对象。
/// @param index 图片的索引。
- (void)imageViewer:(XZImageViewer *)imageViewer didShowImageAtIndex:(NSInteger)index;

@end

@protocol UITableViewDataSource, UICollectionViewDataSource;

@protocol XZImageViewerDataSource <NSObject>
@required

/// 获取图片的数量。
///
/// @param imageViewer 调用此方法的 XZImageViewer 对象。
/// @return 图片数量。
- (NSInteger)numberOfItemsInImageViewer:(XZImageViewer *)imageViewer;

/// 加载图片。
///
/// @param imageViewer 调用此方法的 XZImageViewer 对象。
/// @param imageView 展示图片的 UIImageView 对象。
/// @param index 图片的索引。
/// @param completion 如果是网络图片，图片加载完成后，通过此句柄更新图片视图的大小；本地图片无须此参数，直接在此方法中设置图片，并修改 UIImageView 的大小即可。
//- (void)imageViewer:(XZImageViewer *)imageViewer imageView:(UIImageView *)imageView loadImageAtIndex:(NSInteger)index completion:(void (^)(CGSize preferredImageSize, BOOL animated))completion;
- (nullable UIImage *)imageViewer:(XZImageViewer *)imageViewer loadImageForItemAtIndex:(NSInteger)index; // completion:(void (^)(UIImage *image, CGSize preferredImageSize, BOOL animated))completion;

@end

/// 图片查看器，全屏查看图片的控制器。
@interface XZImageViewer : UIViewController

/// 设置当前展示的图片。
@property (nonatomic) NSInteger currentIndex;
- (void)setCurrentIndex:(NSInteger)newIndex animated:(BOOL)animated;

- (nullable UIImage *)imageForItemAtIndex:(NSInteger)index;
- (void)setImage:(UIImage *)image forItemAtIndex:(NSInteger)index animated:(BOOL)animated;

/// 代理。
@property (nonatomic, weak, nullable) id<XZImageViewerDelegate> delegate;
@property (nonatomic, weak, nullable) id<XZImageViewerDataSource> dataSource;

+ (BOOL)isViewControllerBasedStatusBarAppearance;

@end

@interface _XZImageViewerPresentingAnimationController : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, weak, readonly) XZImageViewer *delegate;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDelegate:(XZImageViewer *)delegate NS_DESIGNATED_INITIALIZER;
@end

@interface _XZImageViewerDismissingAnimationController : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, weak, readonly) XZImageViewer *delegate;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDelegate:(XZImageViewer *)delegate NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
