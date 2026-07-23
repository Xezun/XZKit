//
//  XZMocoaCollectionPlaceholderSectionSupplementaryViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaCollectionSectionSupplementaryViewModel.h>
#else
#import "XZMocoaCollectionSectionSupplementaryViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN
#if DEBUG
@interface XZMocoaCollectionPlaceholderSectionSupplementaryViewModel : XZMocoaCollectionSectionSupplementaryViewModel
@end
#else
typedef XZMocoaCollectionSectionSupplementaryViewModel XZMocoaCollectionPlaceholderSectionSupplementaryViewModel;
#endif

NS_ASSUME_NONNULL_END
