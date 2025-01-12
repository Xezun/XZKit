//
//  XZMocoaListViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2021/1/23.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaViewModel.h"
#import "XZMocoaListViewSectionViewModel.h"
#import "XZMocoaListViewCellViewModel.h"
#import "XZMocoaListModel.h"
#import "XZMocoaListViewModelDefines.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_UI_ACTOR @protocol XZMocoaListViewModelDelegate <NSObject>
@end

/// 具有列表形式视图的一般视图模型。
/// @attention 由于需要管理子视图，因此需要设置 module 属性才能正常工作。
@interface XZMocoaListViewModel : XZMocoaViewModel <XZMocoaListViewModel>

/// 所支持的附加视图的类型，默认为 @[XZMocoaKindHeader, XZMocoaKindFooter] 两种。
/// @discussion 请在使用 viewModel 前设置此属性。
@property (nonatomic, copy) NSArray<XZMocoaKind> *supportedSupplementaryKinds;

/// 接收来自下级的 XZMocoaUpdatesNameReload 事件，并刷新视图，如果在批量更新的过程中，视图刷新可能会延迟。
- (void)didReceiveUpdates:(XZMocoaUpdates *)updates;

/// 一般而言 TableViewModel 只会有一个事件接收者，这里直接用了代理。
@property (nonatomic, weak) id<XZMocoaListViewModelDelegate> delegate;

/// 判断是否为空。
@property (nonatomic, readonly) BOOL isEmpty;

/// 下级视图模型。
@property (nonatomic, readonly) NSArray<__kindof XZMocoaListViewSectionViewModel *> *sectionViewModels;

- (__kindof XZMocoaListViewSectionViewModel *)sectionViewModelAtIndex:(NSInteger)index;
- (NSInteger)indexOfSectionViewModel:(__kindof XZMocoaListViewSectionViewModel *)sectionViewModel;

@property (nonatomic, readonly) NSInteger numberOfSections;
- (NSInteger)numberOfCellsInSection:(NSInteger)section;
- (__kindof XZMocoaListViewCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath;

// MARK: - 视图模型接收“数据更新”事件

/// 数据更新后，调用此方法以重载所有受管理的子视图模型。
- (void)reloadData;

/// 指定 section 的数据发生更新后，调用此方法以重载该 section 的视图模型。
/// @param section 数据发生更新的行
- (void)reloadSectionAtIndex:(NSInteger)section;

/// 新增指定 section 的数据后，调用此方法以构造该 section 的视图模型。
/// @param section 新增的行
- (void)insertSectionAtIndex:(NSInteger)section;

/// 指定 section 的数据更新后，调用此方法以重载该 section 的视图模型。
/// @param section 数据发生更新的行
- (void)deleteSectionAtIndex:(NSInteger)section;

/// 指定 sections 的数据更新后，调用此方法以重载该 sections 的视图模型。
/// @param sections 数据发生更新的行
- (void)reloadSectionsAtIndexes:(nullable NSIndexSet *)sections;

/// 新增指定 sections 的数据后，调用此方法以构造该 sections 的视图模型。
/// @param sections 新增的行
- (void)insertSectionsAtIndexes:(nullable NSIndexSet *)sections;

/// 指定 sections 的数据更新后，调用此方法以重载该 sections 的视图模型。
/// @param sections 数据发生更新的行
- (void)deleteSectionsAtIndexes:(nullable NSIndexSet *)sections;

/// 移动行 section 到新行 newSection 处。
/// @param section 移动前的位置
/// @param newSection 移动后的位置
- (void)moveSectionAtIndex:(NSInteger)section toIndex:(NSInteger)newSection;

// MARK: - 视图模型的事件派发，子类必须重写并根据实际去实现

// 如下 -did 方法，表示对应的事件已经发生，需要更新视图对应的视图了。
// 子类应该重新下面的方法，并更新视图。

- (void)didReloadData;
- (void)didReloadCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)didInsertCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)didDeleteCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)didMoveCellAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;
- (void)didReloadSectionsAtIndexes:(NSIndexSet *)sections;
- (void)didInsertSectionsAtIndexes:(NSIndexSet *)sections;
- (void)didDeleteSectionsAtIndexes:(NSIndexSet *)sections;
- (void)didMoveSectionAtIndex:(NSInteger)section toIndex:(NSInteger)newSection;
- (void)didPerformBatchUpdates:(void (^NS_NOESCAPE)(void))batchUpdates completion:(void (^ _Nullable)(BOOL finished))completion;

// MARK: - 防崩溃设计的占位视图

/// 子类应该重写此方法，并返回所需的 SectionViewModel 对象。
- (Class)placeholderViewModelClassForSectionAtIndex:(NSInteger)index;

@end

// MARK: - 下级 section 不能独自完成的事件，需要上级处理的事件

@interface XZMocoaListViewModel (XZMocoaListViewSectionViewModelDelegate)
/// section 发送的 Section 重载事件，以刷新视图。
- (void)sectionViewModel:(__kindof XZMocoaListViewSectionViewModel *)viewModel didReloadData:(void * _Nullable)null;
/// section 发送的 Cell 重载事件，以刷新视图。
- (void)sectionViewModel:(__kindof XZMocoaListViewSectionViewModel *)viewModel didReloadCellsAtIndexes:(NSIndexSet *)rows;
/// section 发送的 Cell 插入事件，以刷新视图。
- (void)sectionViewModel:(__kindof XZMocoaListViewSectionViewModel *)viewModel didInsertCellsAtIndexes:(NSIndexSet *)rows;
/// section 发送的 Cell 删除事件，以刷新视图。
- (void)sectionViewModel:(__kindof XZMocoaListViewSectionViewModel *)viewModel didDeleteCellsAtIndexes:(NSIndexSet *)rows;
/// section 发送的 Cell 移动事件，以刷新视图。
- (void)sectionViewModel:(__kindof XZMocoaListViewSectionViewModel *)viewModel didMoveCellAtIndex:(NSInteger)row toIndex:(NSInteger)newRow;
/// section 发送的批量更新事件，以刷新视图。
- (void)sectionViewModel:(__kindof XZMocoaListViewSectionViewModel *)viewModel didPerformBatchUpdates:(void (^NS_NOESCAPE)(void))batchUpdates completion:(void (^ _Nullable)(BOOL))completion;
@end

NS_ASSUME_NONNULL_END
