//
//  XZImageBorderEditor.m
//  XZKitDemo
//
//  Created by Xezun on 2021/2/22.
//

#import "XZImageBorderEditor.h"
#import "XZNumberInputViewController.h"
#import "XZColorViewController.h"

@interface XZImageBorderEditor ()

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation XZImageBorderEditor

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)unwindFromNumberInput:(UIStoryboardSegue *)unwindSegue {
    XZNumberInputViewController *vc = unwindSegue.sourceViewController;
    [self.line setValue:[NSNumber numberWithDouble:vc.value] forKeyPath:vc.title];
    [self.tableView reloadData];
}

- (IBAction)unwindFromColorVC:(UIStoryboardSegue *)unwindSegue {
    XZColorViewController *vc = unwindSegue.sourceViewController;
    self.line.color = vc.color;
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    __kindof UIViewController *vc = segue.destinationViewController;
    if ([vc isKindOfClass:[XZNumberInputViewController class]]) {
        XZNumberInputViewController *input = vc;
        input.title = segue.identifier;
        input.value = [[self.line valueForKeyPath:segue.identifier] doubleValue];
    } else if ([vc isKindOfClass:[XZColorViewController class]]) {
        XZColorViewController *colorVC = vc;
        colorVC.title = segue.identifier;
        colorVC.color = self.line.color;
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
                    cell.detailTextLabel.text = NSStringFromXZColor(color);
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
            cell.detailTextLabel.text = self.line.dash.description;
            break;
        }
            
        default:
            break;
    }
    
    return cell;
}

@end
