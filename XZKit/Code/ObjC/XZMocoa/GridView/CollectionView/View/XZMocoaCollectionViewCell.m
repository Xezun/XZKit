//
//  XZMocoaCollectionViewCell.m
//  XZMocoa
//
//  Created by Xezun on 2023/7/23.
//

#import "XZMocoaCollectionViewCell.h"
#import "XZMocoaModule.h"
#import "XZMocoaDefines.h"
#import <objc/runtime.h>
#if __has_include(<XZDefines/XZRuntime.h>)
#import <XZDefines/XZRuntime.h>
#else
#import "XZRuntime.h"
#endif

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

- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didUpdateRowAtIndexPath:(NSIndexPath *)indexPath forKey:(XZMocoaUpdatesKey)key {
    [self.viewModel collectionView:collectionView didUpdateCell:self atIndexPath:indexPath forKey:key];
}

@end
