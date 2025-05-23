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

@implementation XZMocoaCollectionViewCell
@synthesize viewModel = _viewModel;
- (void)setViewModel:(__kindof XZMocoaCollectionViewCellViewModel *)viewModel {
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
    XZLog(@"为协议 XZMocoaCollectionViewCell 的方法 %@ 提供默认实现失败", NSStringFromSelector(target));
}

@interface UICollectionViewCell (XZMocoaCollectionViewCell)
@end

@implementation UICollectionViewCell (XZMocoaCollectionViewCell)

+ (void)load {
    if (self == [UICollectionViewCell class]) {
        xz_mocoa_copyMethod(self, @selector(collectionView:didSelectItemAtIndexPath:), @selector(xz_mocoa_collectionView:didSelectItemAtIndexPath:));
        xz_mocoa_copyMethod(self, @selector(collectionView:willDisplayItemAtIndexPath:), @selector(xz_mocoa_collectionView:willDisplayItemAtIndexPath:));
        xz_mocoa_copyMethod(self, @selector(collectionView:didEndDisplayingItemAtIndexPath:), @selector(xz_mocoa_collectionView:didEndDisplayingItemAtIndexPath:));
    }
}

- (void)xz_mocoa_collectionView:(id<XZMocoaCollectionView>)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self conformsToProtocol:@protocol(XZMocoaCollectionViewCell) ]) {
        [((id<XZMocoaCollectionViewCell>)self).viewModel collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}

- (void)xz_mocoa_collectionView:(id<XZMocoaCollectionView>)collectionView willDisplayItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self conformsToProtocol:@protocol(XZMocoaCollectionViewCell) ]) {
        [((id<XZMocoaCollectionViewCell>)self).viewModel collectionView:collectionView willDisplayItemAtIndexPath:indexPath];
    }
}

- (void)xz_mocoa_collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self conformsToProtocol:@protocol(XZMocoaCollectionViewCell) ]) {
        [((id<XZMocoaCollectionViewCell>)self).viewModel collectionView:collectionView didEndDisplayingItemAtIndexPath:indexPath];
    }
}

@end
