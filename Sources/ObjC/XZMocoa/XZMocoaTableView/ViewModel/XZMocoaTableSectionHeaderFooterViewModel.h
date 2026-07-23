//
//  XZMocoaTableSectionHeaderFooterViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGroupSectionSupplementaryViewModel.h>
#else
#import "XZMocoaGroupSectionSupplementaryViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaTableSectionHeaderFooterViewModel : XZMocoaGroupSectionSupplementaryViewModel
@property (nonatomic) CGFloat height;
@end

@interface XZMocoaTableSectionHeaderViewModel : XZMocoaTableSectionHeaderFooterViewModel
@end

@interface XZMocoaTableSectionFooterViewModel : XZMocoaTableSectionHeaderFooterViewModel
@end

NS_ASSUME_NONNULL_END
