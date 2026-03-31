//
//  XZMocoaTableHeaderFooterViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGridSupplementaryViewModel.h>
#else
#import "XZMocoaGridSupplementaryViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaTableHeaderFooterViewModel : XZMocoaGridSupplementaryViewModel
@property (nonatomic) CGFloat height;
@end

@interface XZMocoaTableHeaderViewModel : XZMocoaTableHeaderFooterViewModel
@end

@interface XZMocoaTableFooterViewModel : XZMocoaTableHeaderFooterViewModel
@end

NS_ASSUME_NONNULL_END
