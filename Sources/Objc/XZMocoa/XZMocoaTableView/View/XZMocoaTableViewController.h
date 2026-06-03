//
//  XZMocoaTableViewController.h
//  XZKit
//
//  Created by Xezun on 2025/1/19.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaTableView.h>
#else
#import "XZMocoaTableView.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaTableViewController : UITableViewController
@end

@interface XZMocoaTableViewController (XZMocoaTableView) <XZMocoaTableView>
@property (nonatomic, strong, nullable) XZMocoaTableViewModel *viewModel;
@property (nonatomic, strong) IBOutlet UITableView *contentView;
@end

NS_ASSUME_NONNULL_END
