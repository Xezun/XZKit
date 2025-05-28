//
//  XZMocoaGridView.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaView.h"
#import "XZMocoaDefines.h"
#import "XZMocoaGridViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class UITableView, UICollectionView;

/// 用以承载列表视图的容器视图的接口协议。
@protocol XZMocoaGridView <XZMocoaView, XZMocoaGridViewModelDelegate>
@optional
/// 视图模型。
@property (nonatomic, strong, nullable) __kindof XZMocoaGridViewModel *viewModel;
/// 承载列表视图的可滚动的容器视图，一般为 UICollectionView 或 UITableView 视图。
/// - 一般情况下，容器视图 contentView 的 delegate 和 dataSource 会被接管，请避免更改。
/// - 由于标注了 IBOutlet 所以在 IB 中使用时，直接将视图关联到此属性即可。
@property (nonatomic, strong) IBOutlet __kindof UIScrollView *contentView;
/// 通过模块注册列表 Cell 视图。
- (void)registerModule:(nullable XZMocoaModule *)module;
@end

/// XZMocoaGridView 是 UITableView、UICollectionView 的抽象封装，不可直接使用。
@interface XZMocoaGridView : UIView <XZMocoaGridView>

/// 提供子类用于监听 contentView 发生改变的方法。
/// > 默认该方法什么也不做。
- (void)contentViewWillChange:(UIScrollView *)newValue;

/// 提供子类用于监听 contentView 发生改变的方法。
/// > 默认该方法什么也不做。
- (void)contentViewDidChange:(UIScrollView *)oldValue;

@end


NS_ASSUME_NONNULL_END
