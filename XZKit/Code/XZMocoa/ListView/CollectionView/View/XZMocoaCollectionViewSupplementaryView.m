//
//  XZMocoaCollectionViewSupplementaryView.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import "XZMocoaCollectionViewSupplementaryView.h"
#import <objc/runtime.h>

@implementation XZMocoaCollectionViewSupplementaryView
@synthesize viewModel = _viewModel;
- (void)setViewModel:(__kindof XZMocoaCollectionViewSupplementaryViewModel *)viewModel {
    if (_viewModel != viewModel) {
        [self viewModelWillChange];
        [viewModel ready];
        _viewModel = viewModel;
        [self viewModelDidChange];
    }
}
@end

static void xz_mocoa_copyMethod(Class const cls, SEL const target, SEL const source) {
    if (xz_objc_class_copyMethod(cls, source, nil, target)) return;
    XZLog(@"为协议 XZMocoaCollectionViewSupplementaryView 的方法 %@ 提供默认实现失败", NSStringFromSelector(target));
}

@interface UICollectionReusableView (XZMocoaCollectionViewSupplementaryView) <XZMocoaCollectionViewSupplementaryView>
@end

@implementation UICollectionReusableView (XZMocoaCollectionViewSupplementaryView)

@dynamic viewModel;

+ (void)load {
    if (self == [UICollectionReusableView class]) {
        xz_mocoa_copyMethod(self, @selector(collectionView:willDisplaySupplementaryViewAtIndexPath:), @selector(xz_mocoa_collectionView:willDisplaySupplementaryViewAtIndexPath:));
        xz_mocoa_copyMethod(self, @selector(collectionView:didEndDisplayingSupplementaryViewAtIndexPath:), @selector(xz_mocoa_collectionView:didEndDisplayingSupplementaryViewAtIndexPath:));
    }
}

- (void)xz_mocoa_collectionView:(id<XZMocoaCollectionView>)collectionView willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel collectionView:collectionView willDisplaySupplementaryViewAtIndexPath:indexPath];
}

- (void)xz_mocoa_collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel collectionView:collectionView didEndDisplayingSupplementaryViewAtIndexPath:indexPath];
}

@end
