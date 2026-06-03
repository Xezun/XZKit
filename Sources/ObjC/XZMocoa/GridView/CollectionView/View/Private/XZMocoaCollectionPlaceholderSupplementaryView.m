//
//  XZMocoaCollectionPlaceholderSupplementaryView.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaCollectionPlaceholderSupplementaryView.h"
#import "XZMocoaGridPlaceholderView.h"
#import "XZMocoaCollectionSectionViewModel.h"

#if DEBUG
@implementation XZMocoaCollectionPlaceholderSupplementaryView {
    XZMocoaGridPlaceholderView *_view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _view = [[XZMocoaGridPlaceholderView alloc] initWithFrame:self.bounds];
        _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_view];
    }
    return self;
}

- (void)prepareForViewModel {
    [super prepareForViewModel];
    
    _view.viewModel = [[XZMocoaGridPlaceholderViewModel alloc] initWithModel:self.viewModel];;
}

@end
#endif
