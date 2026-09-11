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
    XZMocoa(@"https://mocoa.xezun.com/examples/21/").cell.viewNibClass = self;
}

- (void)prepareForViewModel {
    [super prepareForViewModel];
    
    [self.viewModel addTarget:self.textLabel action:@selector(setText:) forKey:@"name" value:nil];
    [self.viewModel addTarget:self.detailTextLabel action:@selector(setText:) forKey:@"phone" value:nil];
}

@end
