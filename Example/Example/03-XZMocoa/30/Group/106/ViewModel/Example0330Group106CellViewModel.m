//
//  Example0330Group106CellViewModel.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0330Group106CellViewModel.h"
#import "Example0330Group106CellModel.h"

@implementation Example0330Group106CellViewModel

- (void)prepare {
    [super prepare];
    self.height = 80.0;
    
    Example0330Group106CellModel *model = self.model;
    self.text = model.text;
}

@end
