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

- (void)viewModelWillChange:(XZMocoaViewModel *)newValue {
    [super viewModelWillChange:newValue];
    
    [self.viewModel removeTarget:self.textLabel action:nil forKey:nil];
    [self.viewModel removeTarget:self.detailTextLabel action:nil forKey:nil];
}

- (void)viewModelDidChange:(nullable XZMocoaViewModel *)oldValue {
    [super viewModelDidChange:oldValue];
    
    [self.viewModel addTarget:self.textLabel action:@selector(setText:) forKey:@"name" value:nil];
    [self.viewModel addTarget:self.detailTextLabel action:@selector(setText:) forKey:@"phone" value:nil];
}

@end
