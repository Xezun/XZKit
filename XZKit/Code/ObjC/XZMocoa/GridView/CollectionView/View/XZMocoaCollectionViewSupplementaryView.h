//
//  XZMocoaCollectionViewSupplementaryView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import <UIKit/UIKit.h>
#import "XZMocoaView.h"
#import "XZMocoaCollectionViewSupplementaryViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaCollectionView;

@protocol XZMocoaCollectionViewSupplementaryView <XZMocoaView>
@optional
@property (nonatomic, strong, nullable) __kindof XZMocoaCollectionViewSupplementaryViewModel *viewModel;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath*)indexPath;
@end

@interface UICollectionReusableView (XZMocoaCollectionViewSupplementaryView)
@property (nonatomic, strong, nullable) __kindof XZMocoaCollectionViewSupplementaryViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
