//
//  XZMocoaTableHeaderFooterView.h
//  XZKit
//
//  Created by Xezun on 2026/9/3.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGroupReusableView.h>
#import <XZKit/XZMocoaTableHeaderFooterViewModel.h>
#else
#import "XZMocoaGroupReusableView.h"
#import "XZMocoaTableHeaderFooterViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

typedef UITableViewHeaderFooterView XZMocoaTableHeaderFooterView;
typedef UITableViewHeaderFooterView XZMocoaTableHeaderView;
typedef UITableViewHeaderFooterView XZMocoaTableFooterView;

@interface UITableViewHeaderFooterView (XZMocoaTableHeaderFooterView)
@property (nonatomic, strong, nullable) __kindof XZMocoaTableHeaderFooterViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
