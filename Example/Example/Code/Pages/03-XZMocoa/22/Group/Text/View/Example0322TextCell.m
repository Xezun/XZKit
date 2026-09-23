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
    XZMocoa(@"https://mocoa.xezun.com/examples/03/22/collection").cell.viewNibClass = self;
}

- (void)prepareForViewModel:(__kindof XZMocoaViewModel *)viewModel {
    [super prepareForViewModel:viewModel];
    
    [self.viewModel bindTarget:self.textLabel action:@selector(setText:) forKey:@"name"];
    [self.viewModel bindTarget:self.detailTextLabel action:@selector(setText:) forKey:@"phone"];
}

@end
