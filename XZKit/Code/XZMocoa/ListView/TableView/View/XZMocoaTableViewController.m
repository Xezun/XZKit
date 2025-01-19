//
//  XZMocoaTableViewController.m
//  XZKit
//
//  Created by 徐臻 on 2025/1/19.
//

#import "XZMocoaTableViewController.h"
#import "XZMocoaTableViewCell.h"
#import "XZMocoaTableViewHeaderFooterView.h"

@interface XZMocoaTableViewController ()

@end

@implementation XZMocoaTableViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self.proxy;
    self.tableView.dataSource = self.proxy;
}

@synthesize viewModel = _viewModel;

- (void)setViewModel:(__kindof XZMocoaTableViewModel *)viewModel {
    if (_viewModel != viewModel) {
        [self viewModelWillChange];
        
        _viewModel.delegate = nil;
        
        _viewModel = viewModel;
        
        [self registerCellWithModule:_viewModel.module];
        _viewModel.delegate = self.proxy;
        
        [self viewModelDidChange];
    }
}

- (void)viewModelDidChange {
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
    [self.proxy registerCellWithModule:module];
}


@end

