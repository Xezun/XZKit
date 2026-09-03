//
//  XZMocoaCollectionPlaceholderSupplementView.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaCollectionPlaceholderSupplementView.h"
#import "XZMocoaGroupPlaceholderView.h"

#if DEBUG
@implementation XZMocoaCollectionPlaceholderSupplementView {
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
