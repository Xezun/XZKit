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

typedef NS_OPTIONS(NSUInteger, XZMocoaGroupModelMapMode) {
    XZMocoaGroupModelMapModeSupplements = 1 << 0,
    XZMocoaGroupModelMapModeCells = 1 << 1,
    XZMocoaGroupModelMapModeAll = XZMocoaGroupModelMapModeSupplements | XZMocoaGroupModelMapModeCells,
};

@interface XZMocoaGroupSection<ObjectType> : NSObject
@property (nonatomic, readonly) NSInteger index;

- (instancetype)initWithIndex:(NSInteger)index NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, readonly, nullable) NSArray<ObjectType> *cells;
@property (nonatomic, readonly, nullable) NSDictionary<XZMocoaKind, NSArray<ObjectType> *> *supplements;

- (void)addCell:(ObjectType)cell;
- (void)insertCell:(ObjectType)cell atIndex:(NSInteger)index;
- (ObjectType)cellAtIndex:(NSInteger)index;
- (void)addSupplement:(ObjectType)object forKind:(XZMocoaKind)kind;
- (void)insertSupplement:(ObjectType)object atIndex:(NSInteger)index forKind:(XZMocoaKind)kind;
- (nullable NSMutableArray<ObjectType> *)supplementsForKind:(XZMocoaKind)kind;
- (nullable ObjectType)supplementForKind:(XZMocoaKind)kind atIndex:(NSInteger)index;
- (BOOL)isSupplementsEqualToSupplementsOfSection:(XZMocoaGroupSection *)section;

- (void)removeAllSupplements;
- (void)removeAllCells;
- (void)removeAllObjects;

- (void)shareSupplementsFromSection:(XZMocoaGroupSection *)otherSection;

@property (nonatomic, readonly, nullable) ObjectType cell;
@property (nonatomic, readonly, nullable) ObjectType supplement;
@property (nonatomic, readonly, nullable) XZMocoaKind supplementKind;
@end

typedef void (^BatchUpdatesCompletion)(BOOL);

/// 在批量更新的过程中，同一元素只能应用一个操作，但是在 MVVM 结构中，
/// 数据变化也可能会引起刷新操作，为了避免多个更新操作，因此会将这些操作暂存并延迟执行。
/// Mocoa 并不能区分所有重复操作，开发者应避免。
typedef void(^XZMocoaGroupDelayedUpdates)(__kindof XZMocoaViewModel *self);

@interface XZMocoaGroupViewModel () {
    /// 所有视图模型。
    NSMutableArray<XZMocoaGroupSection<__kindof XZMocoaViewModel *> *> * _Nonnull _viewModelSections;
    /// 所有数据模型。
    NSMutableArray<XZMocoaGroupSection<id<XZMocoaModel>> *>            * _Nonnull _modelSections;
}

@end

@implementation XZMocoaGroupViewModel

- (instancetype)initWithModel:(id)model {
    self = [super initWithModel:model];
    if (self) {
        _viewModelSections = [NSMutableArray array];
        _modelSections     = [NSMutableArray array];
        _supportedSupplementKinds = @[XZMocoaKindHeader, XZMocoaKindFooter];
    }
    return self;
}

- (void)prepare {
    [super prepare];
    [self _loadSubViewModelsWithoutEvents];
}

- (BOOL)isEmpty {
    return _viewModelSections.count == 0;
}

- (NSInteger)numberOfSections {
    return _viewModelSections.count;
}

- (NSInteger)numberOfCellsInSection:(NSInteger)section {
    return _viewModelSections[section].cells.count;
}

- (__kindof XZMocoaGroupCellViewModel *)viewModelForCellAtIndexPath:(NSIndexPath *)indexPath {
    return _viewModelSections[indexPath.section].cells[indexPath.item];
}

- (__kindof XZMocoaGroupSupplementViewModel *)viewModelForSupplementOfKind:(XZMocoaKind)kind atIndexPath:(NSIndexPath *)indexPath {
    return [_viewModelSections[indexPath.section] supplementForKind:kind atIndex:indexPath.item];
}

- (XZMocoaGroupSupplementViewModel *)viewModelForHeaderInSection:(NSInteger)section {
    return [_viewModelSections[section] supplementsForKind:XZMocoaKindHeader].firstObject;
}

- (XZMocoaGroupSupplementViewModel *)viewModelForFooterInSection:(NSInteger)section {
    return [_viewModelSections[section] supplementsForKind:XZMocoaKindFooter].firstObject;
}

- (NSIndexPath *)indexPathForCellViewModel:(XZMocoaGroupCellViewModel *)viewModel {
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

- (NSIndexPath *)indexPathForSupplementViewModel:(XZMocoaGroupSupplementViewModel *)viewModel {
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

#pragma mark - 处理 SectionViewModel 的事件

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
    [self _loadSubViewModelsWithoutEvents];
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
        [self.class model:model section:index standardizeToModelSection:modelSection supportedSupplementKinds:supportedSupplementKinds];
        
        // 加载新视图模型
        [self section:viewModelSection loadSubViewModelsWithModel:modelSection supportedSupplementKinds:supportedSupplementKinds];
    }];

    [self didReloadSectionsAtIndexes:sections];
}

- (void)insertSections:(NSIndexSet *)sections {
    id const model = self.model;
    NSArray<XZMocoaKind> * const supportedSupplementKinds = self.supportedSupplementKinds;
    
    // 添加元素，正向遍历：只有前面的元素正确了，后面的才能正确。
    [sections enumerateIndexesUsingBlock:^(NSUInteger const index, BOOL * _Nonnull stop) {
        // 加载新数据模型
        XZMocoaGroupSection * const modelSection = [[XZMocoaGroupSection alloc] initWithIndex:index];
        [self.class model:model section:index standardizeToModelSection:modelSection supportedSupplementKinds:supportedSupplementKinds];
        // 加载新视图模型
        XZMocoaGroupSection * const viewModelSection = [[XZMocoaGroupSection alloc] initWithIndex:index];
        [self section:viewModelSection loadSubViewModelsWithModel:model supportedSupplementKinds:supportedSupplementKinds];
    }];
    
    // 后更新 indexPath 以避免因 index 改变而发生视图刷新时，当前的事件还没有派发。
    [self _updateIndexPathsForSubViewModelsInSectionsFromIndex:sections.firstIndex toIndex:(_viewModelSections.count - 1) excludeSections:sections modelMaps:nil];
    
    // 更新 UI
    [self didInsertSectionsAtIndexes:sections];
}

- (void)deleteSections:(NSIndexSet *)sections {
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
    
    // 更新 indexPath
    [self _updateIndexPathsForSubViewModelsInSectionsFromIndex:sections.firstIndex toIndex:(_viewModelSections.count - 1) excludeSections:nil modelMaps:nil];
    
    // 更新 UI
    [self didDeleteSectionsAtIndexes:sections];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    {
        XZMocoaGroupSection * const viewModelSection = _viewModelSections[section];
        [_viewModelSections removeObjectAtIndex:section];
        [_viewModelSections insertObject:viewModelSection atIndex:newSection];
        
        XZMocoaGroupSection * const modelSection = _modelSections[section];
        [_modelSections removeObjectAtIndex:section];
        [_modelSections insertObject:modelSection atIndex:newSection];
    }
    
    // 更新 index
    NSInteger const min = MIN(section, newSection);
    NSInteger const max = MAX(section, newSection);
    [self _updateIndexPathsForSubViewModelsInSectionsFromIndex:min toIndex:max excludeSections:nil modelMaps:nil];
}

#pragma mark - 批量更新

- (NSMutableDictionary<XZMocoaKind, NSMapTable *> *)modelMapsForModelSections:(NSArray<XZMocoaGroupSection *> * const)modelSections mode:(XZMocoaGroupModelMapMode)mode {
    NSMutableDictionary<XZMocoaKind, NSMapTable *> * const modelMaps = [NSMutableDictionary dictionary];
    
    NSInteger const sectionCount = modelSections.count;
    for (NSInteger sectionIndex = 0; sectionIndex < sectionCount; sectionIndex++) {
        XZMocoaGroupSection * const modelSection = modelSections[sectionIndex];
        
        if (mode & XZMocoaGroupModelMapModeSupplements) {
            for (XZMocoaKind const kind in modelSection.supplements) {
                NSMapTable *supplementModelMap = modelMaps[kind];
                if (supplementModelMap == nil) {
                    supplementModelMap = [NSMapTable strongToStrongObjectsMapTable];
                    modelMaps[kind] = supplementModelMap;
                }
                
                NSArray * const supplementModels = [modelSection supplementsForKind:kind];
                NSInteger const supplementCount = supplementModels.count;
                
                for (NSInteger supplementIndex = 0; supplementIndex < supplementCount; supplementIndex++) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:supplementIndex inSection:sectionIndex];
                    id const newSupplementModel = supplementModels[sectionIndex];
                    
                    if (newSupplementModel == nil || [supplementModelMap objectForKey:newSupplementModel]) {
                        return nil;
                    }
                    [supplementModelMap setObject:indexPath forKey:newSupplementModel];
                }
            }
        }
        
        if (mode & XZMocoaGroupModelMapModeCells) {
            NSMapTable *cellModelMap = modelMaps[XZMocoaKindDefault];
            if (cellModelMap == nil) {
                cellModelMap = [NSMapTable strongToStrongObjectsMapTable];
                modelMaps[XZMocoaKindDefault] = cellModelMap;
            }
            
            NSArray * const cellModels = modelSection.cells;
            NSInteger const cellCount = cellModels.count;
            for (NSInteger cellIndex = 0; cellIndex < cellCount; cellIndex++) {
                NSIndexPath *    const indexPath = [NSIndexPath indexPathForItem:cellIndex inSection:sectionIndex];
                id<XZMocoaModel> const cellModel = cellModels[cellIndex];
                
                if (cellModelMap == nil || [cellModelMap objectForKey:cellModel]) {
                    return nil;
                }
                [cellModelMap setObject:indexPath forKey:cellModel];
            }
        }
    }
    
    return modelMaps;
}

- (void)performBatchUpdates:(void (^NS_NOESCAPE const)(void))batchUpdates completion:(void (^ _Nullable)(BOOL))completion {
    XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 开始");
    if (batchUpdates == nil) {
        return;
    }
    
    NSInteger __block flag = 0;
    completion = ^(BOOL finished) {
        if ((--flag) > 0) {
            return;
        }
        if (completion) completion(finished);
    };
    
    NSMutableDictionary<XZMocoaKind, NSMapTable *> * const oldModelMaps = [self modelMapsForModelSections:_modelSections mode:XZMocoaGroupModelMapModeAll];
    if (oldModelMaps == nil) {
        XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 旧数据存在重复，无差异分析");
        [self reloadData];
        XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 结束");
        return completion(YES);
    }
    
    batchUpdates();
    
    id        const model                    = self.model;
    NSArray * const supportedSupplementKinds = self.supportedSupplementKinds;
    
    // 标准化新数据
    NSMutableArray<XZMocoaGroupSection<id<XZMocoaModel>> *> * const newModelSections = [NSMutableArray array];
    [self.class model:model standardizeToModelSections:newModelSections supportedSupplementKinds:supportedSupplementKinds];
    
    // 新数据 与 indexPath 的映射关系，若数据包含重复元素，将被置为 nil
    NSDictionary<XZMocoaKind, NSMapTable *> * const newModelMaps = [self modelMapsForModelSections:newModelSections mode:XZMocoaGroupModelMapModeAll];
    
    if (newModelMaps == nil) {
        XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 新数据存在重复，无差异分析");
        // TODO: 利用已经生成的 newModelSections 刷新数据
        [self reloadData];
        XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 结束");
        return completion(YES);
    }
    
    XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 差异分析开始");
    NSInteger const newSectionCount = newModelSections.count;
    
    // 在批量更新时，同一个元素只能有一种更新行为。
    // 不论是 tableView 还是 collectionView 都没有直接刷新 supplement 视图的方法，
    // 所以只要 supplements 发生改变，都需要重新创建 section 中的所有元素。
    // 因此，首先将 supplements 发生改变的删除。
    NSMutableIndexSet * const deleteSectionIndexes = [NSMutableIndexSet indexSet];
    // 从 oldSectionIndex 到 newSectionIndex 的映射
    NSMutableDictionary<NSNumber *, NSNumber *> * const sectionIndexChanges = [NSMutableDictionary dictionary];
    // 位置发生移动元素的新位置，用于回填到数组中
    NSMutableIndexSet * const newSectionIndexes = [NSMutableIndexSet indexSet];
    // 位置发生移动元素的旧位置，用于从数组中移除
    NSMutableIndexSet * const oldSectionIndexes = [NSMutableIndexSet indexSet];
    // 新位置 newSectionIndex 与 model、viewModel 的映射
    NSMutableDictionary<NSNumber *, NSArray<XZMocoaGroupSection *> *> * const newSectionIndexToModelViewModelDict = [NSMutableDictionary dictionary];
    
    // 遍历旧 supplements 看是否能在新的中找到
    for (NSInteger oldSectionIndex = _modelSections.count - 1; oldSectionIndex >= 0; oldSectionIndex--) {
        XZMocoaGroupSection * const oldModelSection = _modelSections[oldSectionIndex];
        
        // 没有 supplements 保留，cell 可能复用
        if (oldModelSection.supplementKind == nil) {
            continue;
        }
        
        NSIndexPath * const newIndexPath = [newModelMaps[oldModelSection.supplementKind] objectForKey:oldModelSection.supplement];
        
        // 在新数据中，没有找到对应的 supplements
        if (newIndexPath == nil) {
            [deleteSectionIndexes addIndex:oldSectionIndex];
            continue;
        }
        
        NSInteger const newSectionIndex = newIndexPath.section;
        XZMocoaGroupSection * const newModelSection = newModelSections[newSectionIndex];
        
        // 旧的 supplements 在同一个新的 section 中都能找到，数量一致且一一对应
        if ([oldModelSection isSupplementsEqualToSupplementsOfSection:newModelSection]) {
            sectionIndexChanges[@(oldSectionIndex)] = @(newSectionIndex);
            [newSectionIndexes addIndex:newSectionIndex];
            [oldSectionIndexes addIndex:oldSectionIndex];
            newSectionIndexToModelViewModelDict[@(newSectionIndex)] = @[_modelSections[oldSectionIndex], _viewModelSections[oldSectionIndex]];
            continue;
        }
        
        // 不相等，移除
        [deleteSectionIndexes addIndex:oldSectionIndex];
    }
    
    if (deleteSectionIndexes.count > 0) {
        flag++;
        [self didPerformBatchUpdates:^{
            // 以删除 supplements 代替删除整个 section 以复用 cell
            [deleteSectionIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                XZMocoaGroupSection *viewModelSection = _viewModelSections[idx];
                [viewModelSection removeAllSupplements];
                
                XZMocoaGroupSection *modelSection = _modelSections[idx];
                [modelSection.supplements enumerateKeysAndObjectsUsingBlock:^(XZMocoaKind const kind, NSArray * models, BOOL * _Nonnull stop) {
                    for (id const model in models) {
                        [oldModelMaps[kind] removeObjectForKey:model];
                    }
                }];
                [modelSection removeAllSupplements];
                
                XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 删除附加视图 %ld", idx);
            }];
            [self didReloadSectionsAtIndexes:deleteSectionIndexes];
        } completion:completion];
    }
    
    // 插入空 section 补足数量。
    if (newSectionCount > _viewModelSections.count) {
        flag++;
        [self didPerformBatchUpdates:^{
            NSMutableIndexSet * const sections = [NSMutableIndexSet indexSet];
            for (NSInteger newSectionIndex = _viewModelSections.count; newSectionIndex < newSectionCount; newSectionIndex++) {
                XZMocoaGroupSection *viewModelSection = [[XZMocoaGroupSection alloc] initWithIndex:newSectionIndex];
                [_viewModelSections addObject:viewModelSection];
                
                XZMocoaGroupSection *modelSection = [[XZMocoaGroupSection alloc] initWithIndex:newSectionIndex];
                [_modelSections addObject:modelSection];
                [sections addIndex:newSectionIndex];
                
                XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 添加占位区块 %ld", newSectionIndex);
            }
            [self didInsertSectionsAtIndexes:sections];
        } completion:completion];
    }
    
    // 排序
    if (oldSectionIndexes.count > 0) {
        flag++;
        [self didPerformBatchUpdates:^{
            // 先把有映射关系的先移除，然后再按新顺序插入回去
            [_viewModelSections removeObjectsAtIndexes:oldSectionIndexes];
            [_modelSections removeObjectsAtIndexes:oldSectionIndexes];
            [newSectionIndexes enumerateIndexesUsingBlock:^(NSUInteger newSectionIndex, BOOL * _Nonnull stop) {
                NSArray *elements = newSectionIndexToModelViewModelDict[@(newSectionIndex)];
                id const viewModel = elements[1];
                [_viewModelSections insertObject:viewModel atIndex:newSectionIndex];
                id const model = elements[0];
                [_modelSections insertObject:model atIndex:newSectionIndex];
            }];
            
            // 更新 indexPath
            NSInteger from = MIN(oldSectionIndexes.firstIndex, newSectionIndexes.firstIndex);
            NSInteger to   = MAX(oldSectionIndexes.lastIndex, newSectionIndexes.lastIndex);
            [self _updateIndexPathsForSubViewModelsInSectionsFromIndex:from toIndex:to excludeSections:nil modelMaps:oldModelMaps];
            
            // 发送事件
            [sectionIndexChanges enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull fromValue, NSNumber * _Nonnull toValue, BOOL * _Nonnull stop) {
                NSInteger const from = fromValue.integerValue;
                NSInteger const to   = toValue.integerValue;
                if (from == to) {
                    return;
                }
                [self didMoveSectionAtIndex:from toIndex:to];
                
                XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 排序原始区块 %ld => %ld", from, to);
            }];
        } completion:completion];
    }
    
    // 更新 cells
    flag++;
    [self didPerformBatchUpdates:^{
        NSMapTable * const oldCellMap = oldModelMaps[XZMocoaKindDefault];
        
        NSMutableArray<NSIndexPath *> *deletes = [NSMutableArray array];
        NSMutableArray<NSDictionary<NSString *, NSIndexPath *> *> *changes = [NSMutableArray array];
        NSMutableArray<NSIndexPath *> *inserts = [NSMutableArray array];
        
        NSMutableArray<XZMocoaGroupSection<XZMocoaViewModel *> *> * const newViewModelSections = [NSMutableArray arrayWithCapacity:newSectionCount];
        
        for (NSInteger newSectionIndex = 0; newSectionIndex < newSectionCount; newSectionIndex++) {
            XZMocoaGroupSection * const newViewModelSection = [[XZMocoaGroupSection alloc] initWithIndex:newSectionIndex];
            [newViewModelSections addObject:newViewModelSection];
            
            // 复制 supplements
            [newViewModelSection shareSupplementsFromSection:_viewModelSections[newSectionIndex]];
            XZMocoaGroupSection * const newModelSection = newModelSections[newSectionIndex];
            
            // 刷新 cells
            [newModelSection.cells enumerateObjectsUsingBlock:^(id  _Nonnull newCellModel, NSUInteger newCellIndex, BOOL * _Nonnull stop) {
                NSIndexPath *indexPath = [oldCellMap objectForKey:newCellModel];
                
                // 新增
                if (indexPath == nil) {
                    indexPath = [NSIndexPath indexPathForItem:newCellIndex inSection:newSectionIndex];
                    [inserts addObject:indexPath];
                    XZMocoaViewModel *viewModel = [self createViewModelWithModel:newCellModel forKind:(XZMocoaKindDefault)];
                    [newViewModelSection addCell:viewModel];
                    
                    XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 添加单元视图 %ld, %ld", indexPath.section, indexPath.item);
                    return;
                }
                
                // 移除匹配成功的元素
                [oldCellMap removeObjectForKey:newCellModel];
                
                // 保持
                if (indexPath.section == newSectionIndex && indexPath.item == newCellIndex) {
                    XZMocoaViewModel *viewModel = [_viewModelSections[newSectionIndex] cellAtIndex:newCellIndex];
                    [newViewModelSection addCell:viewModel];
                    return;
                }
                
                // 移动
                XZMocoaViewModel *viewModel = [_viewModelSections[indexPath.section] cellAtIndex:indexPath.item];
                [newViewModelSection addCell:viewModel];
                [changes addObject:@{ @"from": indexPath, @"to": [NSIndexPath indexPathForItem:newCellIndex inSection:newSectionIndex] }];
            }];
        }
        
        for (NSInteger oldSectionIndex = newSectionCount; oldSectionIndex < _viewModelSections.count; oldSectionIndex++) {
            XZMocoaGroupSection * const newViewModelSection = [[XZMocoaGroupSection alloc] initWithIndex:oldSectionIndex];
            [newViewModelSections addObject:newViewModelSection];
            [newViewModelSection shareSupplementsFromSection:_viewModelSections[oldSectionIndex]];
        }
        
        for (id oldCellModel in oldCellMap.keyEnumerator) {
            NSIndexPath *indexPath = [oldCellMap objectForKey:oldCellModel];
            [deletes addObject:indexPath];
            
            XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 删除单元视图 %ld, %ld", indexPath.section, indexPath.item);
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
            
            XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 移动单元视图 %ld, %ld => %ld, %ld", oldIndexPath.section, oldIndexPath.item, newIndexPath.section, newIndexPath.item);
        }
    } completion:completion];
    
    // 移除多余的 section
    if (_viewModelSections.count > newSectionCount) {
        flag++;
        [self didPerformBatchUpdates:^{
            NSRange const range = NSMakeRange(newSectionCount, _viewModelSections.count - newSectionCount);
            [_viewModelSections removeObjectsInRange:range];
            [self didDeleteSectionsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
        } completion:completion];
    }
    
    // 更新 supplemts
    NSMutableIndexSet *updates = [NSMutableIndexSet indexSet];
    for (NSInteger newSectionIndex = 0; newSectionIndex < newSectionCount; newSectionIndex++) {
        if ([newSectionIndexes containsIndex:newSectionIndex]) {
            continue;
        }

        NSDictionary<XZMocoaKind, NSArray *> * const supplements = newModelSections[newSectionIndex].supplements;
        if (supplements.count == 0) {
            continue;
        }
        
        XZMocoaGroupSection *viewModelSection = _viewModelSections[newSectionIndex];
        
        [supplements enumerateKeysAndObjectsUsingBlock:^(XZMocoaKind const kind, NSArray * const supplementModels, BOOL * _Nonnull stop) {
            [supplementModels enumerateObjectsUsingBlock:^(id const supplementModel, NSUInteger idx, BOOL * _Nonnull stop) {
                XZMocoaViewModel *viewModel = [self createViewModelWithModel:supplementModel forKind:kind];
                [viewModelSection addSupplement:viewModel forKind:kind];
            }];
        }];
        
        [updates addIndex:newSectionIndex];
        
        XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 更新辅助视图 %ld", newSectionIndex);
    }
    if (updates.count > 0) {
        flag++;
        [self didPerformBatchUpdates:^{
            [self didReloadSectionsAtIndexes:updates];
        } completion:completion];
    }
    
    XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 结束");
}

#pragma mark - 私有方法
/// 更新 section 范围从 min 到 max 之间（包含临界值）的所有视图模型的 indexPath 值。
- (void)_updateIndexPathsForSubViewModelsInSectionsFromIndex:(NSInteger)min toIndex:(NSInteger)max excludeSections:(nullable NSIndexSet *)excludeSections modelMaps:(nullable NSDictionary *)modelMaps {
    for (NSInteger sectionIndex = min; sectionIndex <= max; sectionIndex++) {
        if ([excludeSections containsIndex:sectionIndex]) {
            continue;
        }
        NSMapTable *cellModelMap = modelMaps[XZMocoaKindDefault];
        
        XZMocoaGroupSection * const viewModelSection = _viewModelSections[sectionIndex];
        XZMocoaGroupSection * const modelSection = _modelSections[sectionIndex];
        [viewModelSection.cells enumerateObjectsUsingBlock:^(XZMocoaViewModel *viewModel, NSUInteger idx, BOOL * _Nonnull stop) {
            NSIndexPath *indexPath = viewModel.indexPath;
            if (indexPath && indexPath.section == sectionIndex && indexPath.item == idx) {
                return;
            }
            indexPath = [NSIndexPath indexPathForItem:idx inSection:sectionIndex];
            viewModel.indexPath = indexPath;
            
            if (cellModelMap) {
                id model = [modelSection cellAtIndex:idx];
                [cellModelMap setObject:indexPath forKey:model];
            }
        }];
        [viewModelSection.supplements enumerateKeysAndObjectsUsingBlock:^(XZMocoaKind const kind, NSArray<XZMocoaViewModel *> * _Nonnull viewModels, BOOL * _Nonnull stop) {
            NSMapTable *supplementModelMap = modelMaps[kind];
            [viewModels enumerateObjectsUsingBlock:^(XZMocoaViewModel * _Nonnull viewModel, NSUInteger idx, BOOL * _Nonnull stop) {
                NSIndexPath *indexPath = viewModel.indexPath;
                if (indexPath && indexPath.section == sectionIndex && indexPath.item == idx) {
                    return;
                }
                indexPath = [NSIndexPath indexPathForItem:idx inSection:sectionIndex];
                viewModel.indexPath = indexPath;
                
                if (supplementModelMap) {
                    id model = [modelSection supplementForKind:kind atIndex:idx];
                    [supplementModelMap setObject:indexPath forKey:model];
                }
            }];
        }];
    }
}

/// 添加所有 section 元素，需先清理数据。
- (void)_loadSubViewModelsWithoutEvents {
    // 清理旧数据
    [_modelSections removeAllObjects];
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
    
    id                     const model                    = self.model;
    NSArray<XZMocoaKind> * const supportedSupplementKinds = self.supportedSupplementKinds;
    
    // 准备数据：数据标准化
    [self.class model:model standardizeToModelSections:_modelSections supportedSupplementKinds:supportedSupplementKinds];
    
    // 创建视图模型
    [_modelSections enumerateObjectsUsingBlock:^(XZMocoaGroupSection<id<XZMocoaModel>> * const modelSection, NSUInteger sectionIndex, BOOL * _Nonnull stop) {
        XZMocoaGroupSection * const viewModelSection = [[XZMocoaGroupSection alloc] initWithIndex:sectionIndex];
        [self section:viewModelSection loadSubViewModelsWithModel:modelSection supportedSupplementKinds:supportedSupplementKinds];
        [_viewModelSections addObject:viewModelSection];
    }];
}

/// 将 model 结构化为标准数据模型，如果数据不包含重复数据，返回映射关系。
+ (void)model:(id)model standardizeToModelSections:(NSMutableArray<XZMocoaGroupSection<id<XZMocoaModel>> *> *)modelSections supportedSupplementKinds:(NSArray<XZMocoaKind> *)supportedSupplementKinds {
    NSInteger const sectionCount = [self model:model numberOfSections:NULL];
    for (NSInteger sectionIndex = 0; sectionIndex < sectionCount; sectionIndex++) {
        XZMocoaGroupSection * const modelSection = [[XZMocoaGroupSection alloc] initWithIndex:sectionIndex];
        [self model:model section:sectionIndex standardizeToModelSection:modelSection supportedSupplementKinds:supportedSupplementKinds];
        [modelSections addObject:modelSection];
    }
}

+ (void)model:(id)model section:(NSInteger const)sectionIndex standardizeToModelSection:(XZMocoaGroupSection *)newModelSection supportedSupplementKinds:(NSArray<XZMocoaKind> *)supportedSupplementKinds {
    // supplements
    for (XZMocoaKind const kind in supportedSupplementKinds) {
        NSInteger const supplementCount = [self model:model numberOfSupplementsOfKind:kind inSection:sectionIndex];
        
        for (NSInteger newSupplementIndex = 0; newSupplementIndex < supplementCount; newSupplementIndex++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:newSupplementIndex inSection:sectionIndex];
            id const newSupplementModel = [self model:model modelForSupplementOfKind:kind atIndexPath:indexPath];
            [newModelSection addSupplement:(newSupplementModel ?: (id)kCFNull) forKind:kind];
        }
    }
    
    // cells
    {
        NSInteger const cellCount = [self model:model numberOfCellsInSection:sectionIndex];
        for (NSInteger item = 0; item < cellCount; item++) {
            NSIndexPath *    const indexPath = [NSIndexPath indexPathForItem:item inSection:sectionIndex];
            id<XZMocoaModel> const newCellModel = [self model:model modelForCellAtIndexPath:indexPath];
            [newModelSection addCell:(newCellModel ?: (id)kCFNull)];
        }
    }
}

- (void)section:(XZMocoaGroupSection<XZMocoaViewModel *> *)viewModelSection loadSubViewModelsWithModel:(XZMocoaGroupSection *)modelSection supportedSupplementKinds:(NSArray<XZMocoaKind> *)supportedSupplementKinds {
    NSInteger const sectionIndex = viewModelSection.index;
    
    for (XZMocoaKind const kind in supportedSupplementKinds) {
        NSMutableArray * const supplementModels = [modelSection supplementsForKind:kind];
        
        [[modelSection supplementsForKind:kind] enumerateObjectsUsingBlock:^(id const supplementModel, NSUInteger supplementIndex, BOOL * _Nonnull stop) {
            NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:supplementIndex inSection:sectionIndex];
            XZMocoaGroupSupplementViewModel * const viewModel = [self createViewModelWithModel:supplementModel forKind:kind];
            viewModel.indexPath = indexPath;
            [self addSubViewModel:viewModel];
            [viewModelSection addSupplement:viewModel forKind:kind];
            // [viewModelSection insertSupplement:viewModel atIndex:supplementIndex forKind:kind];
        }];
    }
    
    {
        NSArray * const cellModels = modelSection.cells;
        for (NSInteger cellIndex = 0; cellIndex < cellModels.count; cellIndex++) {
            NSIndexPath *    const indexPath = [NSIndexPath indexPathForItem:cellIndex inSection:sectionIndex];
            id<XZMocoaModel> const cellModel = cellModels[cellIndex];
            
            XZMocoaGroupCellViewModel * const viewModel = [self createViewModelWithModel:cellModel forKind:(XZMocoaKindDefault)];
            viewModel.indexPath = indexPath;
            [self addSubViewModel:viewModel];
            [viewModelSection addCell:viewModel];
            //[viewModelSection insertCell:viewModel atIndex:cellIndex];
        }
    }
}

- (__kindof XZMocoaViewModel *)createViewModelWithModel:(id<XZMocoaModel>)model forKind:(XZMocoaKind)kind {
    if (model == (id)kCFNull) {
        model = nil;
    }
    
    XZMocoaName     const name   = model.mocoaName ?: XZMocoaNameDefault;
    XZMocoaModule * const module = [self.module submoduleIfLoadedForKind:kind forName:name];
    
    Class      const VMClass    = module.viewModelClass      ?: [self viewModelClassForPlaceholderOfKind:kind];
    NSString * const identifier = module.viewReuseIdentifier ?: XZMocoaReuseIdentifier(kind, name);
    
    XZMocoaGroupCellViewModel * const viewModel = [[VMClass alloc] initWithModel:model];
    viewModel.module     = module;
    viewModel.identifier = identifier;
    return viewModel;
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

- (Class)viewModelClassForPlaceholderOfKind:(XZMocoaKind)kind {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重写 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

@end

@implementation XZMocoaGroupViewModel (XZMocoaGroupModel)

+ (NSInteger)model:(id<XZMocoaGroupModel>)model numberOfSections:(void *)null {
    return [model numberOfSections];
}

+ (NSInteger)model:(id<XZMocoaGroupModel>)model numberOfCellsInSection:(NSInteger)section {
    return [model numberOfCellsInSection:section];
}

+ (id)model:(id<XZMocoaGroupModel>)model modelForCellAtIndexPath:(NSIndexPath *)indexPath {
    return [model modelForCellAtIndexPath:indexPath];
}

+ (NSInteger)model:(id<XZMocoaGroupModel>)model numberOfSupplementsOfKind:(XZMocoaKind)kind inSection:(NSInteger)section {
    return [model numberOfSupplementsOfKind:kind inSection:section];
}

+ (id)model:(id<XZMocoaGroupModel>)model modelForSupplementOfKind:(XZMocoaKind)kind atIndexPath:(NSIndexPath *)indexPath {
    return [model modelForSupplementOfKind:kind atIndexPath:indexPath];
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
    // 调用 db.save() 会触发当前代理方法。
    // 如果在 batchUpdates 中调用的 db.save() 方法，那么下面的批量更新会被拦截。
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
    // if (!self.isReady) return;
//    switch (type) {
//        case NSFetchedResultsChangeInsert: {
//            break;
//        }
//        case NSFetchedResultsChangeMove: {
//            if ([anObject hasPersistentChangedValues]) {
//                XZMocoaGroupCellViewModel * const viewModel = [self cellViewModelAtIndexPath:indexPath];
//                if (viewModel.shouldObserveModelKeysActively) {
//                    break;
//                }
//                NSDictionary<NSString *, id> * const changedValues = anObject.changedValuesForCurrentEvent;
//                [viewModel model:anObject didChangeValuesForKeys:[NSSet setWithArray:changedValues.allKeys]];
//            }
//            break;
//        }
//        case NSFetchedResultsChangeDelete: {
//            break;
//        }
//        case NSFetchedResultsChangeUpdate: {
//            // 如果同时发生了 move 事件，则不会调用此方法
//            // changedValuesForCurrentEvent 中仅包含持久存储属性变更，先使用 hasPersistentChangedValues 判断是否有更新以优化性能
//            if ([anObject hasPersistentChangedValues]) {
//                XZMocoaGroupCellViewModel * const viewModel = [self cellViewModelAtIndexPath:indexPath];
//                if (viewModel.shouldObserveModelKeysActively) {
//                    break;
//                }
//                NSDictionary<NSString *, id> * const changedValues = anObject.changedValuesForCurrentEvent;
//                [viewModel model:anObject didChangeValuesForKeys:[NSSet setWithArray:changedValues.allKeys]];
//            }
//            break;
//        }
//    }
}

@end


@implementation XZMocoaGroupSection {
    NSMutableArray *_cells;
    NSMutableDictionary *_kindedSupplements;
}

- (instancetype)initWithIndex:(NSInteger)index {
    self = [super init];
    if (self) {
        _index = index;
    }
    return self;
}

- (void)addCell:(id)cell {
    _cell = cell;
    if (_cells == nil) {
        _cells = [[NSMutableArray alloc] init];
    }
    [_cells addObject:cell];
}

- (void)insertCell:(id)cell atIndex:(NSInteger)index {
    _cell = cell;
    if (_cells == nil) {
        _cells = [[NSMutableArray alloc] init];
    }
    [_cells insertObject:cell atIndex:index];
}

- (id)cellAtIndex:(NSInteger)index {
    return _cells[index];
}

- (NSDictionary *)supplements {
    return _kindedSupplements;
}

- (void)insertSupplement:(id)supplement atIndex:(NSInteger)index forKind:(XZMocoaKind)kind {
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
    NSArray<XZMocoaKind> * const kinds = _kindedSupplements.allKeys;
    if (![kinds isEqualToArray:section->_kindedSupplements.allKeys]) {
        return NO;
    }
    for (XZMocoaKind const kind in kinds) {
        NSArray *supplements1 = _kindedSupplements[kind];
        NSArray *supplements2 = section->_kindedSupplements[kind];
        if (supplements2 == nil) {
            return NO;
        }
        if ([supplements1 isEqualToArray:supplements2]) {
            continue;
        }
        return NO;
    }
    return YES;
}

- (void)shareSupplementsFromSection:(XZMocoaGroupSection *)otherSection {
    _kindedSupplements = otherSection->_kindedSupplements;
}

- (void)removeAllCells {
    _cell = nil;
    [_cells removeAllObjects];
}

- (void)removeAllSupplements {
    [_kindedSupplements removeAllObjects];
    _supplement = nil;
    _supplementKind = nil;
}

- (void)removeAllObjects {
    [self removeAllCells];
    [self removeAllSupplements];
}

@end
