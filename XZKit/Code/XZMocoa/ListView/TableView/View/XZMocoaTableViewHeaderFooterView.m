//
//  XZMocoaTableViewHeaderFooterView.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import "XZMocoaTableViewHeaderFooterView.h"

@implementation XZMocoaTableViewHeaderFooterView
@synthesize viewModel = _viewModel;
- (void)setViewModel:(__kindof XZMocoaTableViewHeaderFooterViewModel *)viewModel {
    [self viewModelWillChange];
    _viewModel = viewModel;
    [self viewModelDidChange];
}
@end
