//
//  XZMocoaCollectionViewSupplementaryView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import <UIKit/UIKit.h>
#import "XZMocoaGridViewSupplementaryView.h"
#import "XZMocoaCollectionViewSupplementaryViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaCollectionView;

@protocol XZMocoaCollectionViewSupplementaryView <XZMocoaGridViewSupplementaryView>
@optional
@property (nonatomic, strong, nullable) __kindof XZMocoaCollectionViewSupplementaryViewModel *viewModel;
@end

@interface UICollectionReusableView (XZMocoaCollectionViewSupplementaryView)
@property (nonatomic, strong, nullable) __kindof XZMocoaCollectionViewSupplementaryViewModel *viewModel;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
@end

@interface UICollectionViewCell (XZMocoaCollectionViewSupplementaryView)
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind NS_UNAVAILABLE;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
