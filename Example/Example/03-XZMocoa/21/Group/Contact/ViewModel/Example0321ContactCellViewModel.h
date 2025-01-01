//
//  Example0321ContactCellViewModel.h
//  Example
//
//  Created by Xezun on 2021/4/13.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import <XZMocoa/XZMocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface Example0321ContactCellViewModel : XZMocoaTableViewCellViewModel

@property (nonatomic, copy, readonly) NSString *name  XZ_MOCOA_KEY(name);
@property (nonatomic, copy, readonly) NSString *phone XZ_MOCOA_KEY(phone);

@end

NS_ASSUME_NONNULL_END
