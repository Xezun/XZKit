//
//  XZMocoaCollectionSectionSupplementaryView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGroupSectionSupplementaryView.h>
#import <XZKit/XZMocoaCollectionSectionSupplementaryViewModel.h>
#else
#import "XZMocoaGroupSectionSupplementaryView.h"
#import "XZMocoaCollectionSectionSupplementaryViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaCollectionView;

@protocol XZMocoaCollectionSectionSupplementaryView <XZMocoaGroupSectionSupplementaryView>
@optional
@property (nonatomic, strong, nullable) __kindof XZMocoaCollectionSectionSupplementaryViewModel *viewModel;
@end

@interface UICollectionReusableView (XZMocoaCollectionSectionSupplementaryView)
@property (nonatomic, strong, nullable) __kindof XZMocoaCollectionSectionSupplementaryViewModel *viewModel;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
@end

@interface UICollectionViewCell (XZMocoaCollectionSectionSupplementaryView)
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind NS_UNAVAILABLE;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
