//
//  XZMocoaTableViewHeaderFooterViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import "XZMocoaGridViewSupplementaryViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaTableViewHeaderFooterViewModel : XZMocoaGridViewSupplementaryViewModel
@property (nonatomic) CGFloat height;
@end

@interface XZMocoaTableViewHeaderViewModel : XZMocoaTableViewHeaderFooterViewModel
@end

@interface XZMocoaTableViewFooterViewModel : XZMocoaTableViewHeaderFooterViewModel
@end

NS_ASSUME_NONNULL_END
