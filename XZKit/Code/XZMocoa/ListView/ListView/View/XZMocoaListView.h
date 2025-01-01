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

/// XZMocoaListView 是 UITableView、UICollectionView 的抽象封装，不可直接使用。
@interface XZMocoaListView : UIView <XZMocoaView, XZMocoaListViewModelDelegate>

/// 承载内容的视图，为 UICollectionView 或 UITableView 视图，由子类提供。
/// @note 在 IB 中使用时，直接将视图关联到此属性即可。
@property (nonatomic, strong) IBOutlet __kindof UIScrollView *contentView;

/// 提供子类用于监听 contentView 发生改变的方法。
/// @note 默认该方法什么也不做。
- (void)contentViewWillChange;

/// 提供子类用于监听 contentView 发生改变的方法。
/// @note 默认该方法什么也不做。
- (void)contentViewDidChange;

@property (nonatomic, strong, nullable) __kindof XZMocoaListViewModel *viewModel;
- (void)viewModelWillChange;
- (void)viewModelDidChange;

- (void)unregisterModule:(nullable XZMocoaModule *)module;
- (void)registerModule:(nullable XZMocoaModule *)module;

@end

NS_ASSUME_NONNULL_END
