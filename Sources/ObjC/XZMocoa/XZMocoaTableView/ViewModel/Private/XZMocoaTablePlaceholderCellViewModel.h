//
//  XZMocoaTablePlaceholderCellViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/28.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaTableCellViewModel.h>
#else
#import "XZMocoaTableCellViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTablePlaceholderCellViewModel : XZMocoaTableCellViewModel
@end
#else
typedef XZMocoaTableCellViewModel XZMocoaTablePlaceholderCellViewModel;
#endif

NS_ASSUME_NONNULL_END
