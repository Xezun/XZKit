//
//  XZMocoaGroupViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2021/1/23.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "XZMocoaGroupReusableViewModel.h"
#import "XZMocoaGroupModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaGroupViewModelDelegate <NSObject>
@end

@class UITableView, UICollectionView;

/// 列表容器视图的视图模型。
/// @attention 由于需要管理列表 Cell 子视图，因此需要设置 `module` 属性才能正常工作。
@interface XZMocoaGroupViewModel : XZMocoaViewModel

/// 处理事件的对象，一般为视图。
@property (nonatomic, weak) id<XZMocoaGroupViewModelDelegate> delegate;

/// 所支持的附加视图的类型，默认为 `@[XZMocoaKindHeader, XZMocoaKindFooter]` 两种。
/// @discussion 请在使用 viewModel 前设置此属性。
@property (nonatomic, copy) NSArray<XZMocoaKind> *supportedSupplementKinds;

/// 接收来自下级的 XZMocoaKeyReload 事件，并刷新视图，如果在批量更新的过程中，视图刷新可能会延迟。
- (void)didReceiveEvents:(XZMocoaEvents *)events;

/// 判断列表是否为空。
@property (nonatomic, readonly) BOOL isEmpty;

@property (nonatomic, readonly) NSInteger numberOfSections;
- (NSInteger)numberOfCellsInSection:(NSInteger)section;
- (__kindof XZMocoaGroupReusableViewModel *)viewModelForCellAtIndexPath:(NSIndexPath *)indexPath;
- (__kindof XZMocoaGroupReusableViewModel *)viewModelForSupplementOfKind:(XZMocoaKind)kind atIndexPath:(NSIndexPath *)indexPath;
- (__kindof XZMocoaGroupReusableViewModel *)viewModelForHeaderInSection:(NSInteger)section;
- (__kindof XZMocoaGroupReusableViewModel *)viewModelForFooterInSection:(NSInteger)section;

- (nullable NSIndexPath *)indexPathForCellViewModel:(XZMocoaGroupReusableViewModel *)viewModel;
- (nullable NSIndexPath *)indexPathForSupplementViewModel:(XZMocoaGroupReusableViewModel *)viewModel;

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(NSInteger)scrollPosition;
- (void)deselectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

// MARK: - 视图模型接收“数据更新”事件

/// 数据更新后，调用此方法以重载所有受管理的子视图模型。
- (void)reloadData;

/// 指定 section 的数据发生更新后，调用此方法以重载该 section 的视图模型。
/// @param section 数据发生更新的位置
- (void)reloadSection:(NSInteger)section;

/// 新增指定 section 的数据后，调用此方法以构造该 section 的视图模型。
/// @param section 新增的位置
- (void)insertSection:(NSInteger)section;

/// 删除指定 section 的数据后，调用此方法以移除该 section 的视图模型。
/// @param section 被删除的位置
- (void)deleteSection:(NSInteger)section;

/// 指定 sections 的数据更新后，调用此方法以重载该 sections 的视图模型。
/// @param sections 数据发生更新的位置
- (void)reloadSections:(nullable NSIndexSet *)sections;

/// 新增指定 sections 的数据后，调用此方法以构造该 sections 的视图模型。
/// @param sections 新增的位置
- (void)insertSections:(nullable NSIndexSet *)sections;

/// 删除指定 sections 的数据后，调用此方法以移除该 sections 的视图模型。
/// @param sections 被删除的位置
- (void)deleteSections:(nullable NSIndexSet *)sections;

/// 移动 section 到新位置 newSection 处。
/// @param section 移动前的位置
/// @param newSection 移动后的位置
- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection;

- (void)reloadCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)insertCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)deleteCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)moveCellAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)performBatchUpdates:(void (^NS_NOESCAPE)(void))batchUpdates completion:(void (^ _Nullable)(BOOL))completion;

// MARK: - 视图模型的事件派发，子类必须重写并根据实际去实现

// 如下 -did 方法，表示对应的事件已经发生，需要更新视图对应的视图了。
// 子类应该重写下面的方法，并更新视图。

- (void)didReloadData;
- (void)didDeselectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(NSInteger)scrollPosition;

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
- (Class)viewModelClassForPlaceholderForKind:(XZMocoaKind)kind;

@end

/// 视图模型处理数据的方法。
/// - 建议优先通过为数据拓展实现`XZMocoaGroupModel`协议，来解决数据格式标准化的问题。
/// - 也可通过子类重写如下方法，定制数据解析过程。
@interface XZMocoaGroupViewModel (XZMocoaGroupModel)
- (NSInteger)model:(nullable id<XZMocoaGroupModel>)model numberOfSections:(nullable id)null;
- (NSInteger)model:(nullable id<XZMocoaGroupModel>)model numberOfCellsInSection:(NSInteger)section;
- (nullable id)model:(nullable id<XZMocoaGroupModel>)model modelForCellAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)model:(nullable id<XZMocoaGroupModel>)model kind:(XZMocoaKind)kind numberOfSupplementsInSection:(NSInteger)section;
- (nullable id)model:(nullable id<XZMocoaGroupModel>)model kind:(XZMocoaKind)kind modelForSupplementAtIndexPath:(NSIndexPath *)indexPath;
@end

/// 支持直接使用 NSFetchedResultsController 作为数据源，且支持作为 NSFetchedResultsController 的代理。
///
/// 需要主动设置 NSFetchedResultsController 的代理为当前视图模型，默认不会主动设置。
@interface XZMocoaGroupViewModel (NSFetchedResultsControllerDelegate) <NSFetchedResultsControllerDelegate>
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller;
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath;
@end

NS_ASSUME_NONNULL_END
