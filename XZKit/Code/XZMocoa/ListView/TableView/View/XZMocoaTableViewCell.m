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

@implementation XZMocoaTableViewCell
@dynamic viewModel;
@end


#import <objc/runtime.h>

static void xz_mocoa_copyMethod(Class const cls, SEL const target, SEL const source) {
    if (xz_objc_class_copyMethod(cls, source, nil, target)) return;
    XZLog(@"为协议 XZMocoaTableCell 的方法 %@ 提供默认实现失败", NSStringFromSelector(target));
}

@interface UITableViewCell (XZMocoaTableCell) <XZMocoaTableViewCell>
@end

@implementation UITableViewCell (XZMocoaTableCell)

@dynamic viewModel;

+ (void)load {
    Class const aClass = UITableViewCell.class;
    if (self == aClass) {
        xz_mocoa_copyMethod(aClass, @selector(tableView:didSelectRowAtIndexPath:), @selector(xz_mocoa_tableView:didSelectRowAtIndexPath:));
        xz_mocoa_copyMethod(aClass, @selector(tableView:willDisplayRowAtIndexPath:), @selector(xz_mocoa_tableView:willDisplayRowAtIndexPath:));
        xz_mocoa_copyMethod(aClass, @selector(tableView:didEndDisplayingRowAtIndexPath:), @selector(xz_mocoa_tableView:didEndDisplayingRowAtIndexPath:));
    }
}

- (void)xz_mocoa_tableView:(XZMocoaTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)xz_mocoa_tableView:(XZMocoaTableView *)tableView willDisplayRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel tableView:tableView willDisplayRowAtIndexPath:indexPath];
}

- (void)xz_mocoa_tableView:(XZMocoaTableView *)tableView didEndDisplayingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel tableView:tableView didEndDisplayingRowAtIndexPath:indexPath];
}

@end


