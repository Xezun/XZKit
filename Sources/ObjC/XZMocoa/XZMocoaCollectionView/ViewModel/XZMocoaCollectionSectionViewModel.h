//
//  XZMocoaCollectionSectionViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGroupSectionViewModel.h>
#import <XZKit/XZMocoaCollectionCellViewModel.h>
#import <XZKit/XZMocoaCollectionSectionSupplementaryViewModel.h>
#else
#import "XZMocoaGroupSectionViewModel.h"
#import "XZMocoaCollectionCellViewModel.h"
#import "XZMocoaCollectionSectionSupplementaryViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaCollectionSectionViewModel : XZMocoaGroupSectionViewModel
@property (nonatomic) UIEdgeInsets insets;
@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
- (__kindof XZMocoaCollectionSectionSupplementaryViewModel *)viewModelForSupplementaryElementOfKind:(XZMocoaKind)kind atIndex:(NSInteger)index;
@end

@interface XZMocoaCollectionSectionViewModel (XZMocoaCollectionSectionViewModel)
@property (nonatomic, readonly) NSDictionary<XZMocoaKind, NSArray<__kindof XZMocoaCollectionSectionSupplementaryViewModel *> *> *supplementaryViewModels;
@property (nonatomic, copy, readonly) NSArray<__kindof XZMocoaCollectionCellViewModel *> *cellViewModels;
- (__kindof XZMocoaCollectionCellViewModel *)cellViewModelAtIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
