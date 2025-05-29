//
//  XZMocoaTableViewCell.m
//  XZMocoa
//
//  Created by Xezun on 2021/1/13.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaTableViewCell.h"
#import "XZMocoaModule.h"
#import "XZMocoaDefines.h"
#import <objc/runtime.h>
#if __has_include(<XZDefines/XZRuntime.h>)
#import <XZDefines/XZRuntime.h>
#else
#import "XZRuntime.h"
#endif

@implementation UITableViewCell (XZMocoaTableViewCell)

@dynamic viewModel;

- (void)tableView:(id<XZMocoaTableView>)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel tableView:tableView didSelectCell:self atIndexPath:indexPath];
}

- (void)tableView:(id<XZMocoaTableView>)tableView willDisplayRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel tableView:tableView willDisplayCell:self atIndexPath:indexPath];
}

- (void)tableView:(id<XZMocoaTableView>)tableView didEndDisplayingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel tableView:tableView didEndDisplayingCell:self atIndexPath:indexPath];
}

- (void)tableView:(id<XZMocoaTableView>)tableView didUpdateRowAtIndexPath:(NSIndexPath *)indexPath forKey:(XZMocoaUpdatesKey)key {
    [self.viewModel tableView:tableView didUpdateCell:self atIndexPath:indexPath forKey:key];
}

@end


