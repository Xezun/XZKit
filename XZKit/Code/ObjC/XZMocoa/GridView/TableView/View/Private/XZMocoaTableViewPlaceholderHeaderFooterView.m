//
//  XZMocoaTableViewPlaceholderHeaderFooterView.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaTableViewPlaceholderHeaderFooterView.h"
#import "XZMocoaTableViewSectionViewModel.h"
#import "XZMocoaGridViewPlaceholderView.h"

#if DEBUG
@implementation XZMocoaTableViewPlaceholderHeaderFooterView {
    XZMocoaGridViewPlaceholderView *_view;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        _view = [[XZMocoaGridViewPlaceholderView alloc] initWithFrame:self.bounds];
        _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_view];
    }
    return self;
}

- (void)viewModelDidChange {
    XZMocoaGridViewPlaceholderViewModel *viewModel = [[XZMocoaGridViewPlaceholderViewModel alloc] initWithModel:self.viewModel];
    [viewModel ready];
    _view.viewModel = viewModel;
}

@end
#endif
