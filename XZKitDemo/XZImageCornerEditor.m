//
//  XZImageCornerEditor.m
//  XZKitDemo
//
//  Created by Xezun on 2021/2/22.
//

#import "XZImageCornerEditor.h"
#import "XZNumberInputViewController.h"

@interface XZImageCornerEditor ()

@end

@implementation XZImageCornerEditor

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (IBAction)unwindFromNumberInput:(UIStoryboardSegue *)unwindSegue {
    XZNumberInputViewController *vc = unwindSegue.sourceViewController;
    [self.line setValue:[NSNumber numberWithDouble:vc.value] forKeyPath:vc.title];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    XZNumberInputViewController *vc = segue.destinationViewController;
    if ([vc isKindOfClass:[XZNumberInputViewController class]]) {
        vc.title = segue.identifier;
        vc.value = [[self.line valueForKeyPath:segue.identifier] doubleValue];
    }
}

#pragma mark - Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0:
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f", self.line.width];
                    break;
                case 1: {
                    XZColor color = self.line.color.XZColor;
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"#%02lX%02lX%02lX%02lX", color.red, color.green, color.blue, color.alpha];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1: {
            XZImageLineDash *dash = self.line.dash;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f - %.2f", dash.width, dash.space];
            break;
        }
        case 2: {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f", self.line.radius];
            break;
        }
            
        default:
            break;
    }
    
    return cell;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
