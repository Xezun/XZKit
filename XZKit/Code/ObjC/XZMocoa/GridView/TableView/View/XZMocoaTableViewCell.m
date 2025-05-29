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

- (void)tableView:(id<XZMocoaTableView>)tableView didUpdateForKey:(XZMocoaUpdatesKey)key atIndexPath:(NSIndexPath *)indexPath {
    if ([self conformsToProtocol:@protocol(XZMocoaTableViewCell) ]) {
        [((id<XZMocoaTableViewCell>)self).viewModel cell:(id)self didUpdateForKey:key atIndexPath:indexPath];
    }
}

@end


