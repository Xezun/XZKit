//
//  XZMocoaCollectionViewSupplementaryViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import "XZMocoaGridViewSupplementaryViewModel.h"

@protocol XZMocoaCollectionView, XZMocoaCollectionViewSupplementaryView;

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaCollectionViewSupplementaryViewModel : XZMocoaGridViewSupplementaryViewModel

@property (nonatomic) CGSize size;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)supplementaryView atIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)supplementaryView atIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
@end

NS_ASSUME_NONNULL_END
