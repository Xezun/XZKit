//
//  XZMocoaTableViewController.h
//  XZKit
//
//  Created by 徐臻 on 2025/1/19.
//

#import <UIKit/UIKit.h>
#import "XZMocoaTableView.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaTableViewController : UITableViewController <XZMocoaTableView>
@end

@interface XZMocoaTableViewController (XZMocoaTableViewModelDelegate) <XZMocoaTableViewModelDelegate>
@end

NS_ASSUME_NONNULL_END
