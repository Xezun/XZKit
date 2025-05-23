//
//  XZMocoaGridViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2021/1/23.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaViewModel.h"
#import "XZMocoaGridViewSectionViewModel.h"
#import "XZMocoaGridViewCellViewModel.h"
#import "XZMocoaGridModel.h"
#import "XZMocoaGridViewModelDefines.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_UI_ACTOR @protocol XZMocoaGridViewModelDelegate <NSObject>
@end

/// 列表容器视图的视图模型。
/// @attention 由于需要管理列表 Cell 子视图，因此需要设置 `module` 属性才能正常工作。
@interface XZMocoaGridViewModel : XZMocoaViewModel <XZMocoaGridViewModel>

/// 所支持的附加视图的类型，默认为 @[XZMocoaKindHeader, XZMocoaKindFooter] 两种。
/// @discussion 请在使用 viewModel 前设置此属性。
@property (nonatomic, copy) NSArray<XZMocoaKind> *supportedSupplementaryKinds;

/// 接收来自下级的 XZMocoaUpdatesKeyReload 事件，并刷新视图，如果在批量更新的过程中，视图刷新可能会延迟。
- (void)didReceiveUpdates:(XZMocoaUpdates *)updates;

/// 视图模型需要视图处理的事件，比如更新视图等。
@property (nonatomic, weak) id<XZMocoaGridViewModelDelegate> delegate;

/// 判断列表是否为空。
@property (nonatomic, readonly) BOOL isEmpty;

/// 列表子视图模型。
///
/// 在 UITableView 或 UICollectionView 中，Section 是逻辑上的子视图，而视图模型就是处理逻辑的。
@property (nonatomic, readonly) NSArray<__kindof XZMocoaGridViewSectionViewModel *> *sectionViewModels;

- (__kindof XZMocoaGridViewSectionViewModel *)sectionViewModelAtIndex:(NSInteger)index;
- (NSInteger)indexOfSectionViewModel:(__kindof XZMocoaGridViewSectionViewModel *)sectionViewModel;

@property (nonatomic, readonly) NSInteger numberOfSections;
- (NSInteger)numberOfCellsInSection:(NSInteger)section;
- (__kindof XZMocoaGridViewCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath;

// MARK: - 视图模型接收“数据更新”事件

/// 数据更新后，调用此方法以重载所有受管理的子视图模型。
- (void)reloadData;

/// 指定 section 的数据发生更新后，调用此方法以重载该 section 的视图模型。
/// @param section 数据发生更新的行
- (void)reloadSectionAtIndex:(NSInteger)section;
- (void)reloadCellAtIndexPath:(NSIndexPath *)indexPath;

/// 新增指定 section 的数据后，调用此方法以构造该 section 的视图模型。
/// @param section 新增的行
- (void)insertSectionAtIndex:(NSInteger)section;
- (void)insertCellAtIndexPath:(NSIndexPath *)indexPath;

/// 指定 section 的数据更新后，调用此方法以重载该 section 的视图模型。
/// @param section 数据发生更新的行
- (void)deleteSectionAtIndex:(NSInteger)section;
- (void)deleteCellAtIndexPath:(NSIndexPath *)indexPath;

/// 指定 sections 的数据更新后，调用此方法以重载该 sections 的视图模型。
/// @param sections 数据发生更新的行
- (void)reloadSectionsAtIndexes:(nullable NSIndexSet *)sections;
- (void)reloadCellsAtIndexPaths:(nullable NSArray<NSIndexPath *> *)indexPaths;

/// 新增指定 sections 的数据后，调用此方法以构造该 sections 的视图模型。
/// @param sections 新增的行
- (void)insertSectionsAtIndexes:(nullable NSIndexSet *)sections;
- (void)insertCellsAtIndexPaths:(nullable NSArray<NSIndexPath *> *)indexPaths;

/// 指定 sections 的数据更新后，调用此方法以重载该 sections 的视图模型。
/// @param sections 数据发生更新的行
- (void)deleteSectionsAtIndexes:(nullable NSIndexSet *)sections;
- (void)deleteCellsAtIndexPaths:(nullable NSArray<NSIndexPath *> *)indexPaths;

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

@interface XZMocoaGridViewModel (XZMocoaGridViewSectionViewModelDelegate)
/// section 发送的 Section 重载事件，以刷新视图。
- (void)sectionViewModel:(__kindof XZMocoaGridViewSectionViewModel *)viewModel didReloadData:(void * _Nullable)null;
/// section 发送的 Cell 重载事件，以刷新视图。
- (void)sectionViewModel:(__kindof XZMocoaGridViewSectionViewModel *)viewModel didReloadCellsAtIndexes:(NSIndexSet *)rows;
/// section 发送的 Cell 插入事件，以刷新视图。
- (void)sectionViewModel:(__kindof XZMocoaGridViewSectionViewModel *)viewModel didInsertCellsAtIndexes:(NSIndexSet *)rows;
/// section 发送的 Cell 删除事件，以刷新视图。
- (void)sectionViewModel:(__kindof XZMocoaGridViewSectionViewModel *)viewModel didDeleteCellsAtIndexes:(NSIndexSet *)rows;
/// section 发送的 Cell 移动事件，以刷新视图。
- (void)sectionViewModel:(__kindof XZMocoaGridViewSectionViewModel *)viewModel didMoveCellAtIndex:(NSInteger)row toIndex:(NSInteger)newRow;
/// section 发送的批量更新事件，以刷新视图。
- (void)sectionViewModel:(__kindof XZMocoaGridViewSectionViewModel *)viewModel didPerformBatchUpdates:(void (^NS_NOESCAPE)(void))batchUpdates completion:(void (^ _Nullable)(BOOL))completion;
@end

NS_ASSUME_NONNULL_END
