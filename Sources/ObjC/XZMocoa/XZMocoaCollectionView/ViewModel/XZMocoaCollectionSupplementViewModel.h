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
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)supplementaryView atIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)supplementaryView atIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
@end


@interface XZMocoaCollectionHeaderFooterViewModel : XZMocoaCollectionSupplementViewModel
@end

@interface XZMocoaCollectionHeaderViewModel : XZMocoaCollectionHeaderFooterViewModel
@end

@interface XZMocoaCollectionFooterViewModel : XZMocoaCollectionHeaderFooterViewModel
@end

NS_ASSUME_NONNULL_END
