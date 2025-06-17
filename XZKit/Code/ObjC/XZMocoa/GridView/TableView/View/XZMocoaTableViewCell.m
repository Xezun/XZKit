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

+ (void)load {
    if (self == [UITableViewCell class]) {
        const char *encoding = xz_objc_class_getMethodTypeEncoding(self, @selector(prepareForReuse));
        xz_objc_class_addMethodWithBlock(self, @selector(prepareForReuse), encoding, nil, nil, ^id _Nonnull(SEL  _Nonnull selector) {
            return ^(UITableViewCell *self) {
                ((void (*)(UITableViewCell *, SEL))objc_msgSend)(self, selector);
                self.viewModel = nil;
            };
        });
    }
}

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

- (void)mocoa_exchange_prepareForReuse {
    
}

@end


