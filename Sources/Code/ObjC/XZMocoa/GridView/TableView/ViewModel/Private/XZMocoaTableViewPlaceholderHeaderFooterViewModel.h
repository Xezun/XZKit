//
//  XZMocoaTableViewPlaceholderHeaderFooterViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaTableViewHeaderFooterViewModel.h>
#else
#import "XZMocoaTableViewHeaderFooterViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTableViewPlaceholderHeaderFooterViewModel : XZMocoaTableViewHeaderFooterViewModel
@end
#else
typedef XZMocoaTableViewHeaderFooterViewModel XZMocoaTableViewPlaceholderHeaderFooterViewModel;
#endif
NS_ASSUME_NONNULL_END
