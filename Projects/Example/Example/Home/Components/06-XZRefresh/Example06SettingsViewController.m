//
//  Example06SettingsViewController.m
//  Example
//
//  Created by Xezun on 2023/8/15.
//

#import "Example06SettingsViewController.h"
#import "Example06RefreshSettingsViewController.h"
@import XZKit;

@interface Example06SettingsViewController ()

@property (nonatomic, weak) IBOutlet UISwitch *headerInsetSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *footerInsetSwitch;

@end

@implementation Example06SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIEdgeInsets insets = self.scrollView.contentInset;
    self.headerInsetSwitch.on = insets.top > 0;
    self.footerInsetSwitch.on = insets.bottom > 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    if (identifier.length == 0) {
        return;
    }
    
    Example06RefreshSettingsViewController *vc = segue.destinationViewController;
    if ([identifier isEqualToString:@"Header"]) {
        vc.title = @"下拉刷新";
        vc.refreshView = self.scrollView.xz_headerRefreshView;
    } else if ([identifier isEqualToString:@"Footer"]) {
        vc.title = @"上拉加载";
        vc.refreshView = self.scrollView.xz_footerRefreshView;
    }
}

- (IBAction)headerInsetSwitchChanged:(UISwitch *)sender {
    UIEdgeInsets insets = self.scrollView.contentInset;
    insets.top = sender.isOn ? 30.0 : 0;
    self.scrollView.contentInset = insets;
}

- (IBAction)footerInsetSwitchChanged:(UISwitch *)sender {
    UIEdgeInsets insets = self.scrollView.contentInset;
    insets.bottom = sender.isOn ? 30.0 : 0;
    self.scrollView.contentInset = insets;
}

@end



