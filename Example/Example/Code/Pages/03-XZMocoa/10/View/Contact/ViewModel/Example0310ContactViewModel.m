//
//  Example0310ContactViewModel.m
//  Example
//
//  Created by Xezun on 2023/7/23.
//

// 使用绑定机制，解藕 M-V-VM 之间的接口依赖。
#define UsesMocoaBind YES

#import "Example0310ContactViewModel.h"
#ifndef UsesMocoaBind
#import "Example0310Contact.h"
#endif

@implementation Example0310ContactViewModel

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/03/10/contactView").viewModelClass = self;
}

#ifdef UsesMocoaBind
+ (NSDictionary<NSString *,id> *)mappingObserverMethodsForModelKeys {
    return @{
        NSStringFromSelector(@selector(setAddress:)): @"address",
        NSStringFromSelector(@selector(setupNameWithFirstName:lastName:)): @[@"firstName", @"lastName"],
        NSStringFromSelector(@selector(setupPhotoWithURLString:)): @"photo",
        NSStringFromSelector(@selector(setupPhoneWithPhoneNumber:)): @"phone",
    };
}
- (void)prepare {
    [super prepare];
}
#else
- (void)prepare {
    [super prepare];
    
    Example0310Contact *model = self.model;
    [self setAddress:model.address];
    [self setupNameWithFirstName:model.firstName lastName:model.lastName];
    [self setupPhotoWithURLString:model.photo];
    [self setupPhoneWithPhoneNumber:model.phone];
}
#endif

- (void)setupNameWithFirstName:(NSString *)firstName lastName:(NSString *)lastName {
    self.name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
}

- (void)setupPhotoWithURLString:(NSString *)photo {
    self.photo = [NSURL URLWithString:photo];
}

- (void)setupPhoneWithPhoneNumber:(NSString *)phone {
    if (phone.length <= 3) {
        self.phone = phone;
        return;
    }
    NSString *part1 = [phone substringToIndex:3];
    if (phone.length <= 7) {
        NSString *part2 = [phone substringFromIndex:3];
        self.phone = [NSString stringWithFormat:@"%@-%@", part1, part2];
        return;
    }
    NSString *part2 = [phone substringWithRange:NSMakeRange(3, phone.length - 3 - 4)];
    NSString *part3 = [phone substringFromIndex:phone.length - 4];
    self.phone = [NSString stringWithFormat:@"%@-%@-%@", part1, part2, part3];
}

@end
