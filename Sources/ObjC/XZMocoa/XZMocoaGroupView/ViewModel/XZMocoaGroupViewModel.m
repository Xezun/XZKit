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

@interface XZMocoaGroupSection<ObjectType> : NSObject
@property (nonatomic, readonly, nonnull)  NSMutableArray<ObjectType> *cells;
@property (nonatomic, readonly, nullable) NSMutableArray<ObjectType> *cellsIfLoaded;
@property (nonatomic, readonly, nonnull)  NSMutableDictionary<XZMocoaKind, NSMutableArray<ObjectType> *> *supplements;
@property (nonatomic, readonly, nullable) NSMutableDictionary<XZMocoaKind, NSMutableArray<ObjectType> *> *supplementsIfLoaded;
@property (nonatomic, readonly, nonnull)  NSMutableArray<ObjectType> *(^supplementsForKind)(XZMocoaKind kind);
@property (nonatomic, readonly, nonnull)  NSMutableArray<ObjectType> * _Nullable (^supplementsIfLoadedForKind)(XZMocoaKind kind);
@end

typedef void (^BatchUpdatesCompletion)(BOOL);

/// 在批量更新的过程中，同一元素只能应用一个操作，但是在 MVVM 结构中，
/// 数据变化也可能会引起刷新操作，为了避免多个更新操作，因此会将这些操作暂存并延迟执行。
/// Mocoa 并不能区分所有重复操作，开发者应避免。
typedef void(^XZMocoaGroupDelayedUpdates)(__kindof XZMocoaViewModel *self);

@interface XZMocoaGroupViewModel () {
    /// 记录了批量更新前的数据，如果不为空，则表示当前处于批量更新过程中。
//    NSOrderedSet  *_beforesBatchUpdates;
//    NSMutableArray<void (^)(BOOL)>               *_handlerBatchUpdates;
    /// 批量更新时，被延迟的更新。
//    NSMutableArray<XZMocoaGroupDelayedUpdates>   *_delayedBatchUpdates;
    /// 是否需要执行批量更新的差异分析。
    /// @note 在批量更新时，由于同一对象不能重复操作，因此任一独立更新操作被调用时，都会标记此值为NO，以关闭差异分析，避免重复操作。
//    BOOL _needsDifferenceBatchUpdates;
    
    /// 所有视图模型。
    NSMutableArray<XZMocoaGroupSection<__kindof XZMocoaViewModel *> *> *_viewModelSections;
    /// 所有数据模型。
    NSMutableArray<XZMocoaGroupSection<id<XZMocoaModel>> *>            *_modelSections;
    // 数据模型与 indexPath 的映射表。
    // - 如果不存在，则表示存在重复数据，列表不能使用差异分析。
    NSMutableDictionary<XZMocoaKind, NSMapTable *>                     *_modelMaps;
}

@end

@implementation XZMocoaGroupViewModel

- (instancetype)initWithModel:(id)model {
    self = [super initWithModel:model];
    if (self) {
//        _beforesBatchUpdates = nil;
        _viewModelSections = nil;
        _modelSections     = nil;
        _supportedSupplementKinds = @[XZMocoaKindHeader, XZMocoaKindFooter];
    }
    return self;
}

- (void)prepare {
    [super prepare];
    [self _loadSubViewModelsWithoutEvents];
}

- (void)didRemoveSubViewModel:(__kindof XZMocoaViewModel *)viewModel {
    for (XZMocoaGroupSection *info in _viewModelSections) {
        NSMutableArray *cells = info.cellsIfLoaded;
        for (NSInteger index = cells.count - 1; index >= 0; index--) {
            id object = cells[index];
            if (object == viewModel) {
                [cells removeObjectAtIndex:index];
            }
        }
        [info.supplementsIfLoaded enumerateKeysAndObjectsUsingBlock:^(id const key, NSMutableArray * const supplementViewModels, BOOL * _Nonnull stop) {
            for (NSInteger index = supplementViewModels.count - 1; index >= 0; index--) {
                id object = supplementViewModels[index];
                if (object == viewModel) {
                    [supplementViewModels removeObjectAtIndex:index];
                }
            }
        }];
    }
}

- (BOOL)isEmpty {
    return _viewModelSections.count == 0;
}

- (NSInteger)numberOfSections {
    return _viewModelSections.count;
}

- (NSInteger)numberOfCellsInSection:(NSInteger)section {
    return _viewModelSections[section].cellsIfLoaded.count;
}

- (__kindof XZMocoaGroupCellViewModel *)viewModelForCellAtIndexPath:(NSIndexPath *)indexPath {
    return _viewModelSections[indexPath.section].cellsIfLoaded[indexPath.item];
}

- (__kindof XZMocoaGroupSupplementViewModel *)viewModelForSupplementOfKind:(XZMocoaKind)kind atIndexPath:(NSIndexPath *)indexPath {
    return _viewModelSections[indexPath.section].supplementsIfLoadedForKind(kind)[indexPath.item];
}

- (XZMocoaGroupSupplementViewModel *)viewModelForHeaderInSection:(NSInteger)section {
    return _viewModelSections[section].supplementsIfLoadedForKind(XZMocoaKindHeader).firstObject;
}

- (XZMocoaGroupSupplementViewModel *)viewModelForFooterInSection:(NSInteger)section {
    return _viewModelSections[section].supplementsIfLoadedForKind(XZMocoaKindFooter).firstObject;
}

- (NSIndexPath *)indexPathForCellForViewModel:(XZMocoaGroupCellViewModel *)viewModel {
    for (NSInteger sectionIndex = 0; sectionIndex < _viewModelSections.count; sectionIndex++) {
        NSArray * const cellsIfLoaded = _viewModelSections[sectionIndex].cellsIfLoaded;
        for (NSInteger itemIndex = 0; itemIndex < cellsIfLoaded.count; itemIndex++) {
            if (viewModel == cellsIfLoaded[itemIndex]) {
                return [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
            }
        }
    }
    return nil;
}

- (NSIndexPath *)indexPathForSupplementForViewModel:(XZMocoaGroupSupplementViewModel *)viewModel {
    NSIndexPath * __block indexPath = nil;
    for (NSInteger sectionIndex = 0; sectionIndex < _viewModelSections.count; sectionIndex++) {
        [_viewModelSections[sectionIndex].supplementsIfLoaded enumerateKeysAndObjectsUsingBlock:^(id const key, NSMutableArray * const supplementViewModels, BOOL * _Nonnull stop) {
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
//    _needsDifferenceBatchUpdates = NO;
    
    // 清理旧数据
    NSArray *_viewModelSections = self->_viewModelSections;
    self->_viewModelSections = nil;
    self->_modelSections     = nil;
    self->_modelMaps         = nil;
    
    for (XZMocoaGroupSection * const section in _viewModelSections) {
        for (XZMocoaViewModel * const viewModel in section.cellsIfLoaded) {
            [viewModel removeFromSuperViewModel];
        }
        [section.supplementsIfLoaded enumerateKeysAndObjectsUsingBlock:^(XZMocoaKind const key, NSMutableArray * const supplementViewModels, BOOL * _Nonnull stop) {
            for (XZMocoaViewModel *viewModel in supplementViewModels) {
                [viewModel removeFromSuperViewModel];
            }
        }];
    }
    
    // 加载新数据
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
//    _needsDifferenceBatchUpdates = NO;
//    
//    if (sections.count == 0) {
//        return;
//    }
//
//    // 在批量操作时，同一个元素只能进行一种操作，包括被动的操作（比如减少一个元素，后面的元素自动向前移动一个位置）。
//    // 并且在 -[UITableView reloadSections:withRowAnimation:] 的接口文档中，reload 行为与 delete 类似。
//    // 所以即使在批量更新过程中，也只能对未进行任何操作的元素，即还保持在原始位置的元素，执行 reload 操作。
//
//    id const model = self.model;
//
//    if (self.isPerformingBatchUpdates) {
//        // 在批量更新的过程中，由于操作的先后顺序的随机性，元素的实时排序，可能并非最终排序，
//        // 所以需要根据当前位置找到对应元素的原始位置，对原始位置执行 reload 操作。
//        NSMutableIndexSet * const oldSections = [NSMutableIndexSet indexSet];
//        [sections enumerateIndexesUsingBlock:^(NSUInteger const index, BOOL * _Nonnull stop) {
//            XZMocoaGroupSectionViewModel * const oldViewModel = [self sectionViewModelAtIndex:index];
//            NSInteger const oldSection = [_beforesBatchUpdates indexOfObject:oldViewModel];
//            [oldSections addIndex:oldSection];
//            [oldViewModel removeFromSuperViewModel];
//
//            id const newDataModel = [self model:model modelForSectionAtIndex:index];
//            id const newViewModel = [self createSectionViewModelWithModel:newDataModel index:index];
//            [self _insertSectionViewModel:newViewModel atIndex:index];
//        }];
//
//        [self didReloadSectionsAtIndexes:oldSections];
//    } else {
//        [sections enumerateIndexesUsingBlock:^(NSUInteger const index, BOOL * _Nonnull stop) {
//            XZMocoaGroupSectionViewModel * const oldViewModel = [self sectionViewModelAtIndex:index];
//            [oldViewModel removeFromSuperViewModel];
//
//            id const newDataModel = [self model:model modelForSectionAtIndex:index];
//            XZMocoaGroupSectionViewModel *newViewModel = [self createSectionViewModelWithModel:newDataModel index:index];
//            [self _insertSectionViewModel:newViewModel atIndex:index];
//        }];
//
//        [self didReloadSectionsAtIndexes:sections];
//    }
}

- (void)insertSections:(NSIndexSet *)sections {
//    _needsDifferenceBatchUpdates = NO;
//
//    if (sections.count == 0) {
//        return;
//    }
//
//    id const model = self.model;
//
//    // 添加元素，正向遍历：只有前面的元素正确了，后面的才能正确。
//    [sections enumerateIndexesUsingBlock:^(NSUInteger const index, BOOL * _Nonnull stop) {
//        id const newDataModel = [self model:model modelForSectionAtIndex:index];
//        id const newViewModel = [self createSectionViewModelWithModel:newDataModel index:index];
//        [self _insertSectionViewModel:newViewModel atIndex:index];
//    }];
//
//    [self didInsertSectionsAtIndexes:sections];
//
//    if (self.isPerformingBatchUpdates) {
//        return;
//    }
//
//    // 后更新 index 以避免因 index 改变而发生视图刷新时，当前的事件还没有派发。
//    NSInteger const count = self.numberOfSectionModels;
//    for (NSInteger section = sections.firstIndex; section < count; section++) {
//        [self sectionViewModelAtIndex:section].index = section;
//    }
}

- (void)deleteSections:(NSIndexSet *)sections {
//    _needsDifferenceBatchUpdates = NO;
//
//    if (sections.count == 0) {
//        return;
//    }
//
//    // 删除元素，反向遍历：从后面开始删除，不会影响前面的
//    if (self.isPerformingBatchUpdates) {
//        NSMutableIndexSet * const oldSections = [NSMutableIndexSet indexSet];
//        [sections enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger const index, BOOL *stop) {
//            XZMocoaGroupSectionViewModel * const oldViewModel = [self sectionViewModelAtIndex:index];
//            NSInteger const oldSection   = [_beforesBatchUpdates indexOfObject:oldViewModel];
//            [oldSections addIndex:oldSection];
//            [oldViewModel removeFromSuperViewModel];
//        }];
//        [self didDeleteSectionsAtIndexes:oldSections];
//    } else {
//        [sections enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger const index, BOOL *stop) {
//            XZMocoaGroupSectionViewModel * const oldViewModel = [self sectionViewModelAtIndex:index];
//            [oldViewModel removeFromSuperViewModel];
//        }];
//
//        [self didDeleteSectionsAtIndexes:sections];
//
//        // 后更新 index 以避免因 index 改变而发生视图刷新时，当前的事件还没有派发。
//        NSInteger const count = self.numberOfSectionModels;
//        for (NSInteger section = sections.firstIndex; section < count; section++) {
//            [self sectionViewModelAtIndex:section].index = section;
//        }
//    }
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection {
//    if (self.isPerformingBatchUpdates) {
//        // 批量更新过程中，移动 section 需要找到原始位置
//        id        const oldViewModel = [self sectionViewModelAtIndex:section];
//        NSInteger const oldSection   = [_beforesBatchUpdates indexOfObject:oldViewModel];
//        [self moveSectionAtIndex:section fromIndex:oldSection toIndex:newSection];
//    } else {
//        [self moveSectionAtIndex:section fromIndex:section toIndex:newSection];
//
//        // 先刷型视图，后更新 index 的原因：
//        // 因为 index 改变，可能会导致视图再次发生刷新，那么就会导致
//        // 后续的刷新先应用到视图，从而发生问题。
//        NSInteger const min = MIN(section, newSection);
//        NSInteger const max = MAX(section, newSection);
//        for (NSInteger index = min; index <= max; index++) {
//            [self sectionViewModelAtIndex:index].index = index;
//        }
//    }
}

/// 移动 section 。
/// @discussion 对于 UITableView 而言，变化就是从旧位置移动到新位置，但是对于 ViewModel 而言，
///             每次 move 都会改变数据源中数据的排序，所以数据的移动与视图的移动可能不一致。
/// @param section 当前位置
/// @param oldSection 原始位置
/// @param newSection 目标位置
- (void)moveSectionAtIndex:(NSInteger)section fromIndex:(NSInteger)oldSection toIndex:(NSInteger)newSection {
//    _needsDifferenceBatchUpdates = NO;
//
//    // 更新数据
//    [self _moveSectionViewModelFromIndex:section toIndex:newSection];
//
//    // 新旧位置无变化，不需要发送事件。
//    if (oldSection == newSection) {
//        return;
//    }
//
//    [self didMoveSectionAtIndex:oldSection toIndex:newSection];
}

#pragma mark - 批量更新

- (BOOL)isPerformingBatchUpdates {
//    return _beforesBatchUpdates != nil;
    return NO;
}

- (BOOL)prepareForBatchUpdates {
//    if (_beforesBatchUpdates) {
//        return NO;
//    }
    
    // 如果已有 section 处于批量更新状态，table 是不能进入批量更新状态的。
//    for (XZMocoaGroupSectionViewModel *viewModel in _beforesBatchUpdates) {
//        if (viewModel.isPerformingBatchUpdates) {
//            NSAssert(NO, @"不能在 section = %@ 批量更新的过程中，执行 %@ 的批量更新", viewModel, self);
//            return NO;
//        }
//    }
    
//    _handlerBatchUpdates = [NSMutableArray array];;
    
    // 所有 section 进入批量状态
//    for (XZMocoaGroupSectionViewModel *viewModel in _beforesBatchUpdates) {
//        [viewModel prepareForBatchUpdates];
//    }
//    
////    _beforesBatchUpdates = _sectionViewModels.copy;
//    for (XZMocoaGroupSectionViewModel *viewModel in _beforesBatchUpdates) {
//        if (viewModel.isPerformingBatchUpdates) {
//            return NO;
//        }
//        [viewModel prepareForBatchUpdates];
//    }
//    _delayedBatchUpdates = [NSMutableArray array];
    
    // 批量更新开始，默认标记需进行差异分析，并开始拦截需要延迟的操作。
//    _needsDifferenceBatchUpdates = YES;
    
    return YES;
}

- (void)cleanupForBatchUpdates {
    // 批量更新结束，不再接收回调。
//    _handlerBatchUpdates = nil;
//    _beforesBatchUpdates = nil;
//    
//    for (XZMocoaGroupDelayedUpdates const batchUpdates in _delayedBatchUpdates) {
//        batchUpdates(self);
//    }
//    _delayedBatchUpdates = nil;
    
    // 因为某些模块，可能会根据 index 来处理逻辑，所以在批量更新的过程设置 index 可能会造成视图刷新。
    // 所以将更新 index 的操作，放到了批量更新之后进行。
//    [_sectionViewModels enumerateObjectsUsingBlock:^(XZMocoaGroupSectionViewModel *viewModel, NSUInteger idx, BOOL * _Nonnull stop) {
//        [viewModel cleanupForBatchUpdates];
//        viewModel.index = idx;
//    }];
}

- (void)performBatchUpdates:(void (^NS_NOESCAPE)(void))batchUpdates completion:(void (^ _Nullable)(BOOL))completion {
    XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 开始");
    
    NSMutableDictionary<XZMocoaKind, NSMapTable *> *oldModelMaps = self->_modelMaps;
    if (oldModelMaps == nil) {
        XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 旧数据存在重复，无差异分析");
        [self reloadData];
        XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 结束");
        return;
    }
    
    id        const model                    = self.model;
    NSInteger const newSectionCount          = [self model:model numberOfSections:NULL];
    NSArray * const supportedSupplementKinds = self.supportedSupplementKinds;
    
    NSMutableDictionary<XZMocoaKind, NSMapTable *> *newModelMaps     = [NSMutableDictionary dictionary];
    NSMutableArray<XZMocoaGroupSection *>          *newModelSections = [NSMutableArray arrayWithCapacity:newSectionCount];
    
    for (NSInteger newSectionIndex = 0; newSectionIndex < newSectionCount; newSectionIndex++) {
        XZMocoaGroupSection * const newModelSection = [[XZMocoaGroupSection alloc] init];
        [newModelSections addObject:newModelSection];
        
        for (XZMocoaKind const kind in supportedSupplementKinds) {
            NSInteger const supplementCount = [self model:model numberOfSupplementsOfKind:kind inSection:newSectionIndex];
            
            NSMapTable *_newSupplementModelMap = newModelMaps[kind];
            if (_newSupplementModelMap == nil) {
                _newSupplementModelMap = [NSMapTable strongToStrongObjectsMapTable];
                newModelMaps[kind] = _newSupplementModelMap;
            }
            
            for (NSInteger newItem = 0; newItem < supplementCount; newItem++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:newItem inSection:newSectionIndex];
                id const newSupplemenaryModel = [self model:model modelForSupplementaryElementOfKind:kind atIndexPath:indexPath];
                
                [newModelSection.supplementsForKind(kind) addObject:(newSupplemenaryModel ?: (id)kCFNull)];
                
                if (newModelMaps == nil) {
                    continue;
                }
                if (newSupplemenaryModel == nil || [_newSupplementModelMap objectForKey:newSupplemenaryModel]) {
                    _newSupplementModelMap = nil;
                    newModelMaps = nil;
                    continue;
                }
                [_newSupplementModelMap setObject:indexPath forKey:newSupplemenaryModel];
            }
        }
        
        NSMapTable *_newCellModelMap = nil;
        if (newModelMaps) {
            _newCellModelMap = newModelMaps[XZMocoaKindDefault];
            if (_newCellModelMap == nil) {
                _newCellModelMap = [NSMapTable strongToStrongObjectsMapTable];
                newModelMaps[XZMocoaKindDefault] = _newCellModelMap;
            }
        }
        
        NSInteger const cellCount = [self model:model numberOfCellsInSection:newSectionIndex];
        for (NSInteger item = 0; item < cellCount; item++) {
            NSIndexPath *    const indexPath = [NSIndexPath indexPathForItem:item inSection:newSectionIndex];
            id<XZMocoaModel> const newCellModel = [self model:model modelForCellAtIndexPath:indexPath];
            
            [newModelSection.cells addObject:newCellModel];
            
            if (newModelMaps == nil) {
                continue;
            }
            if (_newCellModelMap == nil || [_newCellModelMap objectForKey:newCellModel]) {
                _newCellModelMap = nil;
                newModelMaps = nil;
                continue;
            }
            [_newCellModelMap setObject:indexPath forKey:newCellModel];
        }
    }
    
    if (newModelMaps == nil) {
        XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 新数据存在重复，无差异分析");
        [self reloadData];
        XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 结束");
        return nil;
    }
    
    XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 差异分析开始");
    
    // 不论是 tableView 还是 collectionView 都没有直接刷新 supplement 视图的方法，
    // 所以只要 supplements 中的任意元素发生改变，都需要重新创建 section 中的所有元素。
    
    // 避免插入 cell 时没有 section
    if (newSectionCount > _viewModelSections.count) {
        [self didPerformBatchUpdates:^{
            NSMutableIndexSet * const sections = [NSMutableIndexSet indexSet];
            for (NSInteger newSectionIndex = _viewModelSections.count; newSectionIndex < newSectionCount; newSectionIndex++) {
                XZMocoaGroupSection *viewModelSection = [[XZMocoaGroupSection alloc] init];
                [_viewModelSections addObject:viewModelSection];
                [sections addIndex:newSectionIndex];
            }
            [self didInsertSectionsAtIndexes:sections];
        } completion:nil];
    }
    
    // 假定所有 supplements 不变，先更新 cells
    [self didPerformBatchUpdates:^{
        NSMutableArray<NSIndexPath  *> *inserts = [NSMutableArray array];
        NSMutableArray<NSDictionary *> *changes = [NSMutableArray array];
        NSMutableArray<NSIndexPath  *> *deletes = [NSMutableArray array];
        
        NSMapTable * const oldCellModelMap = oldModelMaps[XZMocoaKindDefault];
        for (NSInteger newSectionIndex = 0; newSectionIndex < newModelSections.count; newSectionIndex++) {
            NSMutableArray *newCellViewModels = [NSMutableArray array];

            XZMocoaGroupSection * const newModelSection = newModelSections[newSectionIndex];
            NSArray * const newCellModels = newModelSection.cellsIfLoaded;
            
            for (NSInteger newCellIndex = 0; newCellIndex < newCellModels.count; newCellIndex++) {
                id const newCellModel = newCellModels[newCellIndex];
                NSIndexPath * const newIndexPath = [NSIndexPath indexPathForItem:newCellIndex inSection:newSectionIndex];
                NSIndexPath * const oldIndexPath = [oldCellModelMap objectForKey:newCellModel];
                if (oldIndexPath == nil) {
                    // 新增
                    XZMocoaGroupCellViewModel *viewModel = [self createViewModelWithModel:newCellModel forKind:(XZMocoaKindDefault)];
                    viewModel.indexPath = newIndexPath;
                    [self addSubViewModel:viewModel];
                    [newCellViewModels addObject:viewModel];
                    [inserts addObject:newIndexPath];
                } else if (oldIndexPath.section != newSectionIndex || oldIndexPath.item != newCellIndex) {
                    // 移动
                    XZMocoaViewModel *viewModel = [self viewModelForCellAtIndexPath:oldIndexPath];
                    [newCellViewModels addObject:viewModel];
                    [changes addObject:@{ @"from": oldIndexPath, @"to": newIndexPath }];
                } else {
                    // 不变
                    XZMocoaViewModel *viewModel = [self viewModelForCellAtIndexPath:oldIndexPath];
                    [newCellViewModels addObject:viewModel];
                }
            }
            
            [_viewModelSections[newSectionIndex].cells removeAllObjects];
            [_viewModelSections[newSectionIndex].cells addObjectsFromArray:newCellViewModels];
        }
        
        for (NSInteger oldSectionIndex = 0; oldSectionIndex < _modelSections.count; oldSectionIndex++) {
            XZMocoaGroupSection * const oldModelSection = _modelSections[oldSectionIndex];
            NSMapTable * const newCellModelMap = newModelMaps[XZMocoaKindDefault];
            [oldModelSection.cellsIfLoaded enumerateObjectsUsingBlock:^(id const oldCellModel, NSUInteger const oldCellIndex, BOOL * _Nonnull stop) {
                if ([newCellModelMap objectForKey:oldCellModel]) {
                    return;
                }
                [deletes addObject:[NSIndexPath indexPathForItem:oldCellIndex inSection:oldSectionIndex]];
            }];
        }
        
        [self didDeleteCellsAtIndexPaths:deletes];
        [self didInsertSectionsAtIndexes:inserts];
        for (NSDictionary *change in changes) {
            NSIndexPath *oldIndexPath = change[@"from"];
            NSIndexPath *newIndexPath = change[@"to"];
            [self didMoveCellAtIndexPath:oldIndexPath toIndexPath:newIndexPath];
        }
    } completion:nil];
    
    // 移除多余的 section
    if (_viewModelSections.count > newSectionCount) {
        [self didPerformBatchUpdates:^{
            NSRange const range = NSMakeRange(newSectionCount, _viewModelSections.count - newSectionCount);
            [_viewModelSections removeObjectsInRange:range];
            [self didDeleteSectionsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
        } completion:nil];
    }
    
    // 刷新 supplements
    [self didPerformBatchUpdates:^{
        NSMutableIndexSet *sections = [NSMutableIndexSet indexSet];
        for (NSInteger newSectionIndex = 0; newSectionIndex < newModelSections.count; newSectionIndex++) {
            NSDictionary *newSupplements = newModelSections[newSectionIndex].supplementsIfLoaded;
            
            
            
            NSDictionary *oldSupplements = _modelSections[newSectionIndex].supplementsIfLoaded;
            
        }
        
        
        NSMutableDictionary<NSNumber *, NSNumber *> *changes = [NSMutableDictionary dictionary];
        // 移除 oldSection
        NSMutableIndexSet *deletes = [NSMutableIndexSet indexSet];
        for (NSInteger oldSectionIndex = oldModelSections.count - 1; oldSectionIndex >= 0; oldSectionIndex--) {
            XZMocoaGroupSection *oldSection = oldModelSections[oldSectionIndex];
            
            // 保留：旧的 supplements 在同一个新的 section 中都能找到，数量一致且一一对应
            NSDictionary<XZMocoaKind, NSMutableArray *> *oldSupplements = oldSection.supplementsIfLoaded;
            
            // 取出一个旧数据，找到其在新数据中的 section
            NSInteger __block newSectionIndex = -1;
            [oldSupplements enumerateKeysAndObjectsUsingBlock:^(XZMocoaKind const kind, NSMutableArray * const oldModels, BOOL * _Nonnull stop) {
                if (oldModels.count == 0) {
                    return;
                }
                id const oldModel = oldModels[0];
                NSIndexPath *newIndexPath = [newModelMaps[kind] objectForKey:oldModel];
                newSectionIndex = newIndexPath ? newIndexPath.section : NSNotFound;
                *stop = YES;
            }];
            
            // 没有旧 supplements
            if (newSectionIndex == -1) {
                continue;
            }
            
            // 在新数据中，没有找到对应的 supplements
            if (newSectionIndex == NSNotFound) {
                [deletes addIndex:oldSectionIndex];
                continue;
            }
            
            XZMocoaGroupSection *newSection = newModelSections[newSectionIndex];
            NSDictionary<XZMocoaKind, NSMutableArray *> *newSupplementaries = newSection.supplementsIfLoaded;
            
            BOOL __block isEqual = YES;
            [newSupplementaries enumerateKeysAndObjectsUsingBlock:^(XZMocoaKind const newKind, NSMutableArray * newMoedels, BOOL * _Nonnull stop) {
                NSMutableArray *oldModels = oldSupplements[newKind];
                if (oldModels.count != newMoedels.count) {
                    isEqual = NO;
                    *stop = YES;
                    return;
                }
                if (oldModels == nil || newMoedels == nil) {
                    return;
                }
                if ([oldModels isEqualToArray:newMoedels]) {
                    return;
                }
                isEqual = NO;
                *stop = YES;
            }];
            
            if (isEqual) {
                changes[@(oldSectionIndex)] = @(newSectionIndex);
                continue;
            }
            
            [deletes addIndex:oldSectionIndex];
        }
        
        [self->_viewModelSections removeObjectsAtIndexes:deletes];
        [self->_modelSections removeObjectsAtIndexes:deletes];
        [self didDeleteSectionsAtIndexes:deletes];
    } completion:nil];
    
    // 添加 newSection 并排序所有 section
    [self didPerformBatchUpdates:^{
        for (NSInteger newSectionIndex = 0; newSectionIndex < newModelSections.count; newSectionIndex++) {
            
        }
    } completion:nil];
    
    // 2、更新 cells
    [self didPerformBatchUpdates:^{
        NSMapTable *oldCellTables = _modelMaps[XZMocoaKindDefault];
        NSMapTable *newCellTables = newModelMaps[XZMocoaKindDefault];
        // 删除
        NSMutableArray<NSIndexPath *> *deletes = [NSMutableArray array];
        NSMutableArray<NSDictionary<NSString *, NSIndexPath *> *> *changes = [NSMutableArray array];
        NSMutableArray<NSIndexPath *> *inserts = [NSMutableArray array];
        for (id const oldModel in oldCellTables.keyEnumerator) {
            NSIndexPath *oldIndexPath = [oldCellTables objectForKey:oldModel];
            NSIndexPath *newIndexPath = [newCellTables objectForKey:oldModel];
            
            if (newIndexPath == nil) {
                [deletes addObject:oldIndexPath];
                // TODO: delete cell vm
                continue;
            }
            
            if (oldIndexPath.section != newIndexPath.section || oldIndexPath.item != newIndexPath.item) {
                [changes addObject:@{ @"from": oldIndexPath, @"to": newIndexPath }];
                // TODO: move cell vm
                continue;
            }
        }
        for (id const newModel in newCellTables.keyEnumerator) {
            NSIndexPath *newIndexPath = [newCellTables objectForKey:newModel];
            NSIndexPath *oldIndexPath = [oldCellTables objectForKey:newModel];
            
            if (oldIndexPath == nil) {
                [inserts addObject:newIndexPath];
                // TODO: insert cell vm
                continue;
            }
        }
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
    } completion:^(BOOL finished) {-+
        
    }];
    
    XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 结束");
//    NSParameterAssert(batchUpdates != nil);
//    
//    if (![self prepareForBatchUpdates]) {
//        if (self.isPerformingBatchUpdates) {
//            XZLog(@"[XZMocoaGroupViewModel] 批量更新重入");
//            batchUpdates();
//            if (completion) [_handlerBatchUpdates addObject:completion];
//        }
//        return;
//    }
//    
//    XZLog(@"[XZMocoaGroupViewModel] 批量更新开始");
//    
//    // 记录批量更新过程中的回调，包括嵌套的回调。
//    if (completion) {
//        [_handlerBatchUpdates addObject:completion];
//    }
//    
//    // 批量更新的过程中，由于 section 内的局部更新可能并不会反馈到 section 的变化上来。
//    // 比如对 section 数据进行了排序，这并不是 section 整体的更新，
//    // 因此对于未更新的 section 会在 table 批量更新后，执行 -performBatchUpdates:completion: 方法以进行更新。
//    NSIndexSet * __block forwardIndexes = nil;
//    // 批量更新回调，应该在 batchUpdates 和 forwardIndexes 更新之后，所以需要一个标记。
//    // 二者更新都会增加这个标记，触发回调就减少，当标记为 0 时执行回调。
//    NSInteger    __block completionFlag = 0;
//    
//    void (^const _batchUpdates)(void) = ^{
//        completionFlag += 1;
//        // 执行批量更新。这其中如果有独立更新的操作，会关闭差异分析。
//        // 在此过程中，如果有 cell 模块，因为交互或事件，需要刷新视图，则操作会被延迟。
//        batchUpdates();
//        // 执行差异分析，并返回
//        forwardIndexes = [self differenceBatchUpdatesIfNeeded];
//    };
//    
//    NSArray * const _handlerBatchUpdates = self->_handlerBatchUpdates;
//    void (^const _completion)(BOOL) = ^(BOOL finished){
//        completionFlag -= 1;
//        if (completionFlag > 0) return;
//        for (BatchUpdatesCompletion completion in _handlerBatchUpdates) {
//            completion(finished);
//        }
//    };
//    
//    // 批量事件，block 会传递到 view 到 -[tableView performBatchUpdates:completion:] 方法中执行。
//    [self didPerformBatchUpdates:_batchUpdates completion:_completion];
//    
//    // 当前的批量操作已完成，清理批量更新环境，并执行延迟的事件
//    [self cleanupForBatchUpdates];
//    
//    XZLog(@"[XZMocoaGroupViewModel] 批量更新结束");
//    
//    // 在批量更新的过程中，前后保留的 section 的内部，可能发生了更新，向他们发送批量更新事件。
//    // 当前批量更新的数据变化监测，只针对的是 section 层级，而 section 的 cells 也可能发生了更新。
//    // 因此在 section 检测完更新之后，我们向保留的 section 发送批量更新消息，让 section 去检查其
//    // 内部的 cell 数据是否发生了更新。
//    // section 的 delete/reload/insert 操作，影响的是整个 section 模块，很明显，批量更新时，如
//    // 果只是 section 内的某个 cell 发生了更新，不应该视为它的整个 section 发生了刷新。
//    if (forwardIndexes.count > 0) {
//        void (^const _batchUpdates)(void) = ^{
//            completionFlag += 1;
//            [forwardIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
////                [[self sectionViewModelAtIndex:idx] performBatchUpdates:^{
////                    // section 内的更新数据已经在 batchUpdates() 执行了。
////                } completion:nil];
//            }];
//        };
//        [self didPerformBatchUpdates:_batchUpdates completion:_completion];
//    }
}

/// 对数据进行差异分析，并执行更新。
/// @discussion
/// 单次批量更新，同一个`Cell`只能有一种变化行为，比如，在移动`Section`的同时操作该`Section`中的`Cell`会直接发生崩溃。
/// 所以，先处理 Section 的变化，然后再由 Section 处理 Cell 的变化：
/// @discussion
/// 1、对于`updates`或`inserts`操作，由于会创建的新视图模型，所以其内部的`Cell`视图模型也是最新的，不需要额外处理。
/// @discussion
/// 2、对于`remains`或`changes`操作，由于不能同时执行其它操作，所以需要在批量更新执行完之后，再发送批量更新事件。
/// @discussion
/// 理论上，由于 remains 没有任何操作，在批量更新时应该可以直接发送批量更新事件，但实际在测试中，还是会发生重复操作的崩溃。
/// 测试数据如下：
/// @code
/// // 更新前
/// NSArray *old = @[@"0", @"1", @"2", @"3", @"4", @"F", @"6", @"E", @"8", @"9", @"10", @"11", @"C"];
/// NSArray *new = @[@"A", @"B", @"C", @"D", @"E", @"F"];
/// @endcode
/// @todo 实现二维数组的差异比较，解决跨 section 的更新问题。
- (NSIndexSet *)differenceBatchUpdatesIfNeeded {
//    if (!_needsDifferenceBatchUpdates) {
//        XZLog(@"[XZMocoaGroupViewModel] 差异分析：禁用");
//        return nil;
//    }
//    _needsDifferenceBatchUpdates = NO;
//
//    // 记录更新前的数据。
//    NSOrderedSet * const oldViewModels = _beforesBatchUpdates.copy;
//    NSInteger      const oldCount      = oldViewModels.count;
//    NSArray      * const oldDataModels = [NSMutableArray arrayWithCapacity:oldCount];
//    for (NSInteger i = 0; i < oldCount; i++) {
//        XZMocoaGroupSectionViewModel * const viewModel = oldViewModels[i];
//        id const dataModel = viewModel.model;
//        [(NSMutableArray *)oldDataModels addObject:(dataModel ?: (id)kCFNull)];
//    }
//    
//    if (oldDataModels.xz_containsEqualObjects) {
//        XZLog(@"[XZMocoaGroupViewModel] 差异分析：停止，因为旧数据存在重复数据");
//        [self reloadData];
//        return nil;
//    }
//    
//    return nil;
//    
//    id const model = self.model;
//
//    // 获取更新后的数据。
//    NSInteger const newCount      = [self model:model numberOfSectionModels:NULL];
//    NSArray * const newDataModels = [NSMutableArray arrayWithCapacity:newCount];
//    for (NSInteger i = 0; i < newCount; i++) {
//        id const newDataModel = [self model:model modelForSectionAtIndex:i];
//        [(NSMutableArray *)newDataModels addObject:(newDataModel ?: (id)kCFNull)];
//    }
//
//    if (newDataModels.xz_containsEqualObjects) {
//        XZLog(@"[XZMocoaGroupViewModel] 差异分析：停止，因为新数据存在重复数据");
//        [self reloadData];
//        return nil;
//    }
//
//    // 差异分析及更新算法：
//    // 对于更新后的所有元素，只可能属于 remain/updates/changes/inserts 中的一个。
//    // 在执行删除、插入操作后，列表数量就与预期的一致了，即仅需要排序即可，但是由于删除或插入操作，
//    // 也可能会改变 remain、changes 中的元素，且排序的过程中，也可能会改变其他元素的位置，
//    // 因此在处理排序时，应从低位 0 开始遍历，逐个查找该位置上预期元素，然后将其移动到该位置上。
//
//    NSIndexSet                           * const inserts = [NSMutableIndexSet indexSet];
//    NSIndexSet                           * const deletes = [NSMutableIndexSet indexSet];
//    NSIndexSet                           * const remains = [NSMutableIndexSet indexSet];
//    NSDictionary<NSNumber *, NSNumber *> * const changes = [NSMutableDictionary dictionaryWithCapacity:oldCount];
//    [newDataModels xz_differenceFromArray:oldDataModels inserts:(id)inserts deletes:(id)deletes changes:(id)changes remains:(id)remains];
//
//    // 删除元素，反向遍历：从后面开始删除，不会影响前面的
//    [deletes enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger section, BOOL *stop) {
//        XZMocoaGroupSectionViewModel * const oldViewModel = [self sectionViewModelAtIndex:section];
//        [oldViewModel removeFromSuperViewModel];
//    }];
//    [self didDeleteSectionsAtIndexes:deletes];
//
//    XZLog(@"[XZMocoaGroupViewModel] 差异分析：删除 [ %@ ]", [deletes xz_reduce:nil next:^id _Nullable(NSMutableString *result, NSInteger idx, BOOL * _Nonnull stop) {
//        if (result) {
//            [result appendFormat:@", %ld", idx];
//        } else {
//            result = [NSMutableString stringWithFormat:@"%ld", idx];
//        }
//        return result;
//    }]);
//
//    // 添加元素，正向遍历：按位置记录下新添加的元素，以便在后续排序时，查找该位置上的元素。
//    NSMutableDictionary * const insertedViewModels = [NSMutableDictionary dictionaryWithCapacity:inserts.count];
//    [inserts enumerateIndexesUsingBlock:^(NSUInteger index, BOOL * _Nonnull stop) {
//        id const newDataModel = newDataModels[index];
//        XZMocoaGroupSectionViewModel * const newViewModel = [self createSectionViewModelWithModel:newDataModel index:index];
//        [self _insertSectionViewModel:newViewModel atIndex:index];
//        insertedViewModels[@(index)] = newViewModel;
//    }];
//    [self didInsertSectionsAtIndexes:inserts];
//
//    XZLog(@"[XZMocoaGroupViewModel] 差异分析：添加 [ %@ ]", [inserts xz_reduce:nil next:^id _Nullable(NSMutableString *result, NSInteger idx, BOOL * _Nonnull stop) {
//        if (result) {
//            [result appendFormat:@", %ld", idx];
//        } else {
//            result = [NSMutableString stringWithFormat:@"%ld", idx];
//        }
//        return result;
//    }]);
//
//    NSMutableIndexSet * const forwardIndexes = [NSMutableIndexSet indexSet];
//
//    // 排序元素：从低位开始遍历，每一个位置，都应该能根据 inserts/remains/changes 中找到对应的元素。
//    for (NSInteger to = 0; to < newCount; to++) {
//        if ([inserts containsIndex:to]) {
//            NSInteger const index = [self indexOfSectionViewModel:insertedViewModels[@(to)]];
//            [self _moveSectionViewModelFromIndex:index toIndex:to];
//        } else if ([remains containsIndex:to]) {
//            // to 位置为保持不变的元素，在 old 中找到 viewModel 然后将其移动到 to 位置上。
//            XZMocoaGroupSectionViewModel *viewModel = oldViewModels[to];
//            // 数据模型 isEqual 结果可能相同，但是内容可能发生改变
//            viewModel.model = newDataModels[to];
//            NSInteger const index = [self indexOfSectionViewModel:viewModel];
//            [self moveSubViewModelAtIndex:index toIndex:to];
//            // 执行更新。在数据更新的过程中，由数据引发的更新已经在更新数据时被拦截下来，在这里差异分析时，不会再触发了。
//            // 记录待更新的 section
//            [forwardIndexes addIndex:to];
//        } else {
//            // to 位置为被移动的元素，先找到它原来的位置，然后找到 viewModel 然后再移动位置。
//            NSInteger const from = changes[@(to)].integerValue;
//            // 根据原来的位置，找到 viewModel 即其当前的位置，并更新数据
//            XZMocoaGroupSectionViewModel * const viewModel = oldViewModels[from];
//            viewModel.model = newDataModels[to];
//            NSInteger const index = [self indexOfSectionViewModel:viewModel];
//            // 移动 section
//            [self _moveSectionViewModelFromIndex:index toIndex:to];
//            // 更新 UI
//            [self didMoveSectionAtIndex:from toIndex:to];
//            // 记录待更新的 section
//            [forwardIndexes addIndex:to];
//            XZLog(@"[XZMocoaGroupViewModel] 差异分析：移动 %ld => %ld", from, to);
//        }
//    }
//
//    XZLog(@"[XZMocoaGroupViewModel] 差异分析：结束");
    
//    return forwardIndexes;
}

#pragma mark - 私有方法

/// 将 viewModel 添加到末尾，并添加为子元素。
//- (void)_addSectionViewModel:(XZMocoaGroupSectionViewModel *)sectionViewModel {
//    NSParameterAssert([sectionViewModel isKindOfClass:[XZMocoaGroupSectionViewModel class]]);
//    [_sectionViewModels addObject:sectionViewModel];
//    [self addSubViewModel:sectionViewModel];
//}

/// 将 viewModel 插入到 index 位置，并添加为子元素。
//- (void)_insertSectionViewModel:(XZMocoaGroupSectionViewModel *)sectionViewModel atIndex:(NSInteger)index {
//    NSParameterAssert([sectionViewModel isKindOfClass:[XZMocoaGroupSectionViewModel class]]);
//    [_sectionViewModels insertObject:sectionViewModel atIndex:index];
//    [self addSubViewModel:sectionViewModel];
//}

/// 将 oldIndex 位置上的 viewModel 移动到 newIndex 位置上，在子元素集合中的位置不变。
//- (void)_moveSectionViewModelFromIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex {
//    if (newIndex == oldIndex) return;
//    id const viewModel = _sectionViewModels[oldIndex];
//    [_sectionViewModels removeObjectAtIndex:oldIndex];
//    [_sectionViewModels insertObject:viewModel atIndex:newIndex];
//}

/// 添加所有 section 元素，需先清理数据。
- (void)_loadSubViewModelsWithoutEvents {
    id        const model        = self.model;
    NSInteger const sectionCount = [self model:model numberOfSections:NULL];
    
    NSMutableArray      *_modelSections     = [NSMutableArray arrayWithCapacity:sectionCount];
    NSMutableDictionary *_modelMaps         = [NSMutableDictionary dictionary];
    NSMutableArray      *_viewModelSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    for (NSInteger sectionIndex = 0; sectionIndex < sectionCount; sectionIndex++) {
        XZMocoaGroupSection * const viewModelSection = [[XZMocoaGroupSection alloc] init];
        XZMocoaGroupSection *modelSection     = _modelSections ? [[XZMocoaGroupSection alloc] init] : nil;
        
        for (XZMocoaKind const kind in self.supportedSupplementKinds) {
            NSInteger const supplementCount = [self model:model numberOfSupplementsOfKind:kind inSection:sectionIndex];
            
            NSMapTable *_supplementModelMap = nil;
            if (_modelMaps) {
                _supplementModelMap = _modelMaps[kind];
                if (_supplementModelMap == nil) {
                    _supplementModelMap = [NSMapTable strongToStrongObjectsMapTable];
                    _modelMaps[kind] = _supplementModelMap;
                }
            }
            
            for (NSInteger itemIndex = 0; itemIndex < supplementCount; itemIndex++) {
                NSIndexPath *    const indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
                id<XZMocoaModel> const supplementaryModel = [self model:model modelForSupplementaryElementOfKind:kind atIndexPath:indexPath];
                
                XZMocoaGroupSupplementViewModel * const viewModel = [self createViewModelWithModel:supplementaryModel forKind:kind];
                viewModel.indexPath = indexPath;
                [self addSubViewModel:viewModel];
                
                [viewModelSection.supplementsForKind(kind) addObject:viewModel];
                
                if (_supplementModelMap == nil) {
                    continue;
                }
                if (supplementaryModel == nil || [_supplementModelMap objectForKey:supplementaryModel]) {
                    _supplementModelMap = nil;
                    _modelSections      = nil;
                    _modelMaps          = nil;
                    continue;
                }
                [_supplementModelMap setObject:indexPath forKey:supplementaryModel];
                [modelSection.supplementsForKind(kind) addObject:supplementaryModel];
            }
        }
        
        {
            NSMapTable *_cellModelMap = nil;
            if (_modelMaps) {
                _cellModelMap = _modelMaps[XZMocoaKindDefault];
                if (_cellModelMap == nil) {
                    _cellModelMap = [NSMapTable strongToStrongObjectsMapTable];
                    _modelMaps[XZMocoaKindDefault] = _cellModelMap;
                }
            }
            
            NSInteger const cellCount = [self model:model numberOfCellsInSection:sectionIndex];
            for (NSInteger itemIndex = 0; itemIndex < cellCount; itemIndex++) {
                NSIndexPath *    const indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
                id<XZMocoaModel> const cellModel = [self model:model modelForCellAtIndexPath:indexPath];
                
                XZMocoaGroupCellViewModel * const viewModel = [self createViewModelWithModel:cellModel forKind:(XZMocoaKindDefault)];
                viewModel.indexPath = indexPath;
                [self addSubViewModel:viewModel];
                
                [viewModelSection.cells addObject:viewModel];
                
                if (_cellModelMap == nil) {
                    continue;
                }
                if (cellModel == nil || [_cellModelMap objectForKey:cellModel]) {
                    _cellModelMap  = nil;
                    _modelSections = nil;
                    _modelMaps     = nil;
                    continue;
                }
                [_cellModelMap setObject:indexPath forKey:cellModel];
                [modelSection.cells addObject:cellModel];
            }
        }
        
        if (modelSection) [_modelSections addObject:modelSection];
        [_viewModelSections addObject:viewModelSection];
    }
    
    self->_modelSections     = _modelSections;
    self->_modelMaps         = _modelMaps;
    self->_viewModelSections = _viewModelSections;
}

- (__kindof XZMocoaViewModel *)createViewModelWithModel:(id<XZMocoaModel> const)model forKind:(XZMocoaKind)kind {
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


@implementation XZMocoaGroupViewModel (XZMocoaGroupSectionViewModelUpdates)

//- (void)sectionViewModel:(XZMocoaGroupSectionViewModel *)viewModel didReloadData:(void * _Nullable)null {
//    if (!self.isReady) return;
//
//    if (self.isPerformingBatchUpdates) {
//        if (viewModel.isPerformingBatchUpdates) {
//            NSInteger const index = [_beforesBatchUpdates indexOfObject:viewModel];
//            if (index == NSNotFound) return;
//
//            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
//            [self didReloadSectionsAtIndexes:indexSet];
//        } else {
//            NSAssert([_sectionViewModels indexOfObject:viewModel] == NSNotFound, @"当前处于批量更新模式，视图模型 %@ 无法同时执行多个更新操作", viewModel);
//        }
//    } else {
//        NSInteger const index = [_sectionViewModels indexOfObject:viewModel];
//        if (index == NSNotFound) return;
//
//        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
//        [self didReloadSectionsAtIndexes:indexSet];
//    }
//}
//
//- (void)sectionViewModel:(XZMocoaGroupSectionViewModel *)viewModel didReloadCellsAtIndexes:(NSIndexSet *)rows {
//    if (!self.isReady) return;
//
//    if (self.isPerformingBatchUpdates) {
//        if (viewModel.isPerformingBatchUpdates) {
//            NSInteger const index = [_beforesBatchUpdates indexOfObject:viewModel];
//            if (index == NSNotFound) return;
//
//            NSArray * const indexPaths = [rows xz_map:^id(NSInteger idx, BOOL *stop) {
//                return [NSIndexPath indexPathForRow:idx inSection:index];
//            }];
//            [self didReloadCellsAtIndexPaths:indexPaths];
//        } else {
//            NSAssert([_sectionViewModels indexOfObject:viewModel] == NSNotFound, @"当前处于批量更新模式，视图模型 %@ 无法同时执行多个更新操作", viewModel);
//        }
//    } else {
//        NSInteger const index = [_sectionViewModels indexOfObject:viewModel];
//        if (index == NSNotFound) return;
//
//        NSArray * const indexPaths = [rows xz_map:^id(NSInteger idx, BOOL *stop) {
//            return [NSIndexPath indexPathForRow:idx inSection:index];
//        }];
//        [self didReloadCellsAtIndexPaths:indexPaths];
//    }
//}
//
//- (void)sectionViewModel:(XZMocoaGroupSectionViewModel *)viewModel didInsertCellsAtIndexes:(NSIndexSet *)rows {
//    if (!self.isReady) return;
//
//    if (self.isPerformingBatchUpdates) {
//        if (viewModel.isPerformingBatchUpdates) {
//            NSInteger const index = [_beforesBatchUpdates indexOfObject:viewModel];
//            if (index == NSNotFound) return;
//
//            NSArray * const indexPaths = [rows xz_map:^id(NSInteger idx, BOOL *stop) {
//                return [NSIndexPath indexPathForRow:idx inSection:index];
//            }];
//            [self didInsertCellsAtIndexPaths:indexPaths];
//        } else {
//            NSAssert([_sectionViewModels indexOfObject:viewModel] == NSNotFound, @"当前处于批量更新模式，视图模型 %@ 无法同时执行多个更新操作", viewModel);
//        }
//    } else {
//        NSInteger const index = [_sectionViewModels indexOfObject:viewModel];
//        if (index == NSNotFound) return;
//
//        NSArray * const indexPaths = [rows xz_map:^id(NSInteger idx, BOOL *stop) {
//            return [NSIndexPath indexPathForRow:idx inSection:index];
//        }];
//        [self didInsertCellsAtIndexPaths:indexPaths];
//    }
//}
//
//- (void)sectionViewModel:(XZMocoaGroupSectionViewModel *)viewModel didDeleteCellsAtIndexes:(NSIndexSet *)rows {
//    if (!self.isReady) return;
//
//    if (self.isPerformingBatchUpdates) {
//        if (viewModel.isPerformingBatchUpdates) {
//            NSInteger const index = [_beforesBatchUpdates indexOfObject:viewModel];
//            if (index == NSNotFound) return;
//
//            NSArray * const indexPaths = [rows xz_map:^id(NSInteger idx, BOOL *stop) {
//                return [NSIndexPath indexPathForRow:idx inSection:index];
//            }];
//            [self didDeleteCellsAtIndexPaths:indexPaths];
//        } else {
//            NSAssert([_sectionViewModels indexOfObject:viewModel] == NSNotFound, @"当前处于批量更新模式，视图模型 %@ 无法同时执行多个更新操作", viewModel);
//        }
//    } else {
//        NSInteger const index = [_sectionViewModels indexOfObject:viewModel];
//        if (index == NSNotFound) return;
//
//        NSArray * const indexPaths = [rows xz_map:^id(NSInteger idx, BOOL *stop) {
//            return [NSIndexPath indexPathForRow:idx inSection:index];
//        }];
//        [self didDeleteCellsAtIndexPaths:indexPaths];
//    }
//}
//
//- (void)sectionViewModel:(XZMocoaGroupSectionViewModel *)viewModel didMoveCellAtIndex:(NSInteger)row toIndex:(NSInteger)newRow {
//    if (!self.isReady) return;
//
//    if (self.isPerformingBatchUpdates) {
//        if (viewModel.isPerformingBatchUpdates) {
//            NSInteger const index = [_beforesBatchUpdates indexOfObject:viewModel];
//            if (index == NSNotFound) return;
//
//            NSIndexPath *from = [NSIndexPath indexPathForRow:row inSection:index];
//            NSIndexPath *to   = [NSIndexPath indexPathForRow:newRow inSection:index];
//            [self didMoveCellAtIndexPath:from toIndexPath:to];
//        } else {
//            NSAssert([_sectionViewModels indexOfObject:viewModel] == NSNotFound, @"当前处于批量更新模式，视图模型 %@ 无法同时执行多个更新操作", viewModel);
//        }
//    } else {
//        NSInteger const index = [_sectionViewModels indexOfObject:viewModel];
//        if (index == NSNotFound) return;
//
//        NSIndexPath *from = [NSIndexPath indexPathForRow:row inSection:index];
//        NSIndexPath *to   = [NSIndexPath indexPathForRow:newRow inSection:index];
//        [self didMoveCellAtIndexPath:from toIndexPath:to];
//    }
//}
//
//- (void)sectionViewModel:(XZMocoaGroupSectionViewModel *)viewModel didPerformBatchUpdates:(void (^NS_NOESCAPE)(void))batchUpdates completion:(void (^ _Nullable)(BOOL))completion {
//    if (!self.isReady) return;
//
//    if (self.isPerformingBatchUpdates) {
//        if (viewModel.isPerformingBatchUpdates) {
//            NSInteger const index = [_beforesBatchUpdates indexOfObject:viewModel];
//            if (index == NSNotFound) return;
//            // 应用 batchUpdates 此方法之后，section 会计算批量更新，并调用上面的方法。
//            batchUpdates();
//            // 将回调添加到上层回调中。
//            if (completion) [_handlerBatchUpdates addObject:completion];
//        } else {
//            NSAssert([_sectionViewModels indexOfObject:viewModel] == NSNotFound, @"当前处于批量更新模式，视图模型 %@ 无法同时执行多个更新操作", viewModel);
//        }
//    } else {
//        NSInteger const index = [_sectionViewModels indexOfObject:viewModel];
//        if (index == NSNotFound) return;
//
//        [self didPerformBatchUpdates:batchUpdates completion:completion];
//    }
//}

@end

@implementation XZMocoaGroupViewModel (XZMocoaGroupModel)

- (NSInteger)model:(id<XZMocoaGroupModel>)model numberOfSections:(void *)null {
    return [model numberOfSections];
}

- (NSInteger)model:(id<XZMocoaGroupModel>)model numberOfCellsInSection:(NSInteger)section {
    return [model numberOfCellsInSection:section];
}

- (id)model:(id<XZMocoaGroupModel>)model modelForCellAtIndexPath:(NSIndexPath *)indexPath {
    return [model modelForCellAtIndexPath:indexPath];
}

- (NSInteger)model:(id<XZMocoaGroupModel>)model numberOfSupplementsOfKind:(XZMocoaKind)kind inSection:(NSInteger)section {
    return [model numberOfSupplementsOfKind:kind inSection:section];
}

- (id)model:(id<XZMocoaGroupModel>)model modelForSupplementaryElementOfKind:(XZMocoaKind)kind atIndexPath:(NSIndexPath *)indexPath {
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
    NSMutableDictionary *_supplementaries;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        XZMocoaGroupSection * __unsafe_unretained info = self;
        
        _supplementsForKind = ^NSMutableArray *(XZMocoaKind kind) {
            NSMutableDictionary *dictM = info.supplements;
            NSMutableArray *arrayM = dictM[kind];
            if (arrayM == nil) {
                arrayM = [NSMutableArray array];
                dictM[kind] = arrayM;
            }
            return arrayM;
        };
        
        _supplementsIfLoadedForKind = ^id (XZMocoaKind kind) {
            NSMutableDictionary *dictM = info.supplementsIfLoaded;
            return dictM[kind];
        };
    }
    return self;
}

- (NSMutableArray *)cells {
    if (_cells) {
        return _cells;
    }
    _cells = [[NSMutableArray alloc] init];
    return _cells;
}

- (NSMutableArray *)cellsIfLoaded {
    return _cells;
}

- (NSMutableDictionary<XZMocoaKind,NSMutableArray *> *)supplements {
    if (_supplementaries) {
        return _supplementaries;
    }
    _supplementaries = [[NSMutableDictionary alloc] init];
    return _supplementaries;
}

- (NSMutableDictionary<XZMocoaKind,NSMutableArray *> *)supplementsIfLoaded {
    return _supplementaries;
}

@end
