//
//  XZMocoaTableViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaTableViewModel.h"
#import "XZMocoaTablePlaceholderCellViewModel.h"
#import "XZMocoaTablePlaceholderSupplementViewModel.h"

@implementation XZMocoaTableViewModel

@dynamic delegate;

- (instancetype)initWithModel:(id)model {
    self = [super initWithModel:model];
    if (self) {
        _rowAnimation = UITableViewRowAnimationAutomatic;
    }
    return self;
}

- (CGFloat)height {
    [self ready];
    CGFloat height = 0;
    NSInteger const sectionCount = self.numberOfSections;
    for (NSInteger sectionIndex = 0; sectionIndex < sectionCount; sectionIndex++) {
        height += [self viewModelForHeaderInSection:sectionIndex].frame.size.height;
        NSInteger const rowCount = [self numberOfCellsInSection:sectionIndex];
        for (NSInteger rowIndex = 0; rowIndex < rowCount; rowIndex++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
            height += [self viewModelForCellAtIndexPath:indexPath].frame.size.height;
        }
        height += [self viewModelForFooterInSection:sectionIndex].frame.size.height;
    }
    return height;
}

- (void)reloadSection:(NSInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    _rowAnimation = animation;
    [super reloadSections:[NSIndexSet indexSetWithIndex:section]];
}

- (void)insertSection:(NSInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    _rowAnimation = animation;
    [super insertSections:[NSIndexSet indexSetWithIndex:section]];
}

- (void)deleteSection:(NSInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    _rowAnimation = animation;
    [super deleteSections:[NSIndexSet indexSetWithIndex:section]];
}

- (void)reloadSections:(nullable NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    _rowAnimation = animation;
    [super reloadSections:sections];
}

- (void)insertSections:(nullable NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    _rowAnimation = animation;
    [super insertSections:sections];
}

- (void)deleteSections:(nullable NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    _rowAnimation = animation;
    [super deleteSections:sections];
}

- (void)reloadCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    _rowAnimation = animation;
    [super reloadCellsAtIndexPaths:indexPaths];
}

- (void)insertCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    _rowAnimation = animation;
    [super insertCellsAtIndexPaths:indexPaths];
}

- (void)deleteCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    _rowAnimation = animation;
    [super deleteCellsAtIndexPaths:indexPaths];
}

// MARK: - 重写方法

- (void)reloadSections:(NSIndexSet *)sections {
    _rowAnimation = UITableViewRowAnimationAutomatic;
    [super reloadSections:sections];
}

- (void)insertSections:(NSIndexSet *)sections {
    _rowAnimation = UITableViewRowAnimationAutomatic;
    [super insertSections:sections];
}

- (void)deleteSections:(NSIndexSet *)sections {
    _rowAnimation = UITableViewRowAnimationAutomatic;
    [super deleteSections:sections];
}

- (void)reloadCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    _rowAnimation = UITableViewRowAnimationAutomatic;
    [super reloadCellsAtIndexPaths:indexPaths];
}

- (void)insertCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    _rowAnimation = UITableViewRowAnimationAutomatic;
    [super insertCellsAtIndexPaths:indexPaths];
}

- (void)deleteCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    _rowAnimation = UITableViewRowAnimationAutomatic;
    [super deleteCellsAtIndexPaths:indexPaths];
}

// MARK: - 子类必须实现的方法

- (void)didReloadData {
    if (!self.isReady) return;
    [self.delegate tableViewModel:self didReloadData:NULL];
}

- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition {
    [self.delegate tableViewModel:self didSelectCellAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
}

- (void)didDeselectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    [self.delegate tableViewModel:self didDeselectCellAtIndexPath:indexPath animated:animated];
}

- (void)didReloadCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (!self.isReady) return;
    [self.delegate tableViewModel:self didReloadCellsAtIndexPaths:indexPaths];
}

- (void)didInsertCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (!self.isReady) return;
    [self.delegate tableViewModel:self didInsertCellsAtIndexPaths:indexPaths];
}

- (void)didDeleteCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (!self.isReady) return;
    [self.delegate tableViewModel:self didDeleteCellsAtIndexPaths:indexPaths];
}

- (void)didMoveCellAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    if (!self.isReady) return;
    [self.delegate tableViewModel:self didMoveCellAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (void)didReloadSectionsAtIndexes:(NSIndexSet *)sections {
    if (!self.isReady) return;
    [self.delegate tableViewModel:self didReloadSectionsAtIndexes:sections];
}

- (void)didInsertSectionsAtIndexes:(NSIndexSet *)sections {
    if (!self.isReady) return;
    [self.delegate tableViewModel:self didInsertSectionsAtIndexes:sections];
}

- (void)didDeleteSectionsAtIndexes:(NSIndexSet *)sections {
    if (!self.isReady) return;
    [self.delegate tableViewModel:self didDeleteSectionsAtIndexes:sections];
}

- (void)didMoveSectionAtIndex:(NSInteger)oldSection toIndex:(NSInteger)newSection {
    if (!self.isReady) return;
    [self.delegate tableViewModel:self didMoveSectionAtIndex:oldSection toIndex:newSection];
}

- (void)didPerformBatchUpdates:(void (^NS_NOESCAPE)(void))batchUpdates completion:(void (^ _Nullable)(BOOL))completion {
    if (self.isReady) {
        [self.delegate tableViewModel:self didPerformBatchUpdates:batchUpdates completion:completion];
    } else {
        batchUpdates();
        if (completion) dispatch_async(dispatch_get_main_queue(), ^{ completion(YES); });
    }
}

- (Class)viewModelClassForPlaceholderOfKind:(XZMocoaKind)kind {
    if (kind == XZMocoaKindHeader || kind == XZMocoaKindFooter) {
        return [XZMocoaTablePlaceholderSupplementViewModel class];
    }
    return [XZMocoaTablePlaceholderCellViewModel class];
}

@end
