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

@implementation UITableViewCell (XZMocoaTableCell)

@dynamic viewModel;

- (UITableView *)xz_tableView {
    UITableView *tableView = (id)self.nextResponder;
    while (tableView != nil) {
        if ([tableView isKindOfClass:UITableView.class]) {
            break;
        }
        tableView = tableView.nextResponder;
    }
    return tableView;
}

- (void)tableView:(id<XZMocoaTableView>)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel tableViewCell:self wasSelectedAtIndexPath:indexPath];
}

- (void)tableView:(id<XZMocoaTableView>)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel tableViewCell:self wasDeselectedAtIndexPath:indexPath];
}

- (void)tableView:(id<XZMocoaTableView>)tableView willDisplayRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel tableViewCell:self willBeDisplayedAtIndexPath:indexPath];
}

- (void)tableView:(id<XZMocoaTableView>)tableView didEndDisplayingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel tableViewCell:self wasEndedDisplayingAtIndexPath:indexPath];
}

- (void)tableView:(id<XZMocoaTableView>)tableView didEditRowAtIndexPath:(NSIndexPath *)indexPath withEventsName:(XZMocoaEventsName)name completion:(void (^ _Nullable)(BOOL))completion {
    [self.viewModel tableViewCell:self wasEndedEditingAtIndexPath:indexPath withEventsName:name completion:completion];
}

@end


