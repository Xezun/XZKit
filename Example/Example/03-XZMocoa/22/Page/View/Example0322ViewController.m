//
//  Example0322ViewController.m
//  Example
//
//  Created by Xezun on 2023/8/9.
//

#import "Example0322ViewController.h"
#import "Example0322ViewModel.h"
#import "Example0321ContactBookTestViewController.h"

@interface Example0322ViewController () <Example0321ContactBookTestViewControllerDelegate>

@property (nonatomic, strong) XZMocoaCollectionView *view;
@property (nonatomic, strong) Example0322ViewModel *viewModel;
@end

@implementation Example0322ViewController

@dynamic view, viewModel;

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/22/").viewNibClass = self;
}


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Example 22";
        self.hidesBottomBarWhenPushed = YES;
        self.navigationItem.backButtonTitle = @"返回";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:(UIBarButtonItemStylePlain) target:self action:@selector(navigationBarButton1Action:)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:(UIBarButtonItemStylePlain) target:self action:@selector(navigationBarButton2Action:)];
    self.navigationItem.rightBarButtonItems = @[item2, item1];
    
    self.viewModel = [[Example0322ViewModel alloc] init];
    [self.viewModel ready];
    
    self.view.contentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
//    self.view.contentView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//    self.view.contentView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
//    self.view.contentView.sectionHeaderHeight = 20.0;
    
    self.view.viewModel = self.viewModel.collectionViewModel;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)navigationBarButton1Action:(id)sender {
    [self.viewModel.collectionViewModel reloadData];
}

- (void)navigationBarButton2Action:(id)sender {
    Example0322ViewModel *viewModel = self.viewModel;
    Example0321ContactBookTestViewController *nextVC = [[Example0321ContactBookTestViewController alloc] initWithTestActions:viewModel.testActions];
    nextVC.delegate = self;
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (void)testVC:(Example0321ContactBookTestViewController *)textVC didSelectTestActionAtIndex:(NSUInteger)index {
    [self.viewModel performTestActionAtIndex:index];
}


@end
