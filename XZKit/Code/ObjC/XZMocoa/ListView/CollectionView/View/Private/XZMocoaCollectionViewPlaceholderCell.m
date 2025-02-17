//
//  XZMocoaCollectionViewPlaceholderCell.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaCollectionViewPlaceholderCell.h"
#import "XZMocoaListViewPlaceholderView.h"
#import "XZMocoaCollectionViewSectionViewModel.h"
#import "XZMocoaCollectionView.h"

#if DEBUG
@implementation XZMocoaCollectionViewPlaceholderCell {
    XZMocoaListViewPlaceholderView *_view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _view = [[XZMocoaListViewPlaceholderView alloc] initWithFrame:self.bounds];
        _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_view];
    }
    return self;
}

- (void)viewModelDidChange {
    XZMocoaListViewPlaceholderViewModel *viewModel = [[XZMocoaListViewPlaceholderViewModel alloc] initWithModel:self.viewModel];
    [viewModel ready];
    _view.viewModel = viewModel;
}

@end
#endif
