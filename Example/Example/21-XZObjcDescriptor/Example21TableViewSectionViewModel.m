//
//  Example21TableViewSectionViewModel.m
//  Example
//
//  Created by 徐臻 on 2025/1/31.
//

#import "Example21TableViewSectionViewModel.h"

@implementation Example21TableViewSectionViewModel

+ (void)load {
    XZMocoa(@"https://xzkit.xezun.com/examples/21").section.viewModelClass = self;
}

@end
