//
//  Example0331Group104CellViewModel.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0331Group104CellViewModel.h"
#import "Example0331Group104CellModel.h"

@implementation Example0331Group104CellViewModel

+ (void)load {
    XZModule(@"https://mocoa.xezun.com/examples/31/collection/104/:/").viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    self.size = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 80.0);
    
    Example0331Group104CellModel *model = self.model;
    self.text = model.text;
}

@end