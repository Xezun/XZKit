//
//  XZMocoaTableHeaderFooterViewModel.h
//  XZKit
//
//  Created by 徐臻 on 2026/9/3.
//

#if __has_include("XZKit.h")
#import "XZMocoaGroupReusableViewModel.h"
#else
#import <XZKit/XZMocoaGroupReusableViewModel.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaTableHeaderFooterViewModel : XZMocoaGroupReusableViewModel
@property (nonatomic) CGFloat height;
@end

typedef XZMocoaTableHeaderFooterViewModel XZMocoaTableHeaderViewModel;
typedef XZMocoaTableHeaderFooterViewModel XZMocoaTableFooterViewModel;

NS_ASSUME_NONNULL_END
