//
//  XZMocoaCollectionViewSupplementaryView.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import "XZMocoaCollectionViewSupplementaryView.h"
#import <objc/runtime.h>
#if __has_include(<XZDefines/XZRuntime.h>)
#import <XZDefines/XZRuntime.h>
#else
#import "XZRuntime.h"
#endif

static void xz_mocoa_addMethod(Class const cls, SEL const target, SEL const source) {
    if (xz_objc_class_copyMethod(cls, source, nil, target)) return;
    XZLog(@"为协议 XZMocoaCollectionViewSupplementaryView 的方法 %@ 提供默认实现失败", NSStringFromSelector(target));
}

@implementation UICollectionReusableView (XZMocoaCollectionViewSupplementaryView)

@dynamic viewModel;

+ (void)load {
    if (self == [UICollectionReusableView class]) {
        xz_mocoa_addMethod(self, @selector(collectionView:willDisplaySupplementaryViewAtIndexPath:), @selector(xz_mocoa_collectionView:willDisplaySupplementaryViewAtIndexPath:));
        xz_mocoa_addMethod(self, @selector(collectionView:didEndDisplayingSupplementaryViewAtIndexPath:), @selector(xz_mocoa_collectionView:didEndDisplayingSupplementaryViewAtIndexPath:));
    }
}

- (void)xz_mocoa_collectionView:(id<XZMocoaCollectionView>)collectionView willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel collectionView:collectionView willDisplaySupplementaryViewAtIndexPath:indexPath];
}

- (void)xz_mocoa_collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel collectionView:collectionView didEndDisplayingSupplementaryViewAtIndexPath:indexPath];
}

@end
