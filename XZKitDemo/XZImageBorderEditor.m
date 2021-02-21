//
//  XZImageBorderEditor.m
//  XZKitDemo
//
//  Created by Xezun on 2021/2/22.
//

#import "XZImageBorderEditor.h"
#import "XZNumberInputViewController.h"

@interface XZImageBorderEditor ()

@end

@implementation XZImageBorderEditor

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)unwindFromNumberInput:(UIStoryboardSegue *)unwindSegue {
    XZNumberInputViewController *vc = unwindSegue.sourceViewController;
    self.line.width = vc.value;
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *nav = segue.destinationViewController;
    XZNumberInputViewController *vc = nav.viewControllers.firstObject;
    vc.value = self.line.width;
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
            XZImageBorderArrow *arrow = self.line.arrow;
            switch (indexPath.row) {
                case 0:
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f", arrow.height];
                    break;
                case 1: {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f", arrow.width];
                    break;
                }
                case 2:
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f", arrow.anchor];
                    break;
                case 3:
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f", arrow.vector];
                    break;
                default:
                    break;
            }
            break;
        }
        case 2: {
            cell.detailTextLabel.text = @"";
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
