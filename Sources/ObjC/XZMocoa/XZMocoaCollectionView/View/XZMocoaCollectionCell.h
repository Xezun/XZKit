//
//  XZMocoaCollectionCell.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/23.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaView.h>
#import <XZKit/XZMocoaGroupCell.h>
#import <XZKit/XZMocoaCollectionCellViewModel.h>
#else
#import "XZMocoaView.h"
#import "XZMocoaGroupCell.h"
#import "XZMocoaCollectionCellViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaCollectionView, UICollectionViewDelegate;

/// 使用 Mocoa 时，UICollectionViewCell 应遵循本协议。
/// @note
/// UICollectionViewCell 已默认实现了本协议，如需使用仅需声明遵循协议即可。
@protocol XZMocoaCollectionCell <XZMocoaGroupCell>
@optional
@property (nonatomic, strong, nullable) __kindof XZMocoaCollectionCellViewModel *viewModel;
@end

@interface UICollectionViewCell (XZMocoaCollectionCell)
@property (nonatomic, strong, nullable) __kindof XZMocoaCollectionCellViewModel *viewModel;

- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplayItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingItemAtIndexPath:(NSIndexPath*)indexPath;

@end

NS_ASSUME_NONNULL_END
