//
//  XZMocoaTablePlaceholderSupplementViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaTableSupplementViewModel.h>
#else
#import "XZMocoaTableSupplementViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTablePlaceholderSupplementViewModel : XZMocoaTableSupplementViewModel
@end
#else
typedef XZMocoaTableSupplementViewModel XZMocoaTablePlaceholderSupplementViewModel;
#endif
NS_ASSUME_NONNULL_END
