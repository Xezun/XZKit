//
//  XZMocoaTableSupplementViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGroupSupplementViewModel.h>
#else
#import "XZMocoaGroupSupplementViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaTableSupplementViewModel : XZMocoaGroupSupplementViewModel
@property (nonatomic) CGFloat height;
@end

@interface XZMocoaTableSectionHeaderViewModel : XZMocoaTableSupplementViewModel
@end

@interface XZMocoaTableSectionFooterViewModel : XZMocoaTableSupplementViewModel
@end

NS_ASSUME_NONNULL_END
