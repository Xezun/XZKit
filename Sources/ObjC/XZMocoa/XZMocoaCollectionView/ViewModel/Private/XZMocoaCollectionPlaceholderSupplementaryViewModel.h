//
//  XZMocoaCollectionPlaceholderSupplementaryViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaCollectionSupplementaryViewModel.h>
#else
#import "XZMocoaCollectionSupplementaryViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN
#if DEBUG
@interface XZMocoaCollectionPlaceholderSupplementaryViewModel : XZMocoaCollectionSupplementaryViewModel
@end
#else
typedef XZMocoaCollectionSupplementaryViewModel XZMocoaCollectionPlaceholderSupplementaryViewModel;
#endif

NS_ASSUME_NONNULL_END
