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

- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didUpdateForKey:(XZMocoaUpdatesKey)key atIndexPath:(NSIndexPath *)indexPath {
    if ([self conformsToProtocol:@protocol(XZMocoaCollectionViewCell) ]) {
        [((id<XZMocoaCollectionViewCell>)self).viewModel cell:(id)self didUpdateForKey:key atIndexPath:indexPath];
    }
}

@end
