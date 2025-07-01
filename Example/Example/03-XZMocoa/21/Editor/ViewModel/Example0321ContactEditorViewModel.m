//
//  Example0321ContactEditorViewModel.m
//  Example
//
//  Created by Xezun on 2021/7/12.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "Example0321ContactEditorViewModel.h"
#import "Example0321Contact.h"

@implementation Example0321ContactEditorViewModel

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/21/editor").viewModelClass = self;
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

- (void)setFirstName:(NSString *)firstName lastName:(NSString *)lastName phone:(NSString *)phone {
    if (firstName.length == 0 || lastName.length == 0 || phone.length == 0) {
        return;
    }
    
    Example0321Contact *model = self.model;
    
    if (![firstName isEqualToString:model.firstName] || ![lastName isEqualToString:model.lastName]) {
        model.firstName = firstName;
        model.lastName  = lastName;
        [self emitUpdatesForKey:@"name" value:nil];
    }

    if (![phone isEqualToString:model.phone]) {
        model.phone = phone;
        [self emitUpdatesForKey:@"phone" value:nil];
    }
}

@end
