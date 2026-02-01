//
//  Example0310ContactViewModel.m
//  Example
//
//  Created by Xezun on 2023/7/23.
//

#import "Example0310ContactViewModel.h"
#import "Example0310Contact.h"

@implementation Example0310ContactViewModel

- (void)prepare {
    [super prepare];
    
    Example0310Contact *data = self.model;
    
    self.name    = [NSString stringWithFormat:@"%@ %@", data.firstName, data.lastName];
    self.photo   = [NSURL URLWithString:data.photo];
    self.phone   = [self formatPhoneNumber:data.phone];
    self.address = data.address;
}


- (NSString *)formatPhoneNumber:(NSString *)phone {
    if (phone.length <= 3) {
        return phone;
    }
    NSString *part1 = [phone substringToIndex:3];
    if (phone.length <= 7) {
        NSString *part2 = [phone substringFromIndex:3];
        return [NSString stringWithFormat:@"%@-%@", part1, part2];
    }
    NSString *part2 = [phone substringWithRange:NSMakeRange(3, phone.length - 3 - 4)];
    NSString *part3 = [phone substringFromIndex:phone.length - 4];
    return [NSString stringWithFormat:@"%@-%@-%@", part1, part2, part3];
}

@end
