//
//  XZMocoaTablePlaceholderSectionHeaderFooterViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaTableSectionHeaderFooterViewModel.h>
#else
#import "XZMocoaTableSectionHeaderFooterViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTablePlaceholderSectionHeaderFooterViewModel : XZMocoaTableSectionHeaderFooterViewModel
@end
#else
typedef XZMocoaTableSectionHeaderFooterViewModel XZMocoaTablePlaceholderSectionHeaderFooterViewModel;
#endif
NS_ASSUME_NONNULL_END
