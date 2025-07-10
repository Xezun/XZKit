//
//  XZMocoaGridView.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaView.h>
#import <XZKit/XZMocoaDefines.h>
#import <XZKit/XZMocoaGridViewModel.h>
#else
#import "XZMocoaView.h"
#import "XZMocoaDefines.h"
#import "XZMocoaGridViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class UITableView, UICollectionView;

/// 用以承载列表视图的容器视图的接口协议。
@protocol XZMocoaGridView <XZMocoaView>
@optional
/// 视图模型。
@property (nonatomic, strong, nullable) __kindof XZMocoaGridViewModel *viewModel;
/// 通过模块注册列表 Cell 视图。
- (void)registerModule:(nullable XZMocoaModule *)module;
@end

/// XZMocoaGridView 是 UITableView、UICollectionView 的抽象封装，不可直接使用。
@interface XZMocoaGridView : UIView <XZMocoaGridView>

/// 承载列表视图的可滚动的容器视图，一般为 UICollectionView 或 UITableView 视图。
/// - 一般情况下，容器视图 contentView 的 delegate 和 dataSource 会被接管，请避免更改。
/// - 由于标注了 IBOutlet 所以在 IB 中使用时，直接将视图关联到此属性即可。
@property (nonatomic, strong) IBOutlet __kindof UIScrollView *contentView;

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
