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

@class XZMocoaCollectionView;

@protocol XZMocoaCollectionViewSupplementaryView <XZMocoaView>
@optional
@property (nonatomic, strong, nullable) __kindof XZMocoaCollectionViewSupplementaryViewModel *viewModel;
- (void)collectionView:(XZMocoaCollectionView *)collectionView willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(XZMocoaCollectionView *)collectionView didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath*)indexPath;
@end

/// 因一致性而提供，非必须基类。
/// @note 任何 UICollectionReusableView 对象都可以作为 Mocoa 的 View 实例，而非必须基于此类。
@interface XZMocoaCollectionViewSupplementaryView : UICollectionReusableView <XZMocoaCollectionViewSupplementaryView>
@end

NS_ASSUME_NONNULL_END
