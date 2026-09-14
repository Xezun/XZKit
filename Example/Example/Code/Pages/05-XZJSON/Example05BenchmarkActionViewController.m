//
//  Example05BenchmarkActionViewController.m
//  Example
//
//  Created by Xezun on 2026/2/3.
//

#import "Example05BenchmarkActionViewController.h"
#import "Example05BenchmarkViewController.h"

@interface Example05BenchmarkActionViewController ()

@end

@implementation Example05BenchmarkActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender {
    if ([sender isKindOfClass:UITableViewCell.class]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            self.action = indexPath.section + indexPath.item;
            self.name = sender.textLabel.text;
        }
    }
}

@end
