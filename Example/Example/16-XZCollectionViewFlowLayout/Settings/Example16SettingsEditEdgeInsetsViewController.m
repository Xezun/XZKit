//
//  Example16SettingsEditEdgeInsetsViewController.m
//  Example
//
//  Created by 徐臻 on 2024/6/3.
//

#import "Example16SettingsEditEdgeInsetsViewController.h"
#import "Example16SettingsSelectNumberViewController.h"

@interface Example16SettingsEditEdgeInsetsViewController ()

@end

@implementation Example16SettingsEditEdgeInsetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)self.value.top];
            break;
        case 1:
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)self.value.left];
            break;
        case 2:
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)self.value.bottom];
            break;
        case 3:
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)self.value.right];
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    Example16SettingsSelectNumberViewController *vc = segue.destinationViewController;
    
    if (![vc isKindOfClass:[Example16SettingsSelectNumberViewController class]]) {
        return;
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    vc.type = indexPath.row + 1;
    switch (indexPath.row) {
        case 0:
            vc.value = self.value.top;
            break;
        case 1:
            vc.value = self.value.left;
            break;
        case 2:
            vc.value = self.value.bottom;
            break;
        case 3:
            vc.value = self.value.right;
            break;
        default:
            break;
    }
}

- (IBAction)unwindToApplySelectValue:(UIStoryboardSegue *)unwindSegue {
    Example16SettingsSelectNumberViewController *sourceViewController = unwindSegue.sourceViewController;
    if (sourceViewController.type == 1) {
        _value.top = sourceViewController.value;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
    } else if (sourceViewController.type == 2) {
        _value.left = sourceViewController.value;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
    } else if (sourceViewController.type == 3) {
        _value.bottom = sourceViewController.value;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
    } else if (sourceViewController.type == 4) {
        _value.right = sourceViewController.value;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
    }
}

@end
