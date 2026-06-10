//
//  XZMocoaCollectionSupplementaryView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGroupSupplementaryView.h>
#import <XZKit/XZMocoaCollectionSupplementaryViewModel.h>
#else
#import "XZMocoaGroupSupplementaryView.h"
#import "XZMocoaCollectionSupplementaryViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaCollectionView;

@protocol XZMocoaCollectionSupplementaryView <XZMocoaGroupSupplementaryView>
@optional
@property (nonatomic, strong, nullable) __kindof XZMocoaCollectionSupplementaryViewModel *viewModel;
@end

@interface UICollectionReusableView (XZMocoaCollectionSupplementaryView)
@property (nonatomic, strong, nullable) __kindof XZMocoaCollectionSupplementaryViewModel *viewModel;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
@end

@interface UICollectionViewCell (XZMocoaCollectionSupplementaryView)
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind NS_UNAVAILABLE;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
