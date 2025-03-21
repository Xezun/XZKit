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

/// 管理刷新状态的对象。
///
/// - Attention: 应避免延长 self 的生命周期。
/// 虽然被 block 强引用 `self` 和 `_scrollView` 对象，但是 block 如果先释放 `_scrollView` 后释放 `self` 对象，
/// 那么释放 `self` 的时候，移除无主引用的 `_scrollView` 可能已经销毁，从而导致移除 KVO 发生问题。
/// 注：由于自 iOS 11.0 之后 KVO 不再需要在对象销毁前移除，当前 `_scrollView` 已改为 `weak` 不会发生上述问题。
@interface XZRefreshManager : NSObject <UIScrollViewDelegate>

/// 被当前对象所管理的 scrollView 对象。
///
/// 当前对象被 scrollView 通过 objc association 强引用。
///
/// 当前对象是 scrollView 的观察者，自 iOS 11.0 之后，被观察的对象释放前，不再需要移除观察者，所以仅需要在观察者销毁时解除观察即可。
@property (nonatomic, weak, readonly)  UIScrollView *scrollView;

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
