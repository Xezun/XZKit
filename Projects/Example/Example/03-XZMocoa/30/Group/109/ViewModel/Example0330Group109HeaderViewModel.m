//
//  Example0330Group109HeaderViewModel.m
//  Example
//
//  Created by Xezun on 2023/8/21.
//

#import "Example0330Group109HeaderViewModel.h"

@implementation Example0330Group109HeaderViewModel

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/30/table/109/header:/").viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    
    self.height = 80.0;
}

@end
