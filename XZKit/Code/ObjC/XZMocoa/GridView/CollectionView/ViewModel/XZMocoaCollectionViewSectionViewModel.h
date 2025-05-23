//
//  XZMocoaCollectionViewSectionViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaGridViewSectionViewModel.h"
#import "XZMocoaCollectionViewCellViewModel.h"
#import "XZMocoaCollectionViewSupplementaryViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaCollectionViewSectionViewModel : XZMocoaGridViewSectionViewModel
@property (nonatomic) UIEdgeInsets insets;
@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
- (__kindof XZMocoaCollectionViewSupplementaryViewModel *)viewModelForSupplementaryKind:(XZMocoaKind)kind atIndex:(NSInteger)index;
@end

@interface XZMocoaCollectionViewSectionViewModel (XZMocoaCollectionViewSectionViewModel)
@property (nonatomic, readonly) NSDictionary<XZMocoaKind, NSArray<__kindof XZMocoaCollectionViewSupplementaryViewModel *> *> *supplementaryViewModels;
@property (nonatomic, copy, readonly) NSArray<__kindof XZMocoaCollectionViewCellViewModel *> *cellViewModels;
- (__kindof XZMocoaCollectionViewCellViewModel *)cellViewModelAtIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
