//
//  Example0330Group102CellViewModel.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0330Group102CellViewModel.h"
#import "Example0330Group102CellModel.h"

@implementation Example0330Group102CellViewModel

- (void)prepare {
    [super prepare];
    self.height = 80.0;
    
    Example0330Group102CellModel *model = self.model;
    self.text = model.text;
}

@end
