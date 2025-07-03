//
//  Example0321Contact.h
//  Example
//
//  Created by Xezun on 2021/4/13.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import <Foundation/Foundation.h>
@import XZMocoaCore;

NS_ASSUME_NONNULL_BEGIN

@interface Example0321Contact : NSObject

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;

@property (nonatomic, copy) NSString *phone;

+ (Example0321Contact *)contactWithFirstName:(NSString *)firstName lastName:(NSString *)lastName phone:(NSString *)phone;
+ (Example0321Contact *)contactForIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
