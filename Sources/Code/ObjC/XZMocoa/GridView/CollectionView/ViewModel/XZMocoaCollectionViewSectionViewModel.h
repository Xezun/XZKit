//
//  XZMocoaCollectionViewSectionViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGridViewSectionViewModel.h>
#import <XZKit/XZMocoaCollectionViewCellViewModel.h>
#import <XZKit/XZMocoaCollectionViewSupplementaryViewModel.h>
#else
#import "XZMocoaGridViewSectionViewModel.h"
#import "XZMocoaCollectionViewCellViewModel.h"
#import "XZMocoaCollectionViewSupplementaryViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaCollectionViewSectionViewModel : XZMocoaGridViewSectionViewModel
@property (nonatomic) UIEdgeInsets insets;
@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
- (__kindof XZMocoaCollectionViewSupplementaryViewModel *)viewModelForSupplementaryElementOfKind:(XZMocoaKind)kind atIndex:(NSInteger)index;
@end

@interface XZMocoaCollectionViewSectionViewModel (XZMocoaCollectionViewSectionViewModel)
@property (nonatomic, readonly) NSDictionary<XZMocoaKind, NSArray<__kindof XZMocoaCollectionViewSupplementaryViewModel *> *> *supplementaryViewModels;
@property (nonatomic, copy, readonly) NSArray<__kindof XZMocoaCollectionViewCellViewModel *> *cellViewModels;
- (__kindof XZMocoaCollectionViewCellViewModel *)cellViewModelAtIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
