//
//  Example0330ViewController.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0330ViewController.h"
#import "Example0330ViewModel.h"
@import XZMocoa;

@interface Example0330ViewController () <XZMocoaView>
@property (nonatomic, strong) XZMocoaTableView *tableView;
@end

@implementation Example0330ViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Example 30";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

+ (void)load {
    XZModule(@"https://mocoa.xezun.com/examples/30/").viewClass = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Example0330ViewModel *viewModel = [[Example0330ViewModel alloc] init];
    self.viewModel = viewModel;

    _tableView = [[XZMocoaTableView alloc] initWithFrame:self.view.bounds style:(UITableViewStyleGrouped)];
    _tableView.contentView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.contentView.estimatedRowHeight = 0;
    _tableView.contentView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    _tableView.contentView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    [self.view addSubview:_tableView];
    
    [viewModel ready];
    _tableView.viewModel = viewModel.tableViewModel;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
