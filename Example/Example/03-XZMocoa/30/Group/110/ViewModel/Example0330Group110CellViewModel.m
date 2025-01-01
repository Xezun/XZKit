//
//  Example0330Group110CellViewModel.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0330Group110CellViewModel.h"
#import "Example0330Group110CellModel.h"

@implementation Example0330Group110CellViewModel

+ (void)load {
    XZModule(@"https://mocoa.xezun.com/examples/30/table/110/:/").viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    self.height = 80.0;
    
    Example0330Group110CellModel *model = self.model;
    self.text = model.text;
}

@end
