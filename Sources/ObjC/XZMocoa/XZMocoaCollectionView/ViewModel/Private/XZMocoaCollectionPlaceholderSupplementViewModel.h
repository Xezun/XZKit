//
//  XZMocoaCollectionPlaceholderSupplementViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaCollectionSupplementViewModel.h>
#else
#import "XZMocoaCollectionSupplementViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN
#if DEBUG
@interface XZMocoaCollectionPlaceholderSupplementViewModel : XZMocoaCollectionSupplementViewModel
@end
#else
typedef XZMocoaCollectionSupplementViewModel XZMocoaCollectionPlaceholderSupplementViewModel;
#endif

NS_ASSUME_NONNULL_END
