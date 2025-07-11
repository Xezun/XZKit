//
//  Example0330Group109FooterViewModel.m
//  Example
//
//  Created by Xezun on 2023/8/21.
//

#import "Example0330Group109FooterViewModel.h"

@implementation Example0330Group109FooterViewModel

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/30/table/109/footer:/").viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    self.height = 80.0;
}

@end
