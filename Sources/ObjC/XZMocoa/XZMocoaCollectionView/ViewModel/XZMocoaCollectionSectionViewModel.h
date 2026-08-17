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
/// 默认值 UIEdgeInsetsNull 标识符优先使用代理或 UICollectionViewLayout 的预设值。
@property (nonatomic) UIEdgeInsets insets;
/// 默认值 CGFloatNull 标识符优先使用代理或 UICollectionViewLayout 的预设值。
@property (nonatomic) CGFloat minimumLineSpacing;
/// 默认值 CGFloatNull 标识符优先使用代理或 UICollectionViewLayout 的预设值。
@property (nonatomic) CGFloat minimumInteritemSpacing;
- (__kindof XZMocoaCollectionSectionSupplementaryViewModel *)viewModelForSupplementaryElementOfKind:(XZMocoaKind)kind atIndex:(NSInteger)index;
@end

@interface XZMocoaCollectionSectionViewModel (XZMocoaCollectionSectionViewModel)
@property (nonatomic, readonly) NSDictionary<XZMocoaKind, NSArray<__kindof XZMocoaCollectionSectionSupplementaryViewModel *> *> *supplementaryViewModels;
@property (nonatomic, copy, readonly) NSArray<__kindof XZMocoaCollectionCellViewModel *> *cellViewModels;
- (__kindof XZMocoaCollectionCellViewModel *)cellViewModelAtIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
