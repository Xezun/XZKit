//
//  XZMocoaTableViewHeaderFooterView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import <UIKit/UIKit.h>
#import "XZMocoaView.h"
#import "XZMocoaTableViewHeaderFooterViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaTableViewHeaderFooterView <XZMocoaView>
@optional
@property (nonatomic, strong, nullable) __kindof XZMocoaTableViewHeaderFooterViewModel *viewModel;
@end

@interface UITableViewHeaderFooterView (XZMocoaTableViewHeaderFooterView)
@property (nonatomic, strong, nullable) __kindof XZMocoaTableViewHeaderFooterViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
