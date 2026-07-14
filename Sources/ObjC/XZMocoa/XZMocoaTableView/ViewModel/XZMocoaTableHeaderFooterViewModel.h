//
//  XZMocoaTableHeaderFooterViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGroupSupplementaryViewModel.h>
#else
#import "XZMocoaGroupSupplementaryViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaTableHeaderFooterViewModel : XZMocoaGroupSupplementaryViewModel
@property (nonatomic) CGFloat height;
@end

@interface XZMocoaTableHeaderViewModel : XZMocoaTableHeaderFooterViewModel
@end

@interface XZMocoaTableFooterViewModel : XZMocoaTableHeaderFooterViewModel
@end

NS_ASSUME_NONNULL_END
