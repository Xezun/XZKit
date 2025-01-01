//
//  XZRefreshManager.h
//  XZRefresh
//
//  Created by Xezun on 2023/8/10.
//

#import <Foundation/Foundation.h>
#import "XZRefreshView.h"

NS_ASSUME_NONNULL_BEGIN

@class UIRefreshControl;

@interface XZRefreshManager : NSObject <UIScrollViewDelegate>

/// 如果使用 weak 引用，那么在 UIScrollView 释放时，会释放其相关联的 XZRefreshManager 对象。
/// 由于 weak 机制，在 UIScrollView 处于释放的过程中，任何指向它的 weak 指针已经被置空，导致
/// 无法在 -[XZRefreshManager dealloc] 中移除 KVO 观察者，因此这里不能使用 weak 属性。
@property (nonatomic, unsafe_unretained, readonly)  UIScrollView *scrollView;

@property (nonatomic, strong, null_resettable)    XZRefreshView *headerRefreshView;
@property (nonatomic, strong, nullable, readonly) XZRefreshView *headerRefreshViewIfLoaded;

@property (nonatomic, strong, null_resettable)    XZRefreshView *footerRefreshView;
@property (nonatomic, strong, nullable, readonly) XZRefreshView *footerRefreshViewIfLoaded;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)setNeedsLayoutRefreshViews;
- (void)layoutRefreshViewsIfNeeded;

- (BOOL)isRefreshViewAnimating:(XZRefreshView *)refreshingView;
- (void)refreshingView:(XZRefreshView *)refreshingView beginAnimating:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (void)refreshingView:(XZRefreshView *)refreshingView endAnimating:(BOOL)animated completion:(void (^)(BOOL finished))completion;

@end

@interface UIScrollView (XZRefreshManager)
@property (nonatomic, strong, readonly) XZRefreshManager *xz_refreshManager;
@property (nonatomic, strong, readonly, nullable) XZRefreshManager *xz_refreshManagerIfLoaded;
@end

@interface XZRefreshView (XZRefreshManager)
/// 此属性在 XZRefreshView.m 中实现。
@property (nonatomic, weak) XZRefreshManager *refreshManager;
@end

NS_ASSUME_NONNULL_END
