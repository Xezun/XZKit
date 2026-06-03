//
//  XZMocoaCollectionViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGroupViewModel.h>
#import <XZKit/XZMocoaCollectionCellViewModel.h>
#import <XZKit/XZMocoaCollectionSectionViewModel.h>
#else
#import "XZMocoaGroupViewModel.h"
#import "XZMocoaCollectionCellViewModel.h"
#import "XZMocoaCollectionSectionViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class XZMocoaCollectionViewModel;

@interface XZMocoaCollectionViewModel : XZMocoaGroupViewModel
@end

/// 重申明
@interface XZMocoaCollectionViewModel (XZMocoaCollectionViewModel)
@property (nonatomic, readonly) NSArray<__kindof XZMocoaCollectionSectionViewModel *> *sectionViewModels;
- (__kindof XZMocoaCollectionSectionViewModel *)sectionViewModelAtIndex:(NSInteger)index;
- (__kindof XZMocoaCollectionCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath;

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition;
- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition;

@end

NS_ASSUME_NONNULL_END
