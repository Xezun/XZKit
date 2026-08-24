//
//  XZMocoaCollectionPlaceholderSectionSupplementaryView.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaCollectionPlaceholderSectionSupplementaryView.h"
#import "XZMocoaGroupPlaceholderView.h"
#import "XZMocoaCollectionSectionViewModel.h"

#if DEBUG
@implementation XZMocoaCollectionPlaceholderSectionSupplementaryView {
    XZMocoaGroupPlaceholderView *_view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _view = [[XZMocoaGroupPlaceholderView alloc] initWithFrame:self.bounds];
        _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_view];
    }
    return self;
}

- (void)viewModelDidChange {
    [super viewModelDidChange];
    
    _view.viewModel = [[XZMocoaGroupPlaceholderViewModel alloc] initWithModel:self.viewModel];;
}

@end
#endif
