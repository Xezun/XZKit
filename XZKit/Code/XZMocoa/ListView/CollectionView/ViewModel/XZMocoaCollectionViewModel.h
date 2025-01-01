//
//  XZMocoaCollectionViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaListViewModel.h"
#import "XZMocoaCollectionViewCellViewModel.h"
#import "XZMocoaCollectionViewSectionViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class XZMocoaCollectionViewModel;
@protocol XZMocoaCollectionViewModelDelegate <XZMocoaListViewModelDelegate>

@required
- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didReloadData:(void * _Nullable)null;

- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didReloadCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didInsertCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didDeleteCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didMoveCellAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didReloadSectionsAtIndexes:(NSIndexSet *)sections;
- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didInsertSectionsAtIndexes:(NSIndexSet *)sections;
- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didDeleteSectionsAtIndexes:(NSIndexSet *)sections;
- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didMoveSectionAtIndex:(NSInteger)section toIndex:(NSInteger)newSection;

- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didPerformBatchUpdates:(void (^NS_NOESCAPE)(void))batchUpdates completion:(void (^ _Nullable)(BOOL finished))completion;

@end

@interface XZMocoaCollectionViewModel : XZMocoaListViewModel
@property (nonatomic, weak) id<XZMocoaCollectionViewModelDelegate> delegate;
@end

/// 重申明
@interface XZMocoaCollectionViewModel (XZMocoaCollectionViewModel)
@property (nonatomic, readonly) NSArray<__kindof XZMocoaCollectionViewSectionViewModel *> *sectionViewModels;
- (__kindof XZMocoaCollectionViewSectionViewModel *)sectionViewModelAtIndex:(NSInteger)index;
- (__kindof XZMocoaCollectionViewCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
