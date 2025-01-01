//
//  Example0330Group105CellViewModel.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0330Group105CellViewModel.h"
#import "Example0330Group105CellModel.h"

@implementation Example0330Group105CellViewModel
+ (void)load {
    XZModule(@"https://mocoa.xezun.com/examples/30/table/105/:/").viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    self.height = 80.0;
    
    Example0330Group105CellModel *model = self.model;
    self.text = model.text;
}

@end
