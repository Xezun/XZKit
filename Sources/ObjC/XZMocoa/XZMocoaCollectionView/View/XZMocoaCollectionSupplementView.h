//
//  XZMocoaCollectionSupplementView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import <UIKit/UIKit.h>
#import "XZMocoaGroupReusableView.h"
#import "XZMocoaCollectionCellViewModel.h"
#import "XZMocoaCollectionSupplementViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaCollectionView;

typedef UICollectionReusableView XZMocoaCollectionSupplementView;

@interface UICollectionReusableView (XZMocoaCollectionSupplementView)
@property (nonatomic, strong, nullable) __kindof XZMocoaCollectionSupplementViewModel *viewModel;
- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
@end

/// 为 Cell 禁用属于 supplement 的方法。
@interface UICollectionViewCell (XZMocoaCollectionSupplementView)
- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind NS_UNAVAILABLE;
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
