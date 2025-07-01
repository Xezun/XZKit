//
//  XZMocoaTableViewPlaceholderCell.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaTableViewPlaceholderCell.h"
#import "XZMocoaTableView.h"
#import "XZMocoaGridViewPlaceholderView.h"
#import "XZMocoaTableViewPlaceholderCellViewModel.h"

#if DEBUG
@implementation XZMocoaTableViewPlaceholderCell {
    XZMocoaGridViewPlaceholderView *_view;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _view = [[XZMocoaGridViewPlaceholderView alloc] initWithFrame:self.bounds];
        _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_view];
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
