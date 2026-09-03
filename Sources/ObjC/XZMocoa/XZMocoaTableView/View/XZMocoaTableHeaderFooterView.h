//
//  XZMocoaTableHeaderFooterView.h
//  XZKit
//
//  Created by Xezun on 2026/9/3.
//

#import <UIKit/UIKit.h>
#import "XZMocoaGroupReusableView.h"
#import "XZMocoaTableHeaderFooterViewModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef UITableViewHeaderFooterView XZMocoaTableHeaderFooterView;
typedef UITableViewHeaderFooterView XZMocoaTableHeaderView;
typedef UITableViewHeaderFooterView XZMocoaTableFooterView;

@interface UITableViewHeaderFooterView (XZMocoaTableHeaderFooterView)
@property (nonatomic, strong, nullable) __kindof XZMocoaTableHeaderFooterViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
