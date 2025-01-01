//
//  XZMocoaTableViewPlaceholderCell.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaTableViewPlaceholderCell.h"
#import "XZMocoaTableView.h"
#import "XZMocoaPlaceholderView.h"
#import "XZMocoaTableViewPlaceholderCellViewModel.h"

#if DEBUG
@implementation XZMocoaTableViewPlaceholderCell {
    XZMocoaPlaceholderView *_view;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _view = [[XZMocoaPlaceholderView alloc] initWithFrame:self.bounds];
        _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_view];
    }
    return self;
}

- (void)viewModelDidChange {
    XZMocoaPlaceholderViewModel *viewModel = [[XZMocoaPlaceholderViewModel alloc] initWithModel:self.viewModel];
    [viewModel ready];
    _view.viewModel = viewModel;
}

@end
#endif
