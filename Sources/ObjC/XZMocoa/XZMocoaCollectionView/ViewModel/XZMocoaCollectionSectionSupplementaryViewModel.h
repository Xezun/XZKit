//
//  XZMocoaCollectionSectionSupplementaryViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGroupSupplementViewModel.h>
#else
#import "XZMocoaGroupSupplementViewModel.h"
#endif

@protocol XZMocoaCollectionView, XZMocoaCollectionSectionSupplementaryView;

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaCollectionSectionSupplementaryViewModel : XZMocoaGroupSupplementViewModel

@property (nonatomic) CGSize size;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)supplementaryView atIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)supplementaryView atIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
@end


@interface XZMocoaCollectionHeaderFooterViewModel : XZMocoaCollectionSectionSupplementaryViewModel
@end

@interface XZMocoaCollectionHeaderViewModel : XZMocoaCollectionHeaderFooterViewModel
@end

@interface XZMocoaCollectionFooterViewModel : XZMocoaCollectionHeaderFooterViewModel
@end

NS_ASSUME_NONNULL_END
