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

- (void)viewModelWillChange:(nullable XZMocoaViewModel *)newValue {
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
