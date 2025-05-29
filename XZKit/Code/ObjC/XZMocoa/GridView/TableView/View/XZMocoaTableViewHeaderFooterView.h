//
//  XZMocoaTableViewHeaderFooterView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import <UIKit/UIKit.h>
#import "XZMocoaGridViewSupplementaryView.h"
#import "XZMocoaTableViewHeaderFooterViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaTableViewHeaderFooterView <XZMocoaGridViewSupplementaryView>
@optional
@property (nonatomic, strong, nullable) __kindof XZMocoaTableViewHeaderFooterViewModel *viewModel;
@end

@interface UITableViewHeaderFooterView (XZMocoaTableViewHeaderFooterView)
@property (nonatomic, strong, nullable) __kindof XZMocoaTableViewHeaderFooterViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
