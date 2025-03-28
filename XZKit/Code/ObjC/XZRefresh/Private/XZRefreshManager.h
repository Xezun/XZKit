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
/// XZRefreshManager 通过 objc association 与 UIScrollView 通过建立强引用关系，且是 UIScrollView 的观察者。
/// 理论上 XZRefreshManager 会随 UIScrollView 一起销毁，但是由于 block 捕捉，XZRefreshManager 的生命周期可能更长。
///
/// 通过 objc association 建立强引用关系的对象，在 Objective-C 历史版本中有过调整，
/// 似乎在 iOS 10.x 之前，被强引用的对象，是在宿主对象销毁后才销毁的，但目前是在 [super dealloc] 中销毁的，即
/// 在宿主的 dealloc 方法中，被强引用的对象未销毁，但在 dealloc 执行结束之前销毁。
///
/// 关于 KVO 的调整：自 iOS 11.0 之后 KVO 不再需要在对象销毁前移除，且大多数情况下，即使事件未移除，观察者销毁了也不会发生崩溃。
@interface XZRefreshManager : NSObject <UIScrollViewDelegate>

/// 被当前对象所管理的 scrollView 对象。
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
