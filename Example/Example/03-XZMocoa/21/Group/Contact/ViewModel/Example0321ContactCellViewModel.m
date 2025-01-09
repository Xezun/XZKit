//
//  Example0321ContactCellViewModel.m
//  Example
//
//  Created by Xezun on 2021/4/13.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "Example0321ContactCellViewModel.h"
#import "Example0321Contact.h"

@implementation Example0321ContactCellViewModel

@dynamic model;
@synthesize name = _name;
@synthesize phone = _phone;

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/21/").section.cell.viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    
    [self loadData];
    self.height = 44.0;
}

- (void)loadData {
    Example0321Contact *model = self.model;
    _name  = [NSString stringWithFormat:@"%@ %@", model.firstName, model.lastName];
    _phone = model.phone;
}

- (NSString *)name {
    Example0321Contact *model = self.model;
    return [NSString stringWithFormat:@"%@ %@", model.firstName, model.lastName];
}

- (NSString *)phone {
    Example0321Contact *model = self.model;
    return model.phone;
}

- (void)didReceiveUpdate:(XZMocoaUpdate *)emition {
    // 收到 editor 的 emit 事件。作为唯一下级，这里省略了对 subViewModel 的身份判定。
    // 由于与 target-action 使用了一样的名称，因此这里用了 emit.name 直接发送 target-action 事件。
    [self sendActionsForKey:emition.name];
}

- (void)tableView:(XZMocoaTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *moduleURL = [NSURL URLWithString:@"https://mocoa.xezun.com/examples/21/editor"];
    UIViewController<XZMocoaView> *nextVC = [tableView.navigationController presentMocoaURL:moduleURL options:@{
        @"model": self.model
    } animated:YES];
    [self addSubViewModel:nextVC.viewModel]; // 添加为子模块，使用 emit 机制监听 name/phone 的变化
}

@end
