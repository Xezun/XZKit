//
//  XZMocoaCollectionPlaceholderCell.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaCollectionPlaceholderCell.h"
#import "XZMocoaGroupPlaceholderView.h"
#import "XZMocoaCollectionSectionViewModel.h"
#import "XZMocoaCollectionView.h"

#if DEBUG
@implementation XZMocoaCollectionPlaceholderCell {
    XZMocoaGroupPlaceholderView *_view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _view = [[XZMocoaGroupPlaceholderView alloc] initWithFrame:self.bounds];
        _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_view];
    }
    return self;
}

- (void)prepareForViewModel {
    [super prepareForViewModel];
    
    _view.viewModel = [[XZMocoaGroupPlaceholderViewModel alloc] initWithModel:self.viewModel];;
}

@end
#endif
