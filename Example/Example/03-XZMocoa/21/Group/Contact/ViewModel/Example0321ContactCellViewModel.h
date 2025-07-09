//
//  Example0321ContactCellViewModel.h
//  Example
//
//  Created by Xezun on 2021/4/13.
//  Copyright © 2021 Xezun. All rights reserved.
//

@import XZMocoa;

NS_ASSUME_NONNULL_BEGIN

@interface Example0321ContactCellViewModel : XZMocoaTableViewCellViewModel

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *phone;

@end

NS_ASSUME_NONNULL_END
