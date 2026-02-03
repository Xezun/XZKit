//
//  Example05BenchmakListViewController.m
//  Example
//
//  Created by 徐臻 on 2026/2/3.
//

#import "Example05BenchmakListViewController.h"
#import "Example05BenchmarkViewController.h"

@interface Example05BenchmakListViewController ()

@end

@implementation Example05BenchmakListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:UITableViewCell.class]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            Example05BenchmarkViewController *nextVC = segue.destinationViewController;
            nextVC.action = indexPath.row;
        }
    }
}

@end
