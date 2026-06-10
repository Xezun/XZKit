//
//  XZMocoaCollectionViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaCollectionViewModel.h"
#import "XZMocoaCollectionView.h"

@implementation XZMocoaCollectionViewModel

- (void)didReloadData {
    if (!self.isReady) return;
    [(id<XZMocoaCollectionView>)self->_view collectionViewModel:self didReloadData:NULL];
}

- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition {
    [(id<XZMocoaCollectionView>)self->_view collectionViewModel:self didSelectCellAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
}

- (void)didDeselectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    [(id<XZMocoaCollectionView>)self->_view collectionViewModel:self didDeselectCellAtIndexPath:indexPath animated:animated];
}

- (void)didReloadCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (!self.isReady) return;
    [(id<XZMocoaCollectionView>)self->_view collectionViewModel:self didReloadCellsAtIndexPaths:indexPaths];
}

- (void)didInsertCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (!self.isReady) return;
    [(id<XZMocoaCollectionView>)self->_view collectionViewModel:self didInsertCellsAtIndexPaths:indexPaths];
}

- (void)didDeleteCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (!self.isReady) return;
    [(id<XZMocoaCollectionView>)self->_view collectionViewModel:self didDeleteCellsAtIndexPaths:indexPaths];
}

- (void)didMoveCellAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    if (!self.isReady) return;
    [(id<XZMocoaCollectionView>)self->_view collectionViewModel:self didMoveCellAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (void)didReloadSectionsAtIndexes:(NSIndexSet *)sections {
    if (!self.isReady) return;
    [(id<XZMocoaCollectionView>)self->_view collectionViewModel:self didReloadSectionsAtIndexes:sections];
}

- (void)didInsertSectionsAtIndexes:(NSIndexSet *)sections {
    if (!self.isReady) return;
    [(id<XZMocoaCollectionView>)self->_view collectionViewModel:self didInsertSectionsAtIndexes:sections];
}

- (void)didDeleteSectionsAtIndexes:(NSIndexSet *)sections {
    if (!self.isReady) return;
    [(id<XZMocoaCollectionView>)self->_view collectionViewModel:self didDeleteSectionsAtIndexes:sections];
}

- (void)didMoveSectionAtIndex:(NSInteger)oldSection toIndex:(NSInteger)newSection {
    if (!self.isReady) return;
    [(id<XZMocoaCollectionView>)self->_view collectionViewModel:self didMoveSectionAtIndex:oldSection toIndex:newSection];
}

- (void)didPerformBatchUpdates:(void (^NS_NOESCAPE)(void))batchUpdates completion:(void (^ _Nullable)(BOOL))completion {
    if (self.isReady) {
        [(id<XZMocoaCollectionView>)self->_view collectionViewModel:self didPerformBatchUpdates:batchUpdates completion:completion];
    } else {
        batchUpdates();
        if (completion) dispatch_async(dispatch_get_main_queue(), ^{ completion(YES); });
    }
}

- (Class)placeholderViewModelClassForSectionAtIndex:(NSInteger)index {
    return [XZMocoaCollectionSectionViewModel class];
}

@end
