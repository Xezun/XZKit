//
//  Example0310ContactViewModel.m
//  Example
//
//  Created by Xezun on 2023/7/23.
//

#import "Example0310ContactViewModel.h"
#import "Example0310Contact.h"

@implementation Example0310ContactViewModel

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/03/10/contactView").viewModelClass = self;
}

+ (NSDictionary<NSString *,id> *)mappingMethodsForObservingModelKeys {
    return @{
        NSStringFromSelector(@selector(setAddress:)): @"address",
        NSStringFromSelector(@selector(setNameWithFirstName:lastName:)): @[@"firstName", @"lastName"],
        NSStringFromSelector(@selector(setPhotoWithURLString:)): @"photo",
        NSStringFromSelector(@selector(setPhoneWithPhoneNumber:)): @"phone",
    };
}

- (void)setNameWithFirstName:(NSString *)firstName lastName:(NSString *)lastName {
    self.name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
}

- (void)setPhotoWithURLString:(NSString *)photo {
    self.photo = [NSURL URLWithString:photo];
}

- (void)setPhoneWithPhoneNumber:(NSString *)phone {
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
