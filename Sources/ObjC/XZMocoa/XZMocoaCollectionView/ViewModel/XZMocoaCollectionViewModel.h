//
//  XZMocoaCollectionViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#if __has_include("XZKit.h")
#import "XZMocoaGroupViewModel.h"
#import "XZMocoaCollectionCellViewModel.h"
#else
#import <XZKit/XZMocoaGroupViewModel.h>
#import <XZKit/XZMocoaCollectionCellViewModel.h>
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

// 布局优先级：
// 1. XZMocoaCollectionView.delegate
// 2. XZMocoaCollectionCellViewModel.size、XZMocoaCollectionSupplementViewModel.size
// 3. XZMocoaCollectionViewModel 的如下属性。
// 4. UICollectionViewFlowLayout 的属性。
//
// 如下属性的初始值为对应类型的 Null 值，比如 CGFloatNull、CGSizeNull 等。

@property (nonatomic) CGSize itemSize;
@property (nonatomic) UIEdgeInsets sectionInsets;
@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) CGSize headerReferenceSize;
@property (nonatomic) CGSize footerReferenceSize;

@end

@interface XZMocoaCollectionViewModel (XZMocoaCollectionViewModel)
- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition;
- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition;
@end

NS_ASSUME_NONNULL_END
