//
//  XZMocoaCollectionSupplementView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGroupSupplementView.h>
#import <XZKit/XZMocoaCollectionSupplementViewModel.h>
#else
#import "XZMocoaGroupSupplementView.h"
#import "XZMocoaCollectionSupplementViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaCollectionView;

@protocol XZMocoaCollectionSupplementView <XZMocoaGroupSupplementView>
@optional
@property (nonatomic, strong, nullable) __kindof XZMocoaCollectionSupplementViewModel *viewModel;
@end

@interface UICollectionReusableView (XZMocoaCollectionSupplementView)
@property (nonatomic, strong, nullable) __kindof XZMocoaCollectionSupplementViewModel *viewModel;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
@end

@interface UICollectionViewCell (XZMocoaCollectionSupplementView)
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind NS_UNAVAILABLE;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
