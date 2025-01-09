//
//  XZMocoaListViewSectionViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2021/1/13.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaViewModel.h"
#import "XZMocoaListViewModelDefines.h"
#import "XZMocoaListSectionModel.h"
#import "XZMocoaListViewSupplementaryViewModel.h"
#import "XZMocoaListViewCellViewModel.h"

@class XZMocoaListViewModel;

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaListViewSectionViewModel : XZMocoaViewModel <XZMocoaListViewModel>

@property (nonatomic, strong, nullable) id<XZMocoaListSectionModel> model;
@property (nonatomic, readonly, nullable) __kindof XZMocoaListViewModel *superViewModel;

/// 接收来自下级的 XZMocoaUpdateNameUpdate 事件，并刷新视图，如果在批量更新的过程中，视图刷新可能会延迟。
- (void)didReceiveUpdate:(XZMocoaUpdate *)emition;

/// 所有 cell 视图模型。这是一个计算属性，除非遍历所有 cell 对象，请尽量避免直接使用。
- (nullable __kindof XZMocoaListViewSupplementaryViewModel *)viewModelForSupplementaryKind:(XZMocoaKind)kind atIndex:(NSInteger)index;
/// 直接返回了内部对象，外部请勿修改，使用请自行 copy 。
@property (nonatomic, readonly) NSDictionary<XZMocoaKind, NSArray<__kindof XZMocoaListViewSupplementaryViewModel *> *> *supplementaryViewModels;

@property (nonatomic, copy, readonly) NSArray<__kindof XZMocoaListViewCellViewModel *> *cellViewModels;

/// 返回 YES 表示 header/cell/footer 都没有。
@property (nonatomic, readonly) BOOL isEmpty;

@property (nonatomic, readonly) NSInteger numberOfCells;
- (__kindof XZMocoaListViewCellViewModel *)cellViewModelAtIndex:(NSInteger)index;
- (NSInteger)indexOfCellViewModel:(__kindof XZMocoaListViewCellViewModel *)cellViewModel;

// MARK: - 局部更新

/// 重载所有视图模型。
- (void)reloadData;

/// 创建视图模型，并替换现有的视图模型。
/// @note 执行此方法前，请确保相应的数据已更新。
/// @param row 视图模型所在的行
- (void)reloadCellAtIndex:(NSInteger)row;

/// 创建视图模型，并插入到指定位置。
/// @note 执行此方法前，请确保已经新增相应的数据。
/// @param row 新增的行
- (void)insertCellAtIndex:(NSInteger)row;

/// 移除指定的视图模型。
/// @note 执行此方法前，请确保相应的数据已移除。
/// @param row 删除的行
- (void)deleteCellAtIndex:(NSInteger)row;

/// 创建视图模型，并替换现有的视图模型。
/// @note 执行此方法前，请确保相应的数据已更新。
/// @param rows 数据发生更新的行
- (void)reloadCellsAtIndexes:(nullable NSIndexSet *)rows;

/// 创建视图模型，并插入到指定位置。
/// @note 执行此方法前，请确保已经新增相应的数据。
/// @param rows 新增的行
- (void)insertCellsAtIndexes:(nullable NSIndexSet *)rows;

/// 移除指定的视图模型。
/// @note 执行此方法前，请确保相应的数据已移除。
/// @param rows 删除的行
- (void)deleteCellsAtIndexes:(nullable NSIndexSet *)rows;

/// 移动视图模型的位置。移动行 row 到新行 newRow 处。
/// @note 执行此方法前，请确保相应的数据已移动。
/// @param row 移动前的位置
/// @param newRow 移动后的位置
- (void)moveCellAtIndex:(NSInteger)row toIndex:(NSInteger)newRow;

// MARK: - 事件派发

/// 向上级发送 Section 重载事件，以刷新视图。
- (void)didReloadData;
/// 向上级发送 Cell 重载事件，以刷新视图。
- (void)didReloadCellsAtIndexes:(NSIndexSet *)rows;
/// 向上级发送 Cell 插入事件，以刷新视图。
- (void)didInsertCellsAtIndexes:(NSIndexSet *)rows;
/// 向上级发送 Cell 删除事件，以刷新视图。
- (void)didDeleteCellsAtIndexes:(NSIndexSet *)rows;
/// 向上级发送 Cell 移动事件，以刷新视图。
- (void)didMoveCellAtIndex:(NSInteger)row toIndex:(NSInteger)newRow;
/// 向上级发送批量更新事件，以刷新视图。
- (void)didPerformBatchUpdates:(void (^NS_NOESCAPE)(void))batchUpdates completion:(void (^ _Nullable)(BOOL))completion;

// MARK: 子类必须重写的方法

- (Class)placeholderViewModelClassForCellAtIndex:(NSInteger)index;
- (Class)placeholderViewModelClassForSupplementaryKind:(XZMocoaKind)kind atIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
