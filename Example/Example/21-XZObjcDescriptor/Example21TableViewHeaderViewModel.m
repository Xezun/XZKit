//
//  Example21TableViewHeaderViewModel.m
//  Example
//
//  Created by 徐臻 on 2025/1/31.
//

#import "Example21TableViewHeaderViewModel.h"

@implementation Example21TableViewHeaderViewModel

+ (void)load {
    XZMocoa(@"https://xzkit.xezun.com/examples/21").section.header.viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    
    self.height = 40.0;
}

@end
