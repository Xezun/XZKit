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
@import ObjectiveC;

@interface XZMocoaTableViewController ()
@end

@implementation XZMocoaTableViewController

+ (void)initialize {
    if (self == [XZMocoaTableViewController class]) {
        unsigned int count = 0;
        Method *list = class_copyMethodList([XZMocoaTableViewProxy class], &count);
        for (unsigned int i = 0; i < count; i++) {
            Method const method = list[i];
            SEL const selector = method_getName(method);
            IMP const implemnt = method_getImplementation(method);
            const char * const types = method_getTypeEncoding(method);
            if (!class_addMethod(self, selector, implemnt, types)) {
                XZLog(@"为 %@ 添加方法 %@ 失败", self, NSStringFromSelector(selector));
            }
        }
    }
}

@dynamic viewModel;

- (UITableView *)contentView {
    return self.tableView;
}

- (void)setContentView:(UITableView *)contentView {
    [self setTableView:contentView];
}

- (void)viewModelWillChange:(nullable XZMocoaViewModel *)newValue {
    [super viewModelWillChange:newValue];
    
    XZMocoaTableViewModel * const _viewModel = self.viewModel;
    _viewModel.delegate = nil;
}

- (void)viewModelDidChange:(nullable XZMocoaViewModel *)oldValue {
    [super viewModelDidChange:oldValue];
    
    XZMocoaTableViewModel * const _viewModel = self.viewModel;
    [self registerModule:_viewModel.module];
    _viewModel.delegate = self;
    
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

@end

