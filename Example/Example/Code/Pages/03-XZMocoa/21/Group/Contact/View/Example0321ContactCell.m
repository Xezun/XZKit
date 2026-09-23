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
    XZMocoa(@"https://mocoa.xezun.com/examples/03/21/table").cell.viewNibClass = self;
}

- (void)prepareForViewModel:(__kindof XZMocoaViewModel *)viewModel {
    [super prepareForViewModel:viewModel];
    
    [self.viewModel bindTarget:self.textLabel action:@selector(setText:) forKey:@"name"];
    [self.viewModel bindTarget:self.detailTextLabel action:@selector(setText:) forKey:@"phone"];
}

@end
