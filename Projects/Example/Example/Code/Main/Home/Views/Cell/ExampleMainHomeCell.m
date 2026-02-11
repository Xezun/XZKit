//
//  ExampleMainHomeCell.m
//  Example
//
//  Created by 徐臻 on 2026/2/2.
//

#import "ExampleMainHomeCell.h"
#import "ExampleMainHomeCellViewModel.h"
@import XZKit;

@implementation ExampleMainHomeCell

+ (void)load {
    XZMocoa(@"https://xzkit.xezun.com/examples").section.cell.viewReuseIdentifier = @"cell";
}

- (void)viewModelDidChange:(XZMocoaViewModel *)oldValue {
    [super viewModelDidChange:oldValue];
    
    ExampleMainHomeCellViewModel *viewModel = self.viewModel;
    self.textLabel.text = viewModel.title;
}

@end
