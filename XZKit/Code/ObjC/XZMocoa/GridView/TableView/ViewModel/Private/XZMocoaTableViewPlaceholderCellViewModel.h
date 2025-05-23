//
//  XZMocoaTableViewPlaceholderCellViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#import "XZMocoaTableViewCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTableViewPlaceholderCellViewModel : XZMocoaTableViewCellViewModel
@end
#else
typedef XZMocoaTableViewCellViewModel XZMocoaTableViewPlaceholderCellViewModel;
#endif

NS_ASSUME_NONNULL_END
