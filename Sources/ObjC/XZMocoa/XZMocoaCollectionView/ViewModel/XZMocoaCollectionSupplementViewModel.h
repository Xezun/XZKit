//
//  XZMocoaCollectionSupplementViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import "XZMocoaGroupReusableViewModel.h"

@protocol XZMocoaCollectionView, XZMocoaCollectionSupplementView;

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaCollectionSupplementViewModel : XZMocoaGroupReusableViewModel
@property (nonatomic) CGSize size;
- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)supplementaryView atIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)supplementaryView atIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
@end

typedef XZMocoaCollectionSupplementViewModel XZMocoaCollectionHeaderViewModel;
typedef XZMocoaCollectionSupplementViewModel XZMocoaCollectionFooterViewModel;

NS_ASSUME_NONNULL_END
