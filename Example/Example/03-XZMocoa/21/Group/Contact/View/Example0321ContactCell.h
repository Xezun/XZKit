//
//  Example0321ContactCell.h
//  Example
//
//  Created by Xezun on 2021/4/13.
//  Copyright © 2021 Xezun. All rights reserved.
//

@import XZMocoa;
#import "Example0321ContactCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Example0321ContactCell : UITableViewCell <XZMocoaTableViewCell>

@property (nonatomic, strong, nullable) Example0321ContactCellViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
