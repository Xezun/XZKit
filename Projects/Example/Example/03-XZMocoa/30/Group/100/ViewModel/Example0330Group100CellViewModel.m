//
//  Example0330Group100CellViewModel.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0330Group100CellViewModel.h"
#import "Example0330Group100CellModel.h"

@implementation Example0330Group100CellViewModel

- (void)prepare {
    [super prepare];
    self.height = 80.0;
    
    Example0330Group100CellModel *model = self.model;
    self.text = model.text;
}

@end
