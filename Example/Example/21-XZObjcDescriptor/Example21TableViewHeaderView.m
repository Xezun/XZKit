//
//  Example21TableViewHeaderView.m
//  Example
//
//  Created by 徐臻 on 2025/1/31.
//

#import "Example21TableViewHeaderView.h"

@implementation Example21TableViewHeaderView {
    UILabel *_textLabel;
}

+ (void)load {
    XZMocoa(@"https://xzkit.xezun.com/examples/21").section.header.viewClass = self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    // 原生内置的 textLabel.text 会在进入重用池时清除
    self.viewModel = nil;
}

- (void)viewModelDidChange:(nullable XZMocoaViewModel *)newValue {
    [super viewModelDidChange:newValue];
    
    self.textLabel.text = self.viewModel.model;
}

@end
