//
//  XZMocoaTableViewSectionViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGridViewSectionViewModel.h>
#import <XZKit/XZMocoaTableViewCellViewModel.h>
#import <XZKit/XZMocoaTableViewHeaderFooterViewModel.h>
#else
#import "XZMocoaGridViewSectionViewModel.h"
#import "XZMocoaTableViewCellViewModel.h"
#import "XZMocoaTableViewHeaderFooterViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaTableViewSectionViewModel : XZMocoaGridViewSectionViewModel

@property (nonatomic, readonly, nullable) XZMocoaTableViewHeaderFooterViewModel *headerViewModel;
@property (nonatomic, readonly, nullable) XZMocoaTableViewHeaderFooterViewModel *footerViewModel;
@property (nonatomic, readonly) CGFloat height;

@end

@interface XZMocoaTableViewSectionViewModel (XZMocoaTableViewSectionViewModel)
@property (nonatomic, readonly) NSDictionary<XZMocoaKind, NSArray<__kindof XZMocoaTableViewHeaderFooterViewModel *> *> *supplementaryViewModels;
@property (nonatomic, copy, readonly) NSArray<__kindof XZMocoaTableViewCellViewModel *> *cellViewModels;
- (__kindof XZMocoaTableViewCellViewModel *)cellViewModelAtIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
