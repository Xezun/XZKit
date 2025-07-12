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
        [super setFrame:(CGRect){CGPointZero, XZMocoaMinimumViewSize}];
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

- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didSelectCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplayCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath*)indexPath {
    
}

@end
