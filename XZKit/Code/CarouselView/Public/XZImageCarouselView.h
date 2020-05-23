//
//  XZImageCarouselView.h
//  XZImageCarousel
//
//  Created by Xezun on 2017/12/27.
//  Copyright © 2017年 XEZUN INC. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifdef XZKIT_FRAMEWORK
#import <XZKit/XZCarouselView.h>
#else
#import "XZCarouselView.h"
#endif

@class XZImageCarouselView;

NS_SWIFT_NAME(ImageCarouselViewDelegate)
@protocol XZImageCarouselViewDelegate <XZCarouselViewDelegate>
@optional
/// 如果展示的为网络图片，那么 XZImageCarouselView 将调用此方法来来下载网络图片。
///
/// @note 1. 默认 XZImageCarouselView 以自己为数据源，如果设置了额外的数据源，则此方法不会被调用。
/// @note 2. 回调参数 preferredImageSize 表示期望的所展示的图片视图的初始大小。
/// @note 3. 回调参数 animated 图片视图如果大小发生变化，是否展示动画过渡效果，建议 false 。
///
/// @param imageCarouselView 调用此方法的 XZImageScrollView 对象。
/// @param imageView 图片，默认大小 {68, 68} ，并默认占位图。
/// @param imageURL 图片地址。
/// @param completion 图片下载完成后的回调，默认情况下，回调必须执行（关系到视图是否可以被缩放）。
- (void)imageCarouselView:(nonnull XZImageCarouselView *)imageCarouselView imageView:(nonnull UIImageView *)imageView loadImageFromURL:(nonnull NSURL *)imageURL completion:(void (^ _Nonnull)(CGSize preferredImageSize, BOOL animated))completion;
@end

/// 图片轮播图，使用图片或图片网络地址作为数据源。
NS_SWIFT_NAME(ImageCarouselView)
@interface XZImageCarouselView : XZCarouselView <XZCarouselViewDataSource>

/// 设置或获取 XZImageCarouselView 所展示本地图片。
/// @note 如果同时设置了网络图片，本地图片将优先显示。
/// @note 设置属性会自动调用 reloadData 方法。
/// @note 如果代理管理了数据源，此属性设置的图片不展示。
@property (nonatomic, copy, nullable) NSArray<UIImage *> *images;

/// 设置或获取 XZImageCarouselView 所显示网络图片。
/// @note 如果同时设置了本地图片，本地图片将优先显示。
/// @note 设置属性会自动调用 reloadData 方法。
/// @note 如果代理管理了数据源，此属性设置的图片不展示。
@property (nonatomic, copy, nullable) NSArray<NSURL *> *imageURLs;

- (void)setImages:(NSArray<UIImage *> * _Nullable)images imageURLs:(NSArray<NSURL *> * _Nullable)imageURLs;

- (nonnull instancetype)initWithFrame:(CGRect)frame pagingOrientation:(XZCarouselViewPagingOrientation)pagingOrientation NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end
