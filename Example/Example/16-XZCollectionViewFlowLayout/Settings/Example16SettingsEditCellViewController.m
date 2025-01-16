//
//  Example16SettingsEditCellViewController.m
//  Example
//
//  Created by Xezun on 2024/6/5.
//

#import "Example16SettingsEditCellViewController.h"
#import "Example16SettingsEditSectionViewController.h"
#import "Example16SettingsSelectNumberViewController.h"

@interface Example16SettingsEditCellViewController () {
    Example16CollectonViewSectionModel *_section;
}

@end

@implementation Example16SettingsEditCellViewController

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
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", _size.width];
                    break;
                case 1:
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", _size.height];
                    break;
                default:
                    break;
            }
            break;
        case 1:
            if (_isCustomized) {
                switch (self.interitemAlignment) {
                    case XZCollectionViewInteritemAlignmentAscended:
                        cell.detailTextLabel.text = @"ascended";
                        break;
                    case XZCollectionViewInteritemAlignmentMedian:
                        cell.detailTextLabel.text = @"median";
                        break;
                    case XZCollectionViewInteritemAlignmentDescended:
                        cell.detailTextLabel.text = @"descended";
                        break;
                }
            } else {
                cell.detailTextLabel.text = @"由 section 决定";
            }
            break;
        case 2:
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)setDataWithModel:(Example16CollectonViewSectionModel *)model indexPath:(NSIndexPath *)indexPath {
    Example16CollectonViewCellModel *_cell = model.cells[indexPath.item];
    _section = model;
    _indexPath = indexPath;
    _size = _cell.size;
    _isCustomized = _cell.isCustomized;
    _interitemAlignment = _cell.interitemAlignment;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    
    if ([identifier isEqualToString:@"SectionSettings"]) {
        Example16SettingsEditSectionViewController *vc = segue.destinationViewController;
        [vc setDataForSection:_section atIndex:_indexPath.section];
    } else if ([identifier isEqualToString:@"interitemAlignment"]) {
        Example16SettingsSelectNumberViewController *vc = segue.destinationViewController;
        vc.type = 0;
        if (_isCustomized) {
            vc.value = _interitemAlignment + 1;
        } else {
            vc.value = 0;
        }
    } else if ([identifier isEqualToString:@"width"]) {
        Example16SettingsSelectNumberViewController *vc = segue.destinationViewController;
        vc.type = 1;
        vc.value = _size.width / 10;
    } else if ([identifier isEqualToString:@"height"]) {
        Example16SettingsSelectNumberViewController *vc = segue.destinationViewController;
        vc.type = 2;
        vc.value = _size.height / 10;
    }
}


- (IBAction)unwindToApplySelectValue:(UIStoryboardSegue *)unwindSegue {
    Example16SettingsSelectNumberViewController *vc = unwindSegue.sourceViewController;
    switch (vc.type) {
        case 0: {
            NSInteger value = vc.value;
            if (value == 0) {
                _isCustomized = NO;
            } else {
                _isCustomized = YES;
                _interitemAlignment = value - 1;
            }
            break;
        }
        case 1: {
            _size.width = vc.value * 10;
            break;
        }
        case 2: {
            _size.height = vc.value * 10;
            break;
        }
        default:
            break;
    }
    [self.tableView reloadData];
}

@end
