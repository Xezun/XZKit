//
//  ExampleMainHomeHeaderViewModel.m
//  Example
//
//  Created by 徐臻 on 2026/2/2.
//

#import "ExampleMainHomeHeaderViewModel.h"

@implementation ExampleMainHomeHeaderViewModel

+ (void)load {
    XZMocoa(@"https://xzkit.xezun.com/examples").section.header.viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    self.height = 40;
}

@end
