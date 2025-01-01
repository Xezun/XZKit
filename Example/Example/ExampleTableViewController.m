//
//  ExampleTableViewController.m
//  Example
//
//  Created by 徐臻 on 2024/9/10.
//

#import "ExampleTableViewController.h"
@import XZExtensions;

@interface ExampleTableViewController ()

@end

@implementation ExampleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"__IPHONE_OS_VERSION_MIN_REQUIRED => %d", __IPHONE_OS_VERSION_MIN_REQUIRED);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
