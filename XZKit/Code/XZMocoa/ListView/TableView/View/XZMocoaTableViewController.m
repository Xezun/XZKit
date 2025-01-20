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

@interface XZMocoaTableViewController ()
@end

@implementation XZMocoaTableViewController

+ (void)initialize {
    if (self == [XZMocoaTableViewController class]) {
        class_addProtocol(self, @protocol(UITableViewDelegate));
        class_addProtocol(self, @protocol(UITableViewDataSource));
        class_addProtocol(self, @protocol(XZMocoaTableViewModelDelegate));
        
        unsigned int count = 0;
        Method *list = class_copyMethodList([XZMocoaTableViewProxy class], &count);
        for (unsigned int i = 0; i < count; i++) {
            Method const method = list[i];
            SEL const selector = method_getName(method);
            IMP const implemnt = method_getImplementation(method);
            const char * const types = method_getTypeEncoding(method);
            if (!class_addMethod(self, selector, implemnt, types)) {
                NSLog(@"为 %@ 添加方法 %@ 失败", self, NSStringFromSelector(selector));
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

- (void)viewModelDidChange {
    XZMocoaTableViewModel * const _viewModel = self.viewModel;
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

