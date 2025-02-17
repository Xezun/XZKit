//
//  XZMocoaTableViewPlaceholderCell.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaTableViewPlaceholderCell.h"
#import "XZMocoaTableView.h"
#import "XZMocoaListViewPlaceholderView.h"
#import "XZMocoaTableViewPlaceholderCellViewModel.h"

#if DEBUG
@implementation XZMocoaTableViewPlaceholderCell {
    XZMocoaListViewPlaceholderView *_view;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
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
