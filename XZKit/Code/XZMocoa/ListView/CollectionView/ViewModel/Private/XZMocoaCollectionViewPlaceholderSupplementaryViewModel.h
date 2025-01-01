//
//  XZMocoaCollectionViewPlaceholderSupplementaryViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#import "XZMocoaCollectionViewSupplementaryViewModel.h"

NS_ASSUME_NONNULL_BEGIN
#if DEBUG
@interface XZMocoaCollectionViewPlaceholderSupplementaryViewModel : XZMocoaCollectionViewSupplementaryViewModel
@end
#else
typedef XZMocoaCollectionViewSupplementaryViewModel XZMocoaCollectionViewPlaceholderSupplementaryViewModel;
#endif

NS_ASSUME_NONNULL_END
