//
//  XZMocoaTablePlaceholderCellViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#import "XZMocoaTableCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTablePlaceholderCellViewModel : XZMocoaTableCellViewModel
@end
#else
typedef XZMocoaTableCellViewModel XZMocoaTablePlaceholderCellViewModel;
#endif

NS_ASSUME_NONNULL_END
