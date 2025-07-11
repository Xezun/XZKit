//
//  Example21TableViewCellViewModel.m
//  Example
//
//  Created by 徐臻 on 2025/1/30.
//

#import "Example21TableViewCellViewModel.h"

@implementation Example21TableViewCellViewModel

+ (void)load {
    XZMocoa(@"https://xzkit.xezun.com/examples/21").section.cell.viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    
    self.height = 50;
}

@end
