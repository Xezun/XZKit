//
//  XZMocoaCollectionCell.m
//  XZMocoa
//
//  Created by Xezun on 2023/7/23.
//

#import "XZMocoaCollectionCell.h"
#import "XZMocoaModule.h"
#import "XZMocoaDefines.h"
#import "XZRuntime.h"
#import <objc/runtime.h>

@implementation UICollectionViewCell (XZMocoaCollectionCell)

@dynamic viewModel;

- (void)collectionView:(XZMocoaCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel collectionViewCell:self wasSelectedAtIndexPath:indexPath];
}

- (void)collectionView:(XZMocoaCollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel collectionViewCell:self wasDeselectedAtIndexPath:indexPath];
}

- (void)collectionView:(XZMocoaCollectionView *)collectionView willDisplayItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel collectionViewCell:self willBeDisplayedAtIndexPath:indexPath];
}

- (void)collectionView:(XZMocoaCollectionView *)collectionView didEndDisplayingItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel collectionViewCell:self wasEndedDisplayingAtIndexPath:indexPath];
}

@end
