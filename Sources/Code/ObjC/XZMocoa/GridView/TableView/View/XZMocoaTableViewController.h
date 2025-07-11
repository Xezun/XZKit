//
//  XZMocoaTableViewController.h
//  XZKit
//
//  Created by 徐臻 on 2025/1/19.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaTableView.h>
#else
#import "XZMocoaTableView.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaTableViewController : UITableViewController <XZMocoaTableView>
@end

@interface XZMocoaTableViewController (XZMocoaTableViewModelDelegate) <XZMocoaTableViewModelDelegate>
@end

NS_ASSUME_NONNULL_END
