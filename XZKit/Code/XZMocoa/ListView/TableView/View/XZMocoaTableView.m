//
//  XZMocoaTableView.m
//  XZMocoa
//
//  Created by Xezun on 2021/3/24.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaTableView.h"
#import "XZMocoaDefines.h"
#import "XZMocoaTableViewCell.h"
#import "XZMocoaTableViewHeaderFooterView.h"
#import "XZMocoaTableViewProxy.h"

@interface XZMocoaTableView ()
@end

@implementation XZMocoaTableView

+ (void)initialize {
    if (self == [XZMocoaTableView class]) {
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

@dynamic viewModel, contentView;

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    return [self initWithFrame:UIScreen.mainScreen.bounds style:style];
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [self initWithTableViewClass:UITableView.class style:style];
    if (self) {
        self.frame = frame;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithTableViewClass:UITableView.class style:(UITableViewStylePlain)];
}

- (instancetype)initWithTableViewClass:(Class)tableViewClass style:(UITableViewStyle)style {
    self = [super initWithFrame:UIScreen.mainScreen.bounds];
    if (self) {
        UITableView *contentView = [[tableViewClass alloc] initWithFrame:self.bounds style:style];
        [super setContentView:contentView];
    }
    return self;
}

@end


