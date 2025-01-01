//
//  Example0331Group107CellViewModel.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0331Group107CellViewModel.h"
#import "Example0331Group107CellModel.h"

@implementation Example0331Group107CellViewModel

+ (void)load {
    XZModule(@"https://mocoa.xezun.com/examples/31/collection/107/:/").viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    self.size = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 80.0);
    
    Example0331Group107CellModel *model = self.model;
    self.text = model.text;
}

@end
