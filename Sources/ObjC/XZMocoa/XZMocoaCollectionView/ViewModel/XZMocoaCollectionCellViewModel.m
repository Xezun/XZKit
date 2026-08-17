//
//  XZMocoaCollectionCellViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaCollectionCellViewModel.h"
#import "XZGeometry.h"

@implementation XZMocoaCollectionCellViewModel

- (instancetype)initWithModel:(id)model {
    self = [super initWithModel:model];
    if (self) {
        CGRect frame = CGRectNull;
        frame.size = CGSizeNull;
        [super setFrame:frame];
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

- (void)collectionViewCell:(UICollectionViewCell *)cell wasSelectedAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionViewCell:(UICollectionViewCell *)cell wasDeselectedAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionViewCell:(UICollectionViewCell *)cell willBeDisplayedAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionViewCell:(UICollectionViewCell *)cell wasEndedDisplayingAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
