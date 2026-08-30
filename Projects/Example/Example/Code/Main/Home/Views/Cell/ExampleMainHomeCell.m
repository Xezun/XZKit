//
//  ExampleMainHomeCell.m
//  Example
//
//  Created by Xezun on 2026/2/2.
//

#import "ExampleMainHomeCell.h"
#import "ExampleMainHomeCellViewModel.h"
@import XZKit;

@implementation ExampleMainHomeCell

+ (void)load {
    XZMocoa(@"https://xzkit.xezun.com/examples").cell.viewReuseIdentifier = @"cell";
}

- (void)viewModelDidChange {
    [super viewModelDidChange];
    
    ExampleMainHomeCellViewModel *viewModel = self.viewModel;
    self.textLabel.text = viewModel.title;
}

@end
