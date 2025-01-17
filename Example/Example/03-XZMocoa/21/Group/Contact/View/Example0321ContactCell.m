//
//  Example0321ContactCell.m
//  Example
//
//  Created by Xezun on 2021/4/13.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "Example0321ContactCell.h"

@implementation Example0321ContactCell

@dynamic viewModel;

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/21/").section.cell.viewNibClass = self;
}

- (void)viewModelWillChange {
    [self.viewModel removeTarget:self action:nil forKey:nil];
}

- (void)viewModelDidChange {
    [self.viewModel addTarget:self action:@selector(nameDidChange:) forKey:@"name"];
    [self.viewModel addTarget:self action:@selector(phoneDidChange:) forKey:@"phone"];
    [self nameDidChange:self.viewModel];
    [self phoneDidChange:self.viewModel];
}

- (void)nameDidChange:(Example0321ContactCellViewModel *)viewModel {
    XZLog(@"old: %@, new: %@", self.textLabel.text, viewModel.name);
    self.textLabel.text = viewModel.name;
}

- (void)phoneDidChange:(Example0321ContactCellViewModel *)viewModel {
    XZLog(@"old: %@, new: %@", self.detailTextLabel.text, viewModel.phone);
    self.detailTextLabel.text = viewModel.phone;
}

@end
