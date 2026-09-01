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
#import "XZMocoaDiff.h"
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

/// 同一个 XZMocoaKind 内的标识与位置的映射。
/// @discussion 标识在同一个 kind 内必须唯一，重复意味着数据不符合约定，无法进行差异分析。
@interface XZMocoaIdentifierMap : NSObject
/// 字符串标识符 -> NSIndexPath。
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, NSIndexPath *> *identifierIndexPaths;
/// 无标识符的模型（对象身份） -> NSIndexPath，同一个模型对象只能出现一次。
@property (nonatomic, strong, readonly) NSMapTable *objectIndexPaths;
@end

@implementation XZMocoaIdentifierMap
- (instancetype)init {
    self = [super init];
    if (self) {
        _identifierIndexPaths = [NSMutableDictionary dictionary];
        _objectIndexPaths     = [[NSMapTable alloc] initWithKeyOptions:(NSPointerFunctionsObjectPersonality | NSPointerFunctionsOpaqueMemory) valueOptions:NSPointerFunctionsStrongMemory capacity:0];
    }
    return self;
}
@end

/// 一对匹配的 section。
typedef struct {
    NSInteger oldIndex;
    NSInteger newIndex;
} XZMocoaSectionPair;

/// 一对匹配的 section，及其 cell 级别的差异分析结果。
/// @discussion 坐标约定：删除 = 旧状态坐标；插入与移动的目标 = 新状态（最终）坐标。
@interface XZMocoaCellDiff : NSObject
@property (nonatomic, assign) XZMocoaSectionPair pair;
@property (nonatomic, copy) NSArray<NSIndexPath *> *deletes;
@property (nonatomic, copy) NSArray<NSIndexPath *> *inserts;
/// 匹配成功的元素（含移动），@[@[旧位置, 新位置], ...]，按新位置升序。
@property (nonatomic, copy) NSArray<NSArray<NSIndexPath *> *> *matches;
/// 标识相同但模型实例发生变化的元素，@[@[旧位置, 新位置], ...]。
/// 视图模型不支持重绑定模型，因此以删除+插入代替刷新（其新位置已包含在 inserts 中）。
@property (nonatomic, copy) NSArray<NSArray<NSIndexPath *> *> *replaces;
/// 需要移动的元素，@[@[旧位置, 新位置], ...]，是 matches 中不在 LIS 内的子集。
@property (nonatomic, copy) NSArray<NSArray<NSIndexPath *> *> *moves;
@end

@implementation XZMocoaCellDiff
@end

/// 一次批量更新的完整差异分析结果。
@interface XZMocoaGroupDiffResult : NSObject
/// 只存在于旧数据中的 section。
@property (nonatomic, copy) NSIndexSet *deletedSections;
/// 只存在于新数据中的 section。
@property (nonatomic, copy) NSIndexSet *insertedSections;
/// 匹配成功但是 supplements 发生变化的 section（新索引），整体重载。
@property (nonatomic, copy) NSIndexSet *reloadedSections;
/// 需要移动行为的 section，@[@[旧索引, 新索引], ...]。
@property (nonatomic, copy) NSArray<NSArray<NSNumber *> *> *sectionMoves;
/// 匹配成功且 supplements 未变化的 section 对，及其 cell 差异。
@property (nonatomic, copy) NSArray<XZMocoaCellDiff *> *fineGrainedCellDiffs;
/// 新的数据模型。
@property (nonatomic, copy) NSArray<XZMocoaGroupSection *> *modelSections;
/// 匹配关系：新 section 索引 -> 旧 section 索引，包含重载与移动的 section。
@property (nonatomic, copy) NSDictionary<NSNumber *, NSNumber *> *sectionIndexChanges;
@end

@implementation XZMocoaGroupDiffResult
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
    for (XZMocoaGroupSection<XZMocoaViewModel *> *viewModelSection in _viewModelSections) {
        if (viewModelSection.cells.count > 0) {
            return NO;
        }
        for (XZMocoaKind kind in viewModelSection.supplements) {
            if ([viewModelSection.supplements objectForKey:kind].count > 0) {
                return NO;
            }
        }
    }
    return YES;
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

/// 获取模型的差异分析标识：优先使用 mocoaIdentifier，未提供时以模型对象自身作为标识。
static id XZMocoaDiffKeyForModel(id const model) {
    NSString * const identifier = [model mocoaIdentifier];
    if (identifier.length > 0) {
        return identifier;
    }
    return [NSString stringWithFormat:@"<%s: %p>", object_getClassName(model), model];
}

/// 向映射中添加一个模型的位置。如果标识已存在（数据不符合唯一性约定），返回 NO。
static BOOL XZMocoaIdentifierMapInsert(XZMocoaIdentifierMap * const map, id const model, NSIndexPath * const indexPath) {
    id const key = XZMocoaDiffKeyForModel(model);
    if ([key isKindOfClass:[NSString class]]) {
        if (map.identifierIndexPaths[key] != nil) {
            return NO;
        }
        map.identifierIndexPaths[key] = indexPath;
        return YES;
    }
    if ([map.objectIndexPaths objectForKey:key] != nil) {
        return NO;
    }
    [map.objectIndexPaths setObject:indexPath forKey:key];
    return YES;
}

/// 从映射中查找模型的位置。
static NSIndexPath * _Nullable XZMocoaIdentifierMapLookup(XZMocoaIdentifierMap * const map, id const model) {
    id const key = XZMocoaDiffKeyForModel(model);
    if ([key isKindOfClass:[NSString class]]) {
        return map.identifierIndexPaths[key];
    }
    return [map.objectIndexPaths objectForKey:key];
}

/// 构建模型与位置的映射关系。
/// @discussion 如果同一 kind 内出现重复标识，说明数据不符合约定，返回 nil。
- (NSDictionary<XZMocoaKind, XZMocoaIdentifierMap *> *)_identifierMapsForModelSections:(NSArray<XZMocoaGroupSection *> * const)modelSections mode:(XZMocoaGroupModelMapMode const)mode {
    NSMutableDictionary<XZMocoaKind, XZMocoaIdentifierMap *> * const maps = [NSMutableDictionary dictionary];
    
    NSInteger const sectionCount = modelSections.count;
    for (NSInteger sectionIndex = 0; sectionIndex < sectionCount; sectionIndex++) {
        XZMocoaGroupSection * const modelSection = modelSections[sectionIndex];
        
        if (mode & XZMocoaGroupModelMapModeSupplements) {
            for (XZMocoaKind const kind in modelSection.supplements) {
                XZMocoaIdentifierMap *map = maps[kind];
                if (map == nil) {
                    map = [[XZMocoaIdentifierMap alloc] init];
                    maps[kind] = map;
                }
                
                NSArray * const supplementModels = [modelSection supplementsForKind:kind];
                NSInteger const supplementCount = supplementModels.count;
                for (NSInteger supplementIndex = 0; supplementIndex < supplementCount; supplementIndex++) {
                    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:supplementIndex inSection:sectionIndex];
                    id const supplementModel = supplementModels[supplementIndex];
                    
                    if (supplementModel == nil || !XZMocoaIdentifierMapInsert(map, supplementModel, indexPath)) {
                        return nil;
                    }
                }
            }
        }
        
        if (mode & XZMocoaGroupModelMapModeCells) {
            XZMocoaIdentifierMap *map = maps[XZMocoaKindDefault];
            if (map == nil) {
                map = [[XZMocoaIdentifierMap alloc] init];
                maps[XZMocoaKindDefault] = map;
            }
            
            NSArray * const cellModels = modelSection.cells;
            NSInteger const cellCount = cellModels.count;
            for (NSInteger cellIndex = 0; cellIndex < cellCount; cellIndex++) {
                NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:cellIndex inSection:sectionIndex];
                id const cellModel = cellModels[cellIndex];
                
                if (cellModel == nil || !XZMocoaIdentifierMapInsert(map, cellModel, indexPath)) {
                    return nil;
                }
            }
        }
    }
    
    return maps;
}

/// 计算 section 的 supplements 指纹，用于判定 section 的身份。
/// @discussion 指纹只关心 supplements 的身份（标识符），不关心内容；
/// kind 按字典序排序，保证指纹的确定性。没有 supplements 的 section 返回 nil。
- (NSString *)_fingerprintForModelSection:(XZMocoaGroupSection * const)modelSection {
    NSDictionary<XZMocoaKind, NSArray *> * const supplements = modelSection.supplements;
    if (supplements.count == 0) {
        return nil;
    }
    
    NSArray<XZMocoaKind> * const kinds = [supplements.allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSMutableString * const fingerprint = [NSMutableString string];
    for (XZMocoaKind const kind in kinds) {
        [fingerprint appendFormat:@"%@:", kind];
        for (id const model in supplements[kind]) {
            id const key = XZMocoaDiffKeyForModel(model);
            if ([key isKindOfClass:[NSString class]]) {
                [fingerprint appendFormat:@"s(%@),", key];
            } else {
                [fingerprint appendFormat:@"o(%p),", key];
            }
        }
        [fingerprint appendString:@";"];
    }
    return fingerprint;
}

/// 判断两个 section 的 supplements 是否完全相同（同一位置是同一个模型实例）。
- (BOOL)_isSupplementsIdenticalOfSection:(XZMocoaGroupSection * const)section toSection:(XZMocoaGroupSection * const)otherSection {
    NSDictionary<XZMocoaKind, NSArray *> * const supplements = section.supplements;
    NSDictionary<XZMocoaKind, NSArray *> * const otherSupplements = otherSection.supplements;
    
    if (supplements.count == 0 && otherSupplements.count == 0) {
        return YES;
    }
    if (![[NSSet setWithArray:supplements.allKeys] isEqualToSet:[NSSet setWithArray:otherSupplements.allKeys]]) {
        return NO;
    }
    for (XZMocoaKind const kind in supplements) {
        NSArray * const models = supplements[kind];
        NSArray * const otherModels = otherSupplements[kind];
        if (models.count != otherModels.count) {
            return NO;
        }
        for (NSInteger index = 0; index < (NSInteger)models.count; index++) {
            if (models[index] != otherModels[index]) {
                return NO;
            }
        }
    }
    return YES;
}

- (void)performBatchUpdates:(void (^NS_NOESCAPE const)(void))batchUpdates completion:(void (^ _Nullable)(BOOL))completion {
    XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 开始");
    // 只有当 completionLock 为零时才能执行 completion
    NSInteger __block completionLock = 0;
    completion = ^(BOOL finished) {
        if ((--completionLock) > 0) {
            return;
        }
        if (completion) completion(finished);
    };
    
    if (batchUpdates == nil) {
        return completion(YES);
    }
    
    // 差异分析以标识符判定元素身份：相同 mocoaIdentifier 的模型，视为同一元素；
    // 没有 mocoaIdentifier 的模型，以模型对象自身作为标识，业务应保证模型唯一。
    // 同一个 kind 内出现重复标识时，说明数据不符合约定，放弃差异分析。
    NSDictionary<XZMocoaKind, XZMocoaIdentifierMap *> * const oldIdentifierMaps = [self _identifierMapsForModelSections:_modelSections mode:XZMocoaGroupModelMapModeAll];
    if (oldIdentifierMaps == nil) {
        XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 旧数据存在重复，无差异分析");
        [self reloadData];
        XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 结束");
        return completion(YES);
    }
    
    batchUpdates();
    
    // 新数据
    NSMutableArray<XZMocoaGroupSection<id<XZMocoaModel>> *> * const newModelSections = [NSMutableArray array];
    [self.class model:self.model standardizeToModelSections:newModelSections supportedSupplementKinds:self.supportedSupplementKinds];
    
    NSDictionary<XZMocoaKind, XZMocoaIdentifierMap *> * const newIdentifierMaps = [self _identifierMapsForModelSections:newModelSections mode:XZMocoaGroupModelMapModeAll];
    if (newIdentifierMaps == nil) {
        XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 新数据存在重复，无差异分析");
        [self reloadData];
        XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 结束");
        return completion(YES);
    }
    
    XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 差异分析开始");
    
    // section 层：以 supplements 指纹判定 section 身份，LIS 之外的 section 产生移动行为；
    // cell 层：以标识符配对，LIS 之外的 cell 产生移动行为，保证移动次数最少。
    XZMocoaGroupDiffResult * const diff = [self _computeDiffWithNewModelSections:newModelSections];
    if (diff == nil) {
        XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 差异分析结果异常，全量刷新");
        [self reloadData];
        XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 结束");
        return completion(YES);
    }
    
    // 所有变更在同一次批量更新中应用并一次性派发，避免多次动画与中间状态。
    completionLock++;
    [self _applyDiff:diff completion:completion];
    
    XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 结束");
}

/// 判断两个 section 的 cells 是否完全相同（同一位置的标识相同，且为同一模型实例）。
- (BOOL)_areCellsIdenticalOfSection:(XZMocoaGroupSection * const)section toSection:(XZMocoaGroupSection * const)otherSection {
    NSArray * const cellModels = section.cells;
    NSArray * const otherCellModels = otherSection.cells;
    if (cellModels.count != otherCellModels.count) {
        return NO;
    }
    for (NSInteger index = 0; index < (NSInteger)cellModels.count; index++) {
        id const model = cellModels[index];
        id const otherModel = otherCellModels[index];
        if (model == otherModel) {
            continue;
        }
        id const key = XZMocoaDiffKeyForModel(model);
        if (![key isEqual:XZMocoaDiffKeyForModel(otherModel)]) {
            return NO;
        }
    }
    return YES;
}

/// 计算一对存活 section 之间的 cell 差异。
/// @discussion 只允许匹配同一个旧 section 中的元素：
/// 1. 其它存活 section 的元素，会在其所属的配对中处理；
/// 2. 被删除、插入、重载或移动的 section 中的元素是密闭的，不能产生 cell 级事件。
- (XZMocoaCellDiff *)_computeCellDiffForPairWithOldSection:(NSInteger const)oldSectionIndex newSection:(NSInteger const)newSectionIndex newModelSections:(NSArray<XZMocoaGroupSection *> * const)newModelSections {
    XZMocoaCellDiff * const cellDiff = [[XZMocoaCellDiff alloc] init];
    cellDiff.pair = (XZMocoaSectionPair){oldSectionIndex, newSectionIndex};
    
    NSArray * const oldCellModels = _modelSections[oldSectionIndex].cells;
    NSArray * const newCellModels = newModelSections[newSectionIndex].cells;
    
    // 旧 cell 的标识 -> 旧索引（同一个 kind 内标识唯一，已前置校验）。
    NSMutableDictionary<id, NSNumber *> * const oldCellIndexes = [NSMutableDictionary dictionaryWithCapacity:oldCellModels.count];
    for (NSInteger oldCellIndex = 0; oldCellIndex < (NSInteger)oldCellModels.count; oldCellIndex++) {
        oldCellIndexes[XZMocoaDiffKeyForModel(oldCellModels[oldCellIndex])] = @(oldCellIndex);
    }
    
    NSMutableArray<NSIndexPath *> * const deletes = [NSMutableArray array];
    NSMutableArray<NSIndexPath *> * const inserts = [NSMutableArray array];
    NSMutableArray<NSArray<NSIndexPath *> *> * const matches  = [NSMutableArray array];
    NSMutableArray<NSArray<NSIndexPath *> *> * const replaces = [NSMutableArray array];
    NSMutableArray<NSNumber *> * const pairedOldIndexes = [NSMutableArray array];
    NSMutableIndexSet * const consumedOldIndexes = [NSMutableIndexSet indexSet];
    
    for (NSInteger newCellIndex = 0; newCellIndex < (NSInteger)newCellModels.count; newCellIndex++) {
        NSIndexPath * const newIndexPath = [NSIndexPath indexPathForItem:newCellIndex inSection:newSectionIndex];
        id const newCellModel = newCellModels[newCellIndex];
        NSNumber * const oldCellIndex = oldCellIndexes[XZMocoaDiffKeyForModel(newCellModel)];
        
        // 标识在旧数据中不存在，或已被消费，视为新增。
        if (oldCellIndex == nil || [consumedOldIndexes containsIndex:oldCellIndex.unsignedIntegerValue]) {
            [inserts addObject:newIndexPath];
            continue;
        }
        
        NSIndexPath * const oldIndexPath = [NSIndexPath indexPathForItem:oldCellIndex.integerValue inSection:oldSectionIndex];
        [consumedOldIndexes addIndex:oldCellIndex.unsignedIntegerValue];
        
        // 标识相同但模型实例变化：视图模型无法重绑定模型，以删除+插入代替刷新。
        if (oldCellModels[oldCellIndex.integerValue] != newCellModel) {
            [replaces addObject:@[oldIndexPath, newIndexPath]];
            [inserts addObject:newIndexPath];
            continue;
        }
        
        [matches addObject:@[oldIndexPath, newIndexPath]];
        [pairedOldIndexes addObject:oldCellIndex];
    }
    
    // 旧数据中未被配对（或实例已变化）的元素，即为删除。
    for (NSInteger oldCellIndex = 0; oldCellIndex < (NSInteger)oldCellModels.count; oldCellIndex++) {
        if (![consumedOldIndexes containsIndex:oldCellIndex]) {
            [deletes addObject:[NSIndexPath indexPathForItem:oldCellIndex inSection:oldSectionIndex]];
        }
    }
    
    // 配对元素中，旧索引构成最长递增子序列的保持相对顺序，其余产生移动行为。
    NSIndexSet * const stablePositions = XZMocoaDiffLongestIncreasingSubsequenceIndexes(pairedOldIndexes);
    NSMutableArray<NSArray<NSIndexPath *> *> * const moves = [NSMutableArray array];
    for (NSInteger position = 0; position < (NSInteger)pairedOldIndexes.count; position++) {
        if ([stablePositions containsIndex:position]) {
            continue;
        }
        [moves addObject:matches[position]];
    }
    
    cellDiff.deletes  = deletes;
    cellDiff.inserts  = inserts;
    cellDiff.matches  = matches;
    cellDiff.replaces = replaces;
    cellDiff.moves    = moves;
    return cellDiff;
}

/// 计算新旧数据的完整差异。
/// @discussion
/// section 层：以 supplements 指纹判定身份；没有 supplements 的匿名 section 按序配对。
/// 配对成功的 section 中，旧索引处于 LIS 内的保持相对顺序（原地存活），做细粒度分析；
/// LIS 外的产生移动行为。为避免 UIKit 组合更新的不稳定行为（动画异常、堆损坏等），
/// 发生移动的 section 不做细粒度分析：内容完全相同时仅移动，否则以删除+插入代替移动。
- (nullable XZMocoaGroupDiffResult *)_computeDiffWithNewModelSections:(NSArray<XZMocoaGroupSection *> * const)newModelSections {
    NSInteger const oldSectionCount = (NSInteger)_modelSections.count;
    NSInteger const newSectionCount = (NSInteger)newModelSections.count;
    
    // 以 supplements 指纹配对。标识符在同一 kind 内唯一，因此指纹也唯一，可直接映射。
    // 没有 supplements 的匿名 section 无指纹，无法判定身份，按序配对。
    NSMutableDictionary<NSString *, NSNumber *> * const fingerprintToOldIndex = [NSMutableDictionary dictionary];
    for (NSInteger oldIndex = 0; oldIndex < oldSectionCount; oldIndex++) {
        NSString * const fingerprint = [self _fingerprintForModelSection:_modelSections[oldIndex]];
        if (fingerprint != nil) {
            fingerprintToOldIndex[fingerprint] = @(oldIndex);
        }
    }
    
    NSMutableArray<NSNumber *> * const pairOldIndexes = [NSMutableArray array];
    NSMutableArray<NSNumber *> * const pairNewIndexes = [NSMutableArray array];
    NSMutableIndexSet * const matchedOldSections = [NSMutableIndexSet indexSet];
    
    for (NSInteger newIndex = 0; newIndex < newSectionCount; newIndex++) {
        XZMocoaGroupSection * const newSection = newModelSections[newIndex];
        NSString * const fingerprint = [self _fingerprintForModelSection:newSection];
        
        NSNumber *oldIndex = nil;
        if (fingerprint != nil) {
            oldIndex = fingerprintToOldIndex[fingerprint];
        } else {
            // 匿名 section：按序匹配第一个未配对的匿名旧 section。
            for (NSInteger candidate = 0; candidate < oldSectionCount; candidate++) {
                if ([matchedOldSections containsIndex:candidate]) {
                    continue;
                }
                if ([self _fingerprintForModelSection:_modelSections[candidate]] == nil) {
                    oldIndex = @(candidate);
                    break;
                }
            }
        }
        
        if (oldIndex == nil || [matchedOldSections containsIndex:oldIndex.unsignedIntegerValue]) {
            continue;
        }
        
        [matchedOldSections addIndex:oldIndex.unsignedIntegerValue];
        if (fingerprint != nil) {
            [fingerprintToOldIndex removeObjectForKey:fingerprint];
        }
        [pairOldIndexes addObject:oldIndex];
        [pairNewIndexes addObject:@(newIndex)];
    }
    
    // 配对元素按新顺序排列，旧索引处于 LIS 内的保持相对顺序，不产生移动行为。
    NSIndexSet * const stablePositions = XZMocoaDiffLongestIncreasingSubsequenceIndexes(pairOldIndexes);
    
    NSMutableIndexSet * const deletedSections  = [NSMutableIndexSet indexSet];
    NSMutableIndexSet * const insertedSections = [NSMutableIndexSet indexSet];
    NSMutableIndexSet * const reloadedSections = [NSMutableIndexSet indexSet];
    NSMutableArray<NSArray<NSNumber *> *> * const sectionMoves = [NSMutableArray array];
    NSMutableArray<XZMocoaCellDiff *> * const fineGrainedCellDiffs = [NSMutableArray array];
    NSMutableDictionary<NSNumber *, NSNumber *> * const newToOldSectionIndexes = [NSMutableDictionary dictionary];
    
    for (NSInteger position = 0; position < (NSInteger)pairOldIndexes.count; position++) {
        NSInteger const oldIndex = pairOldIndexes[position].integerValue;
        NSInteger const newIndex = pairNewIndexes[position].integerValue;
        XZMocoaGroupSection * const oldSection = _modelSections[oldIndex];
        XZMocoaGroupSection * const newSection = newModelSections[newIndex];
        
        newToOldSectionIndexes[@(newIndex)] = @(oldIndex);
        
        // supplements 发生变化：整体重载。重载的 section 是密闭的，不产生 cell 级事件。
        if (![self _isSupplementsIdenticalOfSection:oldSection toSection:newSection]) {
            [reloadedSections addIndex:newIndex];
            continue;
        }
        
        // 发生移动的 section：内容完全相同时仅移动；否则以删除+插入代替移动（整段重建）。
        if (![stablePositions containsIndex:position]) {
            if ([self _areCellsIdenticalOfSection:oldSection toSection:newSection]) {
                [sectionMoves addObject:@[@(oldIndex), @(newIndex)]];
            } else {
                [deletedSections addIndex:oldIndex];
                [insertedSections addIndex:newIndex];
                [newToOldSectionIndexes removeObjectForKey:@(newIndex)];
            }
            continue;
        }
        
        // 原地存活的 section：细粒度分析。
        XZMocoaCellDiff * const cellDiff = [self _computeCellDiffForPairWithOldSection:oldIndex newSection:newIndex newModelSections:newModelSections];
        [fineGrainedCellDiffs addObject:cellDiff];
    }
    
    // 未匹配的 section：旧数据独有 => 删除；新数据独有 => 插入。
    for (NSInteger oldIndex = 0; oldIndex < oldSectionCount; oldIndex++) {
        if (![matchedOldSections containsIndex:oldIndex]) {
            [deletedSections addIndex:oldIndex];
        }
    }
    for (NSInteger newIndex = 0; newIndex < newSectionCount; newIndex++) {
        if (newToOldSectionIndexes[@(newIndex)] == nil) {
            [insertedSections addIndex:newIndex];
        }
    }
    
    XZMocoaGroupDiffResult * const result = [[XZMocoaGroupDiffResult alloc] init];
    result.deletedSections       = deletedSections;
    result.insertedSections      = insertedSections;
    result.reloadedSections      = reloadedSections;
    result.sectionMoves          = sectionMoves;
    result.fineGrainedCellDiffs  = fineGrainedCellDiffs;
    result.modelSections      = newModelSections;
    result.sectionIndexChanges = newToOldSectionIndexes;
    return result;
}

/// 应用差异分析结果：先将数据与视图模型更新至最终状态，然后在同一次批量更新中一次性派发所有事件。
/// @discussion 坐标约定（已实机验证，UITableView 与 UICollectionView 行为一致）：
/// 删除 = 旧状态坐标；插入、重载与移动的目标 = 新状态（最终）坐标。
/// 提交前做守恒校验，不通过则放弃差异分析，防止更新过程中崩溃。
- (void)_applyDiff:(XZMocoaGroupDiffResult * const)diff completion:(void (^ _Nullable const)(BOOL))completion {
    NSInteger const oldSectionCount = (NSInteger)_modelSections.count;
    NSInteger const newSectionCount = (NSInteger)diff.modelSections.count;
    
    // 守恒校验：section 数量。
    if (oldSectionCount - (NSInteger)diff.deletedSections.count + (NSInteger)diff.insertedSections.count != newSectionCount) {
        XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 差异分析不守恒（section），全量刷新");
        [self reloadData];
        return completion(YES);
    }
    
    // 守恒校验：存活 section 的 cell 数量。
    for (XZMocoaCellDiff * const cellDiff in diff.fineGrainedCellDiffs) {
        NSInteger const oldCellCount = (NSInteger)_modelSections[cellDiff.pair.oldIndex].cells.count;
        NSInteger const newCellCount = (NSInteger)diff.modelSections[cellDiff.pair.newIndex].cells.count;
        NSInteger const changedCount = oldCellCount - (NSInteger)cellDiff.deletes.count - (NSInteger)cellDiff.replaces.count + (NSInteger)cellDiff.inserts.count;
        if (changedCount != newCellCount) {
            XZLog(@"[XZMocoaGroupViewModel][batchUpdates] 差异分析不守恒（cell），全量刷新");
            [self reloadData];
            return completion(YES);
        }
    }
    
    NSArray<XZMocoaGroupSection<__kindof XZMocoaViewModel *> *> * const oldViewModelSections = _viewModelSections;
    NSArray<XZMocoaKind> * const supportedSupplementKinds = self.supportedSupplementKinds;
    
    [self didPerformBatchUpdates:^{
        NSMutableArray<XZMocoaGroupSection *> * const newModelSections = [NSMutableArray arrayWithCapacity:newSectionCount];
        NSMutableArray<XZMocoaGroupSection *> * const newViewModelSections = [NSMutableArray arrayWithCapacity:newSectionCount];
        
        for (NSInteger newIndex = 0; newIndex < newSectionCount; newIndex++) {
            XZMocoaGroupSection * const newModelSection = diff.modelSections[newIndex];
            NSNumber * const oldIndexNumber = diff.sectionIndexChanges[@(newIndex)];
            
            // 新增的、以及以删除+插入代替移动的 section：从模型加载全部元素。
            if (oldIndexNumber == nil) {
                XZMocoaGroupSection * const viewModelSection = [[XZMocoaGroupSection alloc] initWithIndex:newIndex];
                [self section:viewModelSection loadSubViewModelsWithModel:newModelSection supportedSupplementKinds:supportedSupplementKinds];
                [newModelSections addObject:newModelSection];
                [newViewModelSections addObject:viewModelSection];
                continue;
            }
            
            NSInteger const oldIndex = oldIndexNumber.integerValue;
            XZMocoaGroupSection * const oldViewModelSection = oldViewModelSections[oldIndex];
            
            // 重载的、或以删除+插入代替移动的 section：清理旧元素，重建新元素。
            if ([diff.reloadedSections containsIndex:newIndex] || [diff.deletedSections containsIndex:oldIndex]) {
                for (XZMocoaViewModel * const viewModel in oldViewModelSection.cells) {
                    [viewModel removeFromSuperViewModel];
                }
                [oldViewModelSection.supplements enumerateKeysAndObjectsUsingBlock:^(XZMocoaKind _Nonnull kind, NSArray<XZMocoaViewModel *> * _Nonnull viewModels, BOOL * _Nonnull stop) {
                    for (XZMocoaViewModel *viewModel in viewModels) {
                        [viewModel removeFromSuperViewModel];
                    }
                }];
                
                XZMocoaGroupSection * const viewModelSection = [[XZMocoaGroupSection alloc] initWithIndex:newIndex];
                [self section:viewModelSection loadSubViewModelsWithModel:newModelSection supportedSupplementKinds:supportedSupplementKinds];
                [newModelSections addObject:newModelSection];
                [newViewModelSections addObject:viewModelSection];
                continue;
            }
            
            // 移动的 section（内容完全相同）：整体复用。
            XZMocoaCellDiff *cellDiff = nil;
            for (XZMocoaCellDiff * const diffItem in diff.fineGrainedCellDiffs) {
                if (diffItem.pair.newIndex == newIndex) {
                    cellDiff = diffItem;
                    break;
                }
            }
            if (cellDiff == nil) {
                XZMocoaGroupSection * const viewModelSection = [[XZMocoaGroupSection alloc] initWithIndex:newIndex];
                [viewModelSection shareSupplementsFromSection:oldViewModelSection];
                for (NSInteger item = 0; item < (NSInteger)oldViewModelSection.cells.count; item++) {
                    XZMocoaViewModel * const viewModel = oldViewModelSection.cells[item];
                    viewModel.indexPath = [NSIndexPath indexPathForItem:item inSection:newIndex];
                    [viewModelSection addCell:viewModel];
                }
                [newModelSections addObject:newModelSection];
                [newViewModelSections addObject:viewModelSection];
                continue;
            }
            
            // 原地存活的 section：复用 supplements，按差异结果重建 cells。
            NSMutableSet<NSIndexPath *> * const removedCells = [NSMutableSet setWithArray:cellDiff.deletes];
            for (NSArray<NSIndexPath *> * const replace in cellDiff.replaces) {
                [removedCells addObject:replace.firstObject];
            }
            for (NSIndexPath * const indexPath in removedCells) {
                XZMocoaViewModel * const viewModel = oldViewModelSection.cells[indexPath.item];
                [viewModel removeFromSuperViewModel];
            }
            
            // 按新顺序重建 cells：匹配的复用旧视图模型，新增的创建新视图模型。
            XZMocoaGroupSection * const viewModelSection = [[XZMocoaGroupSection alloc] initWithIndex:newIndex];
            [viewModelSection shareSupplementsFromSection:oldViewModelSection];
            
            NSSet<NSIndexPath *> * const insertedCells = [NSSet setWithArray:cellDiff.inserts];
            NSArray * const newCellModels = newModelSection.cells;
            NSInteger matchPosition = 0;
            for (NSInteger newCellIndex = 0; newCellIndex < (NSInteger)newCellModels.count; newCellIndex++) {
                NSIndexPath * const newIndexPath = [NSIndexPath indexPathForItem:newCellIndex inSection:newIndex];
                
                if ([insertedCells containsObject:newIndexPath]) {
                    XZMocoaGroupCellViewModel * const viewModel = [self createViewModelWithModel:newCellModels[newCellIndex] forKind:XZMocoaKindDefault];
                    viewModel.indexPath = newIndexPath;
                    [self addSubViewModel:viewModel];
                    [viewModelSection addCell:viewModel];
                    continue;
                }
                
                // 匹配的元素按新位置升序排列（守恒校验保证不会越界）。
                XZMocoaViewModel * const viewModel = oldViewModelSection.cells[cellDiff.matches[matchPosition].firstObject.item];
                matchPosition++;
                viewModel.indexPath = newIndexPath;
                [viewModelSection addCell:viewModel];
            }
            
            [newModelSections addObject:newModelSection];
            [newViewModelSections addObject:viewModelSection];
        }
        
        self->_modelSections = newModelSections;
        self->_viewModelSections = newViewModelSections;
        
        // 更新所有存活视图模型的 indexPath。
        if (newSectionCount > 0) {
            [self _updateIndexPathsForSubViewModelsInSectionsFromIndex:0 toIndex:(newSectionCount - 1) excludeSections:nil modelMaps:nil];
        }
        
        // 派发 section 级事件：删除（旧坐标）、插入（新坐标）、移动（旧=>新）、重载（新坐标）。
        if (diff.deletedSections.count > 0) {
            [self didDeleteSectionsAtIndexes:diff.deletedSections];
        }
        if (diff.insertedSections.count > 0) {
            [self didInsertSectionsAtIndexes:diff.insertedSections];
        }
        for (NSArray<NSNumber *> * const move in diff.sectionMoves) {
            [self didMoveSectionAtIndex:move.firstObject.integerValue toIndex:move.lastObject.integerValue];
        }
        if (diff.reloadedSections.count > 0) {
            [self didReloadSectionsAtIndexes:diff.reloadedSections];
        }
        
        // 派发 cell 级事件：删除（旧坐标）、插入（新坐标）、移动（旧=>新）。
        NSMutableArray<NSIndexPath *> * const cellDeletes = [NSMutableArray array];
        NSMutableArray<NSIndexPath *> * const cellInserts = [NSMutableArray array];
        for (XZMocoaCellDiff * const cellDiff in diff.fineGrainedCellDiffs) {
            [cellDeletes addObjectsFromArray:cellDiff.deletes];
            [cellInserts addObjectsFromArray:cellDiff.inserts];
            for (NSArray<NSIndexPath *> * const replace in cellDiff.replaces) {
                [cellDeletes addObject:replace.firstObject];
            }
        }
        if (cellDeletes.count > 0) {
            [self didDeleteCellsAtIndexPaths:cellDeletes];
        }
        if (cellInserts.count > 0) {
            [self didInsertCellsAtIndexPaths:cellInserts];
        }
        for (XZMocoaCellDiff * const cellDiff in diff.fineGrainedCellDiffs) {
            for (NSArray<NSIndexPath *> * const move in cellDiff.moves) {
                [self didMoveCellAtIndexPath:move.firstObject toIndexPath:move.lastObject];
            }
        }
    } completion:completion];
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
    // kind 集合比较，避免 allKeys 顺序不同导致误判。
    if (![[NSSet setWithArray:_kindedSupplements.allKeys] isEqualToSet:[NSSet setWithArray:section->_kindedSupplements.allKeys]]) {
        return NO;
    }
    for (XZMocoaKind const kind in _kindedSupplements) {
        NSArray *supplements1 = _kindedSupplements[kind];
        NSArray *supplements2 = section->_kindedSupplements[kind];
        if (supplements2 == nil) {
            return NO;
        }
        if (supplements1.count != supplements2.count) {
            return NO;
        }
        // 同一位置必须是同一个模型实例。
        for (NSInteger index = 0; index < (NSInteger)supplements1.count; index++) {
            if (supplements1[index] != supplements2[index]) {
                return NO;
            }
        }
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
