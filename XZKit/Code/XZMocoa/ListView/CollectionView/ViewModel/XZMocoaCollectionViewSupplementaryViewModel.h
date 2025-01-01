//
//  XZMocoaCollectionViewSupplementaryViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import "XZMocoaListViewSupplementaryViewModel.h"

@class XZMocoaCollectionView;

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaCollectionViewSupplementaryViewModel : XZMocoaListViewSupplementaryViewModel

@property (nonatomic) CGSize size;

- (void)collectionView:(XZMocoaCollectionView *)collectionView willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(XZMocoaCollectionView *)collectionView didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
