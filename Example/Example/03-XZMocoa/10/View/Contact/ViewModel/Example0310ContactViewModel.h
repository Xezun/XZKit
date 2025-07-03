//
//  Example0310ContactViewModel.h
//  Example
//
//  Created by Xezun on 2023/7/23.
//

@import XZMocoaCore;

NS_ASSUME_NONNULL_BEGIN

@interface Example0310ContactViewModel : XZMocoaViewModel
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSURL    *photo;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *address;
@end

NS_ASSUME_NONNULL_END
