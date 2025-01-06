//
//  Example0330Group103CellViewModel.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0330Group103CellViewModel.h"
#import "Example0330Group103CellModel.h"

@implementation Example0330Group103CellViewModel

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/30/table/103/:/").viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    
    self.height = 80.0;
    
    Example0330Group103CellModel *model = self.model;
    self.text = model.text;
}

@end
