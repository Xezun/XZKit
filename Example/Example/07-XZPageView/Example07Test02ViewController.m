//
//  Example07Test02ViewController.m
//  Example
//
//  Created by Xezun on 2024/7/13.
//

#import "Example07Test02ViewController.h"
@import XZSegmentedControl;
@import XZPageView;
@import XZDefines;
@import XZToast;
@import XZExtensionsCore;
@import XZLogCore;

@interface Example07Test02ChildViewController : UIViewController
@property (nonatomic) NSInteger index;
@end

@interface Example07Test02ViewController () <XZPageViewControllerDelegate, XZPageViewControllerDataSource>

@property (weak, nonatomic) IBOutlet XZSegmentedControl *segmentedControl;
@property (nonatomic, strong) XZPageViewController *pageViewController;

@property (nonatomic, copy) NSArray *titles;

@property (nonatomic, copy) NSArray *viewControllers;

@end

@implementation Example07Test02ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titles = @[@"业界", @"手机", @"电脑", @"测评", @"视频", @"AI", @"苹果", @"鸿蒙", @"软件", @"数码"];
    self.viewControllers = [self.titles xz_map:^id _Nonnull(id  _Nonnull obj, NSInteger idx, BOOL * _Nonnull stop) {
        Example07Test02ChildViewController *viewController = [[Example07Test02ChildViewController alloc] init];
        viewController.title = obj;
        viewController.index = idx;
        return viewController;
    }];
    
    self.segmentedControl.backgroundColor = UIColor.systemBackgroundColor;
    self.segmentedControl.indicatorSize = CGSizeMake(20, 4.0);
    self.segmentedControl.indicatorColor = UIColor.systemRedColor;
    self.segmentedControl.interitemSpacing = 10;
    self.segmentedControl.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.segmentedControl.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.segmentedControl.titles = self.titles;
    [self.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:(UIControlEventValueChanged)];
    
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"pageViewController"]) {
        _pageViewController = segue.destinationViewController;
        [self addChildViewController:_pageViewController];
        [_pageViewController didMoveToParentViewController:self];
    }
}

- (void)segmentedControlValueChanged:(XZSegmentedControl *)sender {
    [self.pageViewController setCurrentPage:sender.selectedIndex animated:YES];
}

- (IBAction)orientationSwitchAction:(UISwitch *)sender {
    if (sender.isOn) {
        self.pageViewController.orientation = XZPageViewOrientationVertical;
        [self xz_showToast:[XZToast messageToast:@"已切换为纵向滚动"]];
    } else {
        self.pageViewController.orientation = XZPageViewOrientationHorizontal;
        [self xz_showToast:[XZToast messageToast:@"已切换为横向滚动"]];
    }
}

- (NSInteger)numberOfViewControllersInPageViewController:(XZPageViewController *)pageViewController {
    return self.titles.count;
}

- (UIViewController *)pageViewController:(XZPageViewController *)pageViewController viewControllerForPageAtIndex:(NSInteger)index {
    return self.viewControllers[index];
}

- (void)pageViewController:(XZPageViewController *)pageViewController didShowViewControllerAtIndex:(NSInteger)index {
    XZLog(@"%ld", index);
    [self.segmentedControl setSelectedIndex:index animated:YES];
}

- (void)pageViewController:(XZPageViewController *)pageViewController didTurnViewControllerInTransition:(CGFloat)transition {
    [self.segmentedControl updateInteractiveTransition:transition];
}

@end


@implementation Example07Test02ChildViewController

- (void)loadView {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:32];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.text = [NSString stringWithFormat:@"%@\n\n- 第 %ld 页 -", self.title, (long)self.index];
    self.view = label;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    XZLog(@"index: %ld, title: %@, animated: %@", self.index, self.title, (animated ? @"YES" : @"NO"));
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    XZLog(@"index: %ld, title: %@, animated: %@", self.index, self.title, (animated ? @"YES" : @"NO"));
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    XZLog(@"index: %ld, title: %@, animated: %@", self.index, self.title, (animated ? @"YES" : @"NO"));
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    XZLog(@"index: %ld, title: %@, animated: %@", self.index, self.title, (animated ? @"YES" : @"NO"));
}

@end
