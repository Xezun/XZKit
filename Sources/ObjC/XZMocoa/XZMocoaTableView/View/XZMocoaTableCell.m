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

- (void)tableView:(id<XZMocoaTableView>)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel tableView:tableView didSelectCell:self atIndexPath:indexPath];
}

- (void)tableView:(id<XZMocoaTableView>)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel tableView:tableView didDeselectCell:self atIndexPath:indexPath];
}

- (void)tableView:(id<XZMocoaTableView>)tableView willDisplayRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel tableView:tableView willDisplayCell:self atIndexPath:indexPath];
}

- (void)tableView:(id<XZMocoaTableView>)tableView didEndDisplayingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel tableView:tableView didEndDisplayingCell:self atIndexPath:indexPath];
}

- (void)tableView:(id<XZMocoaTableView>)tableView didEditRowAtIndexPath:(NSIndexPath *)indexPath forUpdatesKey:(XZMocoaUpdatesKey)key completion:(void (^ _Nullable)(BOOL))completion {
    [self.viewModel tableView:tableView didEditCell:self atIndexPath:indexPath forUpdatesKey:key completion:completion];
}

@end


