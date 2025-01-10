//
//  Example16SettingsViewController.m
//  Example
//
//  Created by 徐臻 on 2024/6/3.
//

#import "Example16SettingsViewController.h"
#import "Example16SettingsSelectSectionViewController.h"

@interface Example16SettingsViewController ()

@end

@implementation Example16SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"SelectSection"]) {
        Example16SettingsSelectSectionViewController *vc = segue.destinationViewController;
        vc.sections = self.sections;
    }
}

@end
