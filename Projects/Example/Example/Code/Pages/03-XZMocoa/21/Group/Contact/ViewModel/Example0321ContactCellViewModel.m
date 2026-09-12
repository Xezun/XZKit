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
    XZMocoa(@"https://mocoa.xezun.com/examples/03/21/table").cell.viewModelClass = self;
}

// 视图模型初始化
- (void)prepare {
    [super prepare];
    
    self.height = 44.0;
}

// 注册监听 model 属性的方法。
+ (NSDictionary<NSString *,id> *)mappingModelKeys {
    return @{
        NSStringFromSelector(@selector(nameDidChangeWithFirstName:lastName:)): @[@"firstName", @"lastName"],
        NSStringFromSelector(@selector(phoneDidChangeWithValue:)): @"phone"
    };
}

// 开启主动监听
- (BOOL)shouldObserveModelKeysActively {
    return YES;
}

// 监听 firstName lastName
- (void)nameDidChangeWithFirstName:(NSString *)firstName lastName:(NSString *)lastName {
    _name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    [self sendActionsForKey:XZMocoaKeyName value:_name];
}

// 监听 phone
- (void)phoneDidChangeWithValue:(NSString *)phone {
    _phone = phone.copy;
    [self sendActionsForKey:@"phone" value:_phone];
}

// 点击事件
- (void)tableViewCell:(UITableViewCell *)cell wasSelectedAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *moduleURL = [NSURL URLWithString:@"https://mocoa.xezun.com/examples/03/21/editor"];
    [self.navigationController presentMocoaURL:moduleURL options:@{
        XZMocoaKeyModel: self.model,
        XZMocoaKeyViewModel: self
    } animated:YES];
}

@end
