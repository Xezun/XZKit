//
//  XZMocoaCollectionViewSupplementaryViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGridViewSupplementaryViewModel.h>
#else
#import "XZMocoaGridViewSupplementaryViewModel.h"
#endif

@protocol XZMocoaCollectionView, XZMocoaCollectionViewSupplementaryView;

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaCollectionViewSupplementaryViewModel : XZMocoaGridViewSupplementaryViewModel

@property (nonatomic) CGSize size;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)supplementaryView atIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)supplementaryView atIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind;
@end


@interface XZMocoaCollectionViewHeaderFooterViewModel : XZMocoaCollectionViewSupplementaryViewModel
@end

@interface XZMocoaCollectionViewHeaderViewModel : XZMocoaCollectionViewHeaderFooterViewModel
@end

@interface XZMocoaCollectionViewFooterViewModel : XZMocoaCollectionViewHeaderFooterViewModel
@end

NS_ASSUME_NONNULL_END
