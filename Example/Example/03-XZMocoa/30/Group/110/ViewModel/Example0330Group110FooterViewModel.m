//
//  Example0330Group110FooterViewModel.m
//  Example
//
//  Created by Xezun on 2023/8/21.
//

#import "Example0330Group110FooterViewModel.h"

@implementation Example0330Group110FooterViewModel

+ (void)load {
    XZModule(@"https://mocoa.xezun.com/examples/30/table/110/footer:/").viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    
    self.height = 80.0;
}

@end
