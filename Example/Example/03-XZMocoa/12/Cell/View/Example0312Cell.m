//
//  Example0312Cell.m
//  Example
//
//  Created by Xezun on 2023/8/21.
//

#import "Example0312Cell.h"
#import "Example0312CellViewModel.h"

@implementation Example0312Cell

+ (void)load {
    XZModule(@"https://mocoa.xezun.com/examples/12/table/").section.cell.viewNibClass = self;
}

- (void)viewModelDidChange {
    Example0312CellViewModel *viewModel = self.viewModel;
    
    self.nameLabel.text = viewModel.name;
}

@end
