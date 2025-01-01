//
//  Example0321ContactEditorViewModel.h
//  Example
//
//  Created by Xezun on 2021/7/12.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import <XZMocoa/XZMocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface Example0321ContactEditorViewModel : XZMocoaViewModel

@property (nonatomic, readonly) NSString *firstName;
@property (nonatomic, readonly) NSString *lastName;
@property (nonatomic, readonly) NSString *phone;
- (void)setFirstName:(NSString *)firstName lastName:(NSString *)lastName phone:(NSString *)phone;

@end

NS_ASSUME_NONNULL_END
