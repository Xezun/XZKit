//
//  XZMocoaCollectionViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGroupViewModel.h>
#import <XZKit/XZMocoaCollectionCellViewModel.h>
#import <XZKit/XZMocoaCollectionSectionViewModel.h>
#else
#import "XZMocoaGroupViewModel.h"
#import "XZMocoaCollectionCellViewModel.h"
#import "XZMocoaCollectionSectionViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class XZMocoaCollectionViewModel;

@protocol XZMocoaCollectionViewModelDelegate <XZMocoaGroupViewModelDelegate>
@required
- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didReloadData:(void * _Nullable)null;

- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didSelectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition;
- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didDeselectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

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

@interface XZMocoaCollectionViewModel : XZMocoaGroupViewModel

@property (nonatomic, weak) id<XZMocoaCollectionViewModelDelegate> delegate;

@end

/// 重申明
@interface XZMocoaCollectionViewModel (XZMocoaCollectionViewModel)
@property (nonatomic, readonly) NSArray<__kindof XZMocoaCollectionSectionViewModel *> *sectionViewModels;
- (__kindof XZMocoaCollectionSectionViewModel *)sectionViewModelAtIndex:(NSInteger)index;
- (__kindof XZMocoaCollectionCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath;

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition;
- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition;

@end

NS_ASSUME_NONNULL_END
