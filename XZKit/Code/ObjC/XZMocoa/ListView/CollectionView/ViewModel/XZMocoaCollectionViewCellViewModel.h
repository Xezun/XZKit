//
//  XZMocoaCollectionViewCellViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaListViewCellViewModel.h"

@protocol XZMocoaCollectionView;

NS_ASSUME_NONNULL_BEGIN

/// UICollectionViewCell 视图模型基类。
@interface XZMocoaCollectionViewCellViewModel : XZMocoaListViewCellViewModel

@property (nonatomic) CGSize size;

- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplayItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingItemAtIndexPath:(NSIndexPath*)indexPath;
@end

NS_ASSUME_NONNULL_END
