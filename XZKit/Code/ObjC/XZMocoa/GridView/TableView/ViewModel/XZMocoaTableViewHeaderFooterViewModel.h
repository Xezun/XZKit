//
//  XZMocoaTableViewHeaderFooterViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGridViewSupplementaryViewModel.h>
#else
#import "XZMocoaGridViewSupplementaryViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaTableViewHeaderFooterViewModel : XZMocoaGridViewSupplementaryViewModel
@property (nonatomic) CGFloat height;
@end

@interface XZMocoaTableViewHeaderViewModel : XZMocoaTableViewHeaderFooterViewModel
@end

@interface XZMocoaTableViewFooterViewModel : XZMocoaTableViewHeaderFooterViewModel
@end

NS_ASSUME_NONNULL_END
