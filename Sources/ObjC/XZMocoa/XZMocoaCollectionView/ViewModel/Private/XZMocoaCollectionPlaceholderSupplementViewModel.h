//
//  XZMocoaCollectionPlaceholderSupplementViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#import "XZMocoaCollectionSupplementViewModel.h"

NS_ASSUME_NONNULL_BEGIN
#if DEBUG
@interface XZMocoaCollectionPlaceholderSupplementViewModel : XZMocoaCollectionSupplementViewModel
@end
#else
typedef XZMocoaCollectionSupplementViewModel XZMocoaCollectionPlaceholderSupplementViewModel;
#endif

NS_ASSUME_NONNULL_END
