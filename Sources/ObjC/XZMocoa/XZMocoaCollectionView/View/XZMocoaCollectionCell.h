//
//  XZMocoaCollectionCell.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/23.
//

#if __has_include("XZKit.h")
#import "XZMocoaView.h"
#import "XZMocoaGroupReusableView.h"
#import "XZMocoaCollectionCellViewModel.h"
#else
#import <XZKit/XZMocoaView.h>
#import <XZKit/XZMocoaGroupReusableView.h>
#import <XZKit/XZMocoaCollectionCellViewModel.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class XZMocoaCollectionView;

typedef UICollectionView XZMocoaCollectionCell;

@interface UICollectionViewCell (XZMocoaCollectionCell)

@property (nonatomic, strong, nullable) __kindof XZMocoaCollectionCellViewModel *viewModel;

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView willDisplayItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingItemAtIndexPath:(NSIndexPath*)indexPath;

@end

NS_ASSUME_NONNULL_END
