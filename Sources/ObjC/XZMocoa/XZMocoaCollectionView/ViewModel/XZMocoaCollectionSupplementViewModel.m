//
//  XZMocoaCollectionSupplementViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import "XZMocoaCollectionSupplementViewModel.h"
#import "XZGeometry.h"

@implementation XZMocoaCollectionSupplementViewModel

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

- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)supplementaryView atIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind {
    
}

- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)supplementaryView atIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind {
    
}

@end


@implementation XZMocoaCollectionHeaderFooterViewModel
@end

@implementation XZMocoaCollectionHeaderViewModel
@end

@implementation XZMocoaCollectionFooterViewModel
@end
