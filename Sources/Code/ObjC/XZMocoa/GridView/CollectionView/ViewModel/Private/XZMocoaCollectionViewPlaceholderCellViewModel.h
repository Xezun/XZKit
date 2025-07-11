//
//  XZMocoaCollectionViewPlaceholderCellViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaCollectionViewCellViewModel.h>
#else
#import "XZMocoaCollectionViewCellViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaCollectionViewPlaceholderCellViewModel : XZMocoaCollectionViewCellViewModel
@end
#else
typedef XZMocoaCollectionViewCellViewModel XZMocoaCollectionViewPlaceholderCellViewModel;
#endif

NS_ASSUME_NONNULL_END
