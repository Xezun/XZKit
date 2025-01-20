//
//  XZMocoaTableView.m
//  XZMocoa
//
//  Created by Xezun on 2021/3/24.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaTableView.h"
#import "XZMocoaDefines.h"
#import "XZMocoaTableViewCell.h"
#import "XZMocoaTableViewHeaderFooterView.h"
#import "XZMocoaTableViewProxy.h"

@interface XZMocoaTableView () {
    XZMocoaTableViewProxy *_proxy;
}
@end

@implementation XZMocoaTableView

@dynamic viewModel, contentView;

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _proxy = [[XZMocoaTableViewProxy alloc] initWithTableView:self];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    return [self initWithFrame:UIScreen.mainScreen.bounds style:style];
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [self initWithTableViewClass:UITableView.class style:style];
    if (self) {
        self.frame = frame;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithTableViewClass:UITableView.class style:(UITableViewStylePlain)];
}

- (instancetype)initWithTableViewClass:(Class)tableViewClass style:(UITableViewStyle)style {
    self = [super initWithFrame:UIScreen.mainScreen.bounds];
    if (self) {
        UITableView *contentView = [[tableViewClass alloc] initWithFrame:self.bounds style:style];
        [super setContentView:contentView];
        
        _proxy = [[XZMocoaTableViewProxy alloc] initWithTableView:self];
    }
    return self;
}

- (void)viewModelDidChange {
    [super viewModelDidChange];
    
    XZMocoaTableViewModel * const _viewModel = self.viewModel;
    _viewModel.delegate = _proxy;
    
    // 刷新视图。
    UITableView * const tableView = self.contentView;
    if (@available(iOS 11.0, *)) {
        if (tableView && !tableView.hasUncommittedUpdates) {
            [tableView reloadData];
        }
    } else {
        [tableView reloadData];
    }
}

- (void)contentViewWillChange {
    [super contentViewWillChange];
    
    UITableView * const tableView = self.contentView;
    tableView.delegate = nil;
    tableView.dataSource = nil;
}

- (void)contentViewDidChange {
    [super contentViewDidChange];
    
    UITableView * const tableView = self.contentView;
    tableView.delegate   = _proxy;
    tableView.dataSource = _proxy;
}

- (void)registerCellWithModule:(XZMocoaModule *)module {
    [_proxy registerCellWithModule:module];
}

@end


