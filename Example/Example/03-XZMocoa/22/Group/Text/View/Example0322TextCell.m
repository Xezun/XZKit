//
//  Example0322TextCell.m
//  Example
//
//  Created by Xezun on 2023/8/9.
//

#import "Example0322TextCell.h"

@implementation Example0322TextCell
@dynamic viewModel;

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/22/").section.cell.viewNibClass = self;
}

- (void)viewModelWillChange {
    [self.viewModel removeTarget:self action:nil forKey:nil];
}

- (void)viewModelDidChange {
    [self.viewModel addTarget:self action:@selector(nameDidChange:) forKey:@"name"];
    [self.viewModel addTarget:self action:@selector(phoneDidChange:) forKey:@"phone"];
}

- (void)nameDidChange:(Example0322TextViewModel *)viewModel {
    XZLog(@"old: %@, new: %@", self.textLabel.text, viewModel.name);
    self.textLabel.text = viewModel.name;
}

- (void)phoneDidChange:(Example0322TextViewModel *)viewModel {
    XZLog(@"old: %@, new: %@", self.detailTextLabel.text, viewModel.phone);
    self.detailTextLabel.text = viewModel.phone;
}

@end
