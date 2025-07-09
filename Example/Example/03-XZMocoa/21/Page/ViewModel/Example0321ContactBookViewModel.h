//
//  Example0321ContactBookViewModel.h
//  Example
//
//  Created by Xezun on 2021/4/12.
//  Copyright © 2021 Xezun. All rights reserved.
//

@import XZKit;
#import "Example0321ContactBook.h"

NS_ASSUME_NONNULL_BEGIN

@interface Example0321ContactBookViewModel : XZMocoaViewModel

@property (nonatomic, strong, readonly) XZMocoaTableViewModel *tableViewModel;
@property (nonatomic, copy, readonly) NSArray<NSString *> *testActions;
- (void)performTestActionAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
