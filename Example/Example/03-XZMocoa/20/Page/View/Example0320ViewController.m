//
//  Example0320ViewController.m
//  Example
//
//  Created by Xezun on 2023/7/23.
//

#import "Example0320ViewController.h"
#import "Example0320ViewModel.h"
@import XZRefresh;
@import XZExtensions;

// 当前示例展示了：
// 1、控制器展示下拉刷新、列表、上拉加载
// 2、

@interface Example0320ViewController () <XZMocoaView, XZRefreshDelegate>

@property (weak, nonatomic) IBOutlet XZMocoaTableView *tableView;

@end

@implementation Example0320ViewController

@dynamic viewModel;

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/20").viewNibClass = self;
}

- (instancetype)initWithMocoaOptions:(XZMocoaOptions *)options nibName:(NSString *)nibName bundle:(NSBundle *)bundle {
    self = [super initWithMocoaOptions:options nibName:nibName bundle:bundle];
    if (self) {
        self.title = @"Example 20";
        self.hidesBottomBarWhenPushed = YES;
        self.navigationItem.backButtonTitle = @"返回";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.contentView.xz_headerRefreshView.delegate = self;
    self.tableView.contentView.xz_footerRefreshView.delegate = self;
    
    Example0320ViewModel *viewModel = [[Example0320ViewModel alloc] initWithModel:nil ready:YES];
    self.viewModel = viewModel;
    self.tableView.viewModel = viewModel.tableViewModel;
    
    // 刷新状态，通过监听 isHeaderRefreshing/isFooterRefreshing 来更新。
    [viewModel addTarget:self action:@selector(headerRefreshingChanged:) forKeyEvents:@"isHeaderRefreshing"];
    [viewModel addTarget:self action:@selector(footerRefreshingChanged:) forKeyEvents:@"isFooterRefreshing"];
}

- (void)headerRefreshingChanged:(Example0320ViewModel *)viewModel {
    if (viewModel.isHeaderRefreshing) {
        [self.tableView.contentView.xz_headerRefreshView beginRefreshing];
    } else {
        [self.tableView.contentView.xz_headerRefreshView endRefreshing];
    }
}

- (void)footerRefreshingChanged:(Example0320ViewModel *)viewModel {
    if (viewModel.isFooterRefreshing) {
        [self.tableView.contentView.xz_footerRefreshView beginRefreshing];
    } else {
        [self.tableView.contentView.xz_footerRefreshView endRefreshing];
    }
}

- (void)scrollView:(UIScrollView *)scrollView headerDidBeginRefreshing:(XZRefreshView *)refreshView {
    Example0320ViewModel *viewModel = self.viewModel;
    [viewModel refreshingHeaderDidBeginAnimating];
}

- (void)scrollView:(UIScrollView *)scrollView footerDidBeginRefreshing:(XZRefreshView *)refreshView {
    Example0320ViewModel *viewModel = self.viewModel;
    [viewModel refreshingFooterDidBeginAnimating];
}

@end
