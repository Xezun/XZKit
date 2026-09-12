//
//  Example0331Group109FooterViewModel.m
//  Example
//
//  Created by Xezun on 2023/8/21.
//

#import "Example0331Group109FooterViewModel.h"

@implementation Example0331Group109FooterViewModel

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/03/31/collection/footer:109").viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    self.size = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 80.0);
}

@end
