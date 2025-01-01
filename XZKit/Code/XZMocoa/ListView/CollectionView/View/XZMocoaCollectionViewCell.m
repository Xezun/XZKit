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

static void xz_mocoa_copyMethod(Class const cls, SEL const target, SEL const source) {
    if (xz_objc_class_copyMethod(cls, source, nil, target)) return;
    XZLog(@"为协议 XZMocoaCollectionViewCell 的方法 %@ 提供默认实现失败", NSStringFromSelector(target));
}

@interface UICollectionViewCell (XZMocoaCollectionViewCell) <XZMocoaCollectionViewCell>
@end

@implementation UICollectionViewCell (XZMocoaCollectionViewCell)

@dynamic viewModel;

+ (void)load {
    Class const aClass = UICollectionViewCell.class;
    if (self == aClass) {
        xz_mocoa_copyMethod(aClass, @selector(collectionView:didSelectItemAtIndexPath:), @selector(xz_mocoa_collectionView:didSelectItemAtIndexPath:));
        xz_mocoa_copyMethod(aClass, @selector(collectionView:willDisplayItemAtIndexPath:), @selector(xz_mocoa_collectionView:willDisplayItemAtIndexPath:));
        xz_mocoa_copyMethod(aClass, @selector(collectionView:didEndDisplayingItemAtIndexPath:), @selector(xz_mocoa_collectionView:didEndDisplayingItemAtIndexPath:));
    }
}

- (void)xz_mocoa_collectionView:(XZMocoaCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

- (void)xz_mocoa_collectionView:(XZMocoaCollectionView *)collectionView willDisplayItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel collectionView:collectionView willDisplayItemAtIndexPath:indexPath];
}

- (void)xz_mocoa_collectionView:(XZMocoaCollectionView *)collectionView didEndDisplayingItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel collectionView:collectionView didEndDisplayingItemAtIndexPath:indexPath];
}

@end


@implementation XZMocoaCollectionViewCell
@dynamic viewModel;
@end

