//
//  XZMocoaGridViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2021/1/23.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaGridViewModel.h"
#import "XZMocoaDefines.h"
#import "XZMocoaModule.h"
#if __has_include(<XZExtensions/NSArray+XZKit.h>)
#import <XZExtensions/NSArray+XZKit.h>
#import <XZExtensions/NSIndexSet+XZKit.h>
#import <XZDefines/XZDefines.h>
#else
#import "XZDefines.h"
#import "NSArray+XZKit.h"
#import "NSIndexSet+XZKit.h"
#endif

/// 在批量更新的过程中，同一元素只能应用一个操作，但是在 MVVM 结构中，
/// 数据变化也可能会引起刷新操作，为了避免多个更新操作，因此会将这些操作暂存并延迟执行。
/// Mocoa 并不能区分所有重复操作，开发者应避免。
typedef void(^XZMocoaGridDelayedUpdates)(__kindof XZMocoaViewModel *self);

@interface XZMocoaGridViewModel () {
    /// 记录了批量更新前的数据，如果不为空，则表示当前处于批量更新过程中。
    NSOrderedSet<XZMocoaGridViewSectionViewModel *> *_dataBeforeBatchUpdates;
    /// 批量更新时，被延迟的更新。
    NSMutableArray<XZMocoaGridDelayedUpdates> *_delayedBatchUpdates;
    /// 是否需要执行批量更新的差异分析。
    /// @note 在批量更新时，由于同一对象不能重复操作，因此任一独立更新操作被调用时，都会标记此值为NO，以关闭差异分析，避免重复操作。
    BOOL _needsDifferenceBatchUpdates;
    /// 保存所有 section 视图模型。
    NSMutableOrderedSet<XZMocoaGridViewSectionViewModel *> *_sectionViewModels;
}

@end

@implementation XZMocoaGridViewModel

@dynamic delegate;

- (instancetype)initWithModel:(id)model {
    self = [super initWithModel:model];
    if (self) {
        _dataBeforeBatchUpdates = nil;
        _sectionViewModels = [NSMutableOrderedSet orderedSet];
        _supportedSupplementaryKinds = @[XZMocoaKindHeader, XZMocoaKindFooter];
    }
    return self;
}

- (void)prepare {
    [super prepare];
    [self _loadDataWithoutEvents];
}

- (void)didRemoveSubViewModel:(__kindof XZMocoaViewModel *)viewModel {
    [_sectionViewModels removeObject:viewModel];
}

- (NSArray<XZMocoaGridViewSectionViewModel *> *)sectionViewModels {
    return _sectionViewModels.array;
}

- (BOOL)isEmpty {
    return _sectionViewModels.count == 0;
}

- (NSInteger)numberOfSections {
    return _sectionViewModels.count;
}

- (NSInteger)numberOfCellsInSection:(NSInteger)section {
    return _sectionViewModels[section].numberOfCells;
}

- (__kindof XZMocoaGridViewSectionViewModel *)sectionViewModelAtIndex:(NSInteger)index {
    return _sectionViewModels[index];
}

- (__kindof XZMocoaGridViewCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    return [_sectionViewModels[indexPath.section] cellViewModelAtIndex:indexPath.row];
}

- (NSInteger)indexOfSectionViewModel:(XZMocoaGridViewSectionViewModel *)sectionModel {
    return [_sectionViewModels indexOfObject:sectionModel];
}

#pragma mark - 处理 SectionViewModel 的事件

- (void)didReceiveUpdates:(XZMocoaUpdates *)updates {
    if ([updates.key isEqualToString:XZMocoaUpdatesKeyReload]) {
        __kindof XZMocoaViewModel * const subViewModel = updates.target;
        if (self.isPerformingBatchUpdates) {
            // 正在进行批量更新，刷新操作将被延迟到批量更新之后。
            // 主要原因是：
            // 1、不确定批量更新是否会与当前的刷新操作重复。
            // 2、即使当前是操作与批量更新没有重复，可能依然会存在崩溃的可能。
            // 3、批量更新之后，当前操作的对象，可能已经不存在了。
            [_delayedBatchUpdates addObject:^void(XZMocoaGridViewModel *self) {
                [self didReceiveUpdates:updates];
            }];
            return;
        }
        if ([subViewModel isKindOfClass:[XZMocoaGridViewSectionViewModel class]]) {
            XZMocoaGridViewSectionViewModel * const sectionVM = subViewModel;
            NSInteger const section = [self indexOfSectionViewModel:sectionVM];
            if (section != NSNotFound) {
                if ([updates.source isKindOfClass:[XZMocoaGridViewCellViewModel class]]) {
                    NSInteger const row = [sectionVM indexOfCellViewModel:updates.source];
                    if (row != NSNotFound) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                        [self didReloadCellsAtIndexPaths:@[indexPath]];
                        return;
                    }
                }
                [self didReloadSectionsAtIndexes:[NSIndexSet indexSetWithIndex:section]];
                return;
            }
        }
    }
    [super didReceiveUpdates:updates];
}

#pragma mark - 局部更新

- (void)reloadData {
    _needsDifferenceBatchUpdates = NO;
    
    {
        // 清理旧数据
        NSOrderedSet * const sectionViewModels = _sectionViewModels.copy;
        [_sectionViewModels removeAllObjects];
        for (XZMocoaViewModel * const viewModel in sectionViewModels) {
            [viewModel removeFromSuperViewModel];
        }
        // 加载新数据
        [self _loadDataWithoutEvents];
    }
    
    [self didReloadData];
}

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(NSInteger)scrollPosition {
    [self didSelectCellAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
}

- (void)deselectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    [self didDeselectCellAtIndexPath:indexPath animated:animated];
}

- (void)reloadSectionAtIndex:(NSInteger)section {
    [self reloadSectionsAtIndexes:[NSIndexSet indexSetWithIndex:section]];
}

- (void)insertSectionAtIndex:(NSInteger)section {
    [self insertSectionsAtIndexes:[NSIndexSet indexSetWithIndex:section]];
}

- (void)deleteSectionAtIndex:(NSInteger)section {
    [self deleteSectionsAtIndexes:[NSIndexSet indexSetWithIndex:section]];
}

- (void)reloadSectionsAtIndexes:(NSIndexSet *)sections {
    _needsDifferenceBatchUpdates = NO;
    
    if (sections.count == 0) {
        return;
    }
    
    // 在批量操作时，同一个元素只能进行一种操作，包括被动的操作（比如减少一个元素，后面的元素自动向前移动一个位置）。
    // 并且在 -[UITableView reloadSections:withRowAnimation:] 的接口文档中，reload 行为与 delete 类似。
    // 所以即使在批量更新过程中，也只能对未进行任何操作的元素，即还保持在原始位置的元素，执行 reload 操作。
    
    id const model = self.model;
    
    if (self.isPerformingBatchUpdates) {
        // 在批量更新的过程中，由于操作的先后顺序的随机性，元素的实时排序，可能并非最终排序，
        // 所以需要根据当前位置找到对应元素的原始位置，对原始位置执行 reload 操作。
        NSMutableIndexSet * const oldSections = [NSMutableIndexSet indexSet];
        [sections enumerateIndexesUsingBlock:^(NSUInteger const index, BOOL * _Nonnull stop) {
            XZMocoaGridViewSectionViewModel * const oldViewModel = [self sectionViewModelAtIndex:index];
            NSInteger const oldSection = [_dataBeforeBatchUpdates indexOfObject:oldViewModel];
            [oldSections addIndex:oldSection];
            [oldViewModel removeFromSuperViewModel];
            
            id const newDataModel = [self model:model modelForSectionAtIndex:index];
            id const newViewModel = [self makeViewModelWithModel:newDataModel forSectionAtIndex:index];
            [self _insertSectionViewModel:newViewModel atIndex:index];
        }];
        
        [self didReloadSectionsAtIndexes:oldSections];
    } else {
        [sections enumerateIndexesUsingBlock:^(NSUInteger const index, BOOL * _Nonnull stop) {
            XZMocoaGridViewSectionViewModel * const oldViewModel = [self sectionViewModelAtIndex:index];
            [oldViewModel removeFromSuperViewModel];
            
            id const newDataModel = [self model:model modelForSectionAtIndex:index];
            XZMocoaGridViewSectionViewModel *newViewModel = [self makeViewModelWithModel:newDataModel forSectionAtIndex:index];
            [self _insertSectionViewModel:newViewModel atIndex:index];
        }];
        
        [self didReloadSectionsAtIndexes:sections];
    }
}

- (void)insertSectionsAtIndexes:(NSIndexSet *)sections {
    _needsDifferenceBatchUpdates = NO;
    
    if (sections.count == 0) {
        return;
    }
    
    id const model = self.model;
    
    // 添加元素，正向遍历：只有前面的元素正确了，后面的才能正确。
    [sections enumerateIndexesUsingBlock:^(NSUInteger const index, BOOL * _Nonnull stop) {
        id const newDataModel = [self model:model modelForSectionAtIndex:index];
        id const newViewModel = [self makeViewModelWithModel:newDataModel forSectionAtIndex:index];
        [self _insertSectionViewModel:newViewModel atIndex:index];
    }];
    
    [self didInsertSectionsAtIndexes:sections];
    
    // 后更新 index 以避免因 index 改变而发生视图刷新时，当前的事件还没有派发。
    NSInteger const count = self.numberOfSections;
    for (NSInteger section = sections.firstIndex; section < count; section++) {
        [self sectionViewModelAtIndex:section].index = section;
    }
}

- (void)deleteSectionsAtIndexes:(NSIndexSet *)sections {
    _needsDifferenceBatchUpdates = NO;
    
    if (sections.count == 0) {
        return;
    }
    
    // 删除元素，反向遍历：从后面开始删除，不会影响前面的
    if (self.isPerformingBatchUpdates) {
        NSMutableIndexSet * const oldSections = [NSMutableIndexSet indexSet];
        [sections enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger const index, BOOL *stop) {
            XZMocoaGridViewSectionViewModel * const oldViewModel = [self sectionViewModelAtIndex:index];
            NSInteger const oldSection   = [_dataBeforeBatchUpdates indexOfObject:oldViewModel];
            [oldSections addIndex:oldSection];
            [oldViewModel removeFromSuperViewModel];
        }];
        [self didDeleteSectionsAtIndexes:oldSections];
    } else {
        [sections enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger const index, BOOL *stop) {
            XZMocoaGridViewSectionViewModel * const oldViewModel = [self sectionViewModelAtIndex:index];
            [oldViewModel removeFromSuperViewModel];
        }];
        
        [self didDeleteSectionsAtIndexes:sections];
        
        // 后更新 index 以避免因 index 改变而发生视图刷新时，当前的事件还没有派发。
        NSInteger const count = self.numberOfSections;
        for (NSInteger section = sections.firstIndex; section < count; section++) {
            [self sectionViewModelAtIndex:section].index = section;
        }
    }
}

- (void)moveSectionAtIndex:(NSInteger)section toIndex:(NSInteger)newSection {
    if (self.isPerformingBatchUpdates) {
        // 批量更新过程中，移动 section 需要找到原始位置
        id        const oldViewModel = [self sectionViewModelAtIndex:section];
        NSInteger const oldSection   = [_dataBeforeBatchUpdates indexOfObject:oldViewModel];
        [self _moveSectionAtIndex:section fromIndex:oldSection toIndex:newSection];
    } else {
        [self _moveSectionAtIndex:section fromIndex:section toIndex:newSection];
        
        // 先刷型视图，后更新 index 的原因：
        // 因为 index 改变，可能会导致视图再次发生刷新，那么就会导致
        // 后续的刷新先应用到视图，从而发生问题。
        NSInteger const min = MIN(section, newSection);
        NSInteger const max = MAX(section, newSection);
        for (NSInteger index = min; index <= max; index++) {
            [self sectionViewModelAtIndex:index].index = index;
        }
    }
}

- (void)moveCellAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    if (indexPath.section == newIndexPath.section) {
        [[self sectionViewModelAtIndex:indexPath.section] moveCellAtIndex:indexPath.item toIndex:newIndexPath.item];
    } else {
        XZMocoaGridViewSectionViewModel * const oldViewModel = [self sectionViewModelAtIndex:indexPath.section];
        XZMocoaGridViewCellViewModel * const viewModel = [oldViewModel removeCellViewModelAtIndex:indexPath.item];
        
        XZMocoaGridViewSectionViewModel * const newViewModel = [self sectionViewModelAtIndex:newIndexPath.section];
        [newViewModel insertCellViewModel:viewModel atIndex:newIndexPath.item];
        
        [self didMoveCellAtIndexPath:indexPath toIndexPath:newIndexPath];
    }
}

- (void)reloadCellAtIndexPath:(NSIndexPath *)indexPath {
    [[self sectionViewModelAtIndex:indexPath.section] reloadCellAtIndex:indexPath.row];
}

- (void)insertCellAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger const targetSection = indexPath.section;
    
    // 不需要添加新的 section
    NSInteger const numberOfSections = self.numberOfSections;
    if (targetSection <= numberOfSections - 1) {
        [[self sectionViewModelAtIndex:targetSection] insertCellAtIndex:indexPath.row];
        return;
    }
    
    id const model = self.model;
    
    // 添加缺少的 section
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for (NSInteger section = numberOfSections; section <= targetSection; section++) {
        id const newDataModel = [self model:model modelForSectionAtIndex:section];
        id const newViewModel = [self makeViewModelWithModel:newDataModel forSectionAtIndex:section];
        [self _insertSectionViewModel:newViewModel atIndex:section];
        [indexes addIndex:section];
    }
    [self didInsertSectionsAtIndexes:indexes];
    
    // 发送添加 cell 的事件
    [self didInsertCellsAtIndexPaths:@[indexPath]];
}

- (void)deleteCellAtIndexPath:(NSIndexPath *)indexPath {
    [[self sectionViewModelAtIndex:indexPath.section] deleteCellAtIndex:indexPath.row];
}

- (void)reloadCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        [self reloadCellAtIndexPath:indexPath];
    }
}

- (void)insertCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        [self insertCellAtIndexPath:indexPath];
    }
}

- (void)deleteCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        [self deleteCellAtIndexPath:indexPath];
    }
}

#pragma mark - 批量更新

- (BOOL)isPerformingBatchUpdates {
    return _dataBeforeBatchUpdates != nil;
}

- (BOOL)prepareBatchUpdates {
    if (_dataBeforeBatchUpdates) {
        XZLog(@"当前正在批量更新，本次操作取消");
        return NO;
    }
    
    _dataBeforeBatchUpdates = _sectionViewModels.copy;
    _delayedBatchUpdates = [NSMutableArray array];
    return YES;
}

- (void)cleanupBatchUpdates {
    _dataBeforeBatchUpdates = nil;
    for (XZMocoaGridDelayedUpdates const batchUpdates in _delayedBatchUpdates) {
        batchUpdates(self);
    }
    _delayedBatchUpdates = nil;
    
    // 因为某些模块，可能会根据 index 来处理逻辑，所以在批量更新的过程设置 index 可能会造成视图刷新。
    // 所以将更新 index 的操作，放到了批量更新之后进行。
    [_sectionViewModels enumerateObjectsUsingBlock:^(XZMocoaGridViewSectionViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.index = idx;
    }];
}

- (void)setNeedsDifferenceBatchUpdates {
    _needsDifferenceBatchUpdates = YES;
}

- (void)performBatchUpdates:(void (^NS_NOESCAPE)(void))batchUpdates completion:(void (^ _Nullable)(BOOL))completion {
    NSParameterAssert(batchUpdates != nil);
    XZLog(@"===== 批量更新开始 %@ =====", self);
    
    if (![self prepareBatchUpdates]) {
        return;
    }
    
    // 批量更新的过程中，由于 section 内的局部更新可能并不会反馈到 section 的变化上来。
    // 比如对 section 数据进行了排序，这并不是 section 整体的更新，
    // 因此对于未更新的 section 会在 table 批量更新后，执行 -performBatchUpdates:completion: 方法以进行更新。
    NSIndexSet * __block forwardIndexes = nil;
    // 批量更新回调，应该在 batchUpdates 和 forwardIndexes 更新之后，所以需要一个标记。
    // 二者更新都会增加这个标记，触发回调就减少，当标记为 0 时执行回调。
    NSInteger    __block completionFlag = 0;
    
    void (^const tableViewBatchUpdates)(void) = ^{
        completionFlag += 1;
        // 批量更新开始，默认标记需进行差异分析，并开始拦截需要延迟的操作。
        [self setNeedsDifferenceBatchUpdates];
        // 执行批量更新。这其中如果有独立更新的操作，会关闭差异分析。
        // 在此过程中，如果有 cell 模块，因为交互或事件，需要刷新视图，则操作会被延迟。
        batchUpdates();
        // 执行差异分析，并返回
        forwardIndexes = [self differenceBatchUpdatesIfNeeded];
    };
    void (^const tableViewCompletion)(BOOL) = ^(BOOL finished){
        XZLog(@"completionFlag: %ld", completionFlag);
        completionFlag -= 1;
        if (completionFlag > 0) return;
        if (completion) completion(finished);
    };
    
    // 批量事件，block 会传递到 view 到 -[tableView performBatchUpdates:completion:] 方法中执行。
    [self didPerformBatchUpdates:tableViewBatchUpdates completion:tableViewCompletion];
    
    // 当前的批量操作已完成，清理批量更新环境，并执行延迟的事件
    [self cleanupBatchUpdates];
    
    // 传递事件给保留的下级
    // 当前批量更新的数据变化监测，只针对的是 section 层级，而 section 的 cells 也可能发生了更新。
    // 因此在 section 检测完更新之后，我们向保留的 section 发送批量更新消息，让 section 去检查其
    // 内部的 cell 数据是否发生了更新。
    // section 的 delete/reload/insert 操作，影响的是整个 section 模块，很明显，批量更新时，如
    // 果只是 section 内的某个 cell 发生了更新，不应该视为它的整个 section 发生了刷新。
    if (forwardIndexes.count > 0) {
        void (^const tableViewBatchUpdates)(void) = ^{
            completionFlag += 1;
            [forwardIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                [[self sectionViewModelAtIndex:idx] performBatchUpdates:^{
                    // section 内的更新数据已经在 batchUpdates() 执行了。
                } completion:nil];
            }];
        };
        [self didPerformBatchUpdates:tableViewBatchUpdates completion:tableViewCompletion];
    }
    
    XZLog(@"===== 批量更新结束 %@ =====", self);
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
    if (!_needsDifferenceBatchUpdates) {
        return nil;
    }
    _needsDifferenceBatchUpdates = NO;
    
    // 记录更新前的数据。
    NSOrderedSet * const oldViewModels = _dataBeforeBatchUpdates.copy;
    NSInteger      const oldCount      = oldViewModels.count;
    NSArray      * const oldDataModels = [NSMutableArray arrayWithCapacity:oldCount];
    for (NSInteger i = 0; i < oldCount; i++) {
        XZMocoaGridViewSectionViewModel * const viewModel = oldViewModels[i];
        id const dataModel = viewModel.model;
        [(NSMutableArray *)oldDataModels addObject:(dataModel ?: NSNull.null)];
    }
    
    if (oldDataModels.xz_containsDuplicateObjects) {
        XZLog(@"由于旧数据中包含重复元素，本次批量更新无法进行差异化分析");
        [self reloadData];
        return nil;
    }
    
    id const model = self.model;
    
    // 获取更新后的数据。
    NSInteger const newCount      = [self model:model numberOfSectionModels:NULL];
    NSArray * const newDataModels = [NSMutableArray arrayWithCapacity:newCount];
    for (NSInteger i = 0; i < newCount; i++) {
        id const newDataModel = [self model:model modelForSectionAtIndex:i];
        [(NSMutableArray *)newDataModels addObject:(newDataModel ?: NSNull.null)];
    }
    
    if (newDataModels.xz_containsDuplicateObjects) {
        XZLog(@"由于新数据中包含重复元素，本次批量更新无法进行差异化分析");
        [self reloadData];
        return nil;
    }
    
    // 差异分析及更新算法：
    // 对于更新后的所有元素，只可能属于 remain/updates/changes/inserts 中的一个。
    // 在执行删除、插入操作后，列表数量就与预期的一致了，即仅需要排序即可，但是由于删除或插入操作，
    // 也可能会改变 remain、changes 中的元素，且排序的过程中，也可能会改变其他元素的位置，
    // 因此在处理排序时，应从低位 0 开始遍历，逐个查找该位置上预期元素，然后将其移动到该位置上。
    
    XZLog(@"【原始】%@", oldDataModels);
    XZLog(@"【目标】%@", newDataModels);
    XZLog(@"【差异分析】开始");

    NSIndexSet                           * const inserts = [NSMutableIndexSet indexSet];
    NSIndexSet                           * const deletes = [NSMutableIndexSet indexSet];
    NSIndexSet                           * const remains = [NSMutableIndexSet indexSet];
    NSDictionary<NSNumber *, NSNumber *> * const changes = [NSMutableDictionary dictionaryWithCapacity:oldCount];
    [newDataModels xz_differenceFromArray:oldDataModels inserts:(id)inserts deletes:(id)deletes changes:(id)changes remains:(id)remains];
    XZLog(@"【不变】%@", remains);

    // 删除元素，反向遍历：从后面开始删除，不会影响前面的
    [deletes enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger section, BOOL *stop) {
        XZMocoaGridViewSectionViewModel * const oldViewModel = [self sectionViewModelAtIndex:section];
        [oldViewModel removeFromSuperViewModel];
    }];
    [self didDeleteSectionsAtIndexes:deletes];
    XZLog(@"【删除】%@", deletes);
    
    // 添加元素，正向遍历：按位置记录下新添加的元素，以便在后续排序时，查找该位置上的元素。
    NSMutableDictionary * const insertedViewModels = [NSMutableDictionary dictionaryWithCapacity:inserts.count];
    [inserts enumerateIndexesUsingBlock:^(NSUInteger index, BOOL * _Nonnull stop) {
        id const newDataModel = newDataModels[index];
        XZMocoaGridViewSectionViewModel * const newViewModel = [self makeViewModelWithModel:newDataModel forSectionAtIndex:index];
        [self _insertSectionViewModel:newViewModel atIndex:index];
        insertedViewModels[@(index)] = newViewModel;
    }];
    [self didInsertSectionsAtIndexes:inserts];
    XZLog(@"【添加】%@", inserts);
    
    NSMutableIndexSet * const forwardIndexes = [NSMutableIndexSet indexSet];
    
    // 排序元素：从低位开始遍历，每一个位置，都应该能根据 inserts/remains/changes 中找到对应的元素。
    for (NSInteger to = 0; to < newCount; to++) {
        if ([inserts containsIndex:to]) {
            NSInteger const index = [self indexOfSectionViewModel:insertedViewModels[@(to)]];
            [self _moveSectionViewModelFromIndex:index toIndex:to];
            XZLog(@"【调整】%ld -> %ld, %@", (long)index, (long)to, self.sectionDataModels);
        } else if ([remains containsIndex:to]) {
            // to 位置为保持不变的元素，在 old 中找到 viewModel 然后将其移动到 to 位置上。
            XZMocoaGridViewSectionViewModel *viewModel = oldViewModels[to];
            NSInteger const index = [self indexOfSectionViewModel:viewModel];
            [self moveSubViewModelAtIndex:index toIndex:to];
            // 执行更新。在数据更新的过程中，由数据引发的更新已经在更新数据时被拦截下来，在这里差异分析时，不会再触发了。
            [viewModel performBatchUpdates:^{
                // Model 已更新，ViewModel 未更新，直接发送事件即可。
            } completion:nil];;
            XZLog(@"【调整】%ld -> %ld, %@", (long)index, (long)to, self.sectionDataModels);
        } else {
            // to 位置为被移动的元素，先找到它原来的位置，然后找到 viewModel 然后再移动位置。
            NSInteger const from  = changes[@(to)].integerValue;
            NSInteger const index = [self indexOfSectionViewModel:oldViewModels[from]];
            // 移动 section 并更新视图
            [self _moveSectionViewModelFromIndex:index toIndex:to];
            [self didMoveSectionAtIndex:from toIndex:to];
            XZLog(@"【移动】%ld(%ld) -> %ld, %@", from, index, to, self.sectionDataModels);
            // 记录待更新的 section
            [forwardIndexes addIndex:to];
        }
    }

    // 检查结果
    NSAssert([self.sectionDataModels isEqualToArray:newDataModels], @"更新结果与预期不一致");
    
    return forwardIndexes;
}

#pragma mark - 私有方法

/// 将 viewModel 添加到末尾，并添加为子元素。
- (void)_addSectionViewModel:(XZMocoaGridViewSectionViewModel *)sectionViewModel {
    NSParameterAssert([sectionViewModel isKindOfClass:[XZMocoaGridViewSectionViewModel class]]);
    [_sectionViewModels addObject:sectionViewModel];
    [self addSubViewModel:sectionViewModel];
}

/// 将 viewModel 插入到 index 位置，并添加为子元素。
- (void)_insertSectionViewModel:(XZMocoaGridViewSectionViewModel *)sectionViewModel atIndex:(NSInteger)index {
    NSParameterAssert([sectionViewModel isKindOfClass:[XZMocoaGridViewSectionViewModel class]]);
    [_sectionViewModels insertObject:sectionViewModel atIndex:index];
    [self addSubViewModel:sectionViewModel];
}

/// 将 oldIndex 位置上的 viewModel 移动到 newIndex 位置上，在子元素集合中的位置不变。
- (void)_moveSectionViewModelFromIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex {
    if (newIndex == oldIndex) return;
    id const viewModel = _sectionViewModels[oldIndex];
    [_sectionViewModels removeObjectAtIndex:oldIndex];
    [_sectionViewModels insertObject:viewModel atIndex:newIndex];
}

/// 添加所有 section 元素，需先清理数据。
- (void)_loadDataWithoutEvents {
    id const model = self.model;
    
    NSInteger const count = [self model:model numberOfSectionModels:NULL]; // model.numberOfSectionModels;
    
    for (NSInteger section = 0; section < count; section++) {
        id const dataModel = [self model:model modelForSectionAtIndex:section];
        XZMocoaGridViewSectionViewModel *viewModel = [self makeViewModelWithModel:dataModel forSectionAtIndex:section];
        [self _addSectionViewModel:viewModel];
    }
}

/// 移动 section 。
/// @discussion 对于 UITableView 而言，变化就是从旧位置移动到新位置，但是对于 ViewModel 而言，
///             每次 move 都会改变数据源中数据的排序，所以数据的移动与视图的移动可能不一致。
/// @param section 当前位置
/// @param oldSection 原始位置
/// @param newSection 目标位置
- (void)_moveSectionAtIndex:(NSInteger)section fromIndex:(NSInteger)oldSection toIndex:(NSInteger)newSection {
    _needsDifferenceBatchUpdates = NO;
    
    // 更新数据
    [self _moveSectionViewModelFromIndex:section toIndex:newSection];
    
    // 新旧位置无变化，不需要发送事件。
    if (oldSection == newSection) {
        return;
    }
    
    [self didMoveSectionAtIndex:oldSection toIndex:newSection];
}

/// 构造 Section 视图模型
/// @param nullableModel 可能为 Null 对象的数据模型
/// @param index 位置
- (XZMocoaGridViewSectionViewModel *)makeViewModelWithModel:(id)nullableModel forSectionAtIndex:(NSInteger)index {
    id<XZMocoaGridViewSectionModel> const model  = (nullableModel == (id)kCFNull ? nil : nullableModel);
    XZMocoaName                     const name   = model.mocoaName;
    XZMocoaModule *                 const module = [self.module submoduleIfLoadedForKind:XZMocoaKindSection forName:name];
    
    // 查找 VMClass
    Class VMClass = module.viewModelClass;
    if (VMClass) {
        // 1、使用当前 section 模块的视图模型
    } else if (name.length > 0) {
        // 2、使用默认 section 模块的视图模型
        XZMocoaModule *defaultModule = [self.module submoduleIfLoadedForKind:XZMocoaKindSection forName:XZMocoaNameDefault];
        VMClass = defaultModule.viewModelClass;
    }
    if (VMClass == Nil) {
        // 3、使用占位视图模型
        VMClass = [self placeholderViewModelClassForSectionAtIndex:index];
    }
    
    XZMocoaGridViewSectionViewModel * const viewModel = [[VMClass alloc] initWithModel:model];
    viewModel.module = module;
    viewModel.index  = index;
    return viewModel;
}

#pragma mark - 子类重写

- (void)didReloadData {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didDeselectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(NSInteger)scrollPosition {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didReloadCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didInsertCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didDeleteCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didMoveCellAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didReloadSectionsAtIndexes:(NSIndexSet *)sections {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didInsertSectionsAtIndexes:(NSIndexSet *)sections {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didDeleteSectionsAtIndexes:(NSIndexSet *)sections {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didMoveSectionAtIndex:(NSInteger)oldSection toIndex:(NSInteger)newSection {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (void)didPerformBatchUpdates:(void (^NS_NOESCAPE)(void))batchUpdates completion:(void (^ _Nullable)(BOOL))completion {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}

- (Class)placeholderViewModelClassForSectionAtIndex:(NSInteger)index {
    NSString *reason = [NSString stringWithFormat:@"必须使用子类，并重 %s 方法", __PRETTY_FUNCTION__];
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
}


#pragma mark - DEBUG

#if XZ_DEBUG || DEBUG
- (NSArray *)sectionDataModels {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:_sectionViewModels.count];
    [_sectionViewModels enumerateObjectsUsingBlock:^(XZMocoaGridViewSectionViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [result addObject:(obj.model ?: (id)kCFNull)];
    }];
    return result;
}
#endif


@end


@implementation XZMocoaGridViewModel (XZMocoaGridViewSectionViewModelUpdates)

- (void)sectionViewModel:(XZMocoaGridViewSectionViewModel *)viewModel didReloadData:(void * _Nullable)null {
    NSInteger const index = [self indexOfSectionViewModel:viewModel];
    if (index == NSNotFound) return;
    if (!self.isReady) return;
    
    if (!self.isPerformingBatchUpdates || (self.isPerformingBatchUpdates && viewModel.isPerformingBatchUpdates)) {
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:index];
        [self didReloadSectionsAtIndexes:indexes];
    } else {
        [_delayedBatchUpdates addObject:^void(XZMocoaGridViewModel *self) {
            [self sectionViewModel:viewModel didReloadData:null];
        }];
    }
}

- (void)sectionViewModel:(XZMocoaGridViewSectionViewModel *)viewModel didReloadCellsAtIndexes:(NSIndexSet *)rows {
    NSInteger const index = [self indexOfSectionViewModel:viewModel];
    if (index == NSNotFound) return;
    if (!self.isReady) return;
    
    if (!self.isPerformingBatchUpdates || (self.isPerformingBatchUpdates && viewModel.isPerformingBatchUpdates)) {
        NSArray * const indexPaths = [rows xz_map:^id(NSInteger idx, BOOL *stop) {
            return [NSIndexPath indexPathForRow:idx inSection:index];
        }];
        [self didReloadCellsAtIndexPaths:indexPaths];
    } else {
        [_delayedBatchUpdates addObject:^void(XZMocoaGridViewModel *self) {
            [self sectionViewModel:viewModel didReloadCellsAtIndexes:rows];
        }];
    }
}

- (void)sectionViewModel:(XZMocoaGridViewSectionViewModel *)viewModel didInsertCellsAtIndexes:(NSIndexSet *)rows {
    NSInteger const index = [self indexOfSectionViewModel:viewModel];
    if (index == NSNotFound) return;
    if (!self.isReady) return;
    
    if (!self.isPerformingBatchUpdates || (self.isPerformingBatchUpdates && viewModel.isPerformingBatchUpdates)) {
        NSArray * const indexPaths = [rows xz_map:^id(NSInteger idx, BOOL *stop) {
            return [NSIndexPath indexPathForRow:idx inSection:index];
        }];
        [self didInsertCellsAtIndexPaths:indexPaths];
    } else {
        [_delayedBatchUpdates addObject:^void(XZMocoaGridViewModel *self) {
            [self sectionViewModel:viewModel didInsertCellsAtIndexes:rows];
        }];
    }
}

- (void)sectionViewModel:(XZMocoaGridViewSectionViewModel *)viewModel didDeleteCellsAtIndexes:(NSIndexSet *)rows {
    NSInteger const index = [self indexOfSectionViewModel:viewModel];
    if (index == NSNotFound) return;
    if (!self.isReady) return;
    
    if (!self.isPerformingBatchUpdates || (self.isPerformingBatchUpdates && viewModel.isPerformingBatchUpdates)) {
        NSArray * const indexPaths = [rows xz_map:^id(NSInteger idx, BOOL *stop) {
            return [NSIndexPath indexPathForRow:idx inSection:index];
        }];
        [self didDeleteCellsAtIndexPaths:indexPaths];
    } else {
        [_delayedBatchUpdates addObject:^void(XZMocoaGridViewModel *self) {
            [self sectionViewModel:viewModel didDeleteCellsAtIndexes:rows];
        }];
    }
}

- (void)sectionViewModel:(XZMocoaGridViewSectionViewModel *)viewModel didMoveCellAtIndex:(NSInteger)row toIndex:(NSInteger)newRow {
    NSInteger const index = [self indexOfSectionViewModel:viewModel];
    if (index == NSNotFound) return;
    if (!self.isReady) return;
    
    if (!self.isPerformingBatchUpdates || (self.isPerformingBatchUpdates && viewModel.isPerformingBatchUpdates)) {
        NSIndexPath *from = [NSIndexPath indexPathForRow:row inSection:index];
        NSIndexPath *to   = [NSIndexPath indexPathForRow:newRow inSection:index];
        [self didMoveCellAtIndexPath:from toIndexPath:to];
    } else {
        [_delayedBatchUpdates addObject:^void(XZMocoaGridViewModel *self) {
            [self sectionViewModel:viewModel didMoveCellAtIndex:row toIndex:newRow];
        }];
    }
}

- (void)sectionViewModel:(XZMocoaGridViewSectionViewModel *)viewModel didPerformBatchUpdates:(void (^NS_NOESCAPE)(void))batchUpdates completion:(void (^ _Nullable)(BOOL))completion {
    NSInteger const index = [self indexOfSectionViewModel:viewModel];
    if (index == NSNotFound) return;
    
    // 应用 batchUpdates 中的数据操作，视图操作会被拦截
    if (!self.isReady || self.isPerformingBatchUpdates) {
        batchUpdates();
        if (completion) dispatch_async(dispatch_get_main_queue(), ^{ completion(NO); });
    } else {
        [self didPerformBatchUpdates:batchUpdates completion:completion];
    }
}

@end

@implementation XZMocoaGridViewModel (XZMocoaGridModelTransformer)

- (NSInteger)model:(id)model numberOfSectionModels:(void *)null {
    return [(id<XZMocoaGridModel>)model numberOfSectionModels];
}

- (id)model:(id)model modelForSectionAtIndex:(NSInteger)index {
    return [(id<XZMocoaGridModel>)model modelForSectionAtIndex:index];
}

@end


@implementation XZMocoaGridViewModel (NSFetchedResultsControllerDelegate)

/// 这个代理方法会阻断下面所有代理方法，且适合搭配 UITableViewDiffableDataSource/UIColletionViewDiffableDataSource 使用。似乎可能没有 move-to 这种操作。
//- (void)controller:(NSFetchedResultsController *)controller didChangeContentWithSnapshot:(NSDiffableDataSourceSnapshot<NSString *,NSManagedObjectID *> *)snapshot {}

/// 不分 section 时，此方法会阻断下面的方法。似乎只有 insert/remove 两种更新类型。
//- (void)controller:(NSFetchedResultsController *)controller didChangeContentWithDifference:(NSOrderedCollectionDifference<NSManagedObjectID *> *)diff { }

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (!self.isReady) return;

    [self prepareBatchUpdates];
    [self setNeedsDifferenceBatchUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (!self.isReady) return;
    
    NSAssert(_needsDifferenceBatchUpdates, @"在 CoreData 更新数据的期间，对 UITableView 数据源进行了修改，无法进行下一步差异性分析");
    NSIndexSet * __block forwardIndexes = nil;
    
    [self didPerformBatchUpdates:^{
        forwardIndexes = [self differenceBatchUpdatesIfNeeded];
    } completion:nil];
    
    [self cleanupBatchUpdates];
    
    if (forwardIndexes.count > 0) {
        [self didPerformBatchUpdates:^{
            [forwardIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                [[self sectionViewModelAtIndex:idx] performBatchUpdates:^{
                    // section 内的更新数据已经在 batchUpdates() 执行了。
                } completion:nil];
            }];
        } completion:nil];
    }
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
            XZLog(@"[CoreData][insert] %ld", sectionIndex);
            break;
        }
        case NSFetchedResultsChangeDelete: {
            XZLog(@"[CoreData][delete] %ld", sectionIndex);
            break;
        }
        default:
            @throw [NSException exceptionWithName:NSGenericException reason:@"should never be called" userInfo:nil];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    // if (!self.isReady) return;
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            XZLog(@"[CoreData][insert] {%ld, %ld}", newIndexPath.section, newIndexPath.item);
            break;
        }
        case NSFetchedResultsChangeMove: {
            XZLog(@"[CoreData][move] {%ld, %ld} => {%ld, %ld}", indexPath.section, indexPath.item, newIndexPath.section, newIndexPath.item);
            break;
        }
        case NSFetchedResultsChangeDelete: {
            XZLog(@"[CoreData][delete] {%ld, %ld}", indexPath.section, indexPath.item);
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            XZLog(@"[CoreData][update] {%ld, %ld}", indexPath.section, indexPath.item);
            break;
        }
    }
}
#endif

@end
