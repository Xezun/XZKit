//
//  Example04FontSizeViewController.m
//  Example
//
//  Created by 徐臻 on 2024/10/17.
//

#import "Example04FontSizeViewController.h"

@interface Example04FontSizeViewController ()

@end

@implementation Example04FontSizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender {
    if ([sender isKindOfClass:UITableViewCell.class]) {
        self.fontSize = sender.textLabel.text.doubleValue;
    }
}

@end
