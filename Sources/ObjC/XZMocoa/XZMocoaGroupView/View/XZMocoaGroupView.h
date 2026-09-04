//
//  XZMocoaGroupView.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaView.h"
#import "XZMocoaDefines.h"
#import "XZMocoaGroupViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class UITableView, UICollectionView;

/// XZMocoaGroupView 是 UITableView、UICollectionView 的抽象封装，不可直接使用。
@interface XZMocoaGroupView : UIView <XZMocoaView>

/// 视图模型。
@property (nonatomic, strong, nullable) __kindof XZMocoaGroupViewModel *viewModel;
/// 承载列表视图的可滚动的容器视图，一般为 UICollectionView 或 UITableView 视图。
/// - 一般情况下，容器视图 contentView 的 delegate 和 dataSource 会被接管，请避免更改。
/// - 由于标注了 IBOutlet 所以在 IB 中使用时，直接将视图关联到此属性即可。
@property (nonatomic, strong) IBOutlet __kindof UIScrollView *contentView;

/// 通过模块注册列表 Cell 视图。
- (void)prepareForModule:(nullable XZMocoaModule *)module;

/// 提供子类用于监听 contentView 发生改变的方法。
/// > 默认该方法什么也不做。
- (void)contentViewWillChange:(UIScrollView *)newValue;

/// 提供子类用于监听 contentView 发生改变的方法。
/// > 默认该方法什么也不做。
- (void)contentViewDidChange:(UIScrollView *)oldValue;

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
@interface XZMocoaGroupView (XZRefreshDelegate) <XZRefreshDelegate>
- (void)scrollView:(UIScrollView *)scrollView headerDidBeginRefreshing:(XZRefreshView *)refreshView;
- (void)scrollView:(UIScrollView *)scrollView footerDidBeginRefreshing:(XZRefreshView *)refreshView;
@end
#endif

NS_ASSUME_NONNULL_END
