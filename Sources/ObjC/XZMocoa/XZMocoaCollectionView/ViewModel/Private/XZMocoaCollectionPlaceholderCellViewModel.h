//
//  XZMocoaCollectionPlaceholderCellViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#if __has_include("XZKit.h")
#import "XZMocoaCollectionCellViewModel.h"
#else
#import <XZKit/XZMocoaCollectionCellViewModel.h>
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaCollectionPlaceholderCellViewModel : XZMocoaCollectionCellViewModel
@end
#else
typedef XZMocoaCollectionCellViewModel XZMocoaCollectionPlaceholderCellViewModel;
#endif

NS_ASSUME_NONNULL_END
