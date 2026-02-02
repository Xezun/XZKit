//
//  ExampleMainHomeViewController.m
//  Example
//
//  Created by Xezun on 2024/9/10.
//

#import "ExampleMainHomeViewController.h"
#import "ExampleMainHomeSectionModel.h"
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
    
    NSURL *url = [NSBundle.mainBundle URLForResource:@"ExampleMainHome" withExtension:@"json"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    NSArray *models = [XZJSON decode:data options:kNilOptions class:[ExampleMainHomeSectionModel class]];
    
    XZMocoaTableViewModel *viewModel = [[XZMocoaTableViewModel alloc] initWithModel:models];
    viewModel.module = XZMocoa(@"https://xzkit.xezun.com/examples");
    self.tableView.viewModel = viewModel;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (IBAction)unwindToMainPage:(UIStoryboardSegue *)unwindSegue {
    
}

@end

