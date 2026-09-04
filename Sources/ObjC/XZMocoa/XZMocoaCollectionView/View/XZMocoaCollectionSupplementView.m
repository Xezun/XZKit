//
//  XZMocoaCollectionSupplementView.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import "XZMocoaCollectionSupplementView.h"
#import "XZRuntime.h"
#import <objc/runtime.h>

@implementation UICollectionReusableView (XZMocoaCollectionSupplementView)

@dynamic viewModel;

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind {
    [self.viewModel collectionView:collectionView willDisplaySupplementaryView:self atIndexPath:indexPath forElementOfKind:elementKind];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind {
    [self.viewModel collectionView:collectionView didEndDisplayingSupplementaryView:self atIndexPath:indexPath forElementOfKind:elementKind];
}

@end
