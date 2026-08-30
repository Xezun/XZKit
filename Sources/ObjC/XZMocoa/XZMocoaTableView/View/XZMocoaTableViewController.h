//
//  XZMocoaTableViewController.h
//  XZKit
//
//  Created by Xezun on 2025/1/19.
//

#import <UIKit/UIKit.h>
#import "XZMocoaTableView.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaTableViewController : UITableViewController
@end

@interface XZMocoaTableViewController (XZMocoaTableView)
@property (nonatomic, strong, nullable) XZMocoaTableViewModel *viewModel;
@property (nonatomic, strong) IBOutlet UITableView *contentView;
- (void)prepareForModule:(nullable XZMocoaModule *)module;
@end

NS_ASSUME_NONNULL_END
