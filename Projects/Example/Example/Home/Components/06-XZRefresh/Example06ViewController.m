//
//  Example06ViewController.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "Example06ViewController.h"
#import "Example06SettingsViewController.h"
#import "Example06RefreshSettingsViewController.h"
@import XZKit;

@interface Example06ViewController () <XZRefreshDelegate, UITableViewDataSource> {
    NSMutableArray<NSString *> *_dataArray;
    CGFloat _rowHeight;
    
    UIView *_top;
    UIView *_bottom;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation Example06ViewController

- (void)dealloc {
    [_top removeFromSuperview];
    [_bottom removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UINavigationBar * const navigationBar = self.navigationController.navigationBar;
//    UIImage *image = [UIImage xz_imageWithColor:UIColor.whiteColor];
//    if (@available(iOS 13.0, *)) {
//        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
//        appearance.backgroundImage = image;
//        appearance.titleTextAttributes = @{ NSForegroundColorAttributeName: UIColor.blackColor };
//        navigationBar.standardAppearance = appearance;
//        navigationBar.scrollEdgeAppearance = appearance;
//    } else {
//        [navigationBar setBackgroundImage:image forBarMetrics:(UIBarMetricsDefault)];
//    }

    _rowHeight = 57.0;
    _dataArray = [NSMutableArray arrayWithObjects:@"XZRefresh", @"下拉刷新组件", @"刷新组件背景为粉红色", @"安全区边距为兰色", nil];
    
    self.tableView.xz_headerRefreshView.backgroundColor = rgb(0xfeb5d7);
    self.tableView.xz_footerRefreshView.backgroundColor = rgb(0xfeb5d7);
    
    self.tableView.xz_headerRefreshView.adjustment = XZRefreshAdjustmentNone;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    
    CGRect const frame = self.view.frame;
    UIEdgeInsets const insets = self.view.safeAreaInsets;
    
    _rowHeight = (frame.size.height - insets.top - insets.bottom) / 10;
    [self.tableView reloadData];
}

- (void)scrollView:(__kindof UIScrollView *)scrollView headerDidBeginRefreshing:(XZRefreshView *)refreshView {
//    XZLog(@"%s", __PRETTY_FUNCTION__);
    NSTimeInterval time = arc4random_uniform(20) * 0.1 + 2.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_dataArray removeAllObjects];
        
        NSInteger const count = arc4random_uniform(10) + 5;
        for (NSInteger i = 0; i < count; i++) {
            NSString *text = [NSString stringWithFormat:@"第 %ld 行", self->_dataArray.count];
            [self->_dataArray addObject:text];
        }
        
        [self.tableView reloadData];
        [refreshView endRefreshing:YES];
        [self xz_showToast:[XZToast sharedToast:(XZToastStyleSuccess) text:@"刷新成功"]];
    });
}

- (void)scrollView:(__kindof UIScrollView *)scrollView footerDidBeginRefreshing:(XZRefreshView *)refreshView {
//    XZLog(@"%s", __PRETTY_FUNCTION__);
    NSTimeInterval time = arc4random_uniform(20) * 0.1 + 2.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self->_dataArray.count < 20) {
            NSInteger const count = arc4random_uniform(5) + 4;
            NSMutableArray *rows = [NSMutableArray arrayWithCapacity:count];
            
            for (NSInteger i = 0; i < count; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self->_dataArray.count inSection:0];
                [rows addObject:indexPath];
                
                NSString *text = [NSString stringWithFormat:@"第 %ld 行", self->_dataArray.count];
                [self->_dataArray addObject:text];
            }
            
            [self.tableView insertRowsAtIndexPaths:rows withRowAnimation:(UITableViewRowAnimationTop)];
            
            NSString *message = [NSString stringWithFormat:@"新增 %ld 条数据", count];
            [self xz_showToast:[XZToast sharedToast:(XZToastStyleMessage) text:message] position:(XZToastPositionBottom)];
        } else {
            [self xz_showToast:[XZToast sharedToast:(XZToastStyleMessage) text:@"没有更多数据了"] position:(XZToastPositionBottom)];
        }
        [refreshView endRefreshing:YES];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    XZLog(@"contentOffset => %@, adjustedContentInset => %@", NSStringFromCGPoint(scrollView.contentOffset), NSStringFromUIEdgeInsets(scrollView.adjustedContentInset));
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = _dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _rowHeight;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"settings"]) {
        Example06SettingsViewController *vc = segue.destinationViewController;
        vc.scrollView = self.tableView;
    }
}

- (IBAction)unwindFromRefreshSettings:(UIStoryboardSegue *)unwindSegue {
    
}

- (IBAction)unwindFromHeaderRefreshAction:(UIStoryboardSegue *)unwindSegue {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.tableView.xz_headerRefreshView.isRefreshing) {
            [self.tableView.xz_headerRefreshView endRefreshing:YES];
        } else {
            [self.tableView.xz_headerRefreshView beginRefreshing:YES];
        }
    });
}

- (IBAction)unwindFromFooterRefreshAction:(UIStoryboardSegue *)unwindSegue {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.tableView.xz_footerRefreshView.isRefreshing) {
            [self.tableView.xz_footerRefreshView endRefreshing:YES];
        } else {
            [self.tableView.xz_footerRefreshView beginRefreshing:YES];
        }
    });
}

- (IBAction)unwindFromInsertRowAction:(UIStoryboardSegue *)unwindSegue {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *text = [NSString stringWithFormat:@"第 %ld 行", self->_dataArray.count];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self->_dataArray.count inSection:0];
        [self->_dataArray addObject:text];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationLeft)];
    });
}

- (IBAction)unwindFromDeleteRowAction:(UIStoryboardSegue *)unwindSegue {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self->_dataArray.count == 0) {
            return;
        }
        [self->_dataArray removeLastObject];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self->_dataArray.count inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationLeft)];
    });
}

@end


@interface Example06TableView : UITableView
@end
@implementation Example06TableView

- (void)setFrame:(CGRect)frame {
//    XZLog(@"");
    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds {
//    XZLog(@"isTracking: %d, isDragging: %d, isDecelerating: %d", self.isTracking, self.isDragging, self.isDecelerating);
    [super setBounds:bounds];
}

- (void)adjustedContentInsetDidChange {
//    XZLog(@"");
    [super adjustedContentInsetDidChange];
}

@end
