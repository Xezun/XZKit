//
//  XZMocoaCollectionView.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/24.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGroupView.h>
#import <XZKit/XZMocoaCollectionViewModel.h>
#else
#import "XZMocoaGroupView.h"
#import "XZMocoaCollectionViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaCollectionView <XZMocoaGroupView>
@required
@property (nonatomic, strong) IBOutlet UICollectionView *contentView;
@property (nonatomic, strong, nullable) XZMocoaCollectionViewModel *viewModel;
- (void)collectionViewModel:(XZMocoaCollectionViewModel *)collectionViewModel didReloadData:(void * _Nullable)null;

- (void)collectionViewModel:(XZMocoaCollectionViewModel *)tableViewModel didSelectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition;
- (void)collectionViewModel:(XZMocoaCollectionViewModel *)tableViewModel didDeselectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

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

@interface XZMocoaCollectionView : XZMocoaGroupView
- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCollectionViewClass:(Class)collectionViewClass layout:(UICollectionViewLayout *)layout NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithLayout:(UICollectionViewLayout *)layout;
- (instancetype)initWithFrame:(CGRect)frame layout:(UICollectionViewLayout *)layout;
- (instancetype)initWithFrame:(CGRect)frame;
@end

// 以下由 XZMocoaCollectionViewProxy 动态实现。

@interface XZMocoaCollectionView (XZMocoaCollectionView) <XZMocoaCollectionView>
@end
@interface XZMocoaCollectionView (UICollectionViewDelegate) <UICollectionViewDelegate>
@end
@interface XZMocoaCollectionView (UICollectionViewDataSource) <UICollectionViewDataSource>
@end
@interface XZMocoaCollectionView (UICollectionViewDelegateFlowLayout) <UICollectionViewDelegateFlowLayout>
@end

NS_ASSUME_NONNULL_END
