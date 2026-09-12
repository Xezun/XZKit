//
//  Example0312CellModel.m
//  Example
//
//  Created by Xezun on 2023/8/21.
//

#import "Example0312CellModel.h"

@implementation Example0312CellModel

+ (void)load {
    XZMocoaModule *module = XZMocoa(@"https://mocoa.xezun.com/examples/03/12/table");
    module.cell.modelClass = self;
}

@end
