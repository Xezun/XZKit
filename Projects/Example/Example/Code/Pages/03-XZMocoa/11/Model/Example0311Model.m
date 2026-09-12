//
//  Example0311Model.m
//  Example
//
//  Created by Xezun on 2023/7/23.
//

#import "Example0311Model.h"
@import XZKit;

@implementation Example0311Model

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/03/11").modelClass = self;
}

@end
