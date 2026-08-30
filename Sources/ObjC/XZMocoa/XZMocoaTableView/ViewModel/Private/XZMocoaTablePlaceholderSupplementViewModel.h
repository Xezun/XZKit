//
//  XZMocoaTablePlaceholderSupplementViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#import "XZMocoaTableSupplementViewModel.h"

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTablePlaceholderSupplementViewModel : XZMocoaTableSupplementViewModel
@end
#else
typedef XZMocoaTableSupplementViewModel XZMocoaTablePlaceholderSupplementViewModel;
#endif
NS_ASSUME_NONNULL_END
