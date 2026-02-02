//
//  Example0312CellModel.m
//  Example
//
//  Created by Xezun on 2023/8/21.
//

#import "Example0312CellModel.h"

@implementation Example0312CellModel

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/12/table/").section.cell.modelClass = self;
}

@end
