//
//  XZMocoaGroupViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2021/1/23.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaGroupViewModel.h"
#import "XZMocoaDefines.h"
#import "XZMocoaModule.h"
#import "XZMacros.h"
#import "NSArray+XZKit.h"
#import "NSIndexSet+XZKit.h"
#import "XZLog.h"
#import "XZDefer.h"

@interface XZMocoaGroupSection<ObjectType> : NSObject

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) BOOL isEmpty;

@property (nonatomic, readonly, nullable) NSArray<ObjectType> *cells;
@property (nonatomic, readonly, nullable) NSDictionary<XZMocoaKind, NSArray<ObjectType> *> *supplements;

- (void)addCell:(ObjectType)cell;
- (void)insertCell:(ObjectType)cell atIndex:(NSInteger)index;
- (ObjectType)cellAtIndex:(NSInteger)index;
- (void)removeCellAtIndex:(NSInteger)index;
- (void)replaceCellAtIndex:(NSInteger)index withCell:(ObjectType)cell;
- (void)addSupplement:(ObjectType)object forKind:(XZMocoaKind)kind;
- (void)insertSupplement:(ObjectType)object atIndex:(NSInteger)index forKind:(XZMocoaKind)kind;
- (nullable NSMutableArray<ObjectType> *)supplementsForKind:(XZMocoaKind)kind;
- (nullable ObjectType)supplementForKind:(XZMocoaKind)kind atIndex:(NSInteger)index;
- (BOOL)isSupplementsEqualToSupplementsOfSection:(XZMocoaGroupSection *)section;

- (void)removeAllSupplements;
- (void)removeAllCells;
- (void)removeAllObjects;

- (void)copySupplementsFromSection:(XZMocoaGroupSection *)otherSection;

@property (nonatomic, readonly, nullable) ObjectType cell;
@property (nonatomic, readonly, nullable) ObjectType supplement;
@property (nonatomic, readonly, nullable) XZMocoaKind supplementKind;
@end

@interface XZMocoaGroupViewModel () {
    /// 每开始一个批量更新就会添加一个 BOOL 值到此数组中，标记该次批量更新是否需要差异分析。
    NSMutableArray<NSNumber *> *_needsDifferenceBatchUpdates;
    /// 所有视图模型。
    NSMutableArray<XZMocoaGroupSection<__kindof XZMocoaViewModel *> *> * _Nonnull _viewModelSections;
    /// 所有数据模型。
    NSMutableArray<XZMocoaGroupSection<id<XZMocoaModel>> *>            * _Nonnull _modelSections;
    /// 如果已经验证当前数据支持差异分析，此属性将被赋值。
    NSMapTable<id, NSIndexPath *> * _Nullable _modelIndexPathTable;
}

@end

@implementation XZMocoaGroupViewModel

- (instancetype)initWithModel:(id)model {
    self = [super initWithModel:model];
    if (self) {
        _modelIndexPathTable = nil;
        _viewModelSections = [NSMutableArray array];
        _modelSections     = [NSMutableArray array];
        _supportedSupplementKinds = @[XZMocoaKindHeader, XZMocoaKindFooter];
        _needsDifferenceBatchUpdates = [NSMutableArray array];
    }
    return self;
}

- (void)prepare {
    [super prepare];
    [self _reloadDataWithoutEvents];
}

- (BOOL)isEmpty {
    // 强制初始化。
    [self ready];
    // 任意 section 非空，列表非空
    for (XZMocoaGroupSection<XZMocoaViewModel *> *viewModelSection in _viewModelSections) {
        if (viewModelSection.isEmpty) {
            continue;
        }
        return NO;
    }
    return YES;
}

- (NSInteger)numberOfSections {
    return _viewModelSections.count;
}

- (NSInteger)numberOfCellsInSection:(NSInteger)section {
    return _viewModelSections[section].cells.count;
}

- (__kindof XZMocoaGroupReusableViewModel *)viewModelForCellAtIndexPath:(NSIndexPath *)indexPath {
    return _viewModelSections[indexPath.section].cells[indexPath.item];
}

- (__kindof XZMocoaGroupReusableViewModel *)viewModelForSupplementOfKind:(XZMocoaKind)kind atIndexPath:(NSIndexPath *)indexPath {
    return [_viewModelSections[indexPath.section] supplementForKind:kind atIndex:indexPath.item];
}

- (XZMocoaGroupReusableViewModel *)viewModelForHeaderInSection:(NSInteger)section {
    return [_viewModelSections[section] supplementsForKind:XZMocoaKindHeader].firstObject;
}

- (XZMocoaGroupReusableViewModel *)viewModelForFooterInSection:(NSInteger)section {
    return [_viewModelSections[section] supplementsForKind:XZMocoaKindFooter].firstObject;
}

- (NSIndexPath *)indexPathForCellViewModel:(XZMocoaGroupReusableViewModel *)viewModel {
    for (NSInteger sectionIndex = 0; sectionIndex < _viewModelSections.count; sectionIndex++) {
        NSArray * const cellViewModels = _viewModelSections[sectionIndex].cells;
        for (NSInteger itemIndex = 0; itemIndex < cellViewModels.count; itemIndex++) {
            if (viewModel == cellViewModels[itemIndex]) {
                return [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
            }
        }
    }
    return nil;
}

- (NSIndexPath *)indexPathForSupplementViewModel:(XZMocoaGroupReusableViewModel *)viewModel {
    NSIndexPath * __block indexPath = nil;
    for (NSInteger sectionIndex = 0; sectionIndex < _viewModelSections.count; sectionIndex++) {
        [_viewModelSections[sectionIndex].supplements enumerateKeysAndObjectsUsingBlock:^(XZMocoaKind key, NSArray<__kindof XZMocoaViewModel *> *supplementViewModels, BOOL *stop) {
            for (NSInteger itemIndex = 0; itemIndex < supplementViewModels.count; itemIndex++) {
                if (viewModel == supplementViewModels[itemIndex]) {
                    indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
                    *stop = YES;
                    return;
                }
            }
        }];
        if (indexPath) break;
    }
    return indexPath;
}

#pragma mark - 处理事件

- (void)didReceiveEvents:(XZMocoaEvents *)events {
    if ([events.key isEqualToString:XZMocoaKeyReloadData]) {
        return [self reloadData];
    }
    return [super didReceiveEvents:events];
}

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(NSInteger)scrollPosition {
    [self didSelectCellAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
}

- (void)deselectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    [self didDeselectCellAtIndexPath:indexPath animated:animated];
}

#pragma mark - 局部更新

- (void)reloadData {
    [self setNeedsDifferenceBatchUpdates:NO];
    _modelIndexPathTable = nil;
    [self _reloadDataWithoutEvents];
    [self didReloadData];
}

- (void)reloadSection:(NSInteger)section {
    [self reloadSections:[NSIndexSet indexSetWithIndex:section]];
}

- (void)insertSection:(NSInteger)section {
    [self insertSections:[NSIndexSet indexSetWithIndex:section]];
}

- (void)deleteSection:(NSInteger)section {
    [self deleteSections:[NSIndexSet indexSetWithIndex:section]];
}

- (void)reloadSections:(NSIndexSet *)sections {
    [self setNeedsDifferenceBatchUpdates:NO];
    _modelIndexPathTable = nil;
    
    id const model = self.model;
    NSArray<XZMocoaKind> * const supportedSupplementKinds = self.supportedSupplementKinds;
    
    [sections enumerateIndexesUsingBlock:^(NSUInteger const index, BOOL * _Nonnull stop) {
        // 清理旧视图模型
        XZMocoaGroupSection * const viewModelSection = _viewModelSections[index];
        for (XZMocoaViewModel *viewModel in viewModelSection.cells) {
            [viewModel removeFromSuperViewModel];
        }
        [viewModelSection.supplements enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull viewModels, BOOL * _Nonnull stop) {
            for (XZMocoaViewModel *viewModel in viewModels) {
                [viewModel removeFromSuperViewModel];
            }
        }];
        [viewModelSection removeAllObjects];
        
        // 清理旧数据模型
        XZMocoaGroupSection * const modelSection = _modelSections[index];
        [modelSection removeAllObjects];
        
        // 加载新数据模型
        [self _loadModelSection:modelSection atIndex:index model:model supportedSupplementKinds:supportedSupplementKinds];
        
        // 加载新视图模型
        [self _loadSubViewModelsForSectionAtIndex:index modelSection:modelSection viewModelSection:viewModelSection supportedSupplementKinds:supportedSupplementKinds];
    }];

    [self didReloadSectionsAtIndexes:sections];
}

- (void)insertSections:(NSIndexSet *)sections {
    [self setNeedsDifferenceBatchUpdates:NO];
    _modelIndexPathTable = nil;
    
    id const model = self.model;
    NSArray<XZMocoaKind> * const supportedSupplementKinds = self.supportedSupplementKinds;
    
    // 添加元素，正向遍历：只有前面的元素正确了，后面的才能正确。
    [sections enumerateIndexesUsingBlock:^(NSUInteger const index, BOOL * _Nonnull stop) {
        // 加载新数据模型
        XZMocoaGroupSection * const modelSection = [[XZMocoaGroupSection alloc] init];
        [self _loadModelSection:modelSection atIndex:index model:model supportedSupplementKinds:supportedSupplementKinds];
        [_modelSections insertObject:modelSection atIndex:index];
        // 加载新视图模型
        XZMocoaGroupSection * const viewModelSection = [[XZMocoaGroupSection alloc] init];
        [self _loadSubViewModelsForSectionAtIndex:index modelSection:modelSection viewModelSection:viewModelSection supportedSupplementKinds:supportedSupplementKinds];
        [_viewModelSections insertObject:viewModelSection atIndex:index];
    }];
    
    // 更新 UI
    [self didInsertSectionsAtIndexes:sections];
    
    // 最后更新 indexPath 以避免因 index 改变而发生视图刷新时，当前的事件还没有派发。
    [XZMocoaGroupViewModel _updateIndexPathsForViewModelSections:_viewModelSections fromIndex:sections.firstIndex toIndex:(_viewModelSections.count - 1) excludeSections:sections];
}

- (void)deleteSections:(NSIndexSet *)sections {
    [self setNeedsDifferenceBatchUpdates:NO];
    
    id const model = self.model;
    NSArray<XZMocoaKind> * const supportedSupplementKinds = self.supportedSupplementKinds;
    
    [sections enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger const index, BOOL *stop) {
        XZMocoaGroupSection *viewModelSection = _viewModelSections[index];
        for (XZMocoaViewModel *viewModel in viewModelSection.cells) {
            [viewModel removeFromSuperViewModel];
        }
        [viewModelSection.supplements enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull viewModels, BOOL * _Nonnull stop) {
            for (XZMocoaViewModel *viewModel in viewModels) {
                [viewModel removeFromSuperViewModel];
            }
        }];
        [_viewModelSections removeObjectAtIndex:index];
        
        [_modelSections removeObjectAtIndex:index];
    }];
    
    // 更新 UI
    [self didDeleteSectionsAtIndexes:sections];
    
    // 更新 indexPath
    [XZMocoaGroupViewModel _updateIndexPathsForViewModelSections:_viewModelSections fromIndex:sections.firstIndex toIndex:(_viewModelSections.count - 1) excludeSections:nil];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    [self setNeedsDifferenceBatchUpdates:NO];
    
    {
        XZMocoaGroupSection * const viewModelSection = _viewModelSections[section];
        [_viewModelSections removeObjectAtIndex:section];
        [_viewModelSections insertObject:viewModelSection atIndex:newSection];
        
        XZMocoaGroupSection * const modelSection = _modelSections[section];
        [_modelSections removeObjectAtIndex:section];
        [_modelSections insertObject:modelSection atIndex:newSection];
    }
    
    // 更新 UI
    [self didMoveSectionAtIndex:section toIndex:newSection];
    
    // 更新 index
    NSInteger const min = MIN(section, newSection);
    NSInteger const max = MAX(section, newSection);
    [XZMocoaGroupViewModel _updateIndexPathsForViewModelSections:_viewModelSections fromIndex:min toIndex:max excludeSections:nil];
}

- (void)reloadCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self setNeedsDifferenceBatchUpdates:NO];
    _modelIndexPathTable = nil;
    
    id const model = self.model;
    
    for (NSIndexPath * const indexPath in indexPaths) {
        NSInteger const section = indexPath.section;
        NSInteger const item    = indexPath.item;
        
        // 清理旧视图模型
        XZMocoaGroupSection * const viewModelSection = _viewModelSections[section];
        XZMocoaViewModel * const oldViewModel = [viewModelSection cellAtIndex:item];
        [oldViewModel removeFromSuperViewModel];
        
        // 加载新数据模型
        XZMocoaGroupSection * const modelSection = _modelSections[section];
        id<XZMocoaModel> const newCellModel = [self model:model modelForCellAtIndexPath:indexPath] ?: (id)kCFNull;
        [modelSection replaceCellAtIndex:item withCell:newCellModel];
        
        // 加载新视图模型
        XZMocoaGroupReusableViewModel * const viewModel = [self _createViewModelWithModel:newCellModel forKind:XZMocoaKindDefault];
        viewModel.indexPath = indexPath;
        [self addSubViewModel:viewModel];
        [viewModelSection replaceCellAtIndex:item withCell:viewModel];
    }
    
    // 更新 UI
    [self didReloadCellsAtIndexPaths:indexPaths];
}

- (void)insertCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self setNeedsDifferenceBatchUpdates:NO];
    _modelIndexPathTable = nil;
    
    id const model = self.model;
    
    // 新增元素，升序遍历：只有前面的元素插入正确了，后面的索引才正确。
    NSArray<NSIndexPath *> * const sortedIndexPaths = [indexPaths sortedArrayUsingSelector:@selector(compare:)];
    NSMutableIndexSet * const affectedSections = [NSMutableIndexSet indexSet];
    
    for (NSIndexPath * const indexPath in sortedIndexPaths) {
        NSInteger const section = indexPath.section;
        NSInteger const item    = indexPath.item;
        
        // 加载新数据模型
        XZMocoaGroupSection * const modelSection = _modelSections[section];
        id<XZMocoaModel> const newCellModel = [self model:model modelForCellAtIndexPath:indexPath] ?: (id)kCFNull;
        [modelSection insertCell:newCellModel atIndex:item];
        
        // 加载新视图模型
        XZMocoaGroupSection * const viewModelSection = _viewModelSections[section];
        XZMocoaGroupReusableViewModel * const viewModel = [self _createViewModelWithModel:newCellModel forKind:XZMocoaKindDefault];
        viewModel.indexPath = indexPath;
        [self addSubViewModel:viewModel];
        [viewModelSection insertCell:viewModel atIndex:item];
        
        [affectedSections addIndex:section];
    }
    
    // 更新 UI
    [self didInsertCellsAtIndexPaths:indexPaths];
    
    // 最后更新 indexPath 以避免因 index 改变而发生视图刷新时，当前的事件还没有派发。
    [affectedSections enumerateIndexesUsingBlock:^(NSUInteger const index, BOOL * _Nonnull stop) {
        [XZMocoaGroupViewModel _updateIndexPathsForViewModelSections:_viewModelSections fromIndex:index toIndex:index excludeSections:nil];
    }];
}

- (void)deleteCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self setNeedsDifferenceBatchUpdates:NO];
    
    // 删除元素，降序遍历：先删除靠后的元素，靠前元素的索引才不受影响。
    NSArray<NSIndexPath *> * const sortedIndexPaths = [indexPaths sortedArrayUsingSelector:@selector(compare:)];
    NSMutableIndexSet * const affectedSections = [NSMutableIndexSet indexSet];
    
    for (NSIndexPath * const indexPath in sortedIndexPaths.reverseObjectEnumerator) {
        NSInteger const section = indexPath.section;
        NSInteger const item    = indexPath.item;
        
        // 清理旧视图模型
        XZMocoaGroupSection * const viewModelSection = _viewModelSections[section];
        XZMocoaViewModel * const viewModel = [viewModelSection cellAtIndex:item];
        [viewModel removeFromSuperViewModel];
        [viewModelSection removeCellAtIndex:item];
        
        // 清理旧数据模型
        XZMocoaGroupSection * const modelSection = _modelSections[section];
        [modelSection removeCellAtIndex:item];
        
        [affectedSections addIndex:section];
    }
    
    // 更新 UI
    [self didDeleteCellsAtIndexPaths:indexPaths];
    
    // 更新 indexPath
    [affectedSections enumerateIndexesUsingBlock:^(NSUInteger const index, BOOL * _Nonnull stop) {
        [XZMocoaGroupViewModel _updateIndexPathsForViewModelSections:_viewModelSections fromIndex:index toIndex:index excludeSections:nil];
    }];
}

- (void)moveCellAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    [self setNeedsDifferenceBatchUpdates:NO];
    
    NSInteger const fromSection = indexPath.section;
    NSInteger const fromItem    = indexPath.item;
    NSInteger const toSection   = newIndexPath.section;
    NSInteger const toItem      = newIndexPath.item;
    
    {
        // 移动视图模型
        XZMocoaGroupSection * const fromViewModelSection = _viewModelSections[fromSection];
        XZMocoaViewModel * const viewModel = [fromViewModelSection cellAtIndex:fromItem];
        [fromViewModelSection removeCellAtIndex:fromItem];
        [_viewModelSections[toSection] insertCell:viewModel atIndex:toItem];
        
        // 移动数据模型
        XZMocoaGroupSection * const fromModelSection = _modelSections[fromSection];
        id const cellModel = [fromModelSection cellAtIndex:fromItem];
        [fromModelSection removeCellAtIndex:fromItem];
        [_modelSections[toSection] insertCell:cellModel atIndex:toItem];
    }
    
    // 更新 UI
    [self didMoveCellAtIndexPath:indexPath toIndexPath:newIndexPath];
    
    // 更新 indexPath
    NSMutableIndexSet * const affectedSections = [NSMutableIndexSet indexSet];
    [affectedSections addIndex:fromSection];
    [affectedSections addIndex:toSection];
    [affectedSections enumerateIndexesUsingBlock:^(NSUInteger const index, BOOL * _Nonnull stop) {
        [XZMocoaGroupViewModel _updateIndexPathsForViewModelSections:_viewModelSections fromIndex:index toIndex:index excludeSections:nil];
    }];
}

#pragma mark - 批量更新

- (void)performBatchUpdates:(void (^NS_NOESCAPE const)(void))batchUpdates completion:(void (^ _Nullable)(BOOL))completion {
    XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 开始");
    [self setNeedsDifferenceBatchUpdates:YES];
    NSInteger __block batchUpdatesLock = 0;
    completion = ^(BOOL finished) {
        batchUpdatesLock--;
        if (batchUpdatesLock > 0) {
            return;
        }
        if (completion) completion(finished);
    };
    [self didPerformBatchUpdates:^{
        batchUpdatesLock++;
        if (batchUpdates) batchUpdates();
    } completion:completion];
    [self differenceBatchUpdatesIfNeeded:&batchUpdatesLock completion:completion];
    XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 结束");
}

- (BOOL)isPerformingBatchUpdates {
    return _needsDifferenceBatchUpdates.count > 0;
}

/// 开启批量更新差异分析，或取消最后一个批量更新的差异分析。
/// - 参数 `YES` 表示开始新的 BatchUpdates 并标记**需要**差异分析。
/// - 参数 `NO ` 表示将最后的 BatchUpdates 标记为**不需**差异分析。
/// - Parameter needsDifferenceBatchUpdates: 是否需要差异分析
- (void)setNeedsDifferenceBatchUpdates:(BOOL)needsDifferenceBatchUpdates {
    if (needsDifferenceBatchUpdates) {
        [_needsDifferenceBatchUpdates addObject:@(YES)];
    } else {
        NSInteger const lastIndex = _needsDifferenceBatchUpdates.count - 1;
        _needsDifferenceBatchUpdates[lastIndex] = @(NO);
    }
}

- (void)differenceBatchUpdatesIfNeeded:(NSInteger * _Nonnull)batchUpdatesLock completion:(void (^_Nonnull)(BOOL))completion {
    defer(^{
        [self->_needsDifferenceBatchUpdates removeLastObject];
    });
    
    if (!self->_needsDifferenceBatchUpdates.lastObject.boolValue) {
        return;
    }
    
    XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 差异分析开始");
    
    // 旧数据
    NSMapTable<id, NSIndexPath *> * const oldModelIndexPathMap = _modelIndexPathTable ?: [XZMocoaGroupViewModel _createModelIndexPathMapForModelSections:_modelSections];
    if (oldModelIndexPathMap == nil) {
        XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 旧数据存在重复，无差异分析");
        [self reloadData];
        XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 结束");
        return;
    }
    
    id        const model                    = self.model;
    NSArray * const supportedSupplementKinds = self.supportedSupplementKinds;
    
    // 新数据
    NSMutableArray<XZMocoaGroupSection<id<XZMocoaModel>> *> * const newModelSections = [NSMutableArray array];
    [self _loadModelSections:newModelSections model:model supportedSupplementKinds:supportedSupplementKinds];
    
    // 新数据 与 indexPath 的映射关系
    NSMapTable<id, NSIndexPath *> * const newModelIndexPathMap = [XZMocoaGroupViewModel _createModelIndexPathMapForModelSections:newModelSections];
    
    if (newModelIndexPathMap == nil) {
        XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 新数据存在重复，无差异分析");
        [self _reloadDataWithoutEventsUsingModelSections:newModelSections supportedSupplementKinds:supportedSupplementKinds];
        [self didReloadData];
        XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 结束");
        return;
    }
    // 当前数据已验证支持差异分析。
    _modelIndexPathTable = newModelIndexPathMap;
    
    NSInteger const newSectionCount = newModelSections.count;
    
    // 在批量更新时，同一个元素只能有一种更新行为，
    // 但是由于 tableView 和 collectionView 都没有直接刷新 supplement 的方法，导致只要任一 supplements 发生改变，都需要 section 整个刷新。
    // 因为 supplements 的内容可能与 cells 有关，所以先对 sections 进行排序，然后执行 cells 更新，最后执行 supplements 刷新。
    
    // 使用 reloadData 时，section 的数量不能改变。
    // 使用 reloadData 时，section 中的 cell 的数量不能改变。
    // 使用 reloadSections 时，sections 中的 cell 数量可以改变。
    // 使用 reloadSections 时，可以将 cell 移动到其它 section 中。
    // 使用 reloadSections 时，可以将其它 cell 移动到 section 中。
    // 使用 deleteSections 时，可以将被删除的 cell 移动到其它 section 中。
    // 使用 insertSections 时，可以将其它 cell 移动到新添加的 section 中。
    // 使用 deleteSections 时，可将内部的 cell 移动到别的 section 中，如果时部分移动，剩余的 cell 默认移除
    
    // 最终需要刷新 supplements 的 sections
    NSMutableIndexSet * const reloads = [NSMutableIndexSet indexSet];
    // 最终需要删除的 sections
    NSMutableIndexSet * const deletes = [NSMutableIndexSet indexSet];
    
    // 重排当前 sections
    // 1、根据 section.identifier 判断 section 是否在更新后是保留还是删除。
    // 2、将保留的 sections 按照更新后的顺序排序，待新建的 section 先用空白的占位。
    // 3、待删除的 sections 放到最后，留着复用里面的 cell ，并在最后删除。
    // 4、因为 supplements 的内容可能与 cells 有关，所以放到最后一步刷新。
    [self didPerformBatchUpdates:^{
        (*batchUpdatesLock)++;
        
        // 建立映射：section.identifier => index
        NSDictionary<NSString *, NSNumber *> * const oldSectionIndexMap = [XZMocoaGroupViewModel _createSectionIndexMapForModelSections:_modelSections];
        
        // 记录 index 发送改变的 sections ：oldIndex => newIndex
        NSMutableDictionary<NSNumber *, NSNumber *> * const changes = [NSMutableDictionary dictionary];
        // 记录新添加的 sections 的 index
        NSMutableIndexSet                           * const inserts = [NSMutableIndexSet indexSet];
        // 先标记所有 oldSections 都要被删除，如果被复用再移除
        [deletes addIndexesInRange:NSMakeRange(0, _modelSections.count)];
        
        NSMutableArray<XZMocoaGroupSection<XZMocoaViewModel *> *> * const _viewModelSections = [NSMutableArray arrayWithCapacity:newSectionCount];
        NSMutableArray<XZMocoaGroupSection<id<XZMocoaModel>> *>   * const _modelSections     = [NSMutableArray arrayWithCapacity:newSectionCount];
        
        // 以新数据的顺序为最终顺序，遍历新数据
        for (NSInteger newSectionIndex = 0; newSectionIndex < newSectionCount; newSectionIndex++) {
            XZMocoaGroupSection * const newModelSection = newModelSections[newSectionIndex];
            NSString            * const newIdentifier   = newModelSection.identifier;
            
            NSNumber * const oldIndexValue = oldSectionIndexMap[newIdentifier];
            
            if (oldIndexValue) {
                // 找到旧 section 可以复用，取消删除
                NSInteger const oldSectionIndex = oldIndexValue.integerValue;
                [deletes removeIndex:oldSectionIndex];
                
                XZMocoaGroupSection *modelSection = self->_modelSections[oldSectionIndex];
                [_modelSections addObject:modelSection];
                
                XZMocoaGroupSection *viewModelSection = self->_viewModelSections[oldSectionIndex];
                [_viewModelSections addObject:viewModelSection];
                
                if (oldSectionIndex != newSectionIndex) {
                    changes[@(oldSectionIndex)] = @(newSectionIndex);
                    XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 移动复用分组 %ld => %ld", oldSectionIndex, newSectionIndex);
                }
            } else {
                // 没有可复用的，新建一个空的
                XZMocoaGroupSection *modelSection = [[XZMocoaGroupSection alloc] init];
                [_modelSections addObject:modelSection];
                
                XZMocoaGroupSection *viewModelSection = [[XZMocoaGroupSection alloc] init];
                [_viewModelSections addObject:viewModelSection];
                
                [inserts addIndex:newSectionIndex];
                XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 插入空白分组 %ld", newSectionIndex);
                                
                // 新建的 section 需要刷新
                if (newModelSection.supplementKind != nil) {
                    [reloads addIndex:newSectionIndex];
                }
            }
        }
        
        // 将未复用的 sections 添加到末尾，其内部的 cell 可能被复用，并在最后删除。
        NSInteger const deletesCount = deletes.count;
        if (deletesCount > 0) {
            [deletes enumerateIndexesUsingBlock:^(NSUInteger const oldSectionIndex, BOOL * _Nonnull stop) {
                // 记录需要删除
                [deletes addIndex:_modelSections.count];
                
                XZMocoaGroupSection *modelSection = self->_modelSections[oldSectionIndex];
                [_modelSections addObject:modelSection];
                
                XZMocoaGroupSection *viewModelSection = self->_viewModelSections[oldSectionIndex];
                [_viewModelSections addObject:viewModelSection];
            }];
            [deletes removeAllIndexes];
            [deletes addIndexesInRange:NSMakeRange(_modelSections.count - deletesCount, deletesCount)];
        }
        
        self->_modelSections     = _modelSections;
        self->_viewModelSections = _viewModelSections;
        
        [self didInsertSectionsAtIndexes:inserts];
        [changes enumerateKeysAndObjectsUsingBlock:^(NSNumber * const oldValue, NSNumber *newValue, BOOL * _Nonnull stop) {
            NSInteger const oldSectionIndex = oldValue.integerValue;
            NSInteger const newSectionIndex = newValue.integerValue;
            [self didMoveSectionAtIndex:oldSectionIndex toIndex:newSectionIndex];
        }];
        // 临时状态，不更新 indexPath
    } completion:completion];
    
    // 更新 cells
    [self didPerformBatchUpdates:^{
        (*batchUpdatesLock)++;
        
        // section 排序之后，重新创建索引
        [self _updateModelIndexPathMap:oldModelIndexPathMap forModelSections:_modelSections];
        
        NSMutableArray<NSIndexPath *> * const deletes = [NSMutableArray array];
        NSMutableArray<NSIndexPath *> * const inserts = [NSMutableArray array];
        NSMutableArray<NSDictionary<NSString *, NSIndexPath *> *> * const changes = [NSMutableArray array];
        
        NSMutableArray<XZMocoaGroupSection<XZMocoaViewModel *> *> * const newViewModelSections = [NSMutableArray arrayWithCapacity:newSectionCount];
        
        for (NSInteger newSectionIndex = 0; newSectionIndex < newSectionCount; newSectionIndex++) {
            XZMocoaGroupSection * const newViewModelSection = [[XZMocoaGroupSection alloc] init];
            [newViewModelSections addObject:newViewModelSection];
            
            // 复制 supplements
            [newViewModelSection copySupplementsFromSection:_viewModelSections[newSectionIndex]];
            XZMocoaGroupSection * const newModelSection = newModelSections[newSectionIndex];
            
            // 刷新 cells
            [newModelSection.cells enumerateObjectsUsingBlock:^(id  _Nonnull newCellModel, NSUInteger newCellIndex, BOOL * _Nonnull stop) {
                NSIndexPath *indexPath = [oldModelIndexPathMap objectForKey:newCellModel];
                
                // 新增
                if (indexPath == nil) {
                    indexPath = [NSIndexPath indexPathForItem:newCellIndex inSection:newSectionIndex];
                    [inserts addObject:indexPath];
                    XZMocoaViewModel *viewModel = [self _createViewModelWithModel:newCellModel forKind:(XZMocoaKindDefault)];
                    [self addSubViewModel:viewModel];
                    [newViewModelSection addCell:viewModel];
                    
                    XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 添加单元视图 %ld, %ld", indexPath.section, indexPath.item);
                    return;
                }
                
                // 移除匹配成功的元素
                [oldModelIndexPathMap removeObjectForKey:newCellModel];
                
                // 保持：原始位置与目标位置一致
                if (indexPath.section == newSectionIndex && indexPath.item == newCellIndex) {
                    XZMocoaViewModel *viewModel = [_viewModelSections[newSectionIndex] cellAtIndex:newCellIndex];
                    [newViewModelSection addCell:viewModel];
                    XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 保持单元视图 %ld, %ld", indexPath.section, indexPath.item);
                    return;
                }
                
                // 移动
                XZMocoaViewModel *viewModel = [_viewModelSections[indexPath.section] cellAtIndex:indexPath.item];
                [newViewModelSection addCell:viewModel];
                [changes addObject:@{ @"from": indexPath, @"to": [NSIndexPath indexPathForItem:newCellIndex inSection:newSectionIndex] }];
                
                XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 移动单元视图 %ld, %ld => %ld, %ld", indexPath.section, indexPath.item, newSectionIndex, newCellIndex);
            }];
        }
        
        for (NSInteger oldSectionIndex = newSectionCount; oldSectionIndex < _viewModelSections.count; oldSectionIndex++) {
            XZMocoaGroupSection * const newViewModelSection = [[XZMocoaGroupSection alloc] init];
            [newViewModelSections addObject:newViewModelSection];
            [newViewModelSection copySupplementsFromSection:_viewModelSections[oldSectionIndex]];
        }

        for (id oldCellModel in oldModelIndexPathMap.keyEnumerator) {
            NSIndexPath *indexPath = [oldModelIndexPathMap objectForKey:oldCellModel];
            [deletes addObject:indexPath];
            XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 删除单元视图 %ld, %ld", indexPath.section, indexPath.item);
            
            XZMocoaViewModel *viewModel = [_viewModelSections[indexPath.section] cellAtIndex:indexPath.item];
            [viewModel removeFromSuperViewModel];
        }
        
        self->_modelSections = newModelSections;
        self->_viewModelSections = newViewModelSections;
        
        // 删除
        [self didDeleteCellsAtIndexPaths:deletes];
        // 新增
        [self didInsertCellsAtIndexPaths:inserts];
        // 移动
        for (NSDictionary *info in changes) {
            NSIndexPath *oldIndexPath = info[@"from"];
            NSIndexPath *newIndexPath = info[@"to"];
            [self didMoveCellAtIndexPath:oldIndexPath toIndexPath:newIndexPath];
        }
    } completion:completion];
    
    // 更新 supplements
    [self didPerformBatchUpdates:^{
        (*batchUpdatesLock)++;
        
        [reloads enumerateIndexesUsingBlock:^(NSUInteger const newSectionIndex, BOOL * _Nonnull stop) {
            XZMocoaGroupSection * const viewModelSection = _viewModelSections[newSectionIndex];
            [viewModelSection removeAllSupplements];
            [newModelSections[newSectionIndex].supplements enumerateKeysAndObjectsUsingBlock:^(XZMocoaKind const kind, NSArray * const supplementModels, BOOL * _Nonnull stop) {
                [supplementModels enumerateObjectsUsingBlock:^(id const supplementModel, NSUInteger idx, BOOL * _Nonnull stop) {
                    XZMocoaViewModel *viewModel = [self _createViewModelWithModel:supplementModel forKind:kind];
                    [viewModelSection addSupplement:viewModel forKind:kind];
                    [self addSubViewModel:viewModel];
                }];
            }];
            XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 更新辅助视图 %ld", newSectionIndex);
        }];
        [_viewModelSections removeObjectsAtIndexes:deletes];
        
        [self didReloadSectionsAtIndexes:reloads];
        [self didDeleteSectionsAtIndexes:deletes];
    } completion:completion];
    
    // 更新 indexPath
    [XZMocoaGroupViewModel _updateIndexPathsForViewModelSections:_viewModelSections fromIndex:0 toIndex:(_viewModelSections.count - 1) excludeSections:nil];
    
    XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 差异分析结束");
}

#pragma mark - 私有方法

/// 添加所有 section 元素，需先清理数据。
- (void)_reloadDataWithoutEvents {
    // 清理旧数据
    [_modelSections removeAllObjects];
    
    // 准备新数据：数据标准化
    id                     const model                    = self.model;
    NSArray<XZMocoaKind> * const supportedSupplementKinds = self.supportedSupplementKinds;
    [self _loadModelSections:_modelSections model:model supportedSupplementKinds:supportedSupplementKinds];
    
    // 创建视图模型
    [self _reloadDataWithoutEventsUsingModelSections:_modelSections supportedSupplementKinds:supportedSupplementKinds];
}

- (void)_reloadDataWithoutEventsUsingModelSections:(NSMutableArray *)modelSections supportedSupplementKinds:(NSArray<XZMocoaKind> *)supportedSupplementKinds {
    // 数据模型
    if (_modelSections != modelSections) {
        _modelSections = modelSections;
    }
    
    // 清理旧视图模型
    for (XZMocoaGroupSection * const section in _viewModelSections) {
        for (XZMocoaViewModel * const viewModel in section.cells) {
            [viewModel removeFromSuperViewModel];
        }
        [section.supplements enumerateKeysAndObjectsUsingBlock:^(XZMocoaKind const key, NSMutableArray * const supplementViewModels, BOOL * _Nonnull stop) {
            for (XZMocoaViewModel *viewModel in supplementViewModels) {
                [viewModel removeFromSuperViewModel];
            }
        }];
    }
    [_viewModelSections removeAllObjects];
    
    // 创建新视图模型
    [_modelSections enumerateObjectsUsingBlock:^(XZMocoaGroupSection<id<XZMocoaModel>> * const modelSection, NSUInteger sectionIndex, BOOL * _Nonnull stop) {
        XZMocoaGroupSection * const viewModelSection = [[XZMocoaGroupSection alloc] init];
        [self _loadSubViewModelsForSectionAtIndex:sectionIndex modelSection:modelSection viewModelSection:viewModelSection supportedSupplementKinds:supportedSupplementKinds];
        [_viewModelSections addObject:viewModelSection];
    }];
}

- (void)_loadSubViewModelsForSectionAtIndex:(NSInteger)sectionIndex modelSection:(XZMocoaGroupSection *)modelSection viewModelSection:(XZMocoaGroupSection<XZMocoaViewModel *> *)viewModelSection supportedSupplementKinds:(NSArray<XZMocoaKind> *)supportedSupplementKinds {
    for (XZMocoaKind const kind in supportedSupplementKinds) {
        NSMutableArray * const supplementModels = [modelSection supplementsForKind:kind];
        
        [[modelSection supplementsForKind:kind] enumerateObjectsUsingBlock:^(id const supplementModel, NSUInteger supplementIndex, BOOL * _Nonnull stop) {
            NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:supplementIndex inSection:sectionIndex];
            XZMocoaGroupReusableViewModel * const viewModel = [self _createViewModelWithModel:supplementModel forKind:kind];
            viewModel.indexPath = indexPath;
            [self addSubViewModel:viewModel];
            [viewModelSection addSupplement:viewModel forKind:kind];
        }];
    }
    
    {
        NSArray * const cellModels = modelSection.cells;
        for (NSInteger cellIndex = 0; cellIndex < cellModels.count; cellIndex++) {
            NSIndexPath *    const indexPath = [NSIndexPath indexPathForItem:cellIndex inSection:sectionIndex];
            id<XZMocoaModel> const cellModel = cellModels[cellIndex];
            
            XZMocoaGroupReusableViewModel * const viewModel = [self _createViewModelWithModel:cellModel forKind:(XZMocoaKindDefault)];
            viewModel.indexPath = indexPath;
            [self addSubViewModel:viewModel];
            [viewModelSection addCell:viewModel];
        }
    }
}

- (__kindof XZMocoaViewModel *)_createViewModelWithModel:(id<XZMocoaModel>)model forKind:(XZMocoaKind)kind {
    if (model == (id)kCFNull) {
        model = nil;
    }
    
    XZMocoaName     const name   = model.mocoaName ?: XZMocoaNameDefault;
    XZMocoaModule * const module = [self.module submoduleIfLoadedForKind:kind forName:name];
    
    Class     VMClass         = module.viewModelClass;
    NSString *reuseIdentifier = nil;
    
    if (VMClass) {
        // 模块注册了，且也注册了视图模型
        reuseIdentifier = module.viewReuseIdentifier ?: XZMocoaReuseIdentifier(kind, name);
    } else {
        // 模块未注册，或者未注册视图模型
        if ([name isEqualToString:XZMocoaNameDefault]) {
            // 当前是默认模块，兜底占位模块
            VMClass = [self viewModelClassForPlaceholderForKind:kind];
            reuseIdentifier = XZMocoaReuseIdentifier(kind, XZMocoaNamePlaceholder);
        } else {
            // 当前是定制模块，尝试默认模块
            XZMocoaModule *defaultModule = [self.module submoduleIfLoadedForKind:kind forName:XZMocoaNameDefault];
            if (defaultModule == nil) {
                // 无默认模块，兜底占位模块
                VMClass = [self viewModelClassForPlaceholderForKind:kind];
                reuseIdentifier = XZMocoaReuseIdentifier(kind, XZMocoaNamePlaceholder);
            } else {
                // 有默认模块，读取视图模型
                VMClass = defaultModule.viewModelClass;
                if (VMClass) {
                    // 默认模块注册了视图模型
                    reuseIdentifier = defaultModule.viewReuseIdentifier ?: XZMocoaReuseIdentifier(kind, XZMocoaNameDefault);
                } else {
                    // 默认模块未注册视图模型
                    VMClass = [self viewModelClassForPlaceholderForKind:kind];
                    reuseIdentifier = XZMocoaReuseIdentifier(kind, XZMocoaNamePlaceholder);
                }
            }
        }
    }
    
    XZMocoaGroupReusableViewModel * const viewModel = [[VMClass alloc] initWithModel:model];
    viewModel.module          = module;
    viewModel.reuseIdentifier = reuseIdentifier; // 避免子类重写初始化方法，对 model 进行脱壳后，导致丢失 identifier
    return viewModel;
}

+ (nullable NSMapTable<id, NSIndexPath *> *)_createModelIndexPathMapForModelSections:(NSArray<XZMocoaGroupSection *> * const)modelSections {
    NSMapTable<id, NSIndexPath *> * const modelMap = [NSMapTable strongToStrongObjectsMapTable];
    NSInteger const sectionCount = modelSections.count;
    for (NSInteger sectionIndex = 0; sectionIndex < sectionCount; sectionIndex++) {
        XZMocoaGroupSection * const modelSection = modelSections[sectionIndex];
        NSArray * const cellModels = modelSection.cells;
        NSInteger const cellCount = cellModels.count;
        for (NSInteger cellIndex = 0; cellIndex < cellCount; cellIndex++) {
            NSIndexPath *    const indexPath = [NSIndexPath indexPathForItem:cellIndex inSection:sectionIndex];
            id<XZMocoaModel> const cellModel = cellModels[cellIndex];
            
            if (cellModel == nil || [modelMap objectForKey:cellModel]) {
                return nil;
            }
            [modelMap setObject:indexPath forKey:cellModel];
        }
    }
    return modelMap;
}

- (void)_updateModelIndexPathMap:(NSMapTable<id, NSIndexPath *> *)modelIndexPathMap forModelSections:(NSArray<XZMocoaGroupSection *> * const)modelSections {
    NSInteger const sectionCount = modelSections.count;
    for (NSInteger sectionIndex = 0; sectionIndex < sectionCount; sectionIndex++) {
        XZMocoaGroupSection * const modelSection = modelSections[sectionIndex];
        NSArray * const cellModels = modelSection.cells;
        NSInteger const cellCount = cellModels.count;
        
        for (NSInteger cellIndex = 0; cellIndex < cellCount; cellIndex++) {
            id<XZMocoaModel> const cellModel = cellModels[cellIndex];
            
            NSIndexPath *indexPath = [modelIndexPathMap objectForKey:cellModel];
            if (indexPath.section != sectionIndex || indexPath.item != cellIndex) {
                indexPath = [NSIndexPath indexPathForItem:cellIndex inSection:sectionIndex];
                [modelIndexPathMap setObject:indexPath forKey:cellModel];
            }
        }
    }
}

+ (NSDictionary<NSString *, NSNumber *> *)_createSectionIndexMapForModelSections:(NSArray<XZMocoaGroupSection *> *)modelSections {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:modelSections.count];
    [modelSections enumerateObjectsUsingBlock:^(XZMocoaGroupSection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dictionary[obj.identifier] = @(idx);
    }];
    return dictionary;
}

/// 更新 section 范围从 min 到 max 之间（包含临界值）的所有视图模型的 indexPath 值。
+ (void)_updateIndexPathsForViewModelSections:(NSArray<XZMocoaGroupSection<XZMocoaViewModel *> *> * const)viewModelSections fromIndex:(NSInteger const)minSectionIndex toIndex:(NSInteger const)maxSectionIndex excludeSections:(nullable NSIndexSet *)excludeSections {
    for (NSInteger sectionIndex = minSectionIndex; sectionIndex <= maxSectionIndex; sectionIndex++) {
        if ([excludeSections containsIndex:sectionIndex]) {
            continue;
        }
        XZMocoaGroupSection * const viewModelSection = viewModelSections[sectionIndex];
        
        [viewModelSection.cells enumerateObjectsUsingBlock:^(XZMocoaGroupReusableViewModel *viewModel, NSUInteger idx, BOOL * _Nonnull stop) {
            NSIndexPath *indexPath = viewModel.indexPath;
            if (indexPath && indexPath.section == sectionIndex && indexPath.item == idx) {
                return;
            }
            indexPath = [NSIndexPath indexPathForItem:idx inSection:sectionIndex];
            viewModel.indexPath = indexPath;
        }];
        
        [viewModelSection.supplements enumerateKeysAndObjectsUsingBlock:^(XZMocoaKind const kind, NSArray<XZMocoaGroupReusableViewModel *> * _Nonnull viewModels, BOOL * _Nonnull stop) {
            [viewModels enumerateObjectsUsingBlock:^(XZMocoaGroupReusableViewModel * _Nonnull viewModel, NSUInteger idx, BOOL * _Nonnull stop) {
                NSIndexPath *indexPath = viewModel.indexPath;
                if (indexPath && indexPath.section == sectionIndex && indexPath.item == idx) {
                    return;
                }
                indexPath = [NSIndexPath indexPathForItem:idx inSection:sectionIndex];
                viewModel.indexPath = indexPath;
            }];
        }];
    }
}

/// 将 model 结构化为标准数据模型，如果数据不包含重复数据，返回映射关系。
- (void)_loadModelSections:(NSMutableArray<XZMocoaGroupSection<id<XZMocoaModel>> *> *)modelSections model:(id)model supportedSupplementKinds:(NSArray<XZMocoaKind> *)supportedSupplementKinds {
    NSInteger const sectionCount = [self model:model numberOfSections:nil];
    for (NSInteger sectionIndex = 0; sectionIndex < sectionCount; sectionIndex++) {
        XZMocoaGroupSection * const modelSection = [[XZMocoaGroupSection alloc] init];
        [self _loadModelSection:modelSection atIndex:sectionIndex model:model supportedSupplementKinds:supportedSupplementKinds];
        [modelSections addObject:modelSection];
    }
}

- (void)_loadModelSection:(XZMocoaGroupSection *)modelSection atIndex:(NSInteger)sectionIndex model:(id)model supportedSupplementKinds:(NSArray<XZMocoaKind> *)supportedSupplementKinds {
    // supplements
    for (XZMocoaKind const kind in supportedSupplementKinds) {
        NSInteger const supplementCount = [self model:model kind:kind numberOfSupplementsInSection:sectionIndex];
        
        for (NSInteger newSupplementIndex = 0; newSupplementIndex < supplementCount; newSupplementIndex++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:newSupplementIndex inSection:sectionIndex];
            id const newSupplementModel = [self model:model kind:kind modelForSupplementAtIndexPath:indexPath];
            [modelSection addSupplement:(newSupplementModel ?: (id)kCFNull) forKind:kind];
        }
    }
    
    // cells
    {
        NSInteger const cellCount = [self model:model numberOfCellsInSection:sectionIndex];
        for (NSInteger item = 0; item < cellCount; item++) {
            NSIndexPath *    const indexPath = [NSIndexPath indexPathForItem:item inSection:sectionIndex];
            id<XZMocoaModel> const newCellModel = [self model:model modelForCellAtIndexPath:indexPath];
            [modelSection addCell:(newCellModel ?: (id)kCFNull)];
        }
    }
}

#pragma mark - 子类重写

- (void)didReloadData {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重写 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didDeselectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重写 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(NSInteger)scrollPosition {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重写 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didReloadCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重写 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didInsertCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重写 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didDeleteCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重写 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didMoveCellAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重写 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didReloadSectionsAtIndexes:(NSIndexSet *)sections {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重写 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didInsertSectionsAtIndexes:(NSIndexSet *)sections {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重写 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didDeleteSectionsAtIndexes:(NSIndexSet *)sections {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重写 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didMoveSectionAtIndex:(NSInteger)oldSection toIndex:(NSInteger)newSection {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重写 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didPerformBatchUpdates:(void (^NS_NOESCAPE)(void))batchUpdates completion:(void (^ _Nullable)(BOOL))completion {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重写 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (Class)viewModelClassForPlaceholderForKind:(XZMocoaKind)kind {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重写 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

@end

@implementation XZMocoaGroupViewModel (XZMocoaGroupModel)

- (NSInteger)model:(id<XZMocoaGroupModel>)model numberOfSections:(id)null {
    if (_dataSource) {
        return [_dataSource mocoa:self numberOfSections:null];
    }
    return [model mocoa:self numberOfSections:null];
}

- (NSInteger)model:(id<XZMocoaGroupModel>)model numberOfCellsInSection:(NSInteger)section {
    if (_dataSource) {
        return [_dataSource mocoa:self numberOfCellsInSection:section];
    }
    return [model mocoa:self numberOfCellsInSection:section];
}

- (id)model:(id<XZMocoaGroupModel>)model modelForCellAtIndexPath:(NSIndexPath *)indexPath {
    if (_dataSource) {
        return [_dataSource mocoa:self modelForCellAtIndexPath:indexPath];
    }
    return [model mocoa:self modelForCellAtIndexPath:indexPath];
}

- (NSInteger)model:(id<XZMocoaGroupModel>)model kind:(XZMocoaKind)kind numberOfSupplementsInSection:(NSInteger)section {
    if (_dataSource) {
        return [_dataSource mocoa:self kind:kind numberOfSupplementsInSection:section];
    }
    return [model mocoa:self kind:kind numberOfSupplementsInSection:section];
}

- (id)model:(id<XZMocoaGroupModel>)model kind:(XZMocoaKind)kind modelForSupplementAtIndexPath:(NSIndexPath *)indexPath {
    if (_dataSource) {
        return [_dataSource mocoa:self kind:kind modelForSupplementAtIndexPath:indexPath];
    }
    return [model mocoa:self kind:kind modelForSupplementAtIndexPath:indexPath];
}

@end


@implementation XZMocoaGroupViewModel (NSFetchedResultsControllerDelegate)

/// 这个代理方法会阻断下面所有代理方法，且适合搭配 UITableViewDiffableDataSource/UIColletionViewDiffableDataSource 使用。似乎可能没有 move-to 这种操作。
/// 从目前公开的接口，无法分析出 snapshot 包含的更新内容。
//- (void)controller:(NSFetchedResultsController *)controller didChangeContentWithSnapshot:(NSDiffableDataSourceSnapshot<NSString *,NSManagedObjectID *> *)snapshot {}

/// 不分 section 时，此方法会阻断下面的方法。似乎只有 insert/remove 两种更新类型。
//- (void)controller:(NSFetchedResultsController *)controller didChangeContentWithDifference:(NSOrderedCollectionDifference<NSManagedObjectID *> *)diff { }

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    XZLog(@"%s %@", __FUNCTION__, self);
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    XZLog(@"%s %@", __FUNCTION__, self);
    if (!self.isReady) return;
    // 调用 db.save() 会直接同步触发当前方法，所以
    // 如果在 batchUpdates 块函数中调用 db.save() 方法，那么没有必要再次触发批量更新。
    if ([self isPerformingBatchUpdates]) {
        return;
    }
    [self performBatchUpdates:^{ } completion:^(BOOL finished) {
        [self sendEventsWithKey:XZMocoaKeyContentDidChange value:nil];
    }];
}

// 虽然 CoreData 提供了数据更新的步骤，但是更新事件似乎并是按更新的先后顺序发送，可能是由于排序或者什么原因，比如同时插入三条数据时，
// 触发代理的顺序可能时 0 2 1，这显然没办法直接操作数组。
// 因为先收到插入数据 2 而这个时候 1 还没有插入，无法在数组中插入不连续的值。
// 而且似乎 section/cell 没有分离，比如没有 section=5 时，会直接触发插入 {section=5,row=0} 从而导致更新问题，直接批量操作有风险。

#if DEBUG
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    // if (!self.isReady) return
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            break;
        }
        case NSFetchedResultsChangeDelete: {
            break;
        }
        default:
            @throw [NSException exceptionWithName:NSGenericException reason:@"should never be called" userInfo:nil];
            break;
    }
}
#endif

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(NSManagedObject *)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (!self.isReady) return;
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            break;
        }
        case NSFetchedResultsChangeMove: {
            if ([anObject hasPersistentChangedValues]) {
                XZMocoaGroupReusableViewModel * const viewModel = [self viewModelForCellAtIndexPath:indexPath];
                if (viewModel.shouldObserveModelKeysActively) {
                    break;
                }
                NSDictionary<NSString *, id> * const changedValues = anObject.changedValuesForCurrentEvent;
                [viewModel model:anObject didChangeValuesForKeys:[NSSet setWithArray:changedValues.allKeys]];
            }
            break;
        }
        case NSFetchedResultsChangeDelete: {
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            // 如果同时发生了 move 事件，则不会调用此方法
            // changedValuesForCurrentEvent 中仅包含持久存储属性变更，先使用 hasPersistentChangedValues 判断是否有更新以优化性能
            if ([anObject hasPersistentChangedValues]) {
                XZMocoaGroupReusableViewModel * const viewModel = [self viewModelForCellAtIndexPath:indexPath];
                if (viewModel.shouldObserveModelKeysActively) {
                    break;
                }
                NSDictionary<NSString *, id> * const changedValues = anObject.changedValuesForCurrentEvent;
                [viewModel model:anObject didChangeValuesForKeys:[NSSet setWithArray:changedValues.allKeys]];
            }
            break;
        }
    }
}

@end


@implementation XZMocoaGroupSection {
    NSString *_identifier;
    NSMutableArray *_cells;
    NSMutableDictionary<XZMocoaKind, NSMutableArray *> *_kindedSupplements;
}

- (NSString *)identifier {
    if (_identifier) {
        return _identifier;
    }
    if (_kindedSupplements.count > 0) {
        // supplements:kind1-hash0-hash1-hash2-hashN:kind2-hash0
        NSMutableString *identifier = [NSMutableString stringWithString:@"supplements"];
        NSArray *kinds = [_kindedSupplements.allKeys sortedArrayUsingSelector:@selector(compare:)];
        for (XZMocoaKind const kind in kinds) {
            NSArray *models = _kindedSupplements[kind];
            [identifier appendFormat:@":%@", kind];
            for (NSObject *model in models) {
                [identifier appendFormat:@"-%lu", (unsigned long)model.hash];
            }
        };
        _identifier = identifier.copy;
    } else {
        // cells:cell-hash0-hash1-hash2-hashN
        NSMutableString *identifier = [NSMutableString stringWithString:@"cells:cell"];
        for (NSObject *model in _cells) {
            [identifier appendFormat:@"-%lu", (unsigned long)model.hash];
        }
        _identifier = identifier.copy;
    }
    return _identifier;
}

- (BOOL)isEmpty {
    if (_cells.count > 0) {
        return NO;
    }
    for (XZMocoaKind const kind in _kindedSupplements) {
        if (_kindedSupplements[kind].count > 0) {
            return NO;
        }
    }
    return YES;
}

- (void)addCell:(id)cell {
    _identifier = nil;
    _cell = cell;
    if (_cells == nil) {
        _cells = [[NSMutableArray alloc] init];
    }
    [_cells addObject:cell];
}

- (void)insertCell:(id)cell atIndex:(NSInteger)index {
    _identifier = nil;
    _cell = cell;
    if (_cells == nil) {
        _cells = [[NSMutableArray alloc] init];
    }
    [_cells insertObject:cell atIndex:index];
}

- (id)cellAtIndex:(NSInteger)index {
    return _cells[index];
}

- (void)removeCellAtIndex:(NSInteger)index {
    _identifier = nil;
    [_cells removeObjectAtIndex:index];
    if (_cells.count == 0) {
        _cell = nil;
    }
}

- (void)replaceCellAtIndex:(NSInteger)index withCell:(id)cell {
    _identifier = nil;
    _cell = cell;
    [_cells replaceObjectAtIndex:index withObject:cell];
}

- (NSDictionary *)supplements {
    return _kindedSupplements;
}

- (void)insertSupplement:(id)supplement atIndex:(NSInteger)index forKind:(XZMocoaKind)kind {
    _identifier = nil;
    _supplementKind = kind;
    _supplement = supplement;
    if (_kindedSupplements == nil) {
        _kindedSupplements = [NSMutableDictionary dictionary];
    }
    NSMutableArray *arrayM = _kindedSupplements[kind];
    if (arrayM == nil) {
        arrayM = [NSMutableArray array];
        _kindedSupplements[kind] = arrayM;
    }
    [arrayM insertObject:supplement atIndex:index];
}

- (void)addSupplement:(id)supplement forKind:(XZMocoaKind)kind {
    _identifier = nil;
    _supplementKind = kind;
    _supplement = supplement;
    if (_kindedSupplements == nil) {
        _kindedSupplements = [NSMutableDictionary dictionary];
    }
    NSMutableArray *arrayM = _kindedSupplements[kind];
    if (arrayM == nil) {
        arrayM = [NSMutableArray array];
        _kindedSupplements[kind] = arrayM;
    }
    [arrayM addObject:supplement];
}

- (NSMutableArray *)supplementsForKind:(XZMocoaKind)kind {
    return _kindedSupplements[kind];
}

- (id)supplementForKind:(XZMocoaKind)kind atIndex:(NSInteger)index {
    NSMutableArray *arrayM = _kindedSupplements[kind];
    return arrayM[index];
}

- (BOOL)isSupplementsEqualToSupplementsOfSection:(XZMocoaGroupSection *)section {
    if (_kindedSupplements == nil && section->_kindedSupplements == nil) {
        return YES;
    }
    if (_kindedSupplements == nil || section->_kindedSupplements == nil) {
        return NO;
    }
    return [_kindedSupplements isEqualToDictionary:section->_kindedSupplements];
}

- (void)copySupplementsFromSection:(XZMocoaGroupSection *)otherSection {
    _kindedSupplements = otherSection->_kindedSupplements;
}

- (void)removeAllCells {
    if (_kindedSupplements.count == 0) {
        _identifier = nil;
    }
    [_cells removeAllObjects];
    _cell = nil;
}

- (void)removeAllSupplements {
    if (_kindedSupplements.count > 0) {
        _identifier = nil;
    }
    [_kindedSupplements removeAllObjects];
    _supplement = nil;
    _supplementKind = nil;
}

- (void)removeAllObjects {
    [self removeAllCells];
    [self removeAllSupplements];
}

@end
