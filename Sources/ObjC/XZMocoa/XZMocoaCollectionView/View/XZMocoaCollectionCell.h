//
//  XZMocoaCollectionCell.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/23.
//

#import "XZMocoaView.h"
#import "XZMocoaGroupCell.h"
#import "XZMocoaCollectionCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class XZMocoaCollectionView;

/// 使用 Mocoa 时，UICollectionViewCell 应遵循本协议。
/// @note
/// UICollectionViewCell 已默认实现了本协议，如需使用仅需声明遵循协议即可。
@protocol XZMocoaCollectionCell <XZMocoaGroupCell>
@optional
@property (nonatomic, strong, nullable) __kindof XZMocoaCollectionCellViewModel *viewModel;
@end

@interface UICollectionViewCell (XZMocoaCollectionCell)
@property (nonatomic, strong, nullable) __kindof XZMocoaCollectionCellViewModel *viewModel;

- (void)collectionView:(XZMocoaCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(XZMocoaCollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(XZMocoaCollectionView *)collectionView willDisplayItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(XZMocoaCollectionView *)collectionView didEndDisplayingItemAtIndexPath:(NSIndexPath*)indexPath;

@end

NS_ASSUME_NONNULL_END
