//
//  XZMocoaTableCell.m
//  XZMocoa
//
//  Created by Xezun on 2021/1/13.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import <objc/runtime.h>
#import "XZMocoaTableCell.h"
#import "XZMocoaModule.h"
#import "XZMocoaDefines.h"

@protocol UITableViewDelegate;

@implementation UITableViewCell (XZMocoaTableCell)

@dynamic viewModel;

- (UITableView *)xz_tableView {
    UITableView *tableView = (id)self.nextResponder;
    while (tableView != nil) {
        if ([tableView isKindOfClass:UITableView.class]) {
            break;
        }
        tableView = (id)tableView.nextResponder;
    }
    return tableView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel tableViewCell:self wasSelectedAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel tableViewCell:self wasDeselectedAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel tableViewCell:self willBeDisplayedAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel tableViewCell:self wasEndedDisplayingAtIndexPath:indexPath];
}

@end


