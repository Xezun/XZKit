//
//  Example02Test01ViewController.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "Example02Test01ViewController.h"
@import XZExtensions;

@interface Example02Test01ViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *styleControl;
@property (weak, nonatomic) IBOutlet UISwitch *hiddenControl;

@end

@implementation Example02Test01ViewController

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.preferredStatusBarStyle == UIStatusBarStyleLightContent) {
        self.styleControl.selectedSegmentIndex = 0;
    } else {
        self.styleControl.selectedSegmentIndex = 1;
    }
    
    self.hiddenControl.on = self.prefersStatusBarHidden;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    UITableViewCellAccessoryType type = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    if (self.xz_preferredStatusBarStyle == UIStatusBarStyleLightContent) {
                        type = UITableViewCellAccessoryCheckmark;
                    }
                    break;
                case 1:
                    if (self.xz_preferredStatusBarStyle != UIStatusBarStyleLightContent) {
                        type = UITableViewCellAccessoryCheckmark;
                    }
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    if (!self.xz_prefersStatusBarHidden) {
                        type = UITableViewCellAccessoryCheckmark;
                    }
                    break;
                case 1:
                    if (self.xz_prefersStatusBarHidden) {
                        type = UITableViewCellAccessoryCheckmark;
                    }
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    cell.accessoryType = type;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    self.xz_preferredStatusBarStyle = UIStatusBarStyleLightContent;
                    break;
                case 1:
                    if (@available(iOS 13.0, *)) {
                        self.xz_preferredStatusBarStyle = UIStatusBarStyleDarkContent;
                    } else {
                        self.xz_preferredStatusBarStyle = UIStatusBarStyleDefault;
                    }
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    self.xz_prefersStatusBarHidden = NO;
                    break;
                case 1:
                    self.xz_prefersStatusBarHidden = YES;
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:(UITableViewRowAnimationNone)];
}

@end
