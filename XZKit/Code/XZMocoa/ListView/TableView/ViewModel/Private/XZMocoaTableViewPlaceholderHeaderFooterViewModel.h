//
//  XZMocoaTableViewPlaceholderHeaderFooterViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#import "XZMocoaTableViewHeaderFooterViewModel.h"

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTableViewPlaceholderHeaderFooterViewModel : XZMocoaTableViewHeaderFooterViewModel

@end
#else
typedef XZMocoaTableViewHeaderFooterViewModel XZMocoaTableViewPlaceholderHeaderFooterViewModel;
#endif
NS_ASSUME_NONNULL_END
