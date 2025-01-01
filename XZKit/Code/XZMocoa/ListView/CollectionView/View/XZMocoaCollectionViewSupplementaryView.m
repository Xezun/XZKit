//
//  XZMocoaCollectionViewSupplementaryView.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import "XZMocoaCollectionViewSupplementaryView.h"
#import <objc/runtime.h>

static void xz_mocoa_copyMethod(Class const cls, SEL const target, SEL const source) {
    if (xz_objc_class_copyMethod(cls, source, nil, target)) return;
    XZLog(@"为协议 XZMocoaCollectionViewSupplementaryView 的方法 %@ 提供默认实现失败", NSStringFromSelector(target));
}

@interface UICollectionReusableView (XZMocoaCollectionViewSupplementaryView) <XZMocoaCollectionViewSupplementaryView>
@end

@implementation UICollectionReusableView (XZMocoaCollectionViewSupplementaryView)

@dynamic viewModel;

+ (void)load {
    Class const aClass = UICollectionReusableView.class;
    if (self == aClass) {
        xz_mocoa_copyMethod(aClass, @selector(collectionView:willDisplaySupplementaryViewAtIndexPath:), @selector(xz_mocoa_collectionView:willDisplaySupplementaryViewAtIndexPath:));
        xz_mocoa_copyMethod(aClass, @selector(collectionView:didEndDisplayingSupplementaryViewAtIndexPath:), @selector(xz_mocoa_collectionView:didEndDisplayingSupplementaryViewAtIndexPath:));
    }
}

- (void)xz_mocoa_collectionView:(XZMocoaCollectionView *)collectionView willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel collectionView:collectionView willDisplaySupplementaryViewAtIndexPath:indexPath];
}

- (void)xz_mocoa_collectionView:(XZMocoaCollectionView *)collectionView didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel collectionView:collectionView didEndDisplayingSupplementaryViewAtIndexPath:indexPath];
}

@end

@implementation XZMocoaCollectionViewSupplementaryView
@dynamic viewModel;
@end


