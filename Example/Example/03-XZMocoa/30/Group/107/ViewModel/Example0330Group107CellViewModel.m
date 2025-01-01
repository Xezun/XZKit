//
//  Example0330Group107CellViewModel.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0330Group107CellViewModel.h"
#import "Example0330Group107CellModel.h"

@implementation Example0330Group107CellViewModel

+ (void)load {
    XZModule(@"https://mocoa.xezun.com/examples/30/table/107/:/").viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    self.height = 80.0;
    
    Example0330Group107CellModel *model = self.model;
    self.text = model.text;
}

@end
