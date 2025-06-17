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

@implementation UICollectionReusableView (XZMocoaCollectionViewSupplementaryView)

@dynamic viewModel;

+ (void)load {
    if (self == [UICollectionReusableView class]) {
        const char *encoding = xz_objc_class_getMethodTypeEncoding(self, @selector(prepareForReuse));
        xz_objc_class_addMethodWithBlock(self, @selector(prepareForReuse), encoding, nil, nil, ^id _Nonnull(SEL  _Nonnull selector) {
            return ^(UICollectionReusableView *self) {
                ((void (*)(UICollectionReusableView *, SEL))objc_msgSend)(self, selector);
                self.viewModel = nil;
            };
        });
    }
}

- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind {
    [self.viewModel collectionView:collectionView willDisplaySupplementaryView:self atIndexPath:indexPath forElementOfKind:elementKind];
}

- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath forElementOfKind:(NSString *)elementKind {
    [self.viewModel collectionView:collectionView didEndDisplayingSupplementaryView:self atIndexPath:indexPath forElementOfKind:elementKind];
}

@end
