//
//  XZMocoaCollectionViewCellViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaGridViewCellViewModel.h"

@protocol XZMocoaCollectionView, XZMocoaCollectionViewCell;

NS_ASSUME_NONNULL_BEGIN

/// UICollectionViewCell 视图模型基类。
@interface XZMocoaCollectionViewCellViewModel : XZMocoaGridViewCellViewModel

@property (nonatomic) CGSize size;

- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didSelectCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplayCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath*)indexPath;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didUpdateCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath forKey:(XZMocoaUpdatesKey)key;

@end


NS_ASSUME_NONNULL_END
