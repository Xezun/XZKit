//
//  XZMocoaCollectionViewCell.m
//  XZMocoa
//
//  Created by Xezun on 2023/7/23.
//

#import "XZMocoaCollectionViewCell.h"
#import "XZMocoaModule.h"
#import "XZMocoaDefines.h"
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZRuntime.h>
#else
#import "XZRuntime.h"
#endif
#import <objc/runtime.h>

@implementation UICollectionViewCell (XZMocoaCollectionViewCell)

@dynamic viewModel;

- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel collectionView:collectionView didSelectCell:self atIndexPath:indexPath];
}

- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplayItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel collectionView:collectionView willDisplayCell:self atIndexPath:indexPath];
}

- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel collectionView:collectionView didEndDisplayingCell:self atIndexPath:indexPath];
}

@end
