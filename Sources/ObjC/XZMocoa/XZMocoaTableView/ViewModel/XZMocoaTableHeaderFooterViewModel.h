//
//  XZMocoaTableHeaderFooterViewModel.h
//  XZKit
//
//  Created by 徐臻 on 2026/9/3.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGroupReusableViewModel.h>
#else
#import "XZMocoaGroupReusableViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaTableHeaderFooterViewModel : XZMocoaGroupReusableViewModel
@property (nonatomic) CGFloat height;
@end

typedef XZMocoaTableHeaderFooterViewModel XZMocoaTableHeaderViewModel;
typedef XZMocoaTableHeaderFooterViewModel XZMocoaTableFooterViewModel;

NS_ASSUME_NONNULL_END
