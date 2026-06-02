//
//  XZMocoaCollectionSupplementaryViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGridSupplementaryViewModel.h>
#else
#import "XZMocoaGridSupplementaryViewModel.h"
#endif

@protocol XZMocoaCollectionView, XZMocoaCollectionSupplementaryView;

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaCollectionSupplementaryViewModel : XZMocoaGridSupplementaryViewModel

@property (nonatomic) CGSize size;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)supplementaryView atIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)supplementaryView atIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
@end


@interface XZMocoaCollectionHeaderFooterViewModel : XZMocoaCollectionSupplementaryViewModel
@end

@interface XZMocoaCollectionHeaderViewModel : XZMocoaCollectionHeaderFooterViewModel
@end

@interface XZMocoaCollectionFooterViewModel : XZMocoaCollectionHeaderFooterViewModel
@end

NS_ASSUME_NONNULL_END
