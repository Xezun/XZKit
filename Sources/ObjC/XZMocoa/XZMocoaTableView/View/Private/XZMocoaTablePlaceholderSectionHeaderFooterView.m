//
//  XZMocoaTablePlaceholderSectionHeaderFooterView.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaTablePlaceholderSectionHeaderFooterView.h"
#import "XZMocoaTableSectionViewModel.h"
#import "XZMocoaGroupPlaceholderView.h"

#if DEBUG
@implementation XZMocoaTablePlaceholderSectionHeaderFooterView {
    XZMocoaGroupPlaceholderView *_view;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        _view = [[XZMocoaGroupPlaceholderView alloc] initWithFrame:self.bounds];
        _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_view];
    }
    return self;
}

- (void)prepareForViewModel {
    [super prepareForViewModel];
    
    _view.viewModel = [[XZMocoaGroupPlaceholderViewModel alloc] initWithModel:self.viewModel];
}

@end
#endif
