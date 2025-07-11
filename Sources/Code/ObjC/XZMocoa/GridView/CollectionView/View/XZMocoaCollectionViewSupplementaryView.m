//
//  XZMocoaCollectionViewSupplementaryView.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import "XZMocoaCollectionViewSupplementaryView.h"
#import "XZRuntime.h"
#import <objc/runtime.h>

@implementation UICollectionReusableView (XZMocoaCollectionViewSupplementaryView)

@dynamic viewModel;

- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind {
    [self.viewModel collectionView:collectionView willDisplaySupplementaryView:self atIndexPath:indexPath forElementOfKind:elementKind];
}

- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind {
    [self.viewModel collectionView:collectionView didEndDisplayingSupplementaryView:self atIndexPath:indexPath forElementOfKind:elementKind];
}

@end
