//
//  XZMocoaCollectionViewPlaceholderCellViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#import "XZMocoaCollectionViewCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaCollectionViewPlaceholderCellViewModel : XZMocoaCollectionViewCellViewModel
@end
#else
typedef XZMocoaCollectionViewCellViewModel XZMocoaCollectionViewPlaceholderCellViewModel;
#endif

NS_ASSUME_NONNULL_END
