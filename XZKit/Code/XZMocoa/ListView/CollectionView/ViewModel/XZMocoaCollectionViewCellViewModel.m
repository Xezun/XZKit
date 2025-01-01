//
//  XZMocoaCollectionViewCellViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaCollectionViewCellViewModel.h"

@implementation XZMocoaCollectionViewCellViewModel

- (instancetype)initWithModel:(id)model {
    self = [super initWithModel:model];
    if (self) {
        [super setFrame:(CGRect){CGPointZero, XZMocoaViewMinimumSize}];
    }
    return self;
}

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

- (void)collectionView:(XZMocoaCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(XZMocoaCollectionView *)collectionView willDisplayItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(XZMocoaCollectionView *)collectionView didEndDisplayingItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
