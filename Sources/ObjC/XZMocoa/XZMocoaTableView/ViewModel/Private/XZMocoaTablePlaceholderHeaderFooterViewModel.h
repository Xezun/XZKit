//
//  XZMocoaTablePlaceholderHeaderFooterViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#import "XZMocoaTableHeaderFooterViewModel.h"

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTablePlaceholderHeaderFooterViewModel : XZMocoaTableHeaderFooterViewModel
@end
#else
typedef XZMocoaTableHeaderFooterViewModel XZMocoaTablePlaceholderHeaderFooterViewModel;
#endif

NS_ASSUME_NONNULL_END
