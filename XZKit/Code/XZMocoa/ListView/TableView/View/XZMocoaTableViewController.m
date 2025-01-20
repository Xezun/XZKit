//
//  XZMocoaTableViewController.m
//  XZKit
//
//  Created by 徐臻 on 2025/1/19.
//

#import "XZMocoaTableViewController.h"
#import "XZMocoaTableViewCell.h"
#import "XZMocoaTableViewHeaderFooterView.h"
#import "XZMocoaTableViewProxy.h"

@interface XZMocoaTableViewController () {
    XZMocoaTableViewProxy *_proxy;
}

@end

@implementation XZMocoaTableViewController

@dynamic viewModel;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _proxy = [[XZMocoaTableViewProxy alloc] initWithTableView:self];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _proxy = [[XZMocoaTableViewProxy alloc] initWithTableView:self];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        _proxy = [[XZMocoaTableViewProxy alloc] initWithTableView:self];
    }
    return self;
}

- (void)viewModelWillChange {
    XZMocoaTableViewModel * const _viewModel = self.viewModel;
    _viewModel.delegate = nil;
}

- (void)viewModelDidChange {
    XZMocoaTableViewModel * const _viewModel = self.viewModel;
    [self registerCellWithModule:_viewModel.module];
    _viewModel.delegate = _proxy;
    
    UITableView * const tableView = self.tableView;
    if (@available(iOS 11.0, *)) {
        if (tableView && !tableView.hasUncommittedUpdates) {
            [tableView reloadData];
        }
    } else {
        [tableView reloadData];
    }
}

- (UITableView *)contentView {
    return self.tableView;
}

- (void)setContentView:(UITableView *)contentView {
    [self setTableView:contentView];
}

- (void)registerCellWithModule:(XZMocoaModule *)module {
    [_proxy registerCellWithModule:module];
}

- (id<UITableViewDelegate>)delegate {
    return _proxy.delegate;
}

- (void)setDelegate:(id<UITableViewDelegate>)delegate {
    [_proxy setDelegate:delegate];
}

- (id<UITableViewDataSource>)dataSource {
    return _proxy.dataSource;
}

- (void)setDataSource:(id<UITableViewDataSource>)dataSource {
    [_proxy setDataSource:dataSource];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate   = _proxy;
    self.tableView.dataSource = _proxy;
}


@end

