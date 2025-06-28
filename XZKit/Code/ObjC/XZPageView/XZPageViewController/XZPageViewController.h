//
//  XZPageViewController.h
//  XZKit
//
//  Created by Xezun on 2019/4/7.
//  Copyright © 2019 XEZUN INC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XZPageViewDefines.h"

NS_ASSUME_NONNULL_BEGIN

@class XZPageView, XZPageViewController, UIPageViewController;

/// 转场事件代理。
@protocol XZPageViewControllerDelegate <NSObject>
@optional
- (void)pageViewController:(XZPageViewController *)pageViewController didShowViewControllerAtIndex:(NSInteger)index;
- (void)pageViewController:(XZPageViewController *)pageViewController didTurnViewControllerInTransition:(CGFloat)transition;
@end

@protocol XZPageViewControllerDataSource <NSObject>
@required
- (NSInteger)numberOfViewControllersInPageViewController:(XZPageViewController *)pageViewController;
- (UIViewController *)pageViewController:(XZPageViewController *)pageViewController viewControllerForPageAtIndex:(NSInteger)index;
@end

/// 封装了 XZPageView 的控制器容器，将控制器视图作为轮播内容，并管理维护了控制器的生命周期。
@interface XZPageViewController : UIViewController <XZPageViewDelegate, XZPageViewDataSource>

@property (nonatomic, weak, nullable) id<XZPageViewControllerDelegate> delegate;
@property (nonatomic, weak, nullable) id<XZPageViewControllerDataSource> dataSource;



@property (nonatomic, readonly, nullable) UIViewController *currentViewController;
@property (nonatomic, readonly, nullable) UIViewController *pendingViewController;

// 以下方法会导致 viewDidLoad 提前调用。

@property (nonatomic) XZPageViewOrientation orientation;
@property (nonatomic, setter=setLooped:) BOOL isLooped;
@property (nonatomic) NSTimeInterval autoPagingInterval;

/// 必须调用控制器的方法翻页，否则会造成子控制器的生命周期不完整。
@property (nonatomic) NSInteger currentPage;
- (void)setCurrentPage:(NSInteger)newPage animated:(BOOL)animated;

- (void)reloadData;

@end



NS_ASSUME_NONNULL_END
