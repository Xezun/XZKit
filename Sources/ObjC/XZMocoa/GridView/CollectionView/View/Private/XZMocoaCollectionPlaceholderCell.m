//
//  XZMocoaCollectionPlaceholderCell.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaCollectionPlaceholderCell.h"
#import "XZMocoaGridPlaceholderView.h"
#import "XZMocoaCollectionSectionViewModel.h"
#import "XZMocoaCollectionView.h"

#if DEBUG
@implementation XZMocoaCollectionPlaceholderCell {
    XZMocoaGridPlaceholderView *_view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _view = [[XZMocoaGridPlaceholderView alloc] initWithFrame:self.bounds];
        _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_view];
    }
    return self;
}

- (void)prepareForViewModel {
    [super prepareForViewModel];
    
    _view.viewModel = [[XZMocoaGridPlaceholderViewModel alloc] initWithModel:self.viewModel];;
}

@end
#endif
