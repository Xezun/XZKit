//
//  XZMocoaCollectionViewPlaceholderSupplementaryView.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaCollectionViewPlaceholderSupplementaryView.h"
#import "XZMocoaGridViewPlaceholderView.h"
#import "XZMocoaCollectionViewSectionViewModel.h"

#if DEBUG
@implementation XZMocoaCollectionViewPlaceholderSupplementaryView {
    XZMocoaGridViewPlaceholderView *_view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _view = [[XZMocoaGridViewPlaceholderView alloc] initWithFrame:self.bounds];
        _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_view];
    }
    return self;
}

- (void)viewModelDidChange:(nullable XZMocoaViewModel *)oldValue {
    [super viewModelDidChange:oldValue];
    
    XZMocoaGridViewPlaceholderViewModel *viewModel = [[XZMocoaGridViewPlaceholderViewModel alloc] initWithModel:self.viewModel];
    [viewModel ready];
    _view.viewModel = viewModel;
}

@end
#endif
