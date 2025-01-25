//
//  XZMocoaListView.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaView.h"
#import "XZMocoaDefines.h"
#import "XZMocoaListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class UITableView, UICollectionView;

/// 用以承载列表视图的容器视图的接口协议。
@protocol XZMocoaListView <XZMocoaView, XZMocoaListViewModelDelegate>
@optional
/// 视图模型。
@property (nonatomic, strong, nullable) __kindof XZMocoaListViewModel *viewModel;
/// 承载列表视图的可滚动的容器视图，一般为 UICollectionView 或 UITableView 视图。
/// - 一般情况下，容器视图 contentView 的 delegate 和 dataSource 会被接管，请避免更改。
/// - 由于标注了 IBOutlet 所以在 IB 中使用时，直接将视图关联到此属性即可。
@property (nonatomic, strong) IBOutlet __kindof UIScrollView *contentView;
/// 通过模块注册列表 Cell 视图。
- (void)registerCellWithModule:(nullable XZMocoaModule *)module;
@end

/// XZMocoaListView 是 UITableView、UICollectionView 的抽象封装，不可直接使用。
@interface XZMocoaListView : XZMocoaView <XZMocoaListView>

/// 提供子类用于监听 contentView 发生改变的方法。
/// > 默认该方法什么也不做。
- (void)contentViewWillChange;

/// 提供子类用于监听 contentView 发生改变的方法。
/// > 默认该方法什么也不做。
- (void)contentViewDidChange;

- (void)viewModelWillChange;
- (void)viewModelDidChange;

@end


NS_ASSUME_NONNULL_END
