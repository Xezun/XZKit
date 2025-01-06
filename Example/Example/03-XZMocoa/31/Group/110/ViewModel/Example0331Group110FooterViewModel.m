//
//  Example0331Group110FooterViewModel.m
//  Example
//
//  Created by Xezun on 2023/8/21.
//

#import "Example0331Group110FooterViewModel.h"

@implementation Example0331Group110FooterViewModel

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/31/collection/110/footer:/").viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    self.size = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 80.0);
}

@end
