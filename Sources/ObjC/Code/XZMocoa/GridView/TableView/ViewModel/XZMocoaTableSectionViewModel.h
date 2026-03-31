//
//  XZMocoaTableSectionViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGridSectionViewModel.h>
#import <XZKit/XZMocoaTableCellViewModel.h>
#import <XZKit/XZMocoaTableHeaderFooterViewModel.h>
#else
#import "XZMocoaGridSectionViewModel.h"
#import "XZMocoaTableCellViewModel.h"
#import "XZMocoaTableHeaderFooterViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaTableSectionViewModel : XZMocoaGridSectionViewModel

@property (nonatomic, readonly, nullable) XZMocoaTableHeaderFooterViewModel *headerViewModel;
@property (nonatomic, readonly, nullable) XZMocoaTableHeaderFooterViewModel *footerViewModel;
@property (nonatomic, readonly) CGFloat height;

@end

@interface XZMocoaTableSectionViewModel (XZMocoaTableSectionViewModel)
@property (nonatomic, readonly) NSDictionary<XZMocoaKind, NSArray<__kindof XZMocoaTableHeaderFooterViewModel *> *> *supplementaryViewModels;
@property (nonatomic, copy, readonly) NSArray<__kindof XZMocoaTableCellViewModel *> *cellViewModels;
- (__kindof XZMocoaTableCellViewModel *)cellViewModelAtIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
