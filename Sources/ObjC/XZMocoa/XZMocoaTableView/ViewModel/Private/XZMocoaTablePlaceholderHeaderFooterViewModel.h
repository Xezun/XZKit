//
//  XZMocoaTablePlaceholderHeaderFooterViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#if __has_include("XZKit.h")
#import "XZMocoaTableHeaderFooterViewModel.h"
#else
#import <XZKit/XZMocoaTableHeaderFooterViewModel.h>
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTablePlaceholderHeaderFooterViewModel : XZMocoaTableHeaderFooterViewModel
@end
#else
typedef XZMocoaTableHeaderFooterViewModel XZMocoaTablePlaceholderHeaderFooterViewModel;
#endif

NS_ASSUME_NONNULL_END
