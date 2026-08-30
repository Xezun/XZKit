//
//  XZMocoaTableSupplementViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import "XZMocoaGroupSupplementViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaTableSupplementViewModel : XZMocoaGroupSupplementViewModel
@property (nonatomic) CGFloat height;
@end

@interface XZMocoaTableHeaderViewModel : XZMocoaTableSupplementViewModel
@end

@interface XZMocoaTableFooterViewModel : XZMocoaTableSupplementViewModel
@end

NS_ASSUME_NONNULL_END
