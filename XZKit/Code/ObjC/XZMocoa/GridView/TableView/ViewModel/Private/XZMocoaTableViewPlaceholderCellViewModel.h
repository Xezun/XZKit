//
//  XZMocoaTableViewPlaceholderCellViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaTableViewCellViewModel.h>
#else
#import "XZMocoaTableViewCellViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTableViewPlaceholderCellViewModel : XZMocoaTableViewCellViewModel
@end
#else
typedef XZMocoaTableViewCellViewModel XZMocoaTableViewPlaceholderCellViewModel;
#endif

NS_ASSUME_NONNULL_END
