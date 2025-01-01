//
//  Example0321ContactBookViewController.m
//  Example
//
//  Created by Xezun on 2021/4/12.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import <XZMocoa/XZMocoa.h>
#import "Example0321ContactBookViewController.h"
#import "Example0321ContactBookViewModel.h"
#import "Example0321ContactBookTestViewController.h"

@interface Example0321ContactBookViewController () <Example0321ContactBookTestViewControllerDelegate>

@property (nonatomic, readonly) XZMocoaTableView *view;
@property (nonatomic, strong) Example0321ContactBookViewModel *viewModel;

@end

@implementation Example0321ContactBookViewController

@dynamic view;

+ (void)load {
    XZModule(@"https://mocoa.xezun.com/examples/21/").viewClass = self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Example 21";
        self.hidesBottomBarWhenPushed = YES;
        self.navigationItem.backButtonTitle = @"返回";
    }
    return self;
}

- (void)dealloc {
    
}

- (void)loadView {
    self.view = [[XZMocoaTableView alloc] initWithFrame:UIScreen.mainScreen.bounds style:(UITableViewStyleGrouped)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:(UIBarButtonItemStylePlain) target:self action:@selector(navigationBarButton1Action:)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:(UIBarButtonItemStylePlain) target:self action:@selector(navigationBarButton2Action:)];
    self.navigationItem.rightBarButtonItems = @[item2, item1];
    
    self.viewModel = [[Example0321ContactBookViewModel alloc] init];
    [self.viewModel ready];
    
    self.view.contentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    self.view.contentView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.view.contentView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
    self.view.contentView.sectionHeaderHeight = 20.0;
    
    self.view.viewModel = self.viewModel.tableViewModel;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)navigationBarButton1Action:(id)sender {
    [self.viewModel.tableViewModel reloadData];
}

- (void)navigationBarButton2Action:(id)sender {
    Example0321ContactBookViewModel *viewModel = self.viewModel;
    Example0321ContactBookTestViewController *nextVC = [[Example0321ContactBookTestViewController alloc] initWithTestActions:viewModel.testActions];
    nextVC.delegate = self;
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (void)testVC:(Example0321ContactBookTestViewController *)textVC didSelectTestActionAtIndex:(NSUInteger)index {
    [self.viewModel performTestActionAtIndex:index];
}

@end
