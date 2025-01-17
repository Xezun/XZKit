//
//  Example16SettingsSelectSectionViewController.h
//  Example
//
//  Created by Xezun on 2024/6/3.
//

#import <UIKit/UIKit.h>
#import "Example16CollectonViewSectionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Example16SettingsSelectSectionViewController : UITableViewController

@property (nonatomic, copy) NSArray<Example16CollectonViewSectionModel *> *sections;

@end

NS_ASSUME_NONNULL_END
