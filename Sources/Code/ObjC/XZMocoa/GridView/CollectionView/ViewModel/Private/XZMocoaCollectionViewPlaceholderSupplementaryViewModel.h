//
//  XZMocoaCollectionViewPlaceholderSupplementaryViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaCollectionViewSupplementaryViewModel.h>
#else
#import "XZMocoaCollectionViewSupplementaryViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN
#if DEBUG
@interface XZMocoaCollectionViewPlaceholderSupplementaryViewModel : XZMocoaCollectionViewSupplementaryViewModel
@end
#else
typedef XZMocoaCollectionViewSupplementaryViewModel XZMocoaCollectionViewPlaceholderSupplementaryViewModel;
#endif

NS_ASSUME_NONNULL_END
