//
//  Example0331ViewController.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0331ViewController.h"
#import "Example0331ViewModel.h"
@import XZMocoa;

@interface Example0331ViewController () <XZMocoaView>
@property (nonatomic, strong) XZMocoaCollectionView *collectionView;
@end

@implementation Example0331ViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Example 31";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/31/").viewClass = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Example0331ViewModel *viewModel = [[Example0331ViewModel alloc] init];
    self.viewModel = viewModel;

    _collectionView = [[XZMocoaCollectionView alloc] initWithFrame:self.view.bounds];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_collectionView];
    
    [viewModel ready];
    _collectionView.viewModel = viewModel.collectionViewModel;
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
