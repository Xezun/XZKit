//
//  XZMocoaCollectionViewSupplementaryViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import "XZMocoaCollectionViewSupplementaryViewModel.h"

@implementation XZMocoaCollectionViewSupplementaryViewModel

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    if (CGSizeEqualToSize(frame.size, size)) {
        return;
    }
    frame.size = size;
    self.frame = frame;
}

- (void)collectionView:(XZMocoaCollectionView *)collectionView willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(XZMocoaCollectionView *)collectionView didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
