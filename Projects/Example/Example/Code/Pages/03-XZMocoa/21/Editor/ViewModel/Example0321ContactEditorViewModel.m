//
//  Example0321ContactEditorViewModel.m
//  Example
//
//  Created by Xezun on 2021/7/12.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "Example0321ContactEditorViewModel.h"
#import "Example0321Contact.h"
@import XZKit;

@implementation Example0321ContactEditorViewModel

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/03/21/editor").viewModelClass = self;
}

- (void)dealloc {
    XZLog(@"EditorViewModel: %@", self);
}

- (NSString *)firstName {
    Example0321Contact *model = self.model;
    return model.firstName;
}

- (NSString *)lastName {
    Example0321Contact *model = self.model;
    return model.lastName;
}

- (NSString *)phone {
    Example0321Contact *model = self.model;
    return model.phone;
}

- (void)submitWithFirstName:(NSString *)firstName lastName:(NSString *)lastName phone:(NSString *)phone {
    if (firstName.length == 0) {
        [self.viewController xz_showToast:[XZToast messageToast:@"请输入用户名"]];
        return;
    }
    if (lastName.length == 0) {
        [self.viewController xz_showToast:[XZToast messageToast:@"请输入用户名"]];
        return;
    }
    if (phone.length == 0) {
        [self.viewController xz_showToast:[XZToast messageToast:@"请输入手机号"]];
        return;
    }
    
    Example0321Contact *model = self.model;
    model.firstName = firstName;
    model.lastName  = lastName;
    model.phone = phone;
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
