//
//  XZMocoaGroupSectionViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2021/1/13.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaGroupSectionViewModel.h"
#import "XZMocoaDefines.h"
#import "XZMocoaGroupViewModel.h"
#import "XZMocoaGroupCellModel.h"
#import "NSArray+XZKit.h"
#import "NSIndexSet+XZKit.h"
#import "NSDictionary+XZKit.h"
#import "XZLog.h"

/// 在批量更新的过程中，同一元素只能应用一个操作，但是在 MVVM 结构中，
/// 数据变化也可能会引起刷新操作，为了避免多个更新操作，因此会将这些操作暂存并延迟执行。
/// Mocoa 并不能区分所有重复操作，开发者应避免。
typedef void(^XZMocoaGroupDelayedUpdates)(XZMocoaGroupSectionViewModel *self);

@interface XZMocoaGroupSectionViewModel () {
    /// 批量更新前保存的 cell 视图模型。非 nil 时，表示当前正在批量更新。
    /// 没有直接更新 supplementary 的操作，所以 supplementary 视图模型在批量更新的过程中不会改变。
    NSOrderedSet *_beforesBatchUpdates;
    /// 批量更新过程中产生的事件。
    NSMutableArray<XZMocoaGroupDelayedUpdates> *_delayedBatchUpdates;
    NSMutableArray<void (^)(BOOL)>             *_handlerBatchUpdates;
    /// 是否需要执行批量更新的差异分析。
    /// @note 在批量更新时，任一更新操作被调用，都会标记此值为 NO
    BOOL _needsDifferenceBatchUpdates;
    /// 记录 cell 视图模型的数组。
    NSMutableOrderedSet<XZMocoaGroupCellViewModel *> *_cellViewModels;
    NSMutableDictionary<XZMocoaKind, NSMutableArray<XZMocoaViewModel *> *> *_supplementaryViewModels;
}
@end

@implementation XZMocoaGroupSectionViewModel

@dynamic model, superViewModel;

- (instancetype)initWithModel:(id)model {
    self = [super initWithModel:model];
    if (self) {
        _beforesBatchUpdates = nil;
        _cellViewModels          = [NSMutableOrderedSet orderedSet];
        _supplementaryViewModels = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)prepare {
    [super prepare];
    [self _loadSubViewModelsWithoutEvents];
}

- (void)didRemoveSubViewModel:(__kindof XZMocoaViewModel *)viewModel {
    for (XZMocoaKind kind in _supplementaryViewModels) {
        NSMutableArray * const viewModels = _supplementaryViewModels[kind];
        NSInteger        const count      = viewModels.count;
        if (count == 1) {
            if (viewModels.firstObject == viewModel) {
                _supplementaryViewModels[kind] = nil;
                return;
            }
        } else {
            for (NSInteger index = 0; index < count; index++) {
                if (viewModels[index] == viewModel) {
                    [viewModels removeObjectAtIndex:index];
                    return;
                }
            }
        }
    }
    [_cellViewModels removeObject:viewModel];
}

- (void)didReceiveEvents:(XZMocoaEvents *)events {
    if (![events.key isEqualToString:XZMocoaKeyReload]) {
        return [super didReceiveEvents:events];
    }
    
    XZMocoaViewModel * const subViewModel = events.target;
    
    XZMocoaKind kind = nil;
    NSInteger const index = [_cellViewModels indexOfObject:(id)subViewModel];
    if (index != NSNotFound) {
        kind = @"cell";
    } else {
        kind = [_supplementaryViewModels xz_first:^id _Nullable(XZMocoaKind key, NSMutableArray<XZMocoaViewModel *> *obj) {
            for (XZMocoaGroupSectionSupplementaryViewModel *vm in obj) {
                if (subViewModel == vm) {
                    return key;
                }
            }
            return nil;
        }];
    }
    
    if (kind == nil) {
        return [super didReceiveEvents:events];
    }
    
    // 正在批量更新，延迟事件（如果对象被销毁，事件则不会执行）
    if (self.isPerformingBatchUpdates) {
        [_delayedBatchUpdates addObject:^void(XZMocoaGroupSectionViewModel *self) {
            [self didReceiveEvents:events];
        }];
        return;
    }
    
    // cell视图的更新事件
    if ([kind isEqualToString:@"cell"]) {
        [self didReloadCellsAtIndexes:[NSIndexSet indexSetWithIndex:index]];
        return;
    }
    
    // 附加视图更新事件
    [self didReloadData];
}

#pragma mark - 公开方法

- (BOOL)isEmpty {
    return _supplementaryViewModels.count == 0 && _cellViewModels.count == 0;
}

- (NSArray *)cellViewModels {
    return _cellViewModels.array;
}

- (XZMocoaViewModel *)viewModelForSupplementaryElementOfKind:(XZMocoaKind)kind atIndex:(NSInteger)index {
    return _supplementaryViewModels[kind][index];
}

- (NSDictionary<XZMocoaKind,NSArray<XZMocoaViewModel *> *> *)supplementaryViewModels {
    return _supplementaryViewModels;
}

- (NSInteger)numberOfCells {
    return _cellViewModels.count;
}

- (__kindof XZMocoaGroupCellViewModel *)cellViewModelAtIndex:(NSInteger)index {
    return [_cellViewModels objectAtIndex:index];
}

- (NSInteger)indexOfCellViewModel:(XZMocoaGroupCellViewModel *)cellModel {
    return [_cellViewModels indexOfObject:cellModel];
}

#pragma mark - 局部更新

- (void)reloadData {
    _needsDifferenceBatchUpdates = NO;
    
    { // 清理旧数据
        NSMutableDictionary * const supplementaryViewModels = _supplementaryViewModels.copy;
        NSOrderedSet        * const cellViewModels          = _cellViewModels.copy;
        
        [_supplementaryViewModels removeAllObjects];
        [_cellViewModels removeAllObjects];
        
        [supplementaryViewModels enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableArray *obj, BOOL *stop) {
            [obj enumerateObjectsUsingBlock:^(XZMocoaViewModel *viewModel, NSUInteger idx, BOOL * _Nonnull stop) {
                [viewModel removeFromSuperViewModel];
            }];
        }];
        for (XZMocoaViewModel *viewModel in cellViewModels) {
            [viewModel removeFromSuperViewModel];
        }
    }
    // 加载新数据
    [self _loadSubViewModelsWithoutEvents];
    
    // 发送事件
    [self didReloadData];
}

- (void)reloadCellAtIndex:(NSInteger)row {
    [self reloadCellsAtIndexes:[NSIndexSet indexSetWithIndex:row]];
}

- (void)insertCellAtIndex:(NSInteger)row {
    [self insertCellsAtIndexes:[NSIndexSet indexSetWithIndex:row]];
}

- (void)deleteCellAtIndex:(NSInteger)row {
    [self deleteCellsAtIndexes:[NSIndexSet indexSetWithIndex:row]];
}

- (void)reloadCellsAtIndexes:(NSIndexSet *)indexes {
    _needsDifferenceBatchUpdates = NO;
    
    if (indexes.count == 0) {
        return;
    }
    
    id const model = self.model;
    
    if (self.isPerformingBatchUpdates) {
        // 在批量更新的操作中，其它的 cell 位置改变，可能会影响 reload 的 cell 改变位置，所以需要找到其原始位置。
        NSMutableIndexSet * const oldIndexes = [NSMutableIndexSet indexSet];
        [indexes enumerateIndexesUsingBlock:^(NSUInteger const index, BOOL * _Nonnull stop) {
            XZMocoaGroupCellViewModel * const oldViewModel = [self cellViewModelAtIndex:index];
            NSInteger const oldRow = [_beforesBatchUpdates indexOfObject:oldViewModel];
            [oldIndexes addIndex:oldRow];
            [oldViewModel removeFromSuperViewModel];
            
            id const newDataModel = [self model:model modelForCellAtIndex:index];
            id const newViewModel = [self createCellViewModelWithModel:newDataModel index:index];
            [self insertCellViewModel:newViewModel atIndex:index];
        }];
        [self didReloadCellsAtIndexes:oldIndexes];
    } else {
        [indexes enumerateIndexesUsingBlock:^(NSUInteger const index, BOOL * _Nonnull stop) {
            XZMocoaGroupCellViewModel * const oldViewModel = _cellViewModels[index];
            [oldViewModel removeFromSuperViewModel]; // 由 -didRemoveSubViewModel: 执行清理
            
            id const newDataModel = [self model:model modelForCellAtIndex:index];
            id const newViewModel = [self createCellViewModelWithModel:newDataModel index:index];
            [self insertCellViewModel:newViewModel atIndex:index];
        }];
        [self didReloadCellsAtIndexes:indexes];
    }
}

- (void)insertCellsAtIndexes:(NSIndexSet *)indexes {
    _needsDifferenceBatchUpdates = NO;
    
    if (indexes.count == 0) {
        return;
    }
    
    id const model = self.model;
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger const index, BOOL * _Nonnull stop) {
        id const newDataModel = [self model:model modelForCellAtIndex:index];
        id const newViewModel = [self createCellViewModelWithModel:newDataModel index:index];
        [self insertCellViewModel:newViewModel atIndex:index];
    }];
    
    [self didInsertCellsAtIndexes:indexes];
    
    if (self.isPerformingBatchUpdates) {
        return;
    }
    
    // 更新 index
    NSInteger const count = self.numberOfCells;
    for (NSInteger index = indexes.firstIndex; index < count; index++) {
        if ([indexes containsIndex:index]) {
            continue;
        }
        [self cellViewModelAtIndex:index].index = index;
    }
}

- (void)deleteCellsAtIndexes:(NSIndexSet *)indexes {
    _needsDifferenceBatchUpdates = NO;
    
    if (indexes.count == 0) {
        return;
    }
    
    if (self.isPerformingBatchUpdates) {
        NSMutableIndexSet * const oldIndexes = [NSMutableIndexSet indexSet];
        [indexes enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger const index, BOOL * _Nonnull stop) {
            XZMocoaGroupCellViewModel * const oldViewModel = [self cellViewModelAtIndex:index];
            NSInteger const oldRow = [_beforesBatchUpdates indexOfObject:oldViewModel];
            [oldIndexes addIndex:oldRow];
            
            [oldViewModel removeFromSuperViewModel];
        }];
        [self didDeleteCellsAtIndexes:oldIndexes];
    } else {
        [indexes enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger const index, BOOL * _Nonnull stop) {
            XZMocoaGroupCellViewModel * const oldViewModel = [self cellViewModelAtIndex:index];
            [oldViewModel removeFromSuperViewModel];
        }];
        [self didDeleteCellsAtIndexes:indexes];
        
        NSInteger const count = self.numberOfCells;
        for (NSInteger index = indexes.firstIndex; index < count; index++) {
            [self cellViewModelAtIndex:index].index = index;
        }
    }
}

- (void)moveCellAtIndex:(NSInteger)index toIndex:(NSInteger)newIndex {
    if (self.isPerformingBatchUpdates) {
        id const viewModel = [self cellViewModelAtIndex:index];
        NSInteger const oldIndex = [_beforesBatchUpdates indexOfObject:viewModel];
        [self moveCellAtIndex:index fromIndex:oldIndex toIndex:newIndex];
    } else {
        [self moveCellAtIndex:index fromIndex:index toIndex:newIndex];
        
        NSInteger const min = MIN(index, newIndex);
        NSInteger const max = MAX(index, newIndex);
        for (NSInteger index = min; index <= max; index++) {
            [self cellViewModelAtIndex:index].index = index;
        }
    }
}

/// 移动 Cell 位置。
/// @param row 当前位置
/// @param oldRow 原始位置（批量更新前的位置）
/// @param newRow 目标位置
- (void)moveCellAtIndex:(NSInteger)row fromIndex:(NSInteger)oldRow toIndex:(NSInteger)newRow {
    _needsDifferenceBatchUpdates = NO;
    
    if (row != newRow) {
        [self _moveCellViewModelFromIndex:row toIndex:newRow];
    }
    
    if (oldRow == newRow) {
        return;
    }
    
    [self didMoveCellAtIndex:oldRow toIndex:newRow];
}

#pragma mark - 事件派发

- (void)didReloadData {
    // 初始化还未完成，视图还没渲染，纯数据更新，不需要通知上级，因为渲染时，拿到的就是更新后的内容。
    if (!self.isReady) return;
    [self.superViewModel sectionViewModel:self didReloadData:NULL];
}

- (void)didReloadCellsAtIndexes:(NSIndexSet *)rows {
    if (!self.isReady) return;
    [self.superViewModel sectionViewModel:self didReloadCellsAtIndexes:rows];
}

- (void)didInsertCellsAtIndexes:(NSIndexSet *)rows {
    if (!self.isReady) return;
    [self.superViewModel sectionViewModel:self didInsertCellsAtIndexes:rows];
}

- (void)didDeleteCellsAtIndexes:(NSIndexSet *)rows {
    if (!self.isReady) return;
    [self.superViewModel sectionViewModel:self didDeleteCellsAtIndexes:rows];
}

- (void)didMoveCellAtIndex:(NSInteger)row toIndex:(NSInteger)newRow {
    if (!self.isReady) return;
    [self.superViewModel sectionViewModel:self didMoveCellAtIndex:row toIndex:newRow];
}

- (void)didPerformBatchUpdates:(void (^NS_NOESCAPE)(void))batchUpdates completion:(void (^)(BOOL))completion {
    if (self.isReady) {
        [self.superViewModel sectionViewModel:self didPerformBatchUpdates:batchUpdates completion:completion];
    } else {
        batchUpdates(); // 还在初始化的过程中，直接执行更新数据。
        if (completion) dispatch_async(dispatch_get_main_queue(), ^{ completion(YES); });
    }
}

#pragma mark - 批量更新

- (BOOL)isPerformingBatchUpdates {
    return _beforesBatchUpdates != nil;
}

- (BOOL)prepareForBatchUpdates {
    if (_beforesBatchUpdates) {
        return NO;
    }
    _beforesBatchUpdates = _cellViewModels.copy;
    _delayedBatchUpdates = [NSMutableArray array];
    _handlerBatchUpdates = [NSMutableArray array];
    _needsDifferenceBatchUpdates = YES;
    return YES;
}

- (void)cleanupForBatchUpdates {
    _needsDifferenceBatchUpdates = NO;
    for (XZMocoaGroupDelayedUpdates batchUpdates in _delayedBatchUpdates) {
        batchUpdates(self);
    }
    _handlerBatchUpdates = nil;
    _delayedBatchUpdates = nil;
    _beforesBatchUpdates = nil;
}

- (void)performBatchUpdates:(void (^NS_NOESCAPE)(void))batchUpdates completion:(void (^ _Nullable)(BOOL))completion {
    NSAssert(batchUpdates != nil, @"必须提供 batchUpdates 参数");
    
    if (![self prepareForBatchUpdates]) {
        XZLog(@"[XZMocoaGroupSectionViewModel] 批量更新重入");
        batchUpdates();
        if (completion) [_handlerBatchUpdates addObject:completion];
        return;
    }
    
    XZLog(@"[XZMocoaGroupSectionViewModel] 批量更新开始");
    
    void (^const tableViewBatchUpdates)(void) = ^{
        batchUpdates();
        [self differenceBatchUpdatesIfNeeded];
    };
    
    NSArray * const _handlerBatchUpdates = self->_handlerBatchUpdates;
    [self didPerformBatchUpdates:tableViewBatchUpdates completion:^(BOOL finished) {
        for (void (^completion)(BOOL) in _handlerBatchUpdates) {
            completion(finished);
        }
    }];
    
    // 清理批量更新环境，并执行延迟的事件
    [self cleanupForBatchUpdates];
    
    XZLog(@"[XZMocoaGroupSectionViewModel] 批量更新结束");
    
    NSInteger const count = self.numberOfCells;
    for (NSInteger row = 0; row < count; row++) {
        [self cellViewModelAtIndex:row].index = row;
    }
}

- (NSIndexSet *)differenceBatchUpdatesIfNeeded {
    if (!_needsDifferenceBatchUpdates) {
        XZLog(@"[XZMocoaGroupSectionViewModel] 差异分析：禁用");
        return nil;
    }
    _needsDifferenceBatchUpdates = NO;
    
    XZLog(@"[XZMocoaGroupSectionViewModel] 差异分析：开始");
    
    // 进入了差异性分析流程，说明当前视图模型数据没有发生修改
    
    id const model = self.model;
    
    BOOL needsUpdateAll = NO;
    
    // 检查并更新 Supplementary
    for (XZMocoaKind const kind in self.superViewModel.supportedSupplementaryKinds) {
        NSInteger const newCount = [self model:model numberOfModelsForSupplementaryElementOfKind:kind];

        NSMutableArray<XZMocoaViewModel *> * viewModels = _supplementaryViewModels[kind];
        
        for (NSInteger index = 0; index < newCount; index++) {
            id newDataModel = [self model:model modelForSupplementaryElementOfKind:kind atIndex:index];
            // 提前转化 kCFNull 因为 vm 中的 model 提前转化了
            if (newDataModel == (id)kCFNull) {
                newDataModel = nil;
            }
            if (index < viewModels.count) {
                id const oldDataModel = viewModels[index].model;
                // 数据未更新
                if (newDataModel == oldDataModel || (newDataModel && [newDataModel isEqual:oldDataModel])) {
                    continue;
                }
                needsUpdateAll = YES;
                viewModels[index] = [self createSupplementaryElementViewModelWithModel:newDataModel kind:kind index:index];
            } else {
                needsUpdateAll = YES;
                if (viewModels == nil) {
                    viewModels = [NSMutableArray arrayWithCapacity:newCount];
                    _supplementaryViewModels[kind] = viewModels;
                }
                viewModels[index] = [self createSupplementaryElementViewModelWithModel:newDataModel kind:kind index:index];
            }
        }
    }
    
    if (needsUpdateAll) {
        XZLog(@"[XZMocoaGroupSectionViewModel] 差异分析：停止，因 Supplementary 导致整体刷新");
        [self reloadCellsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _cellViewModels.count)]];
        return nil;
    }
    
    NSOrderedSet * const oldViewModels = _beforesBatchUpdates.copy;
    NSInteger      const oldCount      = oldViewModels.count;
    NSArray      * const oldDataModels = [NSMutableArray arrayWithCapacity:oldCount];
    for (NSInteger i = 0; i < oldCount; i++) {
        XZMocoaGroupCellViewModel * const viewModel = oldViewModels[i];
        id const oldDataModel = viewModel.model;
        [(NSMutableArray *)oldDataModels addObject:(oldDataModel ?: (id)kCFNull)];
    }
    
    if (oldDataModels.xz_containsEqualObjects) {
        XZLog(@"[XZMocoaGroupSectionViewModel] 差异分析：停止，因为旧数据存在重复数据");
        [self reloadCellsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, oldCount)]];
        return nil;
    }
    
    NSInteger const newCount      = [self model:model numberOfCellModels:NULL];
    NSArray * const newDataModels = [NSMutableArray arrayWithCapacity:newCount];
    for (NSInteger index = 0; index < newCount; index++) {
        id const newDataModel = [self model:model modelForCellAtIndex:index];
        [(NSMutableArray *)newDataModels addObject:(newDataModel ?: (id)kCFNull)];
    }
    
    if (newDataModels.xz_containsEqualObjects) {
        XZLog(@"[XZMocoaGroupSectionViewModel] 差异分析：停止，因为新数据存在重复数据");
        [self reloadCellsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, oldCount)]];
        return nil;
    }
    
    NSIndexSet   * const inserts = [NSMutableIndexSet indexSet];
    NSIndexSet   * const deletes = [NSMutableIndexSet indexSet];
    NSIndexSet   * const remains = [NSMutableIndexSet indexSet];
    NSDictionary<NSNumber *, NSNumber *> * const changes = [NSMutableDictionary dictionaryWithCapacity:oldCount];
    [newDataModels xz_differenceFromArray:oldDataModels inserts:(id)inserts deletes:(id)deletes changes:(id)changes remains:(id)remains];
    
    // 1、更新数据：先执行删除，后执行添加
    [deletes enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger const index, BOOL *stop) {
        [[self cellViewModelAtIndex:index] removeFromSuperViewModel];
    }];
    [self didDeleteCellsAtIndexes:deletes];
    
    XZLog(@"[XZMocoaGroupSectionViewModel] 差异分析：删除 [ %@ ]", [deletes xz_reduce:nil next:^id _Nullable(NSMutableString *result, NSInteger idx, BOOL * _Nonnull stop) {
        if (result) {
            [result appendFormat:@", %ld", idx];
        } else {
            result = [NSMutableString stringWithFormat:@"%ld", idx];
        }
        return result;
    }]);
    
    NSDictionary<NSNumber *, XZMocoaViewModel *> * const newViewModels = [NSMutableDictionary dictionaryWithCapacity:inserts.count];
    [inserts enumerateIndexesUsingBlock:^(NSUInteger const index, BOOL * _Nonnull stop) {
        id<XZMocoaGroupCellModel>   const newDataModel = newDataModels[index];
        XZMocoaGroupCellViewModel * const newViewModel = [self createCellViewModelWithModel:newDataModel index:index];
        [self insertCellViewModel:newViewModel atIndex:index];
        ((NSMutableDictionary *)newViewModels)[@(index)] = newViewModel;
    }];
    [self didInsertCellsAtIndexes:inserts];
    
    XZLog(@"[XZMocoaGroupSectionViewModel] 差异分析：添加 [ %@ ]", [inserts xz_reduce:nil next:^id _Nullable(NSMutableString *result, NSInteger idx, BOOL * _Nonnull stop) {
        if (result) {
            [result appendFormat:@", %ld", idx];
        } else {
            result = [NSMutableString stringWithFormat:@"%ld", idx];
        }
        return result;
    }]);
    
    // 排序移动
    for (NSInteger to = 0; to < newCount; to++) {
        if ([inserts containsIndex:to]) {
            id const viewModel = newViewModels[@(to)];
            NSInteger const index = [self indexOfCellViewModel:viewModel];
            [self _moveCellViewModelFromIndex:index toIndex:to];
        } else if ([remains containsIndex:to]) {
            // to 位置为保持不变的元素，在 old 中找到 viewModel 然后将其移动到 to 位置上。
            XZMocoaGroupCellViewModel * const viewModel = oldViewModels[to];
            // 更新数据
            viewModel.model = newDataModels[to];
            // 调整位置
            NSInteger const index = [self indexOfCellViewModel:viewModel];
            [self _moveCellViewModelFromIndex:index toIndex:to];
        } else {
            // to 位置为被移动的元素，先找到它原来的位置，然后找到 viewModel 然后再移动位置。
            NSInteger const from = changes[@(to)].integerValue;
            // 更新数据
            XZMocoaGroupCellViewModel * const viewModel = oldViewModels[from];
            viewModel.model = newDataModels[to];
            // 移动位置
            NSInteger const index = [self indexOfCellViewModel:viewModel];
            [self _moveCellViewModelFromIndex:index toIndex:to];
            [self didMoveCellAtIndex:from toIndex:to];
            XZLog(@"[XZMocoaGroupSectionViewModel] 差异分析：移动 %ld => %ld", from, to);
        }
    }
    
    XZLog(@"[XZMocoaGroupSectionViewModel] 差异分析：结束");
    
    return nil;
}

#pragma mark - 私有方法

- (void)_addCellViewModel:(XZMocoaGroupCellViewModel *)cellViewModel {
    [_cellViewModels addObject:cellViewModel];
    [self addSubViewModel:cellViewModel];
}

- (XZMocoaGroupCellViewModel *)removeCellViewModelAtIndex:(NSInteger)index {
    XZMocoaGroupCellViewModel *viewModel = _cellViewModels[index];
    [_cellViewModels removeObjectAtIndex:index];
    [viewModel removeFromSuperViewModel];
    return viewModel;
}

- (void)insertCellViewModel:(XZMocoaGroupCellViewModel *)cellViewModel atIndex:(NSInteger)index {
    [_cellViewModels insertObject:cellViewModel atIndex:index];
    [self addSubViewModel:cellViewModel];
}

- (void)_moveCellViewModelFromIndex:(NSInteger)row toIndex:(NSInteger)newRow {
    if (newRow == row) return;
    id const viewModel = _cellViewModels[row];
    [_cellViewModels removeObjectAtIndex:row];
    [_cellViewModels insertObject:viewModel atIndex:newRow];
}

- (void)_loadSubViewModelsWithoutEvents {
    NSAssert(_supplementaryViewModels.count == 0 && _cellViewModels.count == 0, @"调用此方法前要清除现有的数据");
    
    id const model = self.model;
    
    for (XZMocoaKind kind in self.superViewModel.supportedSupplementaryKinds) {
        NSInteger const count = [self model:model numberOfModelsForSupplementaryElementOfKind:kind];
        for (NSInteger index = 0; index < count; index++) {
            id const dataModel = [self model:model modelForSupplementaryElementOfKind:kind atIndex:index];
            XZMocoaGroupSectionSupplementaryViewModel * const viewModel = [self createSupplementaryElementViewModelWithModel:dataModel kind:kind index:index];
            if (_supplementaryViewModels[kind]) {
                [_supplementaryViewModels[kind] addObject:viewModel];
            } else {
                _supplementaryViewModels[kind] = [NSMutableArray arrayWithObject:viewModel];
            }
            [self addSubViewModel:viewModel];
        }
    }
    
    NSInteger const count = [self model:model numberOfCellModels:NULL];
    for (NSInteger index = 0; index < count; index++) {
        id<XZMocoaGroupCellModel> const dataModel = [self model:model modelForCellAtIndex:index];
        XZMocoaGroupCellViewModel *viewModel = [self createCellViewModelWithModel:dataModel index:index];
        [self _addCellViewModel:viewModel];
    }
}

- (XZMocoaGroupCellViewModel *)createCellViewModelWithModel:(id<XZMocoaGroupCellModel> const)nullableModel index:(NSInteger)index {
    id<XZMocoaModel> const model   = (nullableModel == (id)kCFNull ? nil : nullableModel);
    XZMocoaName      const section = ((id<XZMocoaGroupSectionModel>)self.model).mocoaName;
    XZMocoaName      const name    = model.mocoaName;
    XZMocoaModule *  const module  = [self.module submoduleIfLoadedForKind:XZMocoaKindCell forName:name];
    
    Class     VMClass    = [self _loadSubViewModelClassWithModule:module name:name kind:XZMocoaKindCell section:section];
    NSString *identifier = nil;
    
    if (VMClass) {
        identifier = module.viewReuseIdentifier ?: XZMocoaReuseIdentifier(section, XZMocoaKindCell, name);
    } else {
        VMClass = [self placeholderViewModelClassForCellAtIndex:index];
        identifier = XZMocoaReuseIdentifier(XZMocoaNamePlaceholder, XZMocoaKindCell, XZMocoaNamePlaceholder);
    }
    
    XZMocoaGroupCellViewModel *viewModel = [[VMClass alloc] initWithModel:model];
    viewModel.identifier = identifier;
    viewModel.index      = index;
    viewModel.module     = module;
    return viewModel;
}

- (XZMocoaGroupSectionSupplementaryViewModel *)createSupplementaryElementViewModelWithModel:(id const)nullableModel kind:(XZMocoaKind)kind index:(NSInteger)index {
    id<XZMocoaModel> const model   = (nullableModel == (id)kCFNull ? nil : nullableModel);
    XZMocoaName      const section = ((id<XZMocoaGroupSectionModel>)self.model).mocoaName;
    XZMocoaName      const name    = model.mocoaName;
    XZMocoaModule *  const module  = [self.module submoduleIfLoadedForKind:kind forName:name];
    
    Class      VMClass    = [self _loadSubViewModelClassWithModule:module name:name kind:kind section:section];
    NSString * identifier = nil;
    
    if (VMClass) {
        identifier = module.viewReuseIdentifier ?: XZMocoaReuseIdentifier(section, kind, name);
    } else {
        VMClass = [self placeholderViewModelClassForSupplementaryKind:kind atIndex:index];
        identifier = XZMocoaReuseIdentifier(XZMocoaNamePlaceholder, kind, XZMocoaNamePlaceholder);
    }
    
    XZMocoaGroupSectionSupplementaryViewModel *viewModel = [[VMClass alloc] initWithModel:model];
    viewModel.index      = index;
    viewModel.module     = module;
    viewModel.identifier = identifier;
    return viewModel;
}

/// 按照 currentSection_currentCell -> currentSection_defaultCell -> defaultSection_currentCell -> defaultSection_defaultCell -> placeholder 的顺序查找视图模型。
- (nullable Class)_loadSubViewModelClassWithModule:(XZMocoaModule *)module name:(XZMocoaName)name kind:(XZMocoaKind)kind section:(XZMocoaName)section {
    switch (module.viewForm) {
        case XZMocoaModuleViewFormNib:
        case XZMocoaModuleViewFormClass:
        case XZMocoaModuleViewFormStoryboardReusableView: {
            Class VMClass = module.viewModelClass;
            
            // 已注册视图模型
            if (VMClass) {
                return VMClass;
            }
            
            // 查找同 section 的默认视图模型
            if ([name isEqualToString:XZMocoaNameDefault]) {
                // 当前就是默认视图模型，继续往下查找
            } else {
                VMClass = [self.module submoduleIfLoadedForKind:kind forName:XZMocoaNameDefault].viewModelClass;
                if (VMClass) {
                    return VMClass;
                }
            }
            
            // 查找默认 section
            XZMocoaModule * const defaultSectionModule = [self.superViewModel.module submoduleIfLoadedForKind:XZMocoaKindSection forName:XZMocoaNameDefault];
            
            // 当前已经是默认 section 结束查找
            if (defaultSectionModule == self.module) {
                return nil;
            }
            
            // 查找默认 section 的具名视图模型
            VMClass = [defaultSectionModule submoduleIfLoadedForKind:kind forName:name].viewModelClass;
            if (VMClass) {
                return VMClass;
            }
            
            // 查找默认 section 的默认视图模型（如果没有，则返回 Nil 使用占位视图）
            VMClass = [defaultSectionModule submoduleIfLoadedForKind:kind forName:XZMocoaNameDefault].viewModelClass;
            return VMClass;
        }
        default: {
            // 未注册模块，或者未注册视图，使用占位视图
            return Nil;
        }
    }
}

#if XZ_DEBUG || DEBUG
- (NSArray *)cellDataModels {
    NSInteger const count = self.numberOfCells;
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        id dataModel = [self cellViewModelAtIndex:i].model;
        if (dataModel == nil) {
            dataModel = [NSNull null];
        }
        [result addObject:dataModel];
    }
    return result;
}
#endif

#pragma mark - 子类重写

- (Class)placeholderViewModelClassForCellAtIndex:(NSInteger)index {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (Class)placeholderViewModelClassForSupplementaryKind:(XZMocoaKind)kind atIndex:(NSInteger)index {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

@end

@implementation XZMocoaGroupSectionViewModel (XZMocoaGroupSectionModelTransformer)

- (nullable id)model:(nullable id)model modelForCellAtIndex:(NSInteger)index {
    return [((id<XZMocoaGroupSectionModel>)model) modelForCellAtIndex:index];
}

- (NSInteger)model:(nullable id)model numberOfCellModels:(void * _Nullable)null {
    return [((id<XZMocoaGroupSectionModel>)model) numberOfCellModels];
}

- (nullable id)model:(nullable id)model modelForSupplementaryElementOfKind:(nonnull XZMocoaKind)kind atIndex:(NSInteger)index {
    return [((id<XZMocoaGroupSectionModel>)model) modelForSupplementaryElementOfKind:kind atIndex:index];
}

- (NSInteger)model:(nullable id)model numberOfModelsForSupplementaryElementOfKind:(nonnull XZMocoaKind)kind {
    return [((id<XZMocoaGroupSectionModel>)model) numberOfModelsForSupplementaryElementOfKind:kind];
}

@end
