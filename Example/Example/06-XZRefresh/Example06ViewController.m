//
//  Example06ViewController.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "Example06ViewController.h"
#import "Example06SettingsViewController.h"
#import "Example06RefreshSettingsViewController.h"
@import XZRefresh;
@import XZExtensions;

@interface Example06ViewController () <XZRefreshDelegate> {
    NSInteger _numberOfCells;
    CGFloat _rowHeight;
}
@end

@implementation Example06ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _rowHeight = 57.0;
    _numberOfCells = 10;
    
    // 使用默认样式
    self.tableView.xz_headerRefreshView.adjustment = XZRefreshAdjustmentNone;
    self.tableView.xz_footerRefreshView.adjustment = XZRefreshAdjustmentAutomatic;
}

- (void)scrollView:(__kindof UIScrollView *)scrollView headerDidBeginRefreshing:(XZRefreshView *)refreshView {
    XZLog(@"%s", __PRETTY_FUNCTION__);
    NSTimeInterval time = arc4random_uniform(20) * 0.1 + 2.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_numberOfCells = arc4random_uniform(10) + 5;
        [self.tableView reloadData];
        [refreshView endRefreshing];
    });
}

- (void)scrollView:(__kindof UIScrollView *)scrollView footerDidBeginRefreshing:(XZRefreshView *)refreshView {
    XZLog(@"%s", __PRETTY_FUNCTION__);
    NSTimeInterval time = arc4random_uniform(20) * 0.1 + 2.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSInteger old = self->_numberOfCells;
        if (old < 30) {
            NSInteger new = MIN(arc4random_uniform(5) + 4, 30 - old);
            self->_numberOfCells = old + new;
            NSMutableArray *rows = [NSMutableArray arrayWithCapacity:new];
            for (NSInteger i = 0; i < new; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:old + i inSection:0];
                [rows addObject:indexPath];
            }
            [self.tableView insertRowsAtIndexPaths:rows withRowAnimation:(UITableViewRowAnimationTop)];
        }
        [refreshView endRefreshing];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    XZLog(@"contentOffset => %@, adjustedContentInset => %@", NSStringFromCGPoint(scrollView.contentOffset), NSStringFromUIEdgeInsets(scrollView.adjustedContentInset));
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _numberOfCells;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"No.%02ld", indexPath.row];
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
        
        vc.headerRefreshView = self.tableView.xz_headerRefreshView;
        vc.footerRefreshView = self.tableView.xz_footerRefreshView;
    }
}

- (IBAction)unwindFromRefreshSettings:(UIStoryboardSegue *)unwindSegue {
    
}

- (IBAction)unwindFromHeaderRefreshAction:(UIStoryboardSegue *)unwindSegue {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.tableView.xz_headerRefreshView.isRefreshing) {
            [self.tableView.xz_headerRefreshView endRefreshing];
        } else {
            [self.tableView.xz_headerRefreshView beginRefreshing];
        }
    });
}

- (IBAction)unwindFromFooterRefreshAction:(UIStoryboardSegue *)unwindSegue {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.tableView.xz_footerRefreshView.isRefreshing) {
            [self.tableView.xz_footerRefreshView endRefreshing];
        } else {
            [self.tableView.xz_footerRefreshView beginRefreshing];
        }
    });
}

- (IBAction)unwindFromInsertRowAction:(UIStoryboardSegue *)unwindSegue {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self->_numberOfCells inSection:0];
        self->_numberOfCells += 1;
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationLeft)];
    });
}

- (IBAction)unwindFromDeleteRowAction:(UIStoryboardSegue *)unwindSegue {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self->_numberOfCells > 0) {
            self->_numberOfCells -= 1;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self->_numberOfCells inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationRight)];
        }
    });
}

@end
