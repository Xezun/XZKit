//
//  ExampleMainHomeViewController.m
//  Example
//
//  Created by Xezun on 2024/9/10.
//

#import "ExampleMainHomeViewController.h"
#import "ExampleMainHomeModel.h"
@import XZKit;

@interface ExampleMainHomeViewController ()

@property (nonatomic, readonly) XZMocoaTableView *tableView;

@end

@implementation ExampleMainHomeViewController

- (XZMocoaTableView *)tableView {
    return (id)self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ExampleMainHomeModel *model = [[ExampleMainHomeModel alloc] init];
    
    XZMocoaTableViewModel *viewModel = [[XZMocoaTableViewModel alloc] initWithModel:model];
    viewModel.module = XZMocoa(@"https://xzkit.xezun.com/examples");
    self.tableView.viewModel = viewModel;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (IBAction)unwindToMainPage:(UIStoryboardSegue *)unwindSegue {
    
}

@end

