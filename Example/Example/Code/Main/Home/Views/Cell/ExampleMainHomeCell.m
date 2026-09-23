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
    XZMocoa(@"https://xzkit.xezun.com/examples/table").cell.viewReuseIdentifier = @"cell";
}

- (void)prepareForViewModel:(ExampleMainHomeCellViewModel *)viewModel {
    [super prepareForViewModel:viewModel];
    
    self.textLabel.text = viewModel.title;
}

@end
