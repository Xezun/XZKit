//
//  XZMocoaTableViewHeaderFooterView.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import "XZMocoaTableViewHeaderFooterView.h"
@import XZDefines;

@implementation UITableViewHeaderFooterView (XZMocoaTableViewHeaderFooterView)

@dynamic viewModel;

+ (void)load {
    if (self == [UITableViewHeaderFooterView class]) {
        const char *encoding = xz_objc_class_getMethodTypeEncoding(self, @selector(prepareForReuse));
        xz_objc_class_addMethodWithBlock(self, @selector(prepareForReuse), encoding, nil, nil, ^id _Nonnull(SEL  _Nonnull selector) {
            return ^(UITableViewHeaderFooterView *self) {
                ((void (*)(UITableViewHeaderFooterView *, SEL))objc_msgSend)(self, selector);
                self.viewModel = nil;
            };
        });
    }
}

@end
