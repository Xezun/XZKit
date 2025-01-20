//
//  XZMocoaCollectionViewProxy.h
//  XZKit
//
//  Created by 徐臻 on 2025/1/20.
//

#import <Foundation/Foundation.h>
#import "XZMocoaCollectionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaCollectionViewProxy : NSProxy <XZMocoaCollectionView>
@property (nonatomic, unsafe_unretained, readonly) id<XZMocoaCollectionView> collectionView;
@property (nonatomic, strong, nullable) XZMocoaCollectionViewModel *viewModel;
@property (nonatomic, weak) id<UICollectionViewDelegate> delegate;
@property (nonatomic, weak) id<UICollectionViewDataSource> dataSource;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCollectionView:(id<XZMocoaCollectionView>)collectionView;
@end

@interface XZMocoaCollectionViewProxy (UICollectionViewDelegate) <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
@end

@interface XZMocoaCollectionViewProxy (UICollectionViewDataSource) <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
@end

@interface XZMocoaCollectionViewProxy (UICollectionViewDelegateFlowLayout) <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;
@end

@interface XZMocoaCollectionViewProxy (XZMocoaCollectionViewModelDelegate) <XZMocoaCollectionViewModelDelegate>
@end

NS_ASSUME_NONNULL_END
