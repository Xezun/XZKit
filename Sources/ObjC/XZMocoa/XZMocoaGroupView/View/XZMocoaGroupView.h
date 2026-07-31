//
//  XZMocoaGroupView.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaView.h>
#import <XZKit/XZMocoaDefines.h>
#import <XZKit/XZMocoaGroupViewModel.h>
#else
#import "XZMocoaView.h"
#import "XZMocoaDefines.h"
#import "XZMocoaGroupViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class UITableView, UICollectionView;

/// 用以承载列表视图的容器视图的接口协议。
@protocol XZMocoaGroupView <XZMocoaView>
@optional
/// 视图模型。
@property (nonatomic, strong, nullable) __kindof XZMocoaGroupViewModel *viewModel;
/// 承载列表视图的可滚动的容器视图，一般为 UICollectionView 或 UITableView 视图。
/// - 一般情况下，容器视图 contentView 的 delegate 和 dataSource 会被接管，请避免更改。
/// - 由于标注了 IBOutlet 所以在 IB 中使用时，直接将视图关联到此属性即可。
@property (nonatomic, strong) IBOutlet __kindof UIScrollView *contentView;
/// 通过模块注册列表 Cell 视图。
- (void)prepareForModule:(nullable XZMocoaModule *)module;
@end

/// XZMocoaGroupView 是 UITableView、UICollectionView 的抽象封装，不可直接使用。
@interface XZMocoaGroupView : UIView <XZMocoaGroupView>

/// 提供子类用于监听 contentView 发生改变的方法。
/// > 默认该方法什么也不做。
- (void)contentViewWillChange:(UIScrollView *)newValue;

/// 提供子类用于监听 contentView 发生改变的方法。
/// > 默认该方法什么也不做。
- (void)contentViewDidChange:(UIScrollView *)oldValue;

/// 调用视图模型的 ``-reloadData`` 方法。
/// > 当视图被其它视图管理时，可使用此方法刷新，一般情况下，在 MVVM 设计模式中，不会用到此方法。
- (void)reloadData;

/// 调用视图模型的 ``-performBatchUpdates:completion:`` 方法
/// > 当视图被其它视图管理时，可使用此方法刷新，一般情况下，在 MVVM 设计模式中，不会用到此方法。
/// - Parameters:
///   - updates: 更新数据源的操作
///   - completion: 更新完成后的回调
- (void)performBatchUpdates:(void (NS_NOESCAPE ^ _Nullable)(void))updates completion:(void (^ _Nullable)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END

#if __has_include(<XZKit/XZRefresh.h>)
#import <XZKit/XZRefresh.h>
#define XZ_MOCOA_REFRESH_SUPPORTED 1
#elif __has_include("XZRefresh.h")
#import "XZRefresh.h"
#define XZ_MOCOA_REFRESH_SUPPORTED 1
#endif

NS_ASSUME_NONNULL_BEGIN

#ifdef XZ_MOCOA_REFRESH_SUPPORTED
/// 列表头部开始刷新。
///
/// 当使用 XZRefresh 组件时，发生刷新事件后，将通过事件通道，把刷新视图 refreshView 以此事件名，传递给 viewModel 对象。
/// - events.source 为 XZMocoaGroupView 子类对象。
/// - events.value 为 refreshView 对象。
FOUNDATION_EXPORT XZMocoaEventsName const XZMocoaEventsNameHeaderDidBeginRefreshing;

/// 列表尾部开始刷新。
///
/// 当使用 XZRefresh 组件时，发生刷新事件后，将通过事件通道，把刷新视图 refreshView 以此事件名，传递给 viewModel 对象。
/// - events.source 为 XZMocoaGroupView 子类对象。
/// - events.value 为 refreshView 对象。
FOUNDATION_EXPORT XZMocoaEventsName const XZMocoaEventsNameFooterDidBeginRefreshing;

@interface XZMocoaGroupView (XZRefreshDelegate) <XZRefreshDelegate>
- (void)scrollView:(UIScrollView *)scrollView headerDidBeginRefreshing:(XZRefreshView *)refreshView;
- (void)scrollView:(UIScrollView *)scrollView footerDidBeginRefreshing:(XZRefreshView *)refreshView;
@end
#endif

NS_ASSUME_NONNULL_END
