//
//  Example06SettingsViewController.h
//  Example
//
//  Created by Xezun on 2023/8/15.
//

#import <UIKit/UIKit.h>
@import XZRefresh;

NS_ASSUME_NONNULL_BEGIN

@interface Example06SettingsViewController : UITableViewController

@property (nonatomic, strong) XZRefreshView *headerRefreshView;
@property (nonatomic, strong) XZRefreshView *footerRefreshView;

@end

NS_ASSUME_NONNULL_END
