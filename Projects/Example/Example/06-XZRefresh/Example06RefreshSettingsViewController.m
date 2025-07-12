//
//  Example06RefreshSettingsViewController.m
//  Example
//
//  Created by Xezun on 2024/5/21.
//

#import "Example06RefreshSettingsViewController.h"

@interface Example06RefreshSettingsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *automaticSwitch;

@end

@implementation Example06RefreshSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.title;
    
    self.automaticSwitch.on = self.refreshView.automaticRefreshDistance > 0;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    UITableViewCellAccessoryType (^const isChecked)(BOOL) = ^(BOOL isTrue) {
        return isTrue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryDisclosureIndicator;
    };
    
    XZRefreshView * const refreshView = self.refreshView;
    
    switch (indexPath.section) {
        case 0:
            cell.accessoryType = isChecked(refreshView.adjustment == indexPath.row);
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.accessoryType = isChecked(refreshView.offset < 0);
                    break;
                case 1:
                    cell.accessoryType = isChecked(refreshView.offset == 0);
                    break;
                case 2:
                    cell.accessoryType = isChecked(refreshView.offset > 0);
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    
                    break;
                    
                default:
                    break;
            }
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    self.refreshView.adjustment = XZRefreshAdjustmentAutomatic;
                    break;
                case 1:
                    self.refreshView.adjustment = XZRefreshAdjustmentNormal;
                    break;
                case 2:
                    self.refreshView.adjustment = XZRefreshAdjustmentNone;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    self.refreshView.offset = -20;
                    break;
                case 1:
                    self.refreshView.offset = 0;
                    break;
                case 2:
                    self.refreshView.offset = +20;
                    break;
                default:
                    break;
            }
        default:
            break;
    }
    
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:(UITableViewRowAnimationNone)];
}

- (IBAction)switchValueChanged:(UISwitch *)sender {
    self.refreshView.automaticRefreshDistance = sender.isOn ? 57 * 2 : 0;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
