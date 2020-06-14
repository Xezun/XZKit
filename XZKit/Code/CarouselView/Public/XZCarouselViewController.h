//
//  XZCarouselViewController.h
//  XZKit
//
//  Created by Xezun on 2019/4/7.
//  Copyright © 2019 XEZUN INC. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifdef XZKIT_FRAMEWORK
#import <XZKit/XZCarouselView.h>
#else
#import "XZCarouselView.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class XZCarouselView, XZCarouselViewController, UIPageViewController;

/// 转场事件代理。
NS_SWIFT_NAME(CarouselViewControllerDelegate)
@protocol XZCarouselViewControllerDelegate <NSObject>
@optional
- (void)carouselViewController:(XZCarouselViewController *)carouselViewController didShowViewController:(UIViewController *)viewController atIndex:(NSInteger)index;

- (void)carouselViewController:(XZCarouselViewController *)carouselViewController willBeginTransitioningViewController:(UIViewController *)viewController atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)carouselViewController:(XZCarouselViewController *)carouselViewController didBeginTransitioningViewController:(UIViewController *)viewController atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)carouselViewController:(XZCarouselViewController *)carouselViewController didTransition:(CGFloat)transition animated:(BOOL)animated;
- (void)carouselViewController:(XZCarouselViewController *)carouselViewController willEndTransitioningViewController:(UIViewController *)viewController atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)carouselViewController:(XZCarouselViewController *)carouselViewController didEndTransitioningViewController:(UIViewController *)viewController atIndex:(NSInteger)index animated:(BOOL)animated;
- (XZEdgeInsets)carouselViewController:(XZCarouselViewController *)carouselView edgeInsetsForGestureTransitionViewController:(nullable UIViewController *)viewController atIndex:(NSInteger)index;
@end

NS_SWIFT_NAME(CarouselViewControllerDataSource)
@protocol XZCarouselViewControllerDataSource <NSObject>
@required
- (NSInteger)numberOfViewControllersInCarouselViewController:(XZCarouselViewController *)carouselViewController;
- (UIViewController *)carouselViewController:(XZCarouselViewController *)carouselViewController viewControllerForIndex:(NSInteger)index reusingViewController:(nullable UIViewController *)reusingViewController;
@optional
/// 默认情况下，控制器不会进入 XZCarouselView 的重用机制，除非此方法返回 YES 。
/// @note XZCarouselView 重用机制强引用的是控制器的视图。
- (BOOL)carouselViewController:(XZCarouselViewController *)carouselViewController shouldEnqueueViewController:(UIViewController *)viewController atIndex:(NSInteger)index;
@end

/// 封装了 XZCarouselView 的控制器容器，将控制器视图作为轮播内容，并管理维护了控制器的生命周期。
NS_SWIFT_NAME(CarouselViewController)
@interface XZCarouselViewController : UIViewController <XZCarouselViewDelegate, XZCarouselViewDataSource>

/// 通过此属性设置 XZCarouselViewController 的外观样式。
@property (nonatomic, readonly) XZCarouselView *carouselView;

@property (nonatomic, weak, nullable) id<XZCarouselViewControllerDelegate> delegate;
@property (nonatomic, weak, nullable) id<XZCarouselViewControllerDataSource> dataSource;

@property (nonatomic) NSInteger currentIndex;

- (void)setCurrentIndex:(NSInteger)newIndex animated:(BOOL)animated;

- (void)reloadData;

@end



NS_ASSUME_NONNULL_END
